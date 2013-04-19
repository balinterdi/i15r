require 'i15r/pattern_matcher'
require 'highline/import'
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
    existing_keys = ::YAML.load(File.open('config/locales/en.yml'))
    new_locale_hash = keys.
      deep_merge(existing_keys, ->(k, e, n){ edit_merge k, e, n }).
      deep_sort(->(key, value){ key.to_s })
    File.open('config/locales/en.yml', 'w+') {|f| f.write(::YAML::dump(new_locale_hash.to_hash)) }
  end

  def edit_merge(key, hash_val, merge_hash_val)
    say <<-EOF

Merge options for #{color :cyan, key}:
#{color :red, "(1)Original file: #{merge_hash_val}"}
#{color :green, "(2)New input: #{hash_val}"}
EOF
    selection = ask("Please choose or enter a new value") do |q| q.default = '1' end
    case selection
    when '1' then merge_hash_val
    when '2' then hash_val
    else selection
    end
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

  def color(color, string)
    c = case color
        when :red then "\x1b[31m"
        when :green then "\x1b[32m"
        when :cyan then "\x1b[36m"
        end
    "#{c}#{string}\x1b[0m"
  end

  def edit_key(key, string)
    say "\n\nKey options for #{color :cyan, key}"
    say "with value: #{color :green, string}"
    choices = key_prompts(key)
    choices.each_with_index do |p, i|
      say "(#{i + 1}) #{p}"
    end
    selection = ask("Please choose a key or enter one manually") do |q| q.default = '1' end

    if (1..choices.size).include? selection.to_i
      choices[selection.to_i - 1]
    else
      selection
    end
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
    keys.add_key ['en'] + key.split(/\./), string
  end

  def keys
    @keys ||= KeyStore.new({})
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
