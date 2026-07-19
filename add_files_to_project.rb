require 'xcodeproj'

project_path = '/Users/eric/Desktop/herness/primal-ios-app/Primal.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main group and target
main_group = project.main_group
target = project.targets.first

# Helper to find or create groups recursively
def find_or_create_group(parent, path_components)
  return parent if path_components.empty?
  name = path_components.first
  child = parent.children.find { |c| c.is_a?(Xcodeproj::Project::PBXGroup) && c.name == name }
  child ||= parent.new_group(name)
  find_or_create_group(child, path_components[1..])
end

# Files to add: [disk_path, group_path]
files_to_add = [
  ['Primal/Common/Views/Feed/PostCell/NoteTranslationService.swift', 'Primal/Common/Views/Feed/PostCell'],
  ['Primal/Common/Views/Feed/PostCell/NoteTranslationView.swift', 'Primal/Common/Views/Feed/PostCell'],
  ['Primal/Scenes/Settings/SubControllers/SettingsTranslationViewController.swift', 'Primal/Scenes/Settings/SubControllers'],
]

files_to_add.each do |disk_path, group_path|
  # Check if already in project
  existing = project.files.find { |f| f.path == disk_path }
  if existing
    puts "Already in project: #{disk_path}"
    next
  end

  # Navigate to the right group
  components = group_path.split('/')
  group = find_or_create_group(main_group, components)
  
  # Create file reference
  file = group.new_file(disk_path)
  
  # Add to target's sources build phase
  target.source_build_phase.add_file_reference(file)
  
  puts "Added: #{disk_path}"
end

project.save
puts "Project saved successfully!"
