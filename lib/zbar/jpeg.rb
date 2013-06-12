# zbar-0.10 has a problem handling certain JPEGs:
# * http://sourceforge.net/p/zbar/discussion/664596/thread/58b8d79b
# * https://github.com/willglynn/ruby-zbar/issues/2
#
# This is a problem in the underlying C library. It is fixed in zbar's source
# control repository, but an updated package has not yet been released.
#
# If this affects you, ask whoever compiled your libzbar to apply this patch:
# https://gist.github.com/willglynn/5659946

module ZBar::JPEG
  # Is JPEG support available?
  def self.available?
    if @available.nil?
      @available = image_works?(WorkingBits)
    end
    
    @available
  end
  
  # Is JPEG support bugged?
  # See https://github.com/willglynn/ruby-zbar/issues/2 for details.
  def self.bugged?
    if @bugged.nil?
      @bugged = available? && !image_works?(BuggedBits)
    end
    
    @bugged
  end
  
  def self.warn_once_if_bugged #:nodoc:
    @warn_attempted ||= begin
      if bugged?
        STDERR.print "Your libzbar has a JPEG bug. Some images will fail to process correctly.\nSee: https://github.com/willglynn/ruby-zbar/blob/master/lib/zbar/jpeg.rb\n"
      end
      true
    end
  end

  protected
  WorkingBits = "\377\330\377\340\000\020JFIF\000\001\001\000\000\001\000\001\000\000\377\333\000C\000\e\032\032)\035)A&&AB///BG?>>?GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG\377\333\000C\001\035))4&4?((?G?5?GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG\377\300\000\021\b\000\b\000\b\003\001\"\000\002\021\001\003\021\001\377\304\000\025\000\001\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\006\377\304\000\024\020\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\377\304\000\024\001\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\377\304\000\024\021\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\377\332\000\f\003\001\000\002\021\003\021\000?\000\246\000\037\377\331"
  BuggedBits = "\377\330\377\340\000\020JFIF\000\001\002\000\000d\000d\000\000\377\354\000\021Ducky\000\001\000\004\000\000\000\000\000\000\377\356\000\016Adobe\000d\300\000\000\000\001\377\333\000\204\000\e\032\032)\035)A&&AB///BG?>>?GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG\001\035))4&4?((?G?5?GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG\377\300\000\021\b\000\b\000\b\003\001\"\000\002\021\001\003\021\001\377\304\000K\000\001\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\006\001\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\020\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\021\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\377\332\000\f\003\001\000\002\021\003\021\000?\000\246\000\037\377\331"
  
  def self.image_works?(bits) #:nodoc:
    ZBar::Image.new.tap { |img|
      img.set_data(ZBar::Format::JPEG, bits)
      img.convert(ZBar::Format::Y800)
    } && true
  rescue ArgumentError
    if $!.to_s == "conversion failed"
      false
    else
      raise
    end
  end
  
end
