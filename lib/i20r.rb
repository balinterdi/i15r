require "rubygems"

class AppFolderNotFound < Exception; end

class I20r

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
    "#{prefix}.#{text.gsub(/\s/, '_').downcase}"
  end

  def get_content_from(file)
    f = open(File.expand_path(file), "r")
    content = f.read()
    f.close()
    content
  end

  def write_content_to(file, new_content)
    f = open(File.expand_path(file), "w")
    f.write(new_content)
    f.close()
  end

  def write_i18ned_file(file)
    text = get_content_from(file)
    prefix = file_path_to_message_prefix(file)
    i18ned_text = replace_non_i18_messages(text, prefix)
    write_content_to(file, i18ned_text)
  end

  def replace_in_rails_helpers(text, prefix)
    text.gsub!(/<%=\s*link_to\s+['"](.*)['"]\s*/) do |match|
      i18n_string = get_i18n_message_string($1, prefix)
      %(<%= link_to I18n.t("#{i18n_string}"))
    end
  end
  
  def replace_in_tag_content(text, prefix)
    text = text.gsub!(/>\s*(\w+)\s*</) do |match|
      i18n_string = get_i18n_message_string($1, prefix)
      %(><%= I18n.t("#{i18n_string}") %><)
    end    
  end

  def replace_non_i18_messages(text, prefix)
    replace_in_tag_content(text, prefix)
    replace_in_rails_helpers(text, prefix)
    text
  end
  
end

if __FILE__ == $0
  I20r.new.write_i18ned_file(ARGV[0])
end