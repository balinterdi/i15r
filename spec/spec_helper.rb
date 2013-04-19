current_dir = File.expand_path(File.dirname(__FILE__))
$:.unshift File.join(current_dir, "..", "lib")

require 'i15r'
require 'i15r/file_reader'

Dir["#{current_dir}/support/**/*.rb"].each do |file|
  require file
end

class I15R
  class StringReader
    def read(path)
      "norf"
    end
  end

  class NullWriter
    def write(path, content); end
  end
  class NullPrinter
    def show_diff(old_row, new_row); end
    def display(text); end
  end

  class Fixture < I15R
    def initialize(reader=StringReader.new,
                   writer=NullWriter.new,
                   printer=NullPrinter.new,
                   config={})
      super(reader, writer, printer, config)
    end

    def self.with_config(config)
      new(StringReader.new, NullWriter.new, NullPrinter.new, config)
    end
  end
end

