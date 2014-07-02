desc 'Open the project file'
task :open do
  puts 'Opening the project'
  sh 'open EDDSalesTracker.xcworkspace'

  # Done!
  puts 'Done opening project!'.green
end

desc "Rev the build numbers in your project's plist"
task :rev do
  revBuild './App/Supporting\ Files/EDDSalesTracker-Info.plist'  
end

def revBuild(plistFile)
  puts "Attempting to update #{plistFile} build version..."
  oldVersion = `/usr/libexec/PlistBuddy -c "Print CFBundleVersion" #{plistFile}`
  puts "The old version: #{oldVersion}"

  versionParts = oldVersion.split(".")
  previousDate = versionParts[2]
  newDate = Time.now.strftime("%Y%m%d")

  versionParts[2] = newDate
  versionParts[3] = previousDate == versionParts[2] ? (versionParts[3].to_i+1).to_s : "1"

  versionParts.each do |part|
    part.chomp!
  end

  newVersion = versionParts.join(".")
  
  `/usr/libexec/PlistBuddy -c "Set :CFBundleVersion #{newVersion}" #{plistFile}`

  puts "The new version: #{newVersion}"
end

#Add color to setup
class String
  def self.colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def cyan
    self.class.colorize(self, 36)
  end

  def green
    self.class.colorize(self, 32)
  end
end
