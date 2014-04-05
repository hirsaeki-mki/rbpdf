require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "Image basic func test" do
    pdf = TCPDF.new

    type = pdf.getImageFileType("/tmp/tcpdf_logo.gif")
    assert_equal type, "gif"

    type = pdf.getImageFileType("/tmp/tcpdf_logo.PNG")
    assert_equal type, "png"

    type = pdf.getImageFileType("/tmp/tcpdf_logo.jpg")
    assert_equal type, "jpeg"

    type = pdf.getImageFileType("/tmp/tcpdf_logo.jpeg")
    assert_equal type, "jpeg"

    type = pdf.getImageFileType("/tmp/tcpdf_logo")
    assert_equal type, ""

    type = pdf.getImageFileType("")
    assert_equal type, ""

    type = pdf.getImageFileType(nil)
    assert_equal type, ""
  end
end
