module ZBar
  class Processor
    # Create a new processor.
    def initialize(threads = 0)
      @processor = FFI::AutoPointer.new(
        ZBar.zbar_processor_create(threads),
        ZBar.method(:zbar_processor_destroy)
        )
  
      if ZBar.zbar_processor_init(@processor, nil, 0) > 0
        ZBar._zbar_error_spew(@processor, 0)
        raise "error!"
      end
    end

    # Attempt to recognize barcodes in this image. Raises an exception if ZBar
    # signals an error, otherwise returns an array of ZBar::Symbol objects.
    def process(image)
      raise ArgumentError, "process() operates only on ZBar::Image objects" unless image.kind_of?(ZBar::Image)
      image = image.instance_variable_get(:@img)
  
      if ZBar.zbar_process_image(@processor, image) != 0
        raise ArgumentError, "processing failed"
      end
  
      out = []
  
      sym = ZBar.zbar_image_first_symbol(image)
      until sym.null?
        out << Symbol.new(sym)
        sym = ZBar.zbar_symbol_next(sym)
      end
  
      out
    end
  end
end