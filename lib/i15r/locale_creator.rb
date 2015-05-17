require 'yaml'

class I15R
  class LocaleCreator
    def initialize(file_name = nil)
      @file_name = file_name
      @structure = LocaleStructure.new
    end

    def add(path, value)
      if @file_name
        @structure.add(path, value)
      end
    end

    def save_file
      if @file_name
        yaml = @structure.to_yaml(:en)
        File.write("#{@file_name}.yml", yaml)
      end
    end

    class LocaleStructure
      attr_reader :structure

      def initialize
        @structure = {}
      end

      def add(path, value)
        keys = path.dup.split('.')

        h = nested_hash_for(keys, value)

        @structure = deep_merge(self.structure, h)
      end

      def to_yaml(language)
        { language.to_s => @structure }.to_yaml
      end

      private

      def nested_hash_for(keys, value)
        if keys.size == 1
          { keys.delete_at(0) => value }
        else
          { keys.delete_at(0) => nested_hash_for(keys, value) }
        end
      end

      def deep_merge(hash, other_hash)
        other_hash.each_pair do |current_key, other_value|
          this_value = hash[current_key]

          hash[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
            deep_merge(this_value, other_value)
          else
            other_value
          end
        end

        hash
      end
    end
  end
end
