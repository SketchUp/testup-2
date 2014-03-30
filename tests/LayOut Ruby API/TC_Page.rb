# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Jay Dave

require "testup/testcase"

# module Layout
class TC_Page < TestUp::TestCase

  def setup
   #puts 'Setup TC_Page'
   @new_doc = Layout::Document::new 'C:\\ProgramData\\SketchUp\\SketchUp 2015\\LayOut\\templates\\Paper\\Graph Paper\\A3 Landscape.layout'
   @active_doc = Layout.active_document
  end

  def teardown
    #puts 'Teardown TC_Page'
  end

  # ========================================================================== #  
  
  # method Page.name
  # URL
  
  def test_page_get_name
    doc = @new_doc
    pages = doc.pages
    page_name = pages[0].name
    assert_equal(true, page_name!='')
  end # test_page_get_name
  
  # method Page.name=
  # URL
  
  def test_page_set_name
    doc = @new_doc
    pages = doc.pages
    pages[0].name='New Page Name'
    new_name = pages[0].name
    assert_equal("New Page Name", new_name)
  end # test_page_set_name
  
  # method Page.description
  # URL
  
  def test_page_get_description
    doc = @new_doc
    pages = doc.pages
    desc = pages[0].description
    assert_equal('', desc)
  end # test_page_get_description
  
  # method Page.description=
  # URL
  
  def test_page_set_description
    doc = @new_doc
    pages = doc.pages
    pages[0].description = 'Page Description'
    desc = pages[0].description
    assert_equal('Page Description', desc)    
  end # test_page_set_descritpion
  
  # method Page.index
  # URL
  
  def test_page_get_index
    doc = @new_doc
    pages = doc.pages
    page_index = pages[0].index
    assert_equal(0, page_index)
  end # test_page_get_number
  
  # method Page.layers
  # URL
  
  def test_page_get_layers
    doc = @new_doc
    pages = doc.pages
    layers = pages[0].layers
    assert_equal(1, layers.count)
    assert_kind_of(Layout::Layer, layers[0])
    # TODO (Jay): Assert that this layer is a non-shared layer
  end # test_page_get_layers
  
  # method Page.entities
  # URL
  
  def test_page_get_entities
    # TODO (Jay): To be implemented
    assert(0,0)
  end # test_page_get_entities
  
  # method Page.in_presentation?
  # URL
  
  def test_page_get_in_presentation?
    doc = @new_doc
    pages = doc.pages
    in_presentation = pages[0].in_presentation?
    assert_equal(true, in_presentation)
  end # test_page_get_in_presentation
  
  # method Page.in_presentation=
  # URL
  
  def test_page_set_in_presentation
    doc = @new_doc
    pages = doc.pages
    pages[0].in_presentation = false
    in_presentation = pages[0].in_presentation?
    assert_equal(false, in_presentation)
  end # test_page_set_in_presentation  

end # class