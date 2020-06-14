require "test_helper"

class CourierBotTest < Minitest::Test
  test 'has version number' do
    refute_nil ::CourierBot::VERSION
  end
end
