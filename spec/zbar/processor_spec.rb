require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ZBar::Processor do
  describe "new" do
    it "calls ZBar.zbar_processor_create" do
      ZBar.should_receive(:zbar_processor_create).and_call_original
      described_class.new
    end
    
    it "calls ZBar.zbar_processor_init" do
      ZBar.should_receive(:zbar_processor_init).and_call_original
      described_class.new
    end

    it "should instantiate with no parameters" do
      described_class.new
    end

    it "should instantiate with an integer parameter" do
      described_class.new(0)
    end

    it "should instantiate with a hash parameter" do
      described_class.new(:threads => 0)
    end
  end
  
  describe "#zbar_config=" do
    it "calls ZBar.zbar_parse_config" do
      ZBar.should_receive(:zbar_parse_config).with("disable", anything(), anything(), anything()).and_call_original
      subject.zbar_config = "disable"
    end

    it "calls ZBar.zbar_processor_set_config" do
      ZBar.should_receive(:zbar_processor_set_config).and_call_original
      subject.zbar_config = "disable"
    end

    it "calls itself repeatedly when given an array" do
      args = ["foo", :bar, 1]
      subject.should_receive(:zbar_config=).with(args).and_call_original
      args.each { |arg|
        subject.should_receive(:zbar_config=).with(arg)
      }
      subject.zbar_config = args
    end
    
    it "succeeds for \"disable\"" do
      subject.zbar_config = "disable"
    end
    it "succeeds for \"enable=0\"" do
      subject.zbar_config = "enable=0"
    end
    it "succeeds for \"qrcode.enable=1\"" do
      subject.zbar_config = "qrcode.enable=1"
    end
    
    it "raises ArgumentError for \"foo bar baz\"" do
      lambda {
        subject.zbar_config = "foo bar baz"
      }.should raise_error ArgumentError
    end
  end
  
  describe "#symbology=" do
    it "delegates to #symbologies=" do
      subject.should_receive(:symbologies=).with(['foo'])
      subject.symbology = 'foo'
    end
  end
  
  describe "#symbologies=" do
    it "enables the selected symbologies" do
      subject.should_receive(:zbar_config=).with(["disable", "foo.enable", "bar.enable"])
      subject.symbologies = ['foo', :bar]
    end
  end
  
  describe "#process" do
    context "when processing test.pgm" do
      let(:pgm_data) { read_file "test.pgm" }
      let(:image) { ZBar::Image.from_pgm(pgm_data) }
      let(:config) { {} }
      let(:processor) { described_class.new(config) }
      subject { processor.process(image) }
      
      it "finds the expected symbol" do
        symbols = subject
        symbols.size.should == 1

        symbol = symbols[0]
        symbol.should be_kind_of ZBar::Symbol
        symbol.data.should == "9876543210128"
        symbol.symbology.should == "EAN-13"
      end
      
      context "when all symbologies are disabled" do
        let(:config) { { :symbologies => [] } }
        it { should be_empty }
      end

      context "when only a wrong symbology is enabled" do
        let(:config) { { :symbology => :qrcode } }
        it { should be_empty }
      end

      context "when the correct symbology is enabled" do
        let(:config) { { :symbologies => ["qrcode", :ean13] } }
        it { should_not be_empty }
      end
    end
  end
end
