require 'i15r/pattern_matcher'

class I15R
  class AppFolderNotFound < Exception; end

  class Config
    def initialize(config)
      @options = config
    end

    def prefix
      @options.fetch(:prefix, nil) || prefix_with_path
    end

    def prefix_with_path
      @options.fetch(:prefix_with_path, nil)
    end

    def dry_run?
      @options.fetch(:dry_run, false)
    end

    def add_default
      @options.fetch(:add_default, true)
    end

    def override_i18n_method
      @options.fetch(:override_i18n_method, nil)
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

  def file_path_to_message_prefix(file)
    segments = File.expand_path(file).split('/').reject { |segment| segment.empty? }
    subdir = %w(views helpers controllers models).find do |app_subdir|
       segments.index(app_subdir)
    end
    if subdir.nil?
      raise AppFolderNotFound, "No app. subfolders were found to determine prefix. Path is #{File.expand_path(file)}"
    end
    first_segment_index = segments.index(subdir) + 1
    file_name_without_extensions = segments.last.split('.').first
    if file_name_without_extensions and file_name_without_extensions[0] == '_'
      file_name_without_extensions = file_name_without_extensions[1..-1]
    end
    path_segments = segments.slice(first_segment_index...-1)
    if path_segments.empty?
      file_name_without_extensions
    else
      "#{path_segments.join('.')}.#{file_name_without_extensions}"
    end
  end

  def full_prefix(path)
    prefix = [config.prefix]
    prefix << file_path_to_message_prefix(path) if include_path?
    prefix.compact.join('.')
  end

  def internationalize_file(path)
    text = @reader.read(path)
    template_type = path[/(?:.*)\.(.*)$/, 1]
    @printer.println("#{path}:")
    @printer.println("")
    i18ned_text = sub_plain_strings(text, full_prefix(path), template_type.to_sym)
    @writer.write(path, i18ned_text) unless config.dry_run?
  end

  def sub_plain_strings(text, prefix, file_type)
    pm = I15R::PatternMatcher.new(prefix, file_type, :add_default => config.add_default,
                                  :override_i18n_method => config.override_i18n_method)
    transformed_text = pm.run(text) do |old_line, new_line, key, string|
      @printer.print_diff(old_line, new_line)
      #@printer.println("Key: #{key}\nString: #{String}")
      k = edit_change(key, string)
      store_key(key, string)
    end
    puts keys
    transformed_text + "\n"
  end

  def edit_change(key, string)
    done = false
    k = key
    until done do
      puts("Key: #{k}\nString: #{string}")
      g = gets
      case g
      when /c/
        # change
      when /-/
        k = remove_key_string(k)
      when /u/
        k = key
      else
        done = true
      end
    end
    k
  end

  # remove the second to last key entry
  def remove_key_string(key)
    keys = key.split('.').values_at(0..-3, -1).join('.')
  end

  def store_key(key, string)
    keys << [key, string]
  end

  def keys
    @keys ||= []
  end

  def internationalize!(path)
    @printer.println "Running in dry-run mode" if config.dry_run?
    path = "app" if path.nil?
    files = File.directory?(path) ? Dir.glob("#{path}/**/*.{erb,haml}") : [path]
    files.each { |file| internationalize_file(file) }
  end

  def include_path?
    config.prefix_with_path || !config.prefix
  end

end
