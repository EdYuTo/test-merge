require 'xcodeproj'

if ARGV.empty?
    puts "Usage: #{$0} project_name"
    exit
end

projectName = ARGV[0]
project = Xcodeproj::Project.open("#{projectName}.xcodeproj")

versionFile = File.read('version').split
marketingVersion = versionFile[0]
projectVersion = versionFile[1]

project.targets.each do |target|
    if target.name == projectName then
        target.build_configurations.each do |config|
            config.build_settings['MARKETING_VERSION'] = marketingVersion
            config.build_settings['CURRENT_PROJECT_VERSION'] = projectVersion
        end
    end
end

project.save
