//
//  RegexTests.swift
//  PrimalTests
//
//  Created by Pavle Stevanović on 13.2.25..
//

import XCTest
import Foundation

final class RegexTests: XCTestCase {
    
    var articleRegex: NSRegularExpression!
    
    override func setUpWithError() throws {
        articleRegex = try NSRegularExpression(pattern: .articleMentionPattern, options: [])
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRegex(pattern: String, data: [(String, [String])]) throws {
        let articleMentionRegex = try NSRegularExpression(pattern: pattern, options: [])
        
        for (text, matches) in data {
            var matchCount = 0
            var allMatches: [String] = []
            articleMentionRegex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
                guard let matchRange = match?.range else {
                    XCTFail("No range")
                    return
                }
                
                matchCount += 1
                let mentionText = (text as NSString).substring(with: matchRange)
                allMatches.append(mentionText)
                
                XCTAssertTrue(matches.contains(mentionText), "\(mentionText) not in \(matches)")
            }
            
            XCTAssertEqual(matches.count, matchCount, "\(text): \(matches) != \(allMatches)")
        }
    }

    func testNoteRegex() throws {
        try testRegex(pattern: .noteMentionPattern, data: noteTests)
    }
    
    func testArticleRegex() throws {
        try testRegex(pattern: .articleMentionPattern, data: articleTests)
    }
    
    func testNip08() throws {
//        try testRegex(pattern: .nip08MentionPattern, data: tagTests)
    }
    
    func testNip27() throws {
        try testRegex(pattern: .nip27MentionPattern, data: nip27Tests)
    }
    
    
    let nip27Tests: [(String, [String])] = [
        (
            """
            With just a dozen lines of code, nostr:npub10r8xl2njyepcw2zwv3a6dyufj4e4ajx86hz6v4ehu4gnpupxxp7stjt2p8 protect its users from malicious apps.

            This is only possible thanks to nostr:npub1kpt95rv4q3mcz8e4lamwtxq7men6jprf49l7asfac9lnv2gda0lqdknhmz, which makes adding WoT to your project as simple as signing an event.


            https://m.primal.net/Ofac.mp4
            """,
            [
                "nostr:npub10r8xl2njyepcw2zwv3a6dyufj4e4ajx86hz6v4ehu4gnpupxxp7stjt2p8",
                "nostr:npub1kpt95rv4q3mcz8e4lamwtxq7men6jprf49l7asfac9lnv2gda0lqdknhmz"
            ]
        ),
        (
            """
            With just a dozen lines of code, npub10r8xl2njyepcw2zwv3a6dyufj4e4ajx86hz6v4ehu4gnpupxxp7stjt2p8 protect its users from malicious apps.

            This is only possible thanks to https://primal.net/p/npub1kpt95rv4q3mcz8e4lamwtxq7men6jprf49l7asfac9lnv2gda0lqdknhmz, which makes adding WoT to your project as simple as signing an event.


            https://m.primal.net/Ofac.mp4
            """,
            [
                "npub10r8xl2njyepcw2zwv3a6dyufj4e4ajx86hz6v4ehu4gnpupxxp7stjt2p8",
                "https://primal.net/p/npub1kpt95rv4q3mcz8e4lamwtxq7men6jprf49l7asfac9lnv2gda0lqdknhmz"
            ]
        ),
        (
            "nostr:nprofile1qqsrwny8twqyqtef54j4udy3z3fctdxszcgedm7f4p2l3pk6q247kyqw66hvj aaa",
            [
                "nostr:nprofile1qqsrwny8twqyqtef54j4udy3z3fctdxszcgedm7f4p2l3pk6q247kyqw66hvj"
            ]
        ),
    ]
    
    let articleTests: [(String, [String])] = [
        (
            """
            Just published my thoughts on NWC in Primal 2.1, along with some wallet transaction numbers 👀

            nostr:naddr1qvzqqqr4gupzp4sl80zm866yqrha4esknfwp0j4lxfrt29pkrh5nnnj2rgx6dm62qq0y2an9wfuj6stswqk5uet9v3ej6snfw33k76tw943hjvm4wejqp96a3d
            """,
            [
                "nostr:naddr1qvzqqqr4gupzp4sl80zm866yqrha4esknfwp0j4lxfrt29pkrh5nnnj2rgx6dm62qq0y2an9wfuj6stswqk5uet9v3ej6snfw33k76tw943hjvm4wejqp96a3d"
            ]
        ),
        (
            """
            Just published my thoughts on NWC in Primal 2.1, along with some wallet transaction numbers 👀

            naddr1qvzqqqr4gupzp4sl80zm866yqrha4esknfwp0j4lxfrt29pkrh5nnnj2rgx6dm62qq0y2an9wfuj6stswqk5uet9v3ej6snfw33k76tw943hjvm4wejqp96a3d
            """,
            [
                "naddr1qvzqqqr4gupzp4sl80zm866yqrha4esknfwp0j4lxfrt29pkrh5nnnj2rgx6dm62qq0y2an9wfuj6stswqk5uet9v3ej6snfw33k76tw943hjvm4wejqp96a3d"
            ]
        ),
        (
            """
            Just published my thoughts on NWC in Primal 2.1, along with some wallet transaction numbers 👀

            https://njump.me/naddr1qvzqqqr4gupzp4sl80zm866yqrha4esknfwp0j4lxfrt29pkrh5nnnj2rgx6dm62qq0y2an9wfuj6stswqk5uet9v3ej6snfw33k76tw943hjvm4wejqp96a3d
            """,
            [
                "https://njump.me/naddr1qvzqqqr4gupzp4sl80zm866yqrha4esknfwp0j4lxfrt29pkrh5nnnj2rgx6dm62qq0y2an9wfuj6stswqk5uet9v3ej6snfw33k76tw943hjvm4wejqp96a3d"
            ]
        ),
        // Test 1: Multiple matches in one text
        (
            """
            Check out these nostr addresses:
            - nostr:naddr1abc123
            - https://njump.me/naddr1def456
            - naddr1ghi789
            And a hashtag: #[123]
            """,
            [
                "nostr:naddr1abc123",
                "https://njump.me/naddr1def456",
                "naddr1ghi789",
                "#[123]"
            ]
        ),
        // Test 2: No matches
        (
            """
            This text does not contain any nostr addresses or hashtags.
            It includes some random text and URLs like https://example.com/naddr1xyz.
            """,
            []
        ),
        // Test 3: Edge cases
        (
            """
            nostr:naddr1start at the beginning.
            End with naddr1end.
            Punctuation test: (naddr1punct), [naddr1bracket].
            Hashtag test: #[456]
            """,
            [
                "nostr:naddr1start",
                "naddr1end",
                "#[456]"
            ]
        ),
        // Test 4: Invalid contexts
        (
            """
            This is an invalid URL: https://zap.stream/naddr1invalid.
            Partial match: naddr1 partial.
            Similar pattern: nnaddr1similar.
            """,
            []
        ),
        // Test 5: Mixed valid and invalid
        (
            """
            Valid: nostr:naddr1valid1
            Invalid: https://invalid.com/naddr1invalid2
            Valid standalone: naddr1valid3
            Valid hashtag: #[789]
            """,
            [
                "nostr:naddr1valid1",
                "naddr1valid3",
                "#[789]"
            ]
        ),
    ]

