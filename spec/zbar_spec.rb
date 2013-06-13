require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ZBar do
  it { should be_kind_of Module }
  
  describe "library_version" do
    it "calls zbar_version(uint*, uint*)" do
      ZBar.should_receive(:zbar_version).with(anything, anything).and_return(0)
      ZBar.library_version
    end
    
    it "returns LibraryVersion" do
      ZBar.library_version.should be_kind_of ZBar::LibraryVersion
    end
  end
end
