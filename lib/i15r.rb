require 'i15r/pattern_matcher'
require 'highline/import'

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

    def interactive?
      @options.fetch(:interactive, false)
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
    existing_keys = YAML.load(File.open('config/locales/en.yml'))
    add_keys(keys, existing_keys)
    File.open('config/locales/en.yml', 'w+') {|f| f.write(YAML::dump(existing_keys)) }
  end

  def sub_plain_strings(text, prefix, file_type)
    pm = I15R::PatternMatcher.new(prefix, file_type, :add_default => config.add_default,
                                  :override_i18n_method => config.override_i18n_method)
    transformed_text = pm.run(text) do |old_line, new_line, key, string|
      @printer.print_diff(old_line, new_line)
      if config.interactive?
        key = edit_key(key, string)
      end
      store_key(key, string)
      key # return key at end of block, in case it was changed
    end
    transformed_text + "\n"
  end

  # Add keys to existing hash of key
  #  key - array of arrays like ["application.user.print", "Print"]
  #  existing - hash of existing keys loaded from locale YAML
  def add_keys(new_keys, existing)
    new_keys.each do |k|
      add_key(k, existing)
    end
  end

  def add_key(key_array, existing)
    merge_to = existing
    last_merge_to = nil
    last_key = nil
    key = "en.#{key_array[0]}"
    # build up the key into existing, if it doesn't exist
    key.split('.').each do |k|
      merge_to[k] = {} unless merge_to[k]
      last_merge_to = merge_to
      merge_to = merge_to[k]
      last_key = k
    end

    case merge_to
    when String
      # Already exists and is different
      if merge_to != key_array[1]
        puts "Warning: #{key} already exists. Current:#{merge_to}  Want:#{key_array[1]}"
      end
    when Hash
      # Already exists as populated has
      if merge_to != {}
        puts "Warning: #{key} already exists. Current:#{merge_to}  Want:#{key_array[1]}"
      else
        last_merge_to[last_key] = key_array[1]
      end
    end

  end

  def edit_key(key, string)
    choices = key_prompts(key)

    choose do |menu|
      menu.index = :number
      menu.index_suffix = '. '
      menu.header = "\n\n\n#{string}\n#{key}"
      menu.prompt = "Choose a key"
      menu.choice "<Enter key manually>" do
        key = ask "Enter key:"
      end
      choices.each do |c|
        menu.choice c do key = c end
      end

    end
    key
  end

  # array of prompts, leaving the first and last item intact
  def key_prompts(key)
    keylist = key.split('.')
    choices = []
    until keylist.length <= 1
      choices << keylist.join('.')
      keylist.delete_at(-2)
    end
    choices
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
