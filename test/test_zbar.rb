require 'helper'

Path = File.dirname(__FILE__)

class TestZBar < Test::Unit::TestCase
  should "read the right barcode from a PGM blob" do
    result = ZBar::Image.from_pgm(File.read("#{Path}/test.pgm")).process
    assert_equal(result.size, 1)
    assert_equal(result[0].data, '9876543210128')
    assert_equal(result[0].symbology, 'EAN-13')
  end
  
  should "read a barcode from a PGM file" do
    File.open("#{Path}/test.pgm") { |f|
      result = ZBar::Image.from_pgm(f).process
      assert_equal(result.size, 1)
    }
  end

  should "be able to re-use a processor" do
    processor = ZBar::Processor.new
    pgm = File.read("#{Path}/test.pgm")
    
    result1 = processor.process ZBar::Image.from_pgm(pgm)
    result2 = processor.process ZBar::Image.from_pgm(pgm)
    assert_equal(result1.size, 1)
    assert_equal(result2.size, 1)
    assert_equal(result1, result2)
  end

  should "read a barcode from a JPEG blob" do
    result = ZBar::Image.from_jpeg(File.read("#{Path}/test.jpg")).process
    assert_equal(result.size, 1)
  end
  
  should "read a barcode from a JPEG file" do
    File.open("#{Path}/test.jpg") { |f|
      result = ZBar::Image.from_jpeg(f).process
      assert_equal(result.size, 1)
    }
  end
end
