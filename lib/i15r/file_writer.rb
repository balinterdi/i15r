class I15R
  class FileWriter
    def write(path, content)
      open(File.expand_path(path), "w") { |f| f.write(content) }
    end
  end
end
