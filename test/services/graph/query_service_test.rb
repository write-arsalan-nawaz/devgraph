require "test_helper"

class GraphQueryServiceTest < ActiveSupport::TestCase
  setup do
    @service = Graph::QueryService.new
  end

  teardown do
    @service.close
  end

  test "returns seeded projects" do
    projects = @service.projects

    assert_equal 6, projects.length
    assert projects.any? { |project| project[:name] == "AI Recommendation Engine" }
  end

  test "finds a project by id" do
    project = @service.project("project-005")

    assert_equal "AI Recommendation Engine", project[:name]
    assert_equal "active", project[:status]
  end

  test "finds developers by graph skill matching" do
    matches = @service.developer_matches("project-005")

    assert matches.any? { |developer| developer[:name] == "Daniel Garcia" }
    assert_equal 100, matches.first[:match_percentage]
  end

  test "finds developers through shared skill connections" do
    developers = @service.connected_developers("project-005")

    assert developers.any? { |developer| developer[:name] == "Daniel Garcia" }
  end
end