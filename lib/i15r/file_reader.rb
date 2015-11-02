class I15R
  class FileReader
    def read(file)
      File.read(File.expand_path(file)).force_encoding("UTF-8")
    end
  end
end
