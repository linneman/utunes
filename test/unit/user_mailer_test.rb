require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "confirm" do
    @expected.subject = 'UserMailer#confirm'
    @expected.body    = read_fixture('confirm')
    @expected.date    = Time.now

    assert_equal @expected.encoded, UserMailer.create_confirm(@expected.date).encoded
  end

end
