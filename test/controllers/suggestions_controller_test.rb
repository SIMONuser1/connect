require 'test_helper'

class SuggestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get suggestions_index_url
    assert_response :success
  end

  test "should get update" do
    get suggestions_update_url
    assert_response :success
  end

end
