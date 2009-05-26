require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('i15r', '0.2.1') do |p|
  p.description    = "The internationalizer. Replaces plain text strings in your views and replaces them with I18n message strings so you only have to provide the translations."
  p.url            = "http://github.com/balinterdi/i15r"
  p.author         = "Bálint Érdi"
  p.email          = "balint.erdi@gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
