# frozen_string_literal: true

# Only run Swiftlint locally, Danger will handle linting on CI
if ENV.key?('CI')
  puts "The SwiftLint Run Script does not run on CI. Don't worry, Danger will handle it!"
  return
end

command = '${PODS_ROOT}/SwiftLint/swiftlint lint --no-cache'

# Allow passing in a file path for .swiftlint.yml, otherwise it looks in the project folder
command += " --config #{ARGV[0]}" unless ARGV[0].nil?

system(command)
