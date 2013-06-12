module ZBar
  
  # Encapsulates a ZBar Image data structure.
  class Image
    # Instantiates a new Image object, either by creating an empty one,
    # or wrapping the supplied pointer.
    def initialize(pointer=nil)
      @img = FFI::AutoPointer.new(
        pointer || ZBar.zbar_image_create,
        ZBar.method(:zbar_image_destroy)
        )
    end
    
    # Instantiates an Image given JPEG data.
    #
    # This function uses the internal ZBar conversion function to decode the JPEG
    # and convert it into a greyscale image suitable for further processing.
    # This conversion may fail if ZBar was not built with <tt>--with-jpeg</tt>.
    def self.from_jpeg(io_or_string)
      if io_or_string.respond_to?(:read)
        io_or_string = io_or_string.read
      end
      
      jpeg_image = new()
      jpeg_image.set_data(ZBar::Format::JPEG, io_or_string)
      return jpeg_image.convert(ZBar::Format::Y800)
    end
  
    # Instantiates an Image given raw PGM data.
    #
    # PGM is a NetPBM format, encoding width, height, and greyscale data, one byte
    # per pixel. It is therefore ideally suited for loading into ZBar, which
    # operates natively on Y800 pixel data--identical to the data section of a PGM
    # file.
    #
    # The data is described in greater detail at
    # http://netpbm.sourceforge.net/doc/pgm.html.
    def self.from_pgm(io_or_string)
      if io_or_string.respond_to?(:read)
        string = io_or_string.read
      else
        string = io_or_string
      end
      
      # Ensure we're in binary mode
      if string.respond_to? :force_encoding
        string.force_encoding 'binary'
      end
      
      image_data = string.gsub(/^(P5)\s([0-9]+)\s([0-9]+)\s([0-9]+)\s/, '')
      if $1 != 'P5'
        raise ArgumentError, "input must be a PGM file"
      end
    
      width, height, max_val = $2.to_i, $3.to_i, $4.to_i
    
      if max_val != 255
        raise ArgumentError, "maximum value must be 255"
      end
    
      image = new()
      image.set_data(ZBar::Format::Y800, image_data, width, height)
      image
    end

    # Load arbitrary data from a string into the Image object.
    #
    # Format must be a ZBar::Format constant. See the ZBar documentation
    # for what formats are supported, and how the data should be formatted.
    #
    # Most everyone should use one of the <tt>Image.from_*</tt> methods instead.
    def set_data(format, data, width=nil, height=nil)
      ZBar.zbar_image_set_format(@img, format)
      
      # Note the @buffer jog: it's to keep Ruby GC from losing the last
      # reference to the old @buffer before calling image_set_data.
      new_buffer = FFI::MemoryPointer.from_string(data)
      ZBar.zbar_image_set_data(@img, new_buffer, data.size, nil)
      @buffer = new_buffer
      
      if width && height
        ZBar.zbar_image_set_size(@img, width.to_i, height.to_i)
      end
    end
    
    # Ask ZBar to convert this image to a new format, returning a new Image.
    #
    # Not all conversions are possible: for example, if ZBar was built without
    # JPEG support, it cannot convert JPEGs into anything else.
    def convert(format)
      ptr = ZBar.zbar_image_convert(@img, format)
      if ptr.null?
        raise ArgumentError, "conversion failed"
      else
        Image.new(ptr)
      end
    end
    
    # Attempt to recognize barcodes in this image, using the supplied processor
    # or processor configuration (if any), falling back to defaults.
    #
    # Returns an array of ZBar::Symbol objects.
    def process(processor_or_config = nil)
      if processor_or_config.respond_to?(:process)
        processor = processor_or_config
      elsif processor_or_config.nil?
        processor = Processor.new
      else
        processor = Processor.new(processor_or_config)
      end

      processor.process(self)
    end
    
    # Retrieve the image's width in pixels
    def width
      ZBar.zbar_image_get_width(@img)
    end
    
    # Retrieve the image's height in pixels
    def height
      ZBar.zbar_image_get_height(@img)
    end
  end

end