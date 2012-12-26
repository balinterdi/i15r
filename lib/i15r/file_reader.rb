class I15R
  class FileReader
    def read(file)
      File.read(File.expand_path(file))
    end
  end
end
