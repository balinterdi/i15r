require 'i15r/base'

module I15R
  module PatternMatchers
    module Erb
      class TagContentMatcher < Base
        def self.match_tag_content
          patt = /^(.*)>(\s*)(\w[\s\w:'"!?\.,]+)\s*<\/(.*)$/
          matches do |text, prefix|
            if m = patt.match(text)
              i18n_string = I15R::Base.get_i18n_message_string(m[3], prefix)
              ending_punctuation = m[3][/([?.!:\s]*)$/, 1]
              i18ned_row = %(#{m[1]}>#{m[2]}<%= I18n.t("#{i18n_string}") %>#{ending_punctuation.to_s}</#{m[4]})
              [m[0], i18ned_row]
            end
          end
        end
        register_matcher :match_tag_content
      end
    end
  end
end