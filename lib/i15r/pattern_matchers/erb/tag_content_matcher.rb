require 'i15r/base'

module I15R
  module PatternMatchers
    module Erb
      class TagContentMatcher < Base
        
        def self.run(text, prefix)
          super(text, prefix, :erb)
        end
        
        def self.match_tag_content_on_one_line
          patt = /^(.*)>(\s*)([[:alnum:][:upper:]][\s[:alnum:][:upper:][:punct:]]+)\s*<\/(.*)$/i
          matches(:erb) do |text, prefix|
            if m = patt.match(text)
              i18n_string = I15R::Base.get_i18n_message_string(m[3], prefix)
              ending_punctuation = m[3][/([?.!:\s]*)$/, 1]
              i15d_row = %(#{m[1]}>#{m[2]}<%= I18n.t("#{i18n_string}") %>#{ending_punctuation.to_s}</#{m[4]})
              [m[0], i15d_row]
            end
          end
        end
        register_matcher :match_tag_content_on_one_line

        def self.match_tag_content_multiline
          patt = /^(\s*)([[:alnum:][:upper:]][[:alnum:][:upper:][:space:],']*)(.*)$/i
          matches(:erb) do |text, prefix|
            if m = patt.match(text)
              i18n_string = I15R::Base.get_i18n_message_string(m[2], prefix)
              i15d_row = %(#{m[1]}<%= I18n.t("#{i18n_string}") %>#{m[3]})
              [m[0], i15d_row]
            end
          end
        end
        register_matcher :match_tag_content_multiline

      end
    end
  end
end