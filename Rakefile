require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "i15r"
    gemspec.summary = "The internationalizer. Makes your Ruby app international"
    gemspec.description = <<-EOF
      The internationalizer. Replaces plain text strings in your views and replaces them with I18n message strings so you only have to provide the translations.
    EOF
    gemspec.email = "balint.erdi@gmail.com"
    gemspec.homepage = "http://github.com/balinterdi/i15r"
    gemspec.authors = ["Balint Erdi"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
