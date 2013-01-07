class I15R
  class ConsolePrinter
    def println(text)
      puts text
    end

    def print_diff(old_row, new_row)
      puts "- #{old_row}"
      puts "+ #{new_row}"
      puts
    end
  end
end
