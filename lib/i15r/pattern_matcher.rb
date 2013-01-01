require 'i15r/pattern_matchers/base'
require 'i15r/pattern_matchers/erb'
require 'i15r/pattern_matchers/haml'

class I15R
  class PatternMatcher
    HAML_SYMBOLS = ["%", "#", "{", "}", "(", ")"]
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
      @transformer = self.class.const_get("#{file_type.to_s.capitalize}Transformer").new
    end

    def i18n_string(text)
      #TODO: downcase does not work properly for accented chars, like 'Ú', see function in ActiveSupport that deals with this
      #TODO: [:punct:] would be nice but it includes _ which we don't want to remove
      key = text.strip.downcase.gsub(/[\s\/]+/, '_').gsub(/[!?.,:"';()]/, '')
      "#{@prefix}.#{key}"
    end

    def run(text)
      lines = text.split("\n")
      new_lines = lines.map do |line|
        old_line = line.dup
        new_line = PATTERNS[@file_type].each_with_object(line) do |pattern, transformed_line|
          if m = pattern.match(transformed_line)
            m.names.each do |group_name|
              if /\w/.match(m[group_name])
                @transformer.transform(m, m[group_name], transformed_line, i18n_string(m[group_name]))
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

    class ErbTransformer

      def transform(match_data, match, line, i18n_string)
        if match_data.to_s.index("<%")
          line.gsub!(match, %(I18n.t("#{i18n_string}")))
        else
          line.gsub!(match, %(<%= I18n.t("#{i18n_string}") %>))
        end
      end

    end

    class HamlTransformer
      HAML_START_SYMBOLS = ["%", "#"]
      HAML_EVAL = '='

      def transform(match_data, match, line, i18n_string)
        if HAML_START_SYMBOLS.any? { |s| line.index(s) }
          first_space = line.index(/\s+/)
          open_paren = line.index('(')
          open_brace = line.index('{')
          needs_extra_space = false
          haml_eval_index =
            if open_paren or open_brace
              closing_paren = line.index(')')
              closing_brace = line.index('}')
              [closing_paren, closing_brace].max + 1
            else
              first_space
            end
        else
          haml_eval_index = 0
          needs_extra_space = true
        end
        line.insert(haml_eval_index, HAML_EVAL)
        if needs_extra_space
          line.insert(line.index(HAML_EVAL) + 1, ' ')
        end
        line.gsub!(match, %(I18n.t("#{i18n_string}")))
      end
    end

  end
end
