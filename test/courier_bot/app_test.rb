require "test_helper"

class CourierBotAppTest < AppTestCase
  test 'POST /events with missing payload' do
    post '/events'

    assert_equal 400, last_response.status
  end

  test 'POST /events url_verification' do
    post_event type: 'url_verification', challenge: 'foobar'

    assert_equal 200, last_response.status
    assert_equal 'foobar', last_response.body
  end
end
