require File.join(File.dirname(__FILE__), '..', 'pattern_matcher')

module I15R
  class TagAttributeMatcher < PatternMatcher

    def self.match_title_attribute
      puts "XXX Called!"
      patt = /^(.*)(<a\s+.*title=)['"](.*?)['"](.*)/
      matches(patt) do |text|
        if m = patt.match(text)
          i18n_string = I15R::Base.get_i18n_message_string(m[3], prefix)
          i18ned_row = %(#{m[1]}#{m[2]}"<%= I18n.t("#{i18n_string}") %>#{m[4]})
          [m, i18ned_row]
        end
      end
    end
  end
end
