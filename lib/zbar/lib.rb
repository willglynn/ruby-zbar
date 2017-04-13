module ZBar
  extend FFI::Library

  search_string = '/{opt,usr}/{,local/}lib{,64}/{,x86_64-linux-gnu/,i386-linux-gnu/}libzbar.{dylib,so*}'
  paths =
    Array(
      ENV['ZBAR_LIB'] ||
      Dir[search_string]
      )
  begin
    ffi_lib(*paths)
  rescue LoadError => le
    raise LoadError, [
      "Didn't find libzbar on your system",
      "Searched in \"#{search_string}\"",
      "Please install zbar (http://zbar.sourceforge.net/) or set ZBAR_LIB if it's in a weird place",
      "FFI::Library::ffi_lib() failed with error: #{le}"
    ].join("\n")
  end
  
  attach_function :zbar_symbol_get_type, [:pointer], :int
  attach_function :zbar_symbol_get_data, [:pointer], :string
  attach_function :zbar_symbol_get_type, [:pointer], :int
  attach_function :zbar_symbol_get_quality, [:pointer], :int
  attach_function :zbar_symbol_get_loc_size, [:pointer], :uint
  attach_function :zbar_symbol_get_loc_x, [:pointer, :uint], :int
  attach_function :zbar_symbol_get_loc_y, [:pointer, :uint], :int
  attach_function :zbar_symbol_next, [:pointer], :pointer
  
  attach_function :zbar_image_create, [], :pointer
  attach_function :zbar_image_destroy, [:pointer], :void
  attach_function :zbar_image_first_symbol, [:pointer], :pointer
  attach_function :zbar_image_set_format, [:pointer, :ulong], :void
  attach_function :zbar_image_convert, [:pointer, :ulong], :pointer
  attach_function :zbar_image_get_width, [:pointer], :int
  attach_function :zbar_image_get_height, [:pointer], :int
  attach_function :zbar_image_set_size, [:pointer, :uint, :uint], :void
  attach_function :zbar_image_set_data, [:pointer, :buffer_in, :uint, :pointer], :void
  
  attach_function :zbar_processor_create, [:int], :pointer
  attach_function :zbar_processor_destroy, [:pointer], :void
  attach_function :zbar_processor_init, [:pointer, :string, :int], :int
  attach_function :zbar_processor_set_config, [:pointer, :int, :int, :int], :int
  
  attach_function :zbar_process_image, [:pointer, :pointer], :int
  
  attach_function :zbar_parse_config, [:string, :pointer, :pointer, :pointer], :int
  
  attach_function :zbar_version, [:pointer, :pointer], :int
  attach_function :zbar_set_verbosity, [:int], :void
  attach_function :zbar_get_symbol_name, [:int], :string
  attach_function :zbar_get_addon_name, [:int], :string
  attach_function :_zbar_error_spew, [:pointer, :int], :int

  module Format #:nodoc:
    %w(JPEG Y800 GREY).each { |format|
      const_set(format.to_sym, format.unpack('V')[0])
    }
  end
  
  # Sets the verbosity of the underlying ZBar library, which writes
  # directly to stderr.
  def self.verbosity=(v)
    zbar_set_verbosity(v.to_i)
  end
end
