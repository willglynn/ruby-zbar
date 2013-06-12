module FileHelpers
  def file_path(filename)
    File.dirname(__FILE__) + "/" + filename
  end
  
  def open_file(filename, &block)
    File.open(file_path(filename), 'rb', &block)
  end
  
  def read_file(filename)
    open_file(filename, &:read)
  end
end
