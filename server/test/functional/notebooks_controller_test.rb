require 'test_helper'

class NotebooksControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test "pull provides correct notebooks" do
    sign_in users(:one)
    get 'pull', {:device_id => 'ABC', :format => :json}
    assert_response :success
    data = JSON.parse(@response.body)
    Rails::logger.info data.inspect
    assert(data.has_key?('updated'),"response should contain updated array")
    assert(data.has_key?('deleted'),"response should contain deleted array")
    assert_equal(2,data['updated'].length,"updated array should contain 2 key-value pairs")
    assert_equal(1,data['deleted'].length,"deleted shgould contain 1 key-value pair")
    assert_equal(1,data['updated'][0]['id'],"updated array should contain notebook 1")
    assert_equal(2,data['updated'][1]['id'],"updated array should contain notebook 2")
    assert_equal(3,data['deleted'][0]['notebook_id'],"deleted array should contain notebook 3")
  end
end
