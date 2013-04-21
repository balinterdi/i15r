require 'highline/import'

class I15R
  class Console

    def initialize()

    end

    def edit_merge(key, original_value, merge_value)
      display <<-EOF

Merge options for #{color :cyan, key}:
#{color :red, "(1)Original file: #{merge_value}"}
#{color :green, "(2)New input: #{original_value}"}
EOF
      selection = ask("Please choose or enter a new value") do |q| q.default = '1' end
      case selection
      when '1' then merge_value
      when '2' then original_value
      else selection
      end
    end

    def edit_key(key, value)
      display <<-EOF

Key options for #{color :cyan, key}
with value: #{color :green, value}
EOF
      choices = key_prompts(key)
      choices.each_with_index do |p, i|
        display "(#{i + 1}) #{p}"
      end
      selection = ask("Please choose a key or enter one manually") do |q| q.default = '1' end

      if (1..choices.size).include? selection.to_i
        choices[selection.to_i - 1]
      else
        selection
      end
    end

    def show_diff(old_data, new_data)
      display <<-EOF

- #{color :red, old_data}
+ #{color :green, new_data}
EOF
    end

    def display(string)
      puts string
    end

    private

    # array of prompts, leaving the first and last item intact
    def key_prompts(key)
      keylist = key.split('.')
      choices = []
      until keylist.length <= 1
        choices << keylist.join('.')
        keylist.delete_at(-2)
      end
      choices
    end

    def color(color, string)
      c = case color
          when :red then "\x1b[31m"
          when :green then "\x1b[32m"
          when :cyan then "\x1b[36m"
          end
      "#{c}#{string}\x1b[0m"
    end

  end
end
