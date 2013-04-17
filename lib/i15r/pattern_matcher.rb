# -*- coding: utf-8 -*-
class I15R
  class PatternMatcher
    HAML_SYMBOLS = ["%", "#", "{", "}", "(", ")", ".", "_", "-"]
    PATTERNS = {
      :erb => [
        /<%=\s*link_to\s+(?<title>['"].+?['"])/,
        /<%=.*label(_tag)?[^,]+?(?<label-title>(['"].+?['"]|:[[:alnum:]_]+))[^,]+%>.*$/,
        /<%=.*label(_tag)?.*?,\s*(?<label-title>(['"].+?['"]|:[[:alnum:]_]+))/,
        /<%=.*submit(_tag)?\s+(?<submit-text>(['"].+?['"]|:[[:alnum:]_]+))/,
        />(?<tag-content>[[:space:][:alnum:][:punct:]]+?)<\//,
        /<a\s+title=['"](?<link-title>.+?)['"]/,
        /^\s*(?<pre-tag-text>[[:alnum:]]+[[:alnum:][:space:][:punct:]]*?)</,
        /^\s*(?<no-markup-content>[[:alnum:]]+[[:alnum:][:space:][:punct:]]*)/
      ],
      :haml => [
        /=.*link_to\s+(?<title>['"].+?['"]),/,
        /=.*label(_tag)?[^,]+?(?<label-title>(['"].+?['"]|:[[:alnum:]_]+))[^,]*$/,
        /=.*label(_tag)?.*?,\s*(?<label-title>(['"].+?['"]|:[[:alnum:]_]+))/,
        /=.*submit(_tag)?\s+(?<submit-text>(['"].+?['"]|:[[:alnum:]_]+))/,
        %r{^\s*(?<content>[[:space:][:alnum:]'/(),]+)$},
        %r{^\s*[[#{HAML_SYMBOLS.join('')}][:alnum:]]+?\{.+?\}\s+(?<content>.+)$},
        %r{^\s*[[#{HAML_SYMBOLS.join('')}][:alnum:]]+?\(.+?\)\s+(?<content>.+)$},
        %r{^\s*[[#{(HAML_SYMBOLS - ['{', '}', '(', ')']).join('')}][:alnum:]]+?\s+(?<content>.+)$}
      ]
    }

    def initialize(prefix, file_type, options={})
      @prefix = prefix
      @file_type = file_type
      transformer_class = self.class.const_get("#{file_type.to_s.capitalize}Transformer")
      @transformer = transformer_class.new(options[:add_default], options[:override_i18n_method] || 'I18n.t')
    end

    def translation_key(text)
      #TODO: downcase does not work properly for accented chars, like 'Ú', see function in ActiveSupport that deals with this
      #TODO: [:punct:] would be nice but it includes _ which we don't want to remove
      key = text.strip.downcase.gsub(/[\s\/]+/, '_').gsub(/[!?.,:"';()#\/\\]/, '')
      "#{@prefix}.#{key}"
    end

    def run(text)
      lines = text.split("\n")
      new_lines = lines.map do |line|
        new_line = line
        m, key, match, string = nil
        PATTERNS[@file_type].detect do |pattern|
          if m = pattern.match(line)
            m.names.each do |group_name|
              if /\w/.match(m[group_name])
                match = m[group_name]
                key = translation_key(match)
                new_line = @transformer.transform(m, match, line, key)
              end
            end
          end
        end
        if block_given? and line != new_line
          changed_key = yield line, new_line, key, add_quotes(match)
          # retransform, if key changed
          if changed_key != key
            new_line = @transformer.transform(m, match, line, changed_key)
          end
        end
        new_line
      end
      new_lines.join("\n")
    end

    def add_quotes(string)
      m = /\A[\'\"]?(.*?)[\'\"]?\Z/.match(string)
      "\"#{m[1]}\""
    end

    class Transformer
      def initialize(add_default, i18n_method)
        @add_default = add_default
        @i18n_method = i18n_method
      end

      private
        def i18n_string(key, original)
          if @add_default
            if original.to_s[0] == ':'
              original = original.to_s[1..-1]
            end
            unless original[0] == "'" or original[0] == '"'
              original = %("#{original}")
            end
            %(#{@i18n_method}("#{key}", :default => #{original}))
          else
            %(#{@i18n_method}("#{key}"))
          end
        end
    end

    class ErbTransformer < Transformer

      def transform(match_data, match, line, translation_key)
        return line if line.match /\bt\(/
        if match_data.to_s.index("<%")
          line.gsub(match, i18n_string(translation_key, match))
        else
          line.gsub(match, "<%= #{i18n_string(translation_key, match)} %>")
        end
      end

    end

    class HamlTransformer < Transformer

      def transform(match_data, match, line, translation_key)
        return line if line.match /\bt\(/
        leading_whitespace = line[/^(\s+)/, 1]
        no_leading_whitespace = if leading_whitespace
          line[leading_whitespace.size..-1]
        else
          line
        end
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
        segments = no_leading_whitespace.split(/\s+/)
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
          end
          i += 1
        end

        until_first_whitespace = segments[0...i].join(' ')
        if HAML_SYMBOLS.any? { |sym| until_first_whitespace.index(sym) }
          haml_markup = until_first_whitespace
          content = segments[i..-1].join(' ')
          if haml_markup[-1] == '='
            haml_markup += ' '
          else
            haml_markup += '= '
          end
        else
          haml_markup = ''
          content = no_leading_whitespace
          content.insert(0, '= ') unless content[0] == '='
        end

        new_line = (leading_whitespace or '') + haml_markup + content
        new_line.gsub(match.gsub(/\s+$/, ''), i18n_string(translation_key, match))
      end
    end

  end
end