    let noteTests: [(String, [String])] = [
        (
            """
            nostr:nevent1qgs04xzt6ldm9qhs0ctw0t58kf4z57umjzmjg6jywu0seadwtqqc75spp4mhxue69uhkvdm69e5k7tcpz4mhxue69uhhyetvv9ujummvv9ejuctswqhsqg8t5pvn6dhpxjslzynm9pkdt9r4jwe7ze8xec87yva5w3lszkrgaqnx7uru
            """,
            [
                "nostr:nevent1qgs04xzt6ldm9qhs0ctw0t58kf4z57umjzmjg6jywu0seadwtqqc75spp4mhxue69uhkvdm69e5k7tcpz4mhxue69uhhyetvv9ujummvv9ejuctswqhsqg8t5pvn6dhpxjslzynm9pkdt9r4jwe7ze8xec87yva5w3lszkrgaqnx7uru"
            ]
        ),
        (
            """
            Test
            nostr:nevent1qqsqqy7fy7ufp8sw7hae5utfv7njh0gqlhcj6pllmf6dcdutw374gvspr4mhxue69uhkummnw3ez6ur4vgh8wetvd3hhyer9wghxuet5mcduwx
            """,
            ["nostr:nevent1qqsqqy7fy7ufp8sw7hae5utfv7njh0gqlhcj6pllmf6dcdutw374gvspr4mhxue69uhkummnw3ez6ur4vgh8wetvd3hhyer9wghxuet5mcduwx"]
        ),
        (
            """
            https://primal.net/e/note1ka7zjms3khmzhxlllwrt34jwp7ss8pat0ayrluyln2vp6yrmyuaq536urz
            """,
            ["https://primal.net/e/note1ka7zjms3khmzhxlllwrt34jwp7ss8pat0ayrluyln2vp6yrmyuaq536urz"]
        ),
        (
            """
            https://primal.net/e/note1ka7zjms3khmzhxlllwrt34jwp7ss8pat0ayrluyln2vp6yrmyuaq536urz nostr:nevent1qqsqqy7fy7ufp8sw7hae5utfv7njh0gqlhcj6pllmf6dcdutw374gvspr4mhxue69uhkummnw3ez6ur4vgh8wetvd3hhyer9wghxuet5mcduwx
            nevent1qgs04xzt6ldm9qhs0ctw0t58kf4z57umjzmjg6jywu0seadwtqqc75spp4mhxue69uhkvdm69e5k7tcpz4mhxue69uhhyetvv9ujummvv9ejuctswqhsqg8t5pvn6dhpxjslzynm9pkdt9r4jwe7ze8xec87yva5w3lszkrgaqnx7uru
            """,
            [
                "https://primal.net/e/note1ka7zjms3khmzhxlllwrt34jwp7ss8pat0ayrluyln2vp6yrmyuaq536urz",
                "nostr:nevent1qqsqqy7fy7ufp8sw7hae5utfv7njh0gqlhcj6pllmf6dcdutw374gvspr4mhxue69uhkummnw3ez6ur4vgh8wetvd3hhyer9wghxuet5mcduwx",
                "nevent1qgs04xzt6ldm9qhs0ctw0t58kf4z57umjzmjg6jywu0seadwtqqc75spp4mhxue69uhkvdm69e5k7tcpz4mhxue69uhhyetvv9ujummvv9ejuctswqhsqg8t5pvn6dhpxjslzynm9pkdt9r4jwe7ze8xec87yva5w3lszkrgaqnx7uru"
            ]),
        (
            """
            note1ka7zjms3khmzhxlllwrt34jwp7ss8pat0ayrluyln2vp6yrmyuaq536urz
            https://primal.net/e/note1ka7zjms3khmzhxlllwrt34jwp7ss8pat0ayrluyln2vp6yrmyuaq536urz
            """,
            [
                "https://primal.net/e/note1ka7zjms3khmzhxlllwrt34jwp7ss8pat0ayrluyln2vp6yrmyuaq536urz",
                "note1ka7zjms3khmzhxlllwrt34jwp7ss8pat0ayrluyln2vp6yrmyuaq536urz"
            ]
        ),
    ]
}
