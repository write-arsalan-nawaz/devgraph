require "neo4j_ruby_driver"

module Graph
  class Connection
    class << self
      def driver
        @driver ||= Neo4j::Driver::GraphDatabase.driver(
          ENV.fetch("COGNODB_URI"),
          Neo4j::Driver::AuthTokens.basic(
            ENV.fetch("COGNODB_USERNAME"),
            ENV.fetch("COGNODB_PASSWORD")
          )
        )
      end

      def session
        driver.session
      end

      def close
        @driver&.close
        @driver = nil
      end
    end
  end
end