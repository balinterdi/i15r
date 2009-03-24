require "rubygems"

class I20r
  
  def file_path_to_message_prefix(path)
    segments = path.split('/').select { |segment| !segment.empty? }
    file_name_without_extensions = segments.last.split('.').first
    segments.slice(2...-1).join('.') + '.' + file_name_without_extensions
  end
  
  def get_i18n_message_string(text, prefix)
    "#{prefix}.#{text.downcase}"
  end
  
  def get_content_from(file)
    f = open(File.expand_path(file), "r")
    content = f.read()
    f.close()
    content
  end
  
  def replace_non_i18_messages(file)
    content = get_content_from(file)
    prefix = file_path_to_message_prefix(file)
    content.gsub(/>\s*(\w+)\s*</) do |match|
      i18n_string = get_i18n_message_string($1, prefix)
      %(><%= I18n.t("#{i18n_string}") %><)
    end
  end
end