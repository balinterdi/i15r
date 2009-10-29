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
        i18ned_text = text
        @@matchers.each do |matcher|
          m = matcher.call(text, prefix)
          unless m.nil?
            plain_row, i18ned_row = m
            yield plain_row, i18ned_row if block_given?
            i18ned_text.gsub!(plain_row, i18ned_row)
          end
        end
        i18ned_text
      end
      
      #TODO: use method_added to add to matchers so that
      # matchers do not have to be explicitly registered.
      def self.register_matcher(matcher_method)
        self.method(matcher_method).call
      end
    end
  end
end
