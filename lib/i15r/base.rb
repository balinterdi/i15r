require "optparse"
require "ostruct"

class AppFolderNotFound < Exception; end

module I15R
  class Base
    attr_reader :options

    def self.get_i18n_message_string(text, prefix)
      key = text.strip.downcase.gsub(/\s/, '_').gsub(/[\W]/, '')
      indent = ""
      (0..prefix.split(".").size).each { |i| indent = "  " + indent }
      # silenced_if_testing do
      #   puts "#{indent}#{key}: #{text}"
      # end
      "#{prefix}.#{key}"
    end

    def initialize
      @options = OpenStruct.new
      @options.prefix = nil
      @options
    end

    def parse_options(args)
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: ruby i15r.rb [options] <path_to_internationalize>"
        opts.on("--prefix PREFIX",
                "apply PREFIX to generated I18n messages instead of deriving it from the path") do |prefix|
          @options.prefix = prefix
        end
      end

      if args.length.zero?
        puts opts.banner
        exit
      end

      opts.on_tail("-p", "--pretend", "Do not write the files, just show what would be replaced") do
        @options.dry_run = true
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.on_tail("--version", "Show version") do
        puts "0.0.1"
        exit
      end

      opts.parse!(args)
      # @options
    end

    def prefix
      @options.prefix
    end

    def dry_run?
      !!@options.dry_run
    end

    def file_path_to_message_prefix(file)
      segments = File.expand_path(file).split('/').select { |segment| !segment.empty? }
      subdir = %w(views helpers controllers models).find do |app_subdir|
         segments.index(app_subdir)
      end
      if subdir.nil?
        raise AppFolderNotFound, "No app. subfolders were found to determine prefix. Path is #{File.expand_path(file)}"
      end
      first_segment_index = segments.index(subdir) + 1
      file_name_without_extensions = segments.last.split('.')[0..0]
      path_segments = segments.slice(first_segment_index...-1)
      (path_segments + file_name_without_extensions).join('.')
    end

    def get_content_from(file)
      File.read(File.expand_path(file))
    end

    def write_content_to(file, content)
      open(File.expand_path(file), "w") { |f| f.write(content) }
    end

    def show_diff(plain_row, i9l_row)
      silenced_if_testing do
        $stdout.puts "- #{plain_row}"
        $stdout.puts "+ #{i9l_row}"
      end
    end

    def internationalize_file(file)
      text = get_content_from(file)
      prefix = self.prefix || file_path_to_message_prefix(file)
      i18ned_text = sub_plain_strings(text, prefix)
      write_content_to(file, i18ned_text) unless dry_run?
    end

    def display_indented_header(prefix)
      silenced_if_testing do
        puts "en:"
      end
      prefix_parts = prefix.split(".").each_with_index do |p, i|
        p = "#{p}:"
        (0..i).each { |i| p = "  " + p }
        silenced_if_testing do
          puts "#{p}"
        end
      end
    end

    def sub_plain_strings(text, prefix)
      #TODO: find out how to display diff rows
      I15R::PatternMatchers::Base.run(text, prefix) do |plain_row, i9l_row|
        show_diff(plain_row, i9l_row)
      end
    end

    def internationalize!(path)
      files = File.directory?(path) ? Dir.glob("#{path}/**/*.{erb,haml}") : [path]
      files.each { |file| internationalize_file(file) }
    end

    private
    def silenced_if_testing
      if testing?
        orig_stdout = $stdout
        $stdout = File.new('/dev/null', 'w')
      end
      yield
      if testing?
        $stdout = orig_stdout
      end
    end

    def testing?
      $testing
    end
  end
end