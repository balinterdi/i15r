module I15R
  class PatternMatcher

    def self.inherited(descendant)
      debugger
      descendant.methods(false).grep /^match/ do |matcher_method|
        descendant.method(matcher_method).call
      end
    end

    def self.matches(pattern, &block)
      instance_variable_set("@matchers", []) if instance_variable_get("@matchers").nil?
      instance_variable_set("@matchers", instance_variable_get("@matchers") + block)
    end

    def self.sub(text, prefix)
      matchers = instance_variable_get("@matchers") || []
      matchers.each do |matcher|
        m = matcher.call(text)
        unless m.nil?
          plain_row, i18ned_row = m
          yield plain_row, i18ned_row if block_given?
          text.gsub!(plain_row, i18ned_row)
        end
      end
      text
    end

  end
end

# require File.join(File.dirname(__FILE__), 'pattern_matchers/tag_attribute_matcher')