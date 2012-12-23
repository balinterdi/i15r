class I15R
  module PatternMatchers
    module Erb
      class TagAttributeMatcher < Base

        def self.run(text, prefix)
          super(text, prefix, :erb)
        end

        def self.match_title_attribute
          patt = /^(.*)(<a\s+.*title=)['"](.*?)['"](.*)/
          matches(:erb) do |text, prefix|
            if m = patt.match(text)
              i18n_string = I15R.get_i18n_message_string(m[3], prefix)
              i18ned_row = %(#{m[1]}#{m[2]}"<%= I18n.t("#{i18n_string}") %>"#{m[4]})
              [m[0], i18ned_row]
            end
          end
        end
        register_matcher :match_title_attribute
      end
    end
  end
end
