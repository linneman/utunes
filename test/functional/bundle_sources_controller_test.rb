require 'test_helper'

class BundleSourcesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bundle_sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bundle_source" do
    assert_difference('BundleSource.count') do
      post :create, :bundle_source => { }
    end

    assert_redirected_to bundle_source_path(assigns(:bundle_source))
  end

  test "should show bundle_source" do
    get :show, :id => bundle_sources(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => bundle_sources(:one).id
    assert_response :success
  end

  test "should update bundle_source" do
    put :update, :id => bundle_sources(:one).id, :bundle_source => { }
    assert_redirected_to bundle_source_path(assigns(:bundle_source))
  end

  test "should destroy bundle_source" do
    assert_difference('BundleSource.count', -1) do
      delete :destroy, :id => bundle_sources(:one).id
    end

    assert_redirected_to bundle_sources_path
  end
end
