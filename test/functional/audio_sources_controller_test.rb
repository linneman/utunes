require 'test_helper'

class AudioSourcesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:audio_sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create audio_source" do
    assert_difference('AudioSource.count') do
      post :create, :audio_source => { }
    end

    assert_redirected_to audio_source_path(assigns(:audio_source))
  end

  test "should show audio_source" do
    get :show, :id => audio_sources(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => audio_sources(:one).id
    assert_response :success
  end

  test "should update audio_source" do
    put :update, :id => audio_sources(:one).id, :audio_source => { }
    assert_redirected_to audio_source_path(assigns(:audio_source))
  end

  test "should destroy audio_source" do
    assert_difference('AudioSource.count', -1) do
      delete :destroy, :id => audio_sources(:one).id
    end

    assert_redirected_to audio_sources_path
  end
end
