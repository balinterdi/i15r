require "rubygems"
require 'optparse'
require "ostruct"
# require "ruby-debug"

class AppFolderNotFound < Exception; end

class I15r

  attr_reader :options

  def initialize
    @options = OpenStruct.new
    @options.prefix = nil    
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

  def get_i18n_message_string(text, prefix)
    key = text.strip.downcase.gsub(/\s/, '_').gsub(/[\W]/, '')
    indent = ""
    (0..prefix.split(".").size).each { |i| indent = "  " + indent }
    silenced_if_testing do
      puts "#{indent}#{key}: #{text}"
    end
    "#{prefix}.#{key}"
  end

  def get_content_from(file)
    File.read(File.expand_path(file))
  end

  def show_diff
    
  end

  def write_content_to(file, content)
    open(File.expand_path(file), "w") { |f| f.write(content) }
  end

  def internationalize_file(file)
    text = get_content_from(file)
    prefix = self.prefix || file_path_to_message_prefix(file)
    i18ned_text = internationalize(text, prefix)
    show_diff
    write_content_to(file, i18ned_text) unless dry_run?
  end

  def replace_in_rails_helpers(text, prefix)
    text.gsub!(/<%=\s*link_to\s+['"](.*?)['"]\s*/) do |match|
      i18n_string = get_i18n_message_string($1, prefix)
      %(<%= link_to I18n.t("#{i18n_string}"))
    end

    text.gsub!(/<%=(.*)\.label(.*),\s*['"](.*?)['"]/) do |match|
      i18n_string = get_i18n_message_string($3, prefix)
      %(<%= #{$1.strip}.label #{$2.strip}, I18n.t("#{i18n_string}"))
    end

    text.gsub!(/<%=\s*label_tag(.*),\s*['"](.*?)['"]/) do |match|
      i18n_string = get_i18n_message_string($2, prefix)
      %(<%= label_tag #{$1.strip}, I18n.t("#{i18n_string}"))
    end

    text.gsub!(/<%=(.*)\.submit\s*['"](.*?)['"]/) do |match|
      i18n_string = get_i18n_message_string($2, prefix)
      %(<%= #{$1.strip}.submit I18n.t("#{i18n_string}"))
    end

    text.gsub!(/<%=\s*submit_tag\s*['"](.*?)['"]/) do |match|
      i18n_string = get_i18n_message_string($1, prefix)
      %(<%= submit_tag I18n.t("#{i18n_string}"))
    end

  end

  def replace_in_tag_content(text, prefix)
    # TODO: include accented (non-iso-8859-1) word characters
    # in the words (e.g á or é should be considered such)
    text = text.gsub!(/>(\s*)(\w[\s\w:'"!?\.,]+)\s*</) do |match|
      i18n_string = get_i18n_message_string($2, prefix)
      # readding leading ws and ending punctuation (and ws)
      # (there must be a way to put this into the regex,
      # I just did not find it.)
      leading_whitespace = $1
      ending_punctuation = $2[/([?.!:\s]*)$/, 1]
      %(>#{leading_whitespace}<%= I18n.t("#{i18n_string}") %>#{ending_punctuation.to_s}<)
    end
  end

  def replace_in_tag_attributes(text, prefix)
    text = text.gsub!(/(<a\s+.*title=)['"](.*?)['"]/) do |match|
      i18n_string = get_i18n_message_string($2, prefix)
      %(#{$1}"<%= I18n.t("#{i18n_string}") %>")
    end
  end

  def returning(value)
    yield value
    value
  end

  def internationalize(text, prefix)
    #TODO: that's not very nice since it relies on
    # the replace methods (e.g replace_in_tag_content)
    # being destructive (banged)

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

    returning(text) do |text|
      replace_in_tag_attributes(text, prefix)
      replace_in_tag_content(text, prefix)
      replace_in_rails_helpers(text, prefix)
    end
  end

  def internationalize!(path)
    files = path =~ /.erb$/ ? [path] : Dir.glob("#{path}/**/*.erb")
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
