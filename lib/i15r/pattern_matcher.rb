require 'i15r/pattern_matchers/base'
require 'i15r/pattern_matchers/erb'
require 'i15r/pattern_matchers/haml'

class I15R
  class PatternMatcher
    HAML_SYMBOLS = ["%", "#", "{", "}", "(", ")", ".", "_", "-"]
    PATTERNS = {
      :erb => [
        />(?<tag-content>[[:space:][:alnum:][:punct:]]+?)<\//,
        /<a\s+title=['"](?<link-title>.+?)['"]/,
        /(?<pre-tag-text>[[:alnum:]]+[[:alnum:][:space:][:punct:]]*?)</,
        /<%=\s*link_to\s+(?<title>['"].+?['"])/,
        /<%=.*label(_tag)?.*,\s*(?<label-title>['"].+?['"])/,
        /<%=.*submit(_tag)?\s+(?<submit-text>['"].+?['"])/
      ],
      :haml => [
        %r{^\s*(?<content>[[:space:][:alnum:]'/(),]+)$},
        %r{^\s*[[#{HAML_SYMBOLS.join('')}][:alnum:]]+?\s+(?<content>.+)$},
        %r{=.*link_to\s+(?<title>['"].+?['"]),},
        %r{=.*label(_tag)?.*,\s*(?<label-title>['"].+?['"])},
        %r{=.*submit(_tag)?\s+(?<submit-text>['"].+?['"])}
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
        new_line = PATTERNS[@file_type].each_with_object([line]) do |pattern, transformed_lines|
          l = transformed_lines.last
          if m = pattern.match(l)
            m.names.each do |group_name|
              if /\w/.match(m[group_name])
                transformed_lines << @transformer.transform(pattern, m, m[group_name], l, i18n_string(m[group_name]))
              end
            end
          end
        end.last
        if block_given? and old_line != new_line
          yield old_line, new_line
        end
        new_line
      end
      new_lines.join("\n")
    end

    class ErbTransformer

      def transform(pattern, match_data, match, line, i18n_string)
        if match_data.to_s.index("<%")
          line.gsub(match, %(I18n.t("#{i18n_string}")))
        else
          line.gsub(match, %(<%= I18n.t("#{i18n_string}") %>))
        end
      end

    end

    class HamlTransformer

      def transform(pattern, match_data, match, line, i18n_string)
        no_leading_whitespace = line.gsub(/^\s+/, '')
        if ['/', '-'].include?(no_leading_whitespace[0])
          return line
        end

        # Space can only occur in haml markup in an attribute list
        # enclosed in { } or ( ). If the first segment has { or (
        # we are still in the markup and need to go on to find the beginning
        # of the string to be replaced
        i = 0
        haml_segment = true
        attribute_list_start = nil
        segments = line.split(/\s+/)
        while haml_segment
          s = segments[i]
          if attribute_list_start
            attribute_list_end = [')', '}'].detect { |sym| s.index(sym) }
            if attribute_list_end
              haml_segment = false
            end
          else
            attribute_list_start = ['(', '{'].detect { |sym| s.index(sym) }
            unless attribute_list_start
              haml_segment = false
            end
            i += 1
          end
        end

        until_first_whitespace = segments[0...i].join(' ')
        if HAML_SYMBOLS.any? { |sym| until_first_whitespace.index(sym) }
          haml_markup = until_first_whitespace
          content = segments[i...segments.size].join(' ')
          if haml_markup.index('=')
            haml_markup += ' '
          else
            haml_markup += '= '
          end
        else
          haml_markup = ''
          content = line
          unless no_leading_whitespace[0] == '='
            first_non_whitespace = content.size - no_leading_whitespace.size
            content.insert(first_non_whitespace, '= ')
          end
        end

        new_line = haml_markup + content
        new_line.gsub(match, %(I18n.t("#{i18n_string}")))

      end
    end

  end
end
