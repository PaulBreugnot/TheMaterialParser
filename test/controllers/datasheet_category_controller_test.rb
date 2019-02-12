require 'test_helper'

class DatasheetCategoryControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get datasheet_category_index_url
    assert_response :success
  end

  test "should get create" do
    get datasheet_category_create_url
    assert_response :success
  end

end
