require 'i15r/pattern_matcher'
require 'i15r/key_store'
require 'yaml'

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

  def initialize(reader, writer, interface, config={})
    @reader = reader
    @writer = writer
    @interface = interface
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
    @interface.display("Current file: #{path}:\n\n")
    i18ned_text = sub_plain_strings(text, full_prefix(path), template_type.to_sym)
    @writer.write(path, i18ned_text) unless config.dry_run?
    existing_keys = ::YAML.load(File.open('config/locales/en.yml'))
    new_locale_hash = keys.
      deep_merge(existing_keys, ->(key, namespaced_key, existing_value, new_value){
        @interface.edit_merge namespaced_key, existing_value, new_value
      }).
      deep_sort(->(key, value){ key.to_s })
    File.open('config/locales/en.yml', 'w+') {|f| f.write(::YAML::dump(new_locale_hash.to_hash)) }
  end

  def sub_plain_strings(text, prefix, file_type)
    pm = I15R::PatternMatcher.new(prefix, file_type, :add_default => config.add_default,
                                  :override_i18n_method => config.override_i18n_method)
    transformed_text = pm.run(text) do |old_line, new_line, key, string|
      @interface.show_diff(old_line, new_line)
      if config.interactive?
        key = @interface.edit_key(key, string)
      end
      store_key(key, string)
      key # return key at end of block, in case it was changed
    end
    transformed_text + "\n"
  end

  def store_key(key, string)
    keys.add_key ['en'] + key.split(/\./), string
  end

  def keys
    @keys ||= KeyStore.new({})
  end

  def internationalize!(path)
    @interface.display "Running in dry-run mode" if config.dry_run?
    path = "app" if path.nil?
    files = File.directory?(path) ? Dir.glob("#{path}/**/*.{erb,haml}") : [path]
    files.each { |file| internationalize_file(file) }
  end

  def include_path?
    config.prefix_with_path || !config.prefix
  end

end
