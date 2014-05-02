require 'test_helper'

class TcpdfCssTest < ActiveSupport::TestCase

  test "CSS Basic" do
    pdf = TCPDF.new

    # empty
    css = pdf.extractCSSproperties('')
    assert_equal css, {}
    # empty blocks
    css = pdf.extractCSSproperties('h1 {}')
    assert_equal css, {}
    # comment
    css = pdf.extractCSSproperties('/* comment */')
    assert_equal css, {}

    css = pdf.extractCSSproperties('h1 { color: navy; font-family: times; }')
    assert_equal css, {"0001 h1"=>"color:navy;font-family:times;"}

    css = pdf.extractCSSproperties('h1 { color: navy; font-family: times; } p.first { color: #003300; font-family: helvetica; font-size: 12pt; }')
    assert_equal css, {"0001 h1"=>"color:navy;font-family:times;", "0021 p.first"=>"color:#003300;font-family:helvetica;font-size:12pt;"}

    css = pdf.extractCSSproperties('h1,h2,h3{background-color:#e0e0e0}')
    assert_equal css, {"0001 h1"=>"background-color:#e0e0e0", "0001 h2"=>"background-color:#e0e0e0", "0001 h3"=>"background-color:#e0e0e0"}

    css = pdf.extractCSSproperties('p.second { color: rgb(00,63,127); font-family: times; font-size: 12pt; text-align: justify; }')
    assert_equal css, {"0011 p.second"=>"color:rgb(00,63,127);font-family:times;font-size:12pt;text-align:justify;"}

    css = pdf.extractCSSproperties('p#second { color: rgb(00,63,127); font-family: times; font-size: 12pt; text-align: justify; }')
    assert_equal css, {"0101 p#second"=>"color:rgb(00,63,127);font-family:times;font-size:12pt;text-align:justify;"}

    css = pdf.extractCSSproperties('p.first { color: rgb(00,63,127); } p.second { font-family: times; }')
    assert_equal css, {"0021 p.first"=>"color:rgb(00,63,127);", "0011 p.second"=>"font-family:times;"}

    css = pdf.extractCSSproperties('p#first { color: rgb(00,63,127); } p#second { color: rgb(00,63,127); }')
    assert_equal css, {"0111 p#first"=>"color:rgb(00,63,127);", "0101 p#second"=>"color:rgb(00,63,127);"}

    # media
    css = pdf.extractCSSproperties('@media print { body { font: 10pt serif } }')
    assert_equal css, {"0001 body"=>"font:10pt serif"}
    css = pdf.extractCSSproperties('@media screen { body { font: 12pt sans-serif } }')
    assert_equal css, {}
    css = pdf.extractCSSproperties('@media all { body { line-height: 1.2 } }')
    assert_equal css, {"0001 body"=>"line-height:1.2"}

    css = pdf.extractCSSproperties('@media print {
                   #top-menu, #header, #main-menu, #sidebar, #footer, .contextual, .other-formats { display:none; }
                   #main { background: #fff; }
                   #content { width: 99%; margin: 0; padding: 0; border: 0; background: #fff; overflow: visible !important;}
                   #wiki_add_attachment { display:none; }
                   .hide-when-print { display: none; }
                   .autoscroll {overflow-x: visible;}
                   table.list {margin-top:0.5em;}
                   table.list th, table.list td {border: 1px solid #aaa;}
                 } @media all { body { line-height: 1.2 } }')
    assert_equal css, {"0100 #top-menu"=>"display:none;",
                  "0100 #header"=>"display:none;",
                  "0100 #main-menu"=>"display:none;",
                  "0100 #sidebar"=>"display:none;",
                  "0100 #footer"=>"display:none;",
                  "0010 .contextual"=>"display:none;",
                  "0010 .other-formats"=>"display:none;",
                  "0100 #main"=>"background:#fff;",
                  "0100 #content"=>"width:99%;margin:0;padding:0;border:0;background:#fff;overflow:visible !important;",
                  "0100 #wiki_add_attachment"=>"display:none;",
                  "0010 .hide-when-print"=>"display:none;",
                  "0010 .autoscroll"=>"overflow-x:visible;",
                  "0011 table.list"=>"margin-top:0.5em;",
                  "0012 table.list th"=>"border:1px solid #aaa;",
                  "0012 table.list td"=>"border:1px solid #aaa;",
                  "0001 body"=>"line-height:1.2"}
  end

  test "CSS Selector Valid test" do
    pdf = TCPDF.new

    # Simple CSS
    dom = pdf.getHtmlDomArray('<p>abc</p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 2, ' p') # dom, key, css selector
    assert_equal valid, true
    dom = pdf.getHtmlDomArray('<h1>abc</h1>')
    valid = pdf.isValidCSSSelectorForTag(dom, 2, ' h1') # dom, key, css selector
    assert_equal valid, true
    dom = pdf.getHtmlDomArray('<p class="first">abc</p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 2, ' p.first') # dom, key, css selector
    assert_equal valid, true
    dom = pdf.getHtmlDomArray('<p class="first">abc<span>def</span></p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 4, ' p.first span') # dom, key, css selector
    assert_equal valid, true
    dom = pdf.getHtmlDomArray('<p id="second">abc</p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 2, ' p#second') # dom, key, css selector
    assert_equal valid, true
    dom = pdf.getHtmlDomArray('<p id="second">abc<span>def</span></p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 4, ' p#second > span') # dom, key, css selector
    assert_equal valid, true
  end

  test "CSS Tag Sytle test 1" do
    pdf = TCPDF.new

    # Simple CSS
    dom = pdf.getHtmlDomArray('<h1>abc</h1>')
    tag = pdf.getTagStyleFromCSS(dom, 2, {'0001 h1'=>'color:navy;font-family:times;'}) # dom, key, css selector
    assert_equal tag, ';color:navy;font-family:times;'

    tag = pdf.getTagStyleFromCSS(dom, 2, {'0001h1'=>'color:navy;font-family:times;'}) # dom, key, css selector
    assert_equal tag, ''

    tag = pdf.getTagStyleFromCSS(dom, 2, {'0001 h2'=>'color:navy;font-family:times;'}) # dom, key, css selector
    assert_equal tag, ''
  end

  test "CSS Tag Sytle test 2" do
    pdf = TCPDF.new

    dom = pdf.getHtmlDomArray('<p class="first">abc</p>')
    tag = pdf.getTagStyleFromCSS(dom, 2, {'0021 p.first'=>'color:rgb(00,63,127);'})
    assert_equal tag, ';color:rgb(00,63,127);'

    dom = pdf.getHtmlDomArray('<p id="second">abc</p>')
    tag = pdf.getTagStyleFromCSS(dom, 2, {'0101 p#second'=>'color:rgb(00,63,127);font-family:times;font-size:12pt;text-align:justify;'})
    assert_equal tag, ';color:rgb(00,63,127);font-family:times;font-size:12pt;text-align:justify;'
  end

  test "CSS Dom test" do
    pdf = TCPDF.new

    html = '<style> table, td { border: 2px #ff0000 solid; } </style>
            <h2>HTML TABLE:</h2>
            <table> <tr> <th>abc</th> </tr>
                    <tr> <td>def</td> </tr> </table>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal dom.length, 29

    assert_equal dom[0]['parent'], 0  # Root
    assert_equal dom[0]['tag'], false
    assert_equal dom[0]['attribute'], {}

    # <h2>
    assert_equal dom[2]['elkey'], 1
    assert_equal dom[2]['parent'], 0   # parent -> parent tag key
    assert_equal dom[2]['tag'], true
    assert_equal dom[2]['opening'], true
    assert_equal dom[2]['value'], 'h2'

    # <table>
    assert_equal dom[6]['value'], 'table'
    assert_equal dom[6]['attribute'], {'border'=>'2px #ff0000 solid', 'style'=>';border:2px #ff0000 solid;'}
    assert_equal dom[6]['style']['border'], '2px #ff0000 solid'
    assert_equal dom[6]['attribute']['border'], '2px #ff0000 solid'
  end

  test "CSS Dom line-height test normal" do
    pdf = TCPDF.new

    html = '<style>  h2 { line-height: normal; } </style>
            <h2>HTML TEST</h2>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal dom.length, 5

    # <h2>
    assert_equal dom[2]['elkey'], 1
    assert_equal dom[2]['parent'], 0   # parent -> parent tag key
    assert_equal dom[2]['tag'], true
    assert_equal dom[2]['opening'], true
    assert_equal dom[2]['value'], 'h2'
    assert_equal dom[2]['line-height'], 1.25
  end

  test "CSS Dom line-height test numeric" do
    pdf = TCPDF.new

    html = '<style>  h2 { line-height: 1.4; } </style>
            <h2>HTML TEST</h2>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal dom.length, 5

    # <h2>
    assert_equal dom[2]['elkey'], 1
    assert_equal dom[2]['parent'], 0   # parent -> parent tag key
    assert_equal dom[2]['tag'], true
    assert_equal dom[2]['opening'], true
    assert_equal dom[2]['value'], 'h2'
    assert_equal dom[2]['line-height'], 1.4
  end

  test "CSS Dom line-height test percentage" do
    pdf = TCPDF.new

    html = '<style>  h2 { line-height: 10%; } </style>
            <h2>HTML TEST</h2>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal dom.length, 5

    # <h2>
    assert_equal dom[2]['parent'], 0   # parent -> parent tag key
    assert_equal dom[2]['elkey'], 1
    assert_equal dom[2]['tag'], true
    assert_equal dom[2]['opening'], true
    assert_equal dom[2]['value'], 'h2'
    assert_equal dom[2]['line-height'], 0.1
  end

  test "CSS Dom class test" do
    pdf = TCPDF.new

    html = '<style>p.first { color: #003300; font-family: helvetica; font-size: 12pt; }
                   p.first span { color: #006600; font-style: italic; }</style>
            <p class="first">Example <span>Fusce</span></p>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal dom.length, 9

    # <p class="first">
    assert_equal dom[2]['elkey'], 1
    assert_equal dom[2]['parent'], 0   # parent -> parent tag key
    assert_equal dom[2]['tag'], true
    assert_equal dom[2]['opening'], true
    assert_equal dom[2]['value'], 'p'
    assert_equal dom[2]['attribute']['class'], 'first'
    assert_equal dom[2]['style']['color'],  '#003300'
    assert_equal dom[2]['style']['font-family'], 'helvetica'
    assert_equal dom[2]['style']['font-size'], '12pt'

    # Example 
    assert_equal dom[3]['elkey'], 2
    assert_equal dom[3]['parent'], 2
    assert_equal dom[3]['tag'], false
    assert_equal dom[3]['value'], 'Example '

    # <span>
    assert_equal dom[4]['elkey'], 3
    assert_equal dom[4]['parent'], 2
    assert_equal dom[4]['tag'], true
    assert_equal dom[4]['opening'], true
    assert_equal dom[4]['value'], 'span'
    assert_equal dom[4]['style']['color'], '#006600'
    assert_equal dom[4]['style']['font-style'], 'italic'

  end

  test "CSS Dom id test" do
    pdf = TCPDF.new

    html = '<style> p#second > span { background-color: #FFFFAA; }</style>
            <p id="second">Example <span>Fusce</span></p>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal dom.length, 9

    # <p id="second">
    assert_equal dom[2]['elkey'], 1
    assert_equal dom[2]['parent'], 0   # parent -> parent tag key
    assert_equal dom[2]['tag'], true
    assert_equal dom[2]['opening'], true
    assert_equal dom[2]['value'], 'p'
    assert_equal dom[2]['attribute']['id'], 'second'

    # Example 
    assert_equal dom[3]['elkey'], 2
    assert_equal dom[3]['parent'], 2
    assert_equal dom[3]['tag'], false
    assert_equal dom[3]['value'], 'Example '

    # <span>
    assert_equal dom[4]['elkey'], 3
    assert_equal dom[4]['parent'], 2
    assert_equal dom[4]['tag'], true
    assert_equal dom[4]['opening'], true
    assert_equal dom[4]['value'], 'span'
    assert_equal dom[4]['style']['background-color'], '#FFFFAA'
  end
end
