current_dir = File.expand_path(File.dirname(__FILE__))
$:.unshift File.join(current_dir, "..", "lib")

require 'i15r'
require 'i15r/file_reader'

Dir["#{current_dir}/support/**/*.rb"].each do |file|
  require file
end

class I15R
  class NullWriter
    def write(path, content); end
  end
  class NullPrinter
    def print(old_row, new_row); end
  end

  class Fixture < I15R
    def initialize(reader=FileReader.new,
                   writer=NullWriter.new,
                   printer=NullPrinter.new,
                   config={})
      super(reader, writer, printer, config)
    end
  end
end

