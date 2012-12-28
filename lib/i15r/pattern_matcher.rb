require 'i15r/pattern_matchers/base'
require 'i15r/pattern_matchers/erb'
require 'i15r/pattern_matchers/haml'

class I15R
  class PatternMatcher
    # TODO: Introduce ErbMatcher and HamlMatcher so that all the ugly
    # conditionals with :erb and :haml go away
    HAML_SYMBOLS = ["%", "#", "{", "}", "(", ")"]
    HAML_START_SYMBOLS = ["%", "#"]
    HAML_EVAL = '='
    PATTERNS = {
      :erb => [
        />(?<tag-content>[[:space:][:alnum:][:punct:]]+?)<\//,
        /<a\s+title=['"](?<link-title>.+?)['"]/,
        /(?<pre-tag-text>[[:alnum:]]+[[:alnum:][:space:][:punct:]]*?)</,
        /<%=\s*link_to\s+(?<title>['"].+?['"])/,
        /<%=.*label(_tag)?.*,\s*(?<label-title>['"].+?['"])/,
        /<%=.*submit(_tag)?.*(?<submit-text>['"].+?['"])/
      ],
      :haml => [
        /[%#].+?\s+(?<content>.+)/,
        %r{^\s*(?<content>[[:alnum:][:space:][^#{HAML_SYMBOLS.join('')}]]+)$}
      ]
    }

    def initialize(prefix, file_type)
      @prefix = prefix
      @file_type = file_type
    end

    def run(text)
      lines = text.split("\n")
      new_lines = lines.map do |line|
        old_line = line.dup
        new_line = PATTERNS[@file_type].each_with_object(line) do |pattern, transformed_line|
          if m = pattern.match(transformed_line)
            m.names.each do |group_name|
              if /\w/.match(m[group_name])
                i18n_string = I15R.get_i18n_message_string(m[group_name], @prefix)
                if @file_type == :erb
                  if m.to_s.index("<%")
                    transformed_line.gsub!(m[group_name], %(I18n.t("#{i18n_string}")))
                  else
                    transformed_line.gsub!(m[group_name], %(<%= I18n.t("#{i18n_string}") %>))
                  end
                elsif @file_type == :haml
                  first_space = transformed_line.index(/\s+/)
                  open_paren = transformed_line.index('(')
                  open_brace = transformed_line.index('{')
                  if HAML_START_SYMBOLS.any? { |s| transformed_line.index(s) }
                    needs_extra_space = false
                    haml_eval_index =
                      if open_paren or open_brace
                        closing_paren = transformed_line.index(')')
                        closing_brace = transformed_line.index('}')
                        [closing_paren, closing_brace].max + 1
                      else
                        first_space
                      end
                  else
                    haml_eval_index = 0
                    needs_extra_space = true
                  end
                  transformed_line.insert(haml_eval_index, HAML_EVAL)
                  if needs_extra_space
                    transformed_line.insert(transformed_line.index(HAML_EVAL) + 1, ' ')
                  end
                  transformed_line.gsub!(m[group_name], %(I18n.t("#{i18n_string}")))
                end
              end
            end
          end
        end
        if block_given? and old_line != new_line
          yield old_line, new_line
        end
        new_line
      end
      new_lines.join("\n")
    end

  end
end
