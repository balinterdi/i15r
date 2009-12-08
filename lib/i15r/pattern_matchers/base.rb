module I15R
  module PatternMatchers
    class Base
      # def self.inherited(descendant)
      #   descendant.methods(false).grep /^match/ do |matcher_method|
      #     descendant.method(matcher_method).call
      #   end
      # end

      def self.matches(&block)
        @@matchers ||= []
        @@matchers.push(block)
      end

      def self.run(text, prefix)
        lines = text.split("\n")
        i18ned_lines = lines.map do |line|
          @@matchers.inject(line) do |i18ned_line, matcher|
            m = matcher.call(i18ned_line, prefix)
            unless m.nil?
              row_before_match, row_after_match = m
              yield row_before_match, row_after_match if block_given?
              row_after_match
            else
              i18ned_line
            end
          end
        end
        i18ned_lines.join("\n")
      end
      
      #TODO: use method_added to add to matchers so that
      # matchers do not have to be explicitly registered.
      def self.register_matcher(matcher_method)
        self.method(matcher_method).call
      end
    end
  end
end
