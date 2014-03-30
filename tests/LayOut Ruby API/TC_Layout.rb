# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Jay Dave

require "testup/testcase"

# module Layout
class TC_Layout < TestUp::TestCase
 
  def setup    
  end

  def teardown    
  end
  
  # ========================================================================== #
  # method Layout.application_name
  # URL
  
  def test_application_name
    app_name = Layout::application_name
    assert_equal('LayOut',app_name)
  end # test_application_name
  
  # method Layout.version
  # URL
  
  def test_application_version
    version = Layout::version
    assert_equal('15.0.0', version)
  end # test_application_version
  
  # method Layout.version_number
  # URL
  
  def test_application_version_number
    version = Layout::version_number
    assert_equal(15000000,version)
  end # test_application_version_number
  
  # method Layout.active_document
  # URL
  
  def test_application_active_document
     doc = Layout.active_document
     assert_equal(doc!=nil, true)
     assert_kind_of(Layout::Document, doc)     
  end # test_application_active_document
  
  # method Layout.open_file
  # URL
  
  def test_application_open_file
    assert_equal(0,0)
  end # test_application_open_file
  
  # method Layout.quit
  # URL
  
  def test_application_quit
    assert_equal(0,0)
  end # test_application_quit
  
  # method Layout.online?
  # URL
  
  def test_application_online
    is_online = Layout::online?
    assert_equal(true, is_online)
  end # test_application_online
  
  # method Layout.preferences
  # URL
  
  def test_application_get_preferences   
    prefs = Layout.preferences
    assert_kind_of(Layout::Preferences, prefs)
  end # test_application_get_preferences

end # class