require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ZBar::Image do
  describe ".from_jpeg" do
    let(:jpeg_data) { read_file jpeg_file }
    subject { described_class.from_jpeg(jpeg_data) }
    
    context "given test.jpg" do
      let(:jpeg_file) { "test.jpg" }

      its(:width) { should == 480 }
      its(:height) { should == 240 }
      
      describe "process" do
        it "delegates to the passed processor" do
          processor = double("processor")
          expected_result = Object.new
          processor.should_receive(:process).with(subject).and_return(expected_result)
          
          subject.process(processor).should == expected_result
        end

        it "instantiates a new processor with no arguments" do
          processor = double("processor")
          processor.should_receive(:process)
          ZBar::Processor.should_receive(:new).with().and_return(processor)
          subject.process
        end

        it "instantiates a new processor with configuration" do
          config_hash = { :foo => :bar }
          processor = double("processor")
          processor.should_receive(:process)
          ZBar::Processor.should_receive(:new).with(config_hash).and_return(processor)
          subject.process(config_hash)
        end
      end
    end
  end

  describe ".from_pgm" do
    let(:pgm_data) { read_file pgm_file }
    let(:image) { described_class.from_pgm(pgm_data) }
    subject { image }
    
    context "given test.pgm" do
      let(:pgm_file) { "test.pgm" }

      its(:width) { should == 480 }
      its(:height) { should == 240 }
    end
  end
end
