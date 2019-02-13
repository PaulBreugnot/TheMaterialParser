require 'test_helper'

class DatasheetSelectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get destroy" do
    get datasheet_selections_destroy_url
    assert_response :success
  end

  test "should get process" do
    get datasheet_selections_process_url
    assert_response :success
  end

end
