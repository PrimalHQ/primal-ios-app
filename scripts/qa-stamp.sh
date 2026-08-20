#!/bin/bash
#
# qa-stamp.sh — bump the build number, record what was built, and push.
#
# Run this from the project root immediately before you Archive:
#
#     ./scripts/qa-stamp.sh
#
# It replaces the manual "bump CURRENT_PROJECT_VERSION" step. In one command it
# bumps all targets in lockstep, writes a small file recording which commit the
# build came from, commits both, tags the commit, pushes, and then verifies the
# tag actually arrived on GitHub before telling you it worked.
#
# WHY IT EXISTS
#
# We run an automated sanity check against each TestFlight build — it builds the
# app, launches it in a simulator and reports whether it survived. To report
# anything honest, it has to know WHICH COMMIT a given TestFlight build came
# from. Nothing in App Store Connect records that, and nothing in the repo
# records it either, so today there is no way to tie build 211 to a commit
# except by asking you.
#
# This script creates that link at the only moment it can be created correctly:
# the moment you bump the version, just before archiving. Anything reconstructed
# later describes the repo as it is then, not as it was when the binary was cut.
#
# WHAT IT WRITES
#
#   1. A git tag `qa-build/<build number>` on the bump commit. The tag name
#      carries the build number; its target is the commit.
#   2. A file `.qa-build-stamp.json` at the repo root, committed in the same
#      commit, carrying the version strings, whether the tree was clean, when it
#      was stamped, and this script's own checksum.
#
# Both are pushed. Nothing is read back from your machine, ever — the checker
# only reads this repo over the public API.
#
# WHAT IT DOES NOT DO
#
# It does not archive, upload, or touch App Store Connect. It holds no
# credentials. It makes exactly one commit, one tag and one push, and it refuses
# rather than guessing whenever the repo is not in a state it understands.
#
# IF IT REFUSES
#
# Ship anyway. This is a reporting tool, not a gate — nothing about your release
# depends on it. A build with no stamp simply gets reported as "not testable"
# on our side, and you will see it flagged rather than silently ignored.

set -u
set -o pipefail

readonly CANONICAL_REPO="PrimalHQ/primal-ios-app"
readonly STAMP_FILE=".qa-build-stamp.json"
readonly TAG_PREFIX="qa-build"
readonly SCHEMA=1

die() { printf '\n✗ %s\n\n' "$1" >&2; exit 1; }
say() { printf '  %s\n' "$1"; }

# ─────────────────────────────────────────────────────────────────────────────
# Preconditions. Every one of these is a refusal rather than a warning, because
# each describes a state where stamping would produce a link that is wrong —
# and a wrong link is worse than no link. It would make us report on a commit
# that is not the one you shipped.
# ─────────────────────────────────────────────────────────────────────────────

# 1. The right repository.
#    A stamp pushed to a fork or a second checkout is invisible to the checker,
#    and nothing would ever tell you: it would look exactly like never having
#    run the script.
git rev-parse --show-toplevel >/dev/null 2>&1 || die "not inside a git repository."
cd "$(git rev-parse --show-toplevel)" || die "could not cd to the repository root."

origin_url="$(git remote get-url origin 2>/dev/null || true)"
[ -n "$origin_url" ] || die "this repository has no 'origin' remote."
case "$origin_url" in
  *"$CANONICAL_REPO"*) : ;;
  *) die "origin is
      $origin_url
  but this script only stamps $CANONICAL_REPO. If you are in a fork or a second
  checkout, the stamp would be pushed somewhere nothing reads." ;;
esac

# 2. A clean tree.
#    The stamp records whether the build came from a clean checkout. If there
#    are uncommitted changes now, the binary you archive contains code that no
#    commit describes — so the link would name a commit that is not what you
#    shipped. Listing the files rather than just refusing, because "clean tree"
#    is usually one forgotten file and you should not have to go looking.
dirty="$(git status --porcelain --untracked-files=no)"
if [ -n "$dirty" ]; then
  printf '\n✗ the working tree has uncommitted changes:\n\n%s\n\n' "$dirty" >&2
  printf '  Commit or stash them first. The stamp records the commit the build\n' >&2
  printf '  came from, and uncommitted changes are in the binary but in no commit.\n\n' >&2
  exit 1
