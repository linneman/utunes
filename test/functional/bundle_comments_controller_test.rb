require 'test_helper'

class BundleCommentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bundle_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bundle_comment" do
    assert_difference('BundleComment.count') do
      post :create, :bundle_comment => { }
    end

    assert_redirected_to bundle_comment_path(assigns(:bundle_comment))
  end

  test "should show bundle_comment" do
    get :show, :id => bundle_comments(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => bundle_comments(:one).id
    assert_response :success
  end

  test "should update bundle_comment" do
    put :update, :id => bundle_comments(:one).id, :bundle_comment => { }
    assert_redirected_to bundle_comment_path(assigns(:bundle_comment))
  end

  test "should destroy bundle_comment" do
    assert_difference('BundleComment.count', -1) do
      delete :destroy, :id => bundle_comments(:one).id
    end

    assert_redirected_to bundle_comments_path
  end
end
