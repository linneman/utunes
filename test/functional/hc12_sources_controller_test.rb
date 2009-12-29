require 'test_helper'

class Hc12SourcesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:hc12_sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create hc12_source" do
    assert_difference('Hc12Source.count') do
      post :create, :hc12_source => { }
    end

    assert_redirected_to hc12_source_path(assigns(:hc12_source))
  end

  test "should show hc12_source" do
    get :show, :id => hc12_sources(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => hc12_sources(:one).id
    assert_response :success
  end

  test "should update hc12_source" do
    put :update, :id => hc12_sources(:one).id, :hc12_source => { }
    assert_redirected_to hc12_source_path(assigns(:hc12_source))
  end

  test "should destroy hc12_source" do
    assert_difference('Hc12Source.count', -1) do
      delete :destroy, :id => hc12_sources(:one).id
    end

    assert_redirected_to hc12_sources_path
  end
end