fi

# 3. On a branch, with somewhere to push.
#    The stamp is only useful once it is on GitHub.
branch="$(git symbolic-ref --quiet --short HEAD || true)"
[ -n "$branch" ] || die "HEAD is detached (not on a branch), so there is nothing to push to."
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
[ -n "$upstream" ] || die "branch '$branch' has no upstream. Set one first:
      git push -u origin $branch"

git fetch --quiet --tags origin 2>/dev/null || say "note: could not fetch from origin; working from local refs."

# 4. Has this commit already been stamped?
#    Two things realistically happen at a fortnight's remove: you run it twice,
#    or it died halfway through last time. Both resolve here without anyone
#    diagnosing anything.
newest_tag=""
newest_n=""
if git tag --list "${TAG_PREFIX}/*" >/dev/null 2>&1; then
  newest_n="$(git tag --list "${TAG_PREFIX}/*" | sed "s|^${TAG_PREFIX}/||" | grep -E '^[0-9]+$' | sort -n | tail -1)"
  [ -n "$newest_n" ] && newest_tag="${TAG_PREFIX}/${newest_n}"
fi

if [ -n "$newest_tag" ] && [ "$(git rev-parse "$newest_tag^{commit}" 2>/dev/null)" = "$(git rev-parse HEAD)" ]; then
  # Already stamped at this exact commit. Is it pushed?
  remote_sha="$(git ls-remote origin "refs/tags/$newest_tag" 2>/dev/null | awk '{print $1}')"
  if [ -n "$remote_sha" ]; then
    printf '\n✓ already stamped as build %s at this commit, and the tag is on GitHub.\n' "$newest_n"
    printf '\n  Archive now, from this tree, changing nothing.\n\n'
    exit 0
  fi
  say "already stamped as build $newest_n locally, but the tag never reached GitHub. Completing the push."
  git push --quiet origin "$branch" || die "could not push branch '$branch'."
  git push --quiet origin "refs/tags/$newest_tag" || die "could not push tag $newest_tag."
  remote_sha="$(git ls-remote origin "refs/tags/$newest_tag" 2>/dev/null | awk '{print $1}')"
  [ "$remote_sha" = "$(git rev-parse HEAD)" ] || die "pushed, but GitHub does not report the tag at this commit."
  printf '\n✓ push completed for build %s.\n\n  Archive now, from this tree, changing nothing.\n\n' "$newest_n"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Read the current version, and check nothing has moved it behind our back.
# ─────────────────────────────────────────────────────────────────────────────

command -v agvtool >/dev/null 2>&1 || die "agvtool not found (it ships with Xcode)."

current="$(agvtool what-version -terse 2>/dev/null | tr -d '[:space:]')"
[ -n "$current" ] || die "could not read the current build number with 'agvtool what-version'."
case "$current" in
  ''|*[!0-9]*)
    # agvtool answers with prose when it cannot find a project, so the value is
    # bounded before being shown — a whole paragraph pasted into an error is
    # harder to read than the one line that matters.
    die "'agvtool what-version' did not return a plain number. It said:

      $(printf '%.70s' "$current")

  The usual cause is running this from somewhere other than the project root
  (the directory containing Primal.xcodeproj). This script will not guess a
  build number." ;;
esac

# 5. The version has only ever been moved by this script.
#    If someone hand-bumped since the last stamp, the numbering and the tags
#    have diverged, and continuing would put a tag on a number that does not
#    mean what the tags before it mean.
if [ -n "$newest_n" ] && [ "$current" != "$newest_n" ]; then
  die "CURRENT_PROJECT_VERSION is $current but the newest stamped build is $newest_n.
  The version was changed outside this script. Reconcile them before stamping —
  either stamp from a checkout where they agree, or delete the stale tag."
fi
[ -n "$newest_n" ] || say "no previous stamp found; adopting the current numbering (build $current)."

# ─────────────────────────────────────────────────────────────────────────────
# The marketing version (CFBundleShortVersionString), read from the APP TARGET
# by name — never "whichever one comes first".
#
# ⛔ THIS DOES NOT USE agvtool, AND THE REASON IS MEASURED RATHER THAN STYLISTIC.
# `agvtool what-marketing-version` reads CFBundleShortVersionString out of the
# Info.plist files. In this project all four of them are EMPTY — the version is
# supplied by the MARKETING_VERSION build setting, which is how modern Xcode
# projects carry it. So agvtool finds `""` four times and `-terse1` prints
# NOTHING AT ALL: exit 0, zero bytes. (It also mis-parses its own arguments and
# reports `Cannot find "Primal.xcodeproj/../YES"`.)
#
# An earlier version of this script did `agvtool what-marketing-version -terse1`
# and refused when the result was empty. That refusal fires on EVERY run, so the
# script could never have completed a stamp. It had not been run yet, which is
# the only reason nobody had seen it.
#
# ⛔ AND "TAKE THE FIRST" WOULD HAVE BEEN WRONG EVEN IF IT RETURNED SOMETHING.
# project.pbxproj carries MARKETING_VERSION on twelve build configurations:
# 3.5.60 on the two belonging to the app target, and 1.0 on the ten belonging to
# PrimalTests, PrimalUITests, PrimalNotifications, primalShare and
# RemoteSignerWidget. Which one comes first is an artifact of file ordering, so a
# positional read is a guess that happens to be right — and a future project edit
# would flip it to 1.0 silently, putting a wrong version string inside a record
# whose entire job is identity.
#
# So the version is asked of the thing that actually decides it: the build
# settings for the named app target. Same move as reading a value back rather
# than asserting it. If the target has been renamed, or the setting cannot be
# resolved, this REFUSES — it does not fall back to a guess.
readonly APP_TARGET="Primal"
readonly APP_BUNDLE_ID="net.primal.iosapp.Primal"

build_settings="$(xcodebuild -showBuildSettings \
  -project Primal.xcodeproj \
  -target "$APP_TARGET" \
  -configuration Release \
  -onlyUsePackageVersionsFromResolvedFile 2>/dev/null)" || build_settings=""

[ -n "$build_settings" ] || die "could not read build settings for target '$APP_TARGET'.

  This script will not guess a version string. Check that Primal.xcodeproj still
  has a target called '$APP_TARGET' and that 'xcodebuild -list' works here."

short_version="$(printf '%s\n' "$build_settings" \
  | awk -F' = ' '/^[[:space:]]*MARKETING_VERSION = /{print $2; exit}' | tr -d '[:space:]')"
settings_bundle_id="$(printf '%s\n' "$build_settings" \
  | awk -F' = ' '/^[[:space:]]*PRODUCT_BUNDLE_IDENTIFIER = /{print $2; exit}' | tr -d '[:space:]')"

[ -n "$short_version" ] || die "target '$APP_TARGET' has no MARKETING_VERSION.

  The marketing version is what becomes CFBundleShortVersionString, and the
  stamp is not worth writing without it. Set MARKETING_VERSION on the app
  target, or stamp from a checkout where it is set."

# ⛔ THE TARGET NAME IS A LABEL; THE BUNDLE ID IS THE IDENTITY. Checking both
# means a renamed or re-pointed target cannot quietly hand us another target's
# version — the failure this whole read exists to prevent, arriving through the
# target name instead of through file ordering.
[ "$settings_bundle_id" = "$APP_BUNDLE_ID" ] || die "target '$APP_TARGET' builds
  $settings_bundle_id, not $APP_BUNDLE_ID.

  Refusing rather than stamping a version string read from the wrong target."

say "marketing version $short_version, read from target $APP_TARGET ($APP_BUNDLE_ID)."

# ─────────────────────────────────────────────────────────────────────────────
# Bump, record, commit, tag, push.
# ─────────────────────────────────────────────────────────────────────────────

say "bumping all targets from build $current…"
agvtool next-version -all >/dev/null 2>&1 || die "'agvtool next-version -all' failed. Nothing has been committed."

new_version="$(agvtool what-version -terse 2>/dev/null | tr -d '[:space:]')"
[ -n "$new_version" ] || die "the bump ran but the new build number could not be read. Nothing has been committed."
[ "$new_version" != "$current" ] || die "the bump ran but the build number did not change (still $current)."

new_tag="${TAG_PREFIX}/${new_version}"
if git rev-parse -q --verify "refs/tags/$new_tag" >/dev/null 2>&1; then
  git checkout --quiet -- . 2>/dev/null || true
  die "tag $new_tag already exists on a different commit. The bump has been reverted.
  Someone has stamped this build number already."
fi

# This script's own checksum, so we can tell whether the stamp was written by
# the version of this script that is committed here. It is a plain content hash
# — see the PR description for what it is and is not for.
script_rev="$(shasum -a 256 "$0" 2>/dev/null | cut -c1-12)"
[ -n "$script_rev" ] || die "could not checksum this script."

# Stage the bump, then look at what is LEFT unstaged. Anything still pending at
# this point is not ours — it arrived between the clean-tree check above and
# now, which is a real thing that happens if an editor autosaves mid-run.
#
# This is why `tree_dirty` is a measurement rather than a constant: precondition
# 2 means it is almost always false, and recording it from observation means
# that when it is not, the stamp says so instead of quietly claiming a clean
# build. We would rather know.
git add -u >/dev/null 2>&1
if [ -n "$(git diff --name-only 2>/dev/null)" ]; then
  tree_dirty=true
  say "note: files changed during this run and are NOT part of the stamped commit."
else
  tree_dirty=false
fi

cat > "$STAMP_FILE" <<JSON
{
  "schema": $SCHEMA,
  "cf_bundle_version": "$new_version",
  "cf_bundle_short_version_string": "$short_version",
  "tree_dirty": $tree_dirty,
  "stamped_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "script_rev": "$script_rev"
}
JSON

git add -- "$STAMP_FILE" >/dev/null 2>&1
git commit --quiet -m "qa: stamp build $new_version ($short_version)" \
  || die "the commit failed. Your bump is still in the working tree; nothing was pushed."

commit_sha="$(git rev-parse HEAD)"
git tag "$new_tag" "$commit_sha" || die "could not create tag $new_tag. The commit is made but not tagged."

say "pushing branch '$branch' and tag $new_tag…"
# NOTE: this pushes the current branch, so any other commits you have made and
# not pushed will go up with it. If that is a surprise, stop here and push them
# deliberately first — everything so far is local and can be undone.
if ! git push --quiet origin "$branch"; then
  die "could not push branch '$branch'. The commit and tag exist locally.
  Fix the network or the permissions and run this script again — it will
  detect the existing stamp and just complete the push."
fi
if ! git push --quiet origin "refs/tags/$new_tag"; then
  die "could not push tag $new_tag. The commit and tag exist locally.
  Run this script again and it will complete the push."
fi

# ─────────────────────────────────────────────────────────────────────────────
# Verify from OUTSIDE. Exit code 0 means "the stamp is visible on GitHub", not
# "the commands ran" — this is the whole reason the script bothers to check.
# ─────────────────────────────────────────────────────────────────────────────
remote_sha="$(git ls-remote origin "refs/tags/$new_tag" 2>/dev/null | awk '{print $1}')"
[ -n "$remote_sha" ] || die "the push reported success but GitHub does not have tag $new_tag.
  Run this script again to retry the push."
[ "$remote_sha" = "$commit_sha" ] || die "GitHub reports tag $new_tag at $remote_sha,
  but this commit is $commit_sha. Do not archive until this is resolved."

printf '\n✓ build %s (%s) stamped and verified on GitHub\n' "$new_version" "$short_version"
printf '    commit  %s\n' "$commit_sha"
printf '    tag     %s\n' "$new_tag"
printf '\n  Archive now, from this tree, changing nothing.\n\n'
