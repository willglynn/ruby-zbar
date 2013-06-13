module ZBar
  # Returns a ZBar::LibraryVersion representing the currently loaded library.
  def self.library_version
    @library_version ||= begin
      major = FFI::MemoryPointer.new :uint
      minor = FFI::MemoryPointer.new :uint
      rv = zbar_version(major, minor)
      if rv == 0
        LibraryVersion.new(major.read_uint, minor.read_uint)
      else
        raise "zbar_version failed, returning #{rv}"
      end
    end
  end
  
  # Represents a version of the ZBar library, e.g. as returned by
  # ZBar.library_version.
  class LibraryVersion
    def initialize(major, minor) #:nodoc:
      @major, @minor = major, minor
    end
    
    # Major version number
    attr_reader :major
    
    # Minor version number
    attr_reader :minor
    
    # Compare this version to another LibraryVersion
    def <=>(other)
      [major, minor] <=> [other.major, other.minor]
    end
    
    include Comparable
    
    # Format the library version as a string
    def to_s
      "#{major}.#{minor}"
    end
  end
end
