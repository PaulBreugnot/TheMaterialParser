require 'test_helper'

class DatasheetsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get datasheets_index_url
    assert_response :success
  end

  test "should get new" do
    get datasheets_new_url
    assert_response :success
  end

  test "should get create" do
    get datasheets_create_url
    assert_response :success
  end

  test "should get destroy" do
    get datasheets_destroy_url
    assert_response :success
  end

end
