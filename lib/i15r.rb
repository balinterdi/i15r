require 'i15r/pattern_matcher'

class I15R
  class AppFolderNotFound < Exception; end

  def self.get_i18n_message_string(text, prefix)
    #TODO: downcase does not work properly for accented chars, like 'Ú', see function in ActiveSupport that deals with this
    #TODO: [:punct:] would be nice but it includes _ which we don't want to remove
    key = text.strip.downcase.gsub(/[\s\/]+/, '_').gsub(/[!?.,:"';()]/, '')
    indent = ""
    (0..prefix.split(".").size).each { |i| indent = "  " + indent }
    "#{prefix}.#{key}"
  end

  class Config
    def initialize(config)
      @options = config
    end

    def prefix
      @options.fetch(:prefix, nil)
    end

    def dry_run?
      @options.fetch(:dry_run, false)
    end
  end

  attr_reader :config

  def initialize(reader, writer, printer, config={})
    @reader = reader
    @writer = writer
    @printer = printer
    @config = I15R::Config.new(config)
  end

  def config=(hash)
    @config = I15R::Config.new(hash)
  end

  def prefix
    @options.prefix
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

  def internationalize_file(path)
    text = @reader.read(path)
    prefix = config.prefix || file_path_to_message_prefix(path)
    template_type = path[/(?:.*)\.(.*)$/, 1]
    i18ned_text = sub_plain_strings(text, prefix, template_type.to_sym)
    @writer.write(path, i18ned_text) unless config.dry_run?
  end

  def display_indented_header(prefix)
    puts "en:"
    prefix_parts = prefix.split(".").each_with_index do |p, i|
      p = "#{p}:"
      #TODO: perhaps " "*i is simpler
      (0..i).each { |i| p = "  " + p }
      puts "#{p}"
    end
  end

  def sub_plain_strings(text, prefix, file_type)
    pm = I15R::PatternMatcher.new(prefix, file_type)
    transformed_text = pm.run(text) do |old_line, new_line|
      @printer.print(old_line, new_line)
    end
    transformed_text + "\n"
  end

  def internationalize!(path)
    #TODO: Indicate if we're running in dry-run mode
    files = File.directory?(path) ? Dir.glob("#{path}/**/*.{erb,haml}") : [path]
    files.each { |file| internationalize_file(file) }
  end
end
