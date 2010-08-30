module ZBar

  class Symbol
    attr_reader :symbology, :data, :addon, :quality, :location
  
    def initialize(symbol=nil)
      if symbol
        type = ZBar.zbar_symbol_get_type(symbol)
        @symbology = ZBar.zbar_get_symbol_name(type)
        @data = ZBar.zbar_symbol_get_data(symbol)
        @addon = ZBar.zbar_get_addon_name(type)
        @quality = ZBar.zbar_symbol_get_quality(symbol)

        @location = []
        point_count = ZBar.zbar_symbol_get_loc_size(symbol)
        i = 0
        while i < point_count
          @location << [ZBar.zbar_symbol_get_loc_x(symbol, i), ZBar.zbar_symbol_get_loc_y(symbol, i)]
          i += 1
        end
      end
    end
    
    def ==(symbol)
      return false unless symbol.kind_of?(Symbol)
      
      (
        self.symbology == symbol.symbology &&
        self.data == symbol.data &&
        self.addon == symbol.addon &&
        self.quality == symbol.quality &&
        self.location == symbol.location
      )
    end
  end

end
