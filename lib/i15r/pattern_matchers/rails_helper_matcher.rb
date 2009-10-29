require 'i15r/base'

module I15R
  module PatternMatchers
    class RailsHelperMatcher < Base

      def self.match_link_to_title
        patt = /^(.*)<%=\s*link_to\s+['"](.*?)['"]\s*,(.*)%>(.*)$/
        matches do |text, prefix|
          if m = patt.match(text)
            i18n_string = I15R::Base.get_i18n_message_string(m[2], prefix)
            i18ned_row = %(#{m[1]}<%= link_to I18n.t("#{i18n_string}"),#{m[3]}%>#{m[4]})
            [m[0], i18ned_row]
          end
        end
      end
      register_matcher :match_link_to_title

      def self.match_label_helper_text
        patt = /^(.*)<%=(.*)\.label(.*),\s*['"](.*?)['"]\s*%>(.*)$/
        matches do |text, prefix|
          if m = patt.match(text)
            i18n_string = I15R::Base.get_i18n_message_string(m[4], prefix)
            i18ned_row = %(#{m[1]}<%=#{m[2]}.label#{m[3]}, I18n.t("#{i18n_string}") %>#{m[5]})
            [m[0], i18ned_row]
          end
        end
      end
      register_matcher :match_label_helper_text

      def self.match_label_tag_helper_text
        patt = /^(.*)<%=(.*)label_tag (.*),\s*['"](.*?)['"]\s*%>(.*)$/
        matches do |text, prefix|
          if m = patt.match(text)
            i18n_string = I15R::Base.get_i18n_message_string(m[4], prefix)
            i18ned_row = %(#{m[1]}<%=#{m[2]}label_tag #{m[3]}, I18n.t("#{i18n_string}") %>#{m[5]})
            [m[0], i18ned_row]
          end
        end
      end
      register_matcher :match_label_tag_helper_text

      def self.match_submit_helper_text
        patt = /^(.*)<%=(.*)\.submit\s*['"](.*?)['"]\s*%>(.*)$/
        matches do |text, prefix|
          if m = patt.match(text)
            i18n_string = I15R::Base.get_i18n_message_string(m[3], prefix)
            i18ned_row = %(#{m[1]}<%=#{m[2]}.submit I18n.t("#{i18n_string}") %>#{m[4]})
            [m[0], i18ned_row]
          end
        end
      end
      register_matcher :match_submit_helper_text

      def self.match_submit_tag_helper_text
        patt = /^(.*)<%=\s*submit_tag\s*['"](.*?)['"]\s*%>(.*)$/
        matches do |text, prefix|
          if m = patt.match(text)
            i18n_string = I15R::Base.get_i18n_message_string(m[2], prefix)
            i18ned_row = %(#{m[1]}<%= submit_tag I18n.t("#{i18n_string}") %>#{m[3]})
            [m[0], i18ned_row]
          end
        end
      end
      register_matcher :match_submit_tag_helper_text

    end
  end
end
