module ZBar
  class Processor
    # Create a new processor.
    # Accepts a hash of configurations
    def initialize(config = nil)
      # This function used to accept an integer refering to the number of threads
      if config.kind_of?(Integer)
        config = { :threads => config }
      end
      
      config ||= {}
      
      @processor = FFI::AutoPointer.new(
        ZBar.zbar_processor_create(config[:threads] || 0),
        ZBar.method(:zbar_processor_destroy)
        )
  
      if ZBar.zbar_processor_init(@processor, nil, 0) > 0
        ZBar._zbar_error_spew(@processor, 0)
        raise "error!"
      end
      
      config.each { |key,value|
        if key == :threads
          # do nothing; we handled this above
        else
          setter = "#{key}=".to_sym
          if respond_to?(setter)
            send(setter, value)
          else
            raise ArgumentError, "unsupported configuration option: #{key}"
          end
        end
      }
    end
    
    # Indicates that this processor should only search for the indicated symbologies.
    # Accepts an array of the following symbologies, specified as a string or symbol:
    # - qrcode
    # - upca
    # - upce
    # - ean13
    # - ean8
    # - i25
    # - scanner
    # - isbn13
    # - isbn10
    # - code39
    # - pdf417
    # - code128
    def symbologies=(symbologies)
      self.zbar_config = ["disable"] + symbologies.map { |sym| "#{sym}.enable" }
      true
    end
    
    # Indicates that this processor should only search for the indicated symbology.
    # See #symbologies= for details.
    def symbology=(symbology)
      self.symbologies = [symbology]
    end
    
    # Configures this processor using the specified configuration string. See
    # zbar_parse_config (zbar/config.c) for supported values.
    def zbar_config=(config_value)
      case config_value
      when String
        symbology = FFI::MemoryPointer.new :int
        config_t = FFI::MemoryPointer.new :int
        value = FFI::MemoryPointer.new :int
      
        if ZBar.zbar_parse_config(config_value, symbology, config_t, value) == 0
          # parsed successfully
          if ZBar.zbar_processor_set_config(@processor, symbology.read_int, config_t.read_int, value.read_int) == 0
            true
          else
            raise ArgumentError, "config string #{config_value.inspect} parsed but could not be set"
          end
        else
          raise ArgumentError, "config string #{config_value.inspect} was not recognized"
        end
        
      when Enumerable
        config_value.each { |value|
          self.zbar_config = value
        }
        
      else
        raise ArgumentError, "unsupported config value"
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
