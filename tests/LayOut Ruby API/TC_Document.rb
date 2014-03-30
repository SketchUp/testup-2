# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Jay Dave

require "testup/testcase"

# module Layout
class TC_Document < TestUp::TestCase  
 
  def setup
    #puts 'SetUp TC_Document'
    @new_doc = Layout::Document::new 'C:\\ProgramData\\SketchUp\\SketchUp 2015\\LayOut\\templates\\Paper\\Graph Paper\\A3 Landscape.layout'
    @active_doc = Layout.active_document    
  end

  def teardown
    #puts 'Teardown TC_Document'  
  end

  # ========================================================================== #  
  
  # method Layout::Document
  # URL
  
  def test_document_new
    doc = @new_doc
    assert(true, doc!=nil)
  end # test_document_new
  
  # method Layout::Document.save
  # URL
  
  def test_document_save
    doc = @new_doc
    expected = doc.save
    assert_equal(false, expected)
    expected = doc.save('C:\\Users\\Public\\Documents\\test.layout')
    assert_equal(true, expected)
    GC.start
  end # test_document_save
  
  # method Layout::Document.path
  # URL
  
  def test_document_get_path
    doc = @new_doc
    expected = doc.save
    assert_equal(false, expected)
    expected = doc.save('C:\\Users\\Public\\Documents\\test.layout')
    path = doc.path
    assert_equal(true, path!='')
    GC.start
  end # test_document_get_path
  
  # method Layout::Document.title
  # URL
  
  def test_document_get_title
    doc = @new_doc
    doc_title = doc.title
    assert_equal(true, doc_title=='')
    GC.start
  end # test_document_get_title
  
  # method Layout::Document.title=
  # URL
  
  def test_document_set_title
    doc = @new_doc
    title = doc.title='Test'
    assert_equal(true, title=='Test')
    GC.start
  end # test_document_set_title
  
  # method Layout::Document.paper
  # URL
  
  def test_document_get_paper
    doc = @new_doc
    paper = doc.paper
    assert_equal(true, paper!=nil)
    assert_kind_of(Layout::Paper,paper)
    GC.start
  end # test_document_get_paper  
  
  # method Layout::Document.pages
  # URL  
  
  def test_document_get_pages
    #puts 'Executing test_document_get_pages'
    doc = @new_doc
    pages = doc.pages
    assert_equal(1,pages.count)
    doc.add_page
    pages = doc.pages
    assert_equal(2, pages.count)
    assert_kind_of(Layout::Page, pages[0])
    assert_equal(true, doc!=nil)    
  end # test_document_get_pages
  
  # method Layout::Document.presentation_pages
  # URL
  
  def test_document_get_presentation_pages
    doc = @new_doc
    present_pages = doc.presentation_pages
    assert_equal(1,present_pages.count)
    assert_equal(true, doc!=nil)
    GC.start
  end # test_document_get_presentation_pages 
  
  # method Layout::Document.add_page
  # URL
  
  def test_document_add_page
    doc = @new_doc
    page = doc.add_page
    assert_equal(true,page!=nil)
    assert_kind_of(Layout::Page, page)
    assert_equal(true, doc!=nil)
    GC.start
  end # test_document_add_page
  
  # method Layout::Document.insert_page
  # URL
  
  def test_document_insert_page
    doc = @new_doc
    page = doc.add_page
    assert_equal(true, page!=nil)
    page = doc.insert_page(0)
    assert_kind_of(Layout::Page, page)
    assert_equal(true, doc!=nil)
    GC.start
  end # test_document_insert_page
  
  # method Layout::Document.erase_page
  # URL
  
  def test_document_erase_page
    doc = @new_doc
    page = doc.add_page
    page = doc.add_page
    result = doc.erase_page(1)
    assert_equal(true, result)
    assert_equal(true, doc!=nil)
    GC.start
  end # test_document_insert_page
  
   # method Layout::Document.layers
  # URL
  
  def test_document_get_layers
    doc = @new_doc
    layers = doc.layers    
    assert_equal(2,layers.count)
    assert_kind_of(Layout::Layer, layers[0])
  end # test_document_get_layers
  
  # method Layout::Document.shared_layers
  # URL
  
  def test_document_get_shared_layers
    doc = @new_doc
    shared_layers = doc.shared_layers
    assert_kind_of(Layout::Layer, shared_layers[0])
    assert_equal(1,shared_layers.count)
  end # test_document_get_shared_layers
  
  # method Layout::Document.remove_layer
  # URL
  
  def test_document_remove_layer
    assert_equal(0,0)
  end # test_document_remove_layer  
  
  # method Layout::Document
  # URL
  
  def test_document_get_connections
    assert_equal(0,0)
  end # test_document_get_connections
  
  # method Layout::Document.inference_enabled
  # URL
  
  def test_document_get_inference_enabled
    doc = Layout.active_document
    inference = doc.inference_enabled?
    assert_equal(true,inference)
  end # test_document_get_inference_enabled
  
  # method Layout::Document.inference_enabled=
  # URL
  
  def test_document_set_inference_enabled
    doc = @new_doc
    doc.inference_enabled=false
    inference = doc.inference_enabled?
    assert_equal(false,inference)
  end # test_document_set_inference_enabled
  
  # method Layout::Document.thumbnail
  # URL
  
  def test_document_get_thumbnail
    assert_equal(0,0)
  end # test_document_get_thumbnail
  
  # method Layout::Document.thumbnail=
  # URL
  
  def test_document_set_thumbnail
    assert_equal(0,0)
  end # test_document_set_thumbnail
  
  # method Layout::Document.units
  # URL
  
  def test_document_get_units
    assert_equal(0,0)
  end # test_document_get_units
  
  # method Layout::Document.units=
  # URL
  
  def test_document_set_units
    assert_equal(0,0)
  end # test_document_set_units
  
  # method Layout::Document.version_number
  # URL
  
  def test_document_get_version
    doc = @new_doc
    doc_version = doc.version_number
    assert_equal(15000000,doc_version)
  end # test_document_get_version
  
  # method Layout::Document.time_created
  # URL
  
  def test_document_get_time_created
    doc = @new_doc
    create_time = doc.time_created
    assert_kind_of(Time, create_time)    
  end # test_document_get_time_created
  
  # method Layout::Document.time_modified
  # URL
  
  def test_document_get_time_modified
    doc = @new_doc
    mod_time = doc.time_modified
    assert_kind_of(Time, mod_time)
  end # test_document_get_time_modified
  
  # method Layout::Document.time_published
  # URL
  
  def test_document_get_time_published
    doc = @new_doc
    pub_time = doc.time_published
    assert_kind_of(Time, pub_time)
  end # test_document_get_time_published 
  
end # class