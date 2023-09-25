require 'test_helper'

class SubscribesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subscribe = subscribes(:one)
  end

  test "should get index" do
    get subscribes_url
    assert_response :success
  end

  test "should get new" do
    get new_subscribe_url
    assert_response :success
  end

  test "should create subscribe" do
    assert_difference('Subscribe.count') do
      post subscribes_url, params: { subscribe: {  } }
    end

    assert_redirected_to subscribe_url(Subscribe.last)
  end

  test "should show subscribe" do
    get subscribe_url(@subscribe)
    assert_response :success
  end

  test "should get edit" do
    get edit_subscribe_url(@subscribe)
    assert_response :success
  end

  test "should update subscribe" do
    patch subscribe_url(@subscribe), params: { subscribe: {  } }
    assert_redirected_to subscribe_url(@subscribe)
  end

  test "should destroy subscribe" do
    assert_difference('Subscribe.count', -1) do
      delete subscribe_url(@subscribe)
    end

    assert_redirected_to subscribes_url
  end
end
