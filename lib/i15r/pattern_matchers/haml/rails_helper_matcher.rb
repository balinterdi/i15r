module I15R
  module PatternMatchers
    module Haml
      class RailsHelperMatcher < Base
        def self.match_haml_tag_and_link_to_title
          patt = /^(.*%\w+=\s*)link_to\s+['"](.*?)['"]\s*,(.*)$/
          matches do |text, prefix|
            if m = patt.match(text)
              i18n_string = I15R::Base.get_i18n_message_string(m[2], prefix)
              i18ned_row = %(#{m[1]}link_to I18n.t("#{i18n_string}"),#{m[3]})
              [m[0], i18ned_row]
            end
          end
        end
        register_matcher :match_haml_tag_and_link_to_title

        def self.match_haml_implicit_div_tag_and_link_to_title
          patt = /^(.*#[\w\d\-_]+=\s*)link_to\s+['"](.*?)['"]\s*,(.*)$/
          matches do |text, prefix|
            if m = patt.match(text)
              i18n_string = I15R::Base.get_i18n_message_string(m[2], prefix)
              i18ned_row = %(#{m[1]}link_to I18n.t("#{i18n_string}"),#{m[3]})
              [m[0], i18ned_row]
            end
          end
        end
        register_matcher :match_haml_implicit_div_tag_and_link_to_title
        
        def self.match_haml_label_helper_text
          patt = /^(.*=.*\.label.*,\s*)['"](.*?)['"](.*)$/
          matches do |text, prefix|
            if m = patt.match(text)
              i18n_string = I15R::Base.get_i18n_message_string(m[2], prefix)
              i18ned_row = %(#{m[1]}I18n.t("#{i18n_string}"))
              [m[0], i18ned_row]
            end
          end
        end
        register_matcher :match_haml_label_helper_text

      end

    end
  end
end