module Graph
  class QueryService
    class DatabaseError < StandardError; end

    def initialize(session: nil)
      @session = session || Graph::Connection.session
    end

    def projects
      run(
        <<~CYPHER
          MATCH (p:Project)
          OPTIONAL MATCH (p)-[r:REQUIRES_SKILL]->(s:Skill)
          RETURN
            p.id AS id,
            p.name AS name,
            p.description AS description,
            p.status AS status,
            collect({
              id: s.id,
              name: s.name,
              category: s.category,
              importance: r.importance
            }) AS skills
          ORDER BY name
        CYPHER
      ).map { |record| record_to_hash(record) }
    end

    def project(id)
      record = run(
        <<~CYPHER,
          MATCH (p:Project {id: $id})
          OPTIONAL MATCH (p)-[r:REQUIRES_SKILL]->(s:Skill)
          RETURN
            p.id AS id,
            p.name AS name,
            p.description AS description,
            p.status AS status,
            collect({
              id: s.id,
              name: s.name,
              category: s.category,
              importance: r.importance
            }) AS skills
        CYPHER
        id: id
      ).first

      record && record_to_hash(record)
    end

    def developer_matches(project_id)
    run(
        <<~CYPHER,
        MATCH (p:Project {id: $project_id})-[:REQUIRES_SKILL]->(required:Skill)
        WITH p, collect(DISTINCT required) AS required_skills

        MATCH (d:Developer)-[hs:HAS_SKILL]->(skill:Skill)
        WHERE skill IN required_skills

        WITH
            d,
            required_skills,
            collect({
            name: skill.name,
            level: hs.level,
            years: hs.years
            }) AS skills,
            count(DISTINCT skill) AS matched_skills

        RETURN
            d.id AS id,
            d.name AS name,
            d.title AS title,
            d.location AS location,
            matched_skills,
            size(required_skills) AS total_skills,
            skills,
            CASE
            WHEN size(required_skills) = 0 THEN 0
            ELSE round(
                100.0 * matched_skills / size(required_skills)
            )
            END AS match_percentage

        ORDER BY match_percentage DESC, name
        CYPHER
        project_id: project_id
    ).map { |record| record_to_hash(record) }
    end

    def connected_developers(project_id)
      run(
        <<~CYPHER,
          MATCH (p:Project {id: $project_id})
                -[:REQUIRES_SKILL]->
                (s:Skill)
                <-[:HAS_SKILL]-
                (d:Developer)
          WITH d, count(DISTINCT s) AS shared_skills
          RETURN
            d.id AS id,
            d.name AS name,
            d.title AS title,
            d.location AS location,
            shared_skills
          ORDER BY shared_skills DESC, name
        CYPHER
        project_id: project_id
      ).map { |record| record_to_hash(record) }
    end

    def close
      @session&.close
      @session = nil
    end

    private

    def run(query, **params)
      @session.run(query, **params)
    rescue Neo4j::Driver::Exceptions::Neo4jException => e
      Rails.logger.error("Graph database error: #{e.class}: #{e.message}")
      raise DatabaseError, "Unable to query the graph database"
    end

    def record_to_hash(record)
    record.to_h.transform_keys(&:to_sym)
    end
  end
end