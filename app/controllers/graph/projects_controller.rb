module Graph
  class ProjectsController < ApplicationController
    def index
      @projects = query_service.projects
    rescue StandardError => e
      Rails.logger.error("Graph database error: #{e.class}: #{e.message}")
      @projects = []
      @graph_error = "The graph database is temporarily unavailable."
    ensure
      query_service.close
    end

    def show
      @project = query_service.project(params[:id])

      if @project.nil?
        render :not_found, status: :not_found
        return
      end

      @matches = query_service.developer_matches(params[:id])
      @connected_developers = query_service.connected_developers(params[:id])
    rescue StandardError => e
      Rails.logger.error("Graph database error: #{e.class}: #{e.message}")
      @graph_error = "The graph database is temporarily unavailable."
    ensure
      query_service.close
    end

    private

    def query_service
      @query_service ||= Graph::QueryService.new
    end
  end
end