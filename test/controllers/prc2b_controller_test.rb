require 'test_helper'

class Prc2bControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get prc2b_index_url
    assert_response :success
  end

  test "should get entry" do
    get prc2b_entry_url
    assert_response :success
  end

  test "should get admin" do
    get prc2b_admin_url
    assert_response :success
  end

  test "should get reader" do
    get prc2b_reader_url
    assert_response :success
  end

  test "should get super" do
    get prc2b_super_url
    assert_response :success
  end

end
