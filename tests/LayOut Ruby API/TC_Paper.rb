# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Jay Dave

require "testup/testcase"

# module Layout
class TC_Paper < TestUp::TestCase

  def setup
    #puts 'SetUp TC_Paper'
    @new_doc = Layout::Document::new 'C:\\ProgramData\\SketchUp\\SketchUp 2015\\LayOut\\templates\\Paper\\Graph Paper\\A3 Landscape.layout'
  end

  def teardown
    #puts 'Teardown TC_Paper'
  end

  # ========================================================================== #
  
  # method Paper.width
  # URL
  
  def test_paper_get_width
    paper = @new_doc.paper
    assert_kind_of(Layout::Paper, paper)
    width = paper.width
    assert_equal(16.54, width.round(2))    
  end #test_paper_get_width
  
  # method Paper.width=
  # URL
  
  def test_paper_set_width
    doc = @new_doc
    paper = doc.paper
    paper.width = 17.00    
    paper = doc.paper
    width = paper.width
    assert_equal(17.00, width.round(2))
  end #test_paper_set_width
  
  # method Paper.height
  # URL
  
  def test_paper_get_height
    paper = @new_doc.paper
    height = paper.height
    assert_equal(11.69, height.round(2))
  end #test_paper_get_height
  
  # method Paper.height=
  # URL
  
  def test_paper_set_height
    doc = @new_doc
    doc.paper.height = 12.00
    paper = doc.paper
    height = paper.height
    assert_equal(12.00, height.round(2))    
  end #test_paper_set_height
  
  # method Paper.left_margin
  # URL
  
  def test_paper_get_left_margin
    left_margin = @new_doc.paper.left_margin
    assert_equal(0.39, left_margin.round(2))
  end #test_paper_get_left_margin
  
  # method Paper.left_margin=
  # URL
  
  def test_paper_set_left_margin
    doc = @new_doc
    doc.paper.left_margin = 0.40
    left_margin = doc.paper.left_margin
    assert_equal(0.40, left_margin.round(2))
  end #test_paper_set_left_margin
  
  # method Paper.right_margin
  # URL
  
  def test_paper_get_right_margin
    right_margin = @new_doc.paper.right_margin
    assert_equal(0.39, right_margin.round(2))
  end #test_paper_get_right_margin
  
  # method Paper.right_margin=
  # URL
  
  def test_paper_set_right_margin
    doc = @new_doc
    doc.paper.right_margin = 0.40
    right_margin = doc.paper.right_margin
    assert_equal(0.40, right_margin.round(2))
  end #test_paper_set_right_margin
  
  # method Paper.top_margin
  # URL
  
  def test_paper_get_top_margin
    top_margin = @new_doc.paper.top_margin
    assert_equal(0.39, top_margin.round(2))
  end #test_paper_get_top_margin
  
  # method Paper.top_margin=
  # URL
  
  def test_paper_set_top_margin
    doc = @new_doc
    doc.paper.top_margin = 0.40
    top_margin = doc.paper.top_margin
    assert_equal(0.40, top_margin.round(2))
  end #test_paper_set_top_margin
  
  # method Paper.bottom_margin
  # URL
  
  def test_paper_get_bottom_margin
    bottom_margin = @new_doc.paper.bottom_margin
    assert_equal(0.39, bottom_margin.round(2))
  end #test_paper_get_bottom_margin
  
  # method Paper.bottom_margin=
  # URL
  
  def test_paper_set_bottom_margin
    doc = @new_doc
    doc.paper.bottom_margin = 0.40
    bottom_margin = doc.paper.bottom_margin
    assert_equal(0.40, bottom_margin.round(2))
  end  #test_paper_set_bottom_margin

end # class