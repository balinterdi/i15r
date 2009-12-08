module I15R
  module PatternMatchers
    module Haml
      class RailsHelperMatcher < Base
        def self.match_haml_tag_and_link_to_title
          #TODO: allow parens around link_to arguments
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
          #TODO: allow parens around link_to arguments
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

        def self.match_haml_text_and_link_to_with_parens
          # that's good for the parentheses version
          patt = /^(.*=)(.*)#\{link_to\(['"](.*?)['"],(\s*[\w_]+)\)\}.*$/
          matches do |text, prefix|
            if m = patt.match(text)
              pre_text = I15R::Base.get_i18n_message_string(m[2], prefix)
              link_to_title = I15R::Base.get_i18n_message_string(m[3], prefix)
              i18ned_row = %(#{m[1]} I18n.t("#{pre_text}", :link => link_to(I18n.t("#{link_to_title}"),#{m[4]})#{m[5]}))
              [m[0], i18ned_row]
            end
          end
          # %q(= "I accept the #{link_to 'terms and conditions', terms_and_conditions_path}"
          # = I18n.t("users.new.i_accept_the", :link => link_to(I18n.t("users.new.terms_and_conditions"), terms_and_conditions_path))
        end
        register_matcher :match_haml_text_and_link_to_with_parens
        
        def self.match_haml_text_and_link_to_without_parens
          # that's good for the parentheses version
          patt = /^(.*=)(.*)#\{link_to\s+['"](.*?)['"],(\s*[\w_]+)\}.*$/
          matches do |text, prefix|
            if m = patt.match(text)
              pre_text = I15R::Base.get_i18n_message_string(m[2], prefix)
              link_to_title = I15R::Base.get_i18n_message_string(m[3], prefix)
              i18ned_row = %(#{m[1]} I18n.t("#{pre_text}", :link => link_to(I18n.t("#{link_to_title}"),#{m[4]})#{m[5]}))
              [m[0], i18ned_row]
            end
          end
        end
        register_matcher :match_haml_text_and_link_to_without_parens
        
        
      end

    end
  end
end