require "test_helper"

class GraphConnectionTest < ActiveSupport::TestCase
  test "can connect to CognoDB" do
    session = Graph::Connection.session

    result = session.run("RETURN 1 AS value")
    record = result.single

    assert_equal 1, record["value"]
  ensure
    session&.close
  end
end
