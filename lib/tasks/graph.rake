namespace :graph do
  desc "Seed DevGraph data into CognoDB"
  task seed: :environment do
    session = Graph::Connection.session

    puts "Seeding DevGraph..."

    session.run(<<~CYPHER)
      MATCH (n)
      DETACH DELETE n
    CYPHER

    session.run(<<~CYPHER)
      CREATE
        (:Company {id: "company-001", name: "TechWorks", industry: "Software"}),
        (:Company {id: "company-002", name: "CloudLabs", industry: "Cloud Computing"}),
        (:Company {id: "company-003", name: "DataFlow", industry: "Data & AI"}),
        (:Company {id: "company-004", name: "FinTech Solutions", industry: "Financial Technology"}),
        (:Company {id: "company-005", name: "HealthStack", industry: "Healthcare Technology"})
    CYPHER

    session.run(<<~CYPHER)
      CREATE
        (:Skill {id: "skill-001", name: "Ruby on Rails", category: "Backend"}),
        (:Skill {id: "skill-002", name: "Ruby", category: "Backend"}),
        (:Skill {id: "skill-003", name: "React", category: "Frontend"}),
        (:Skill {id: "skill-004", name: "TypeScript", category: "Frontend"}),
        (:Skill {id: "skill-005", name: "PostgreSQL", category: "Database"}),
        (:Skill {id: "skill-006", name: "Redis", category: "Infrastructure"}),
        (:Skill {id: "skill-007", name: "GraphQL", category: "API"}),
        (:Skill {id: "skill-008", name: "Python", category: "Backend"}),
        (:Skill {id: "skill-009", name: "FastAPI", category: "Backend"}),
        (:Skill {id: "skill-010", name: "AWS", category: "Cloud"}),
        (:Skill {id: "skill-011", name: "Docker", category: "Infrastructure"}),
        (:Skill {id: "skill-012", name: "Machine Learning", category: "AI"})
    CYPHER

    session.run(<<~CYPHER)
      CREATE
        (:Project {
          id: "project-001",
          name: "E-commerce Platform",
          description: "Scalable online commerce platform",
          status: "active"
        }),
        (:Project {
          id: "project-002",
          name: "Analytics Dashboard",
          description: "Real-time business analytics platform",
          status: "active"
        }),
        (:Project {
          id: "project-003",
          name: "Learning Platform",
          description: "Personalized online learning application",
          status: "active"
        }),
        (:Project {
          id: "project-004",
          name: "Payment Service",
          description: "Distributed payment processing service",
          status: "completed"
        }),
        (:Project {
          id: "project-005",
          name: "AI Recommendation Engine",
          description: "Machine learning recommendation system",
          status: "active"
        }),
        (:Project {
          id: "project-006",
          name: "Healthcare Portal",
          description: "Patient-facing healthcare platform",
          status: "active"
        })
    CYPHER

    session.run(<<~CYPHER)
      CREATE
        (:Developer {
          id: "dev-001",
          name: "Alice Khan",
          title: "Senior Full Stack Engineer",
          location: "Lahore"
        }),
        (:Developer {
          id: "dev-002",
          name: "Bob Smith",
          title: "Backend Engineer",
          location: "London"
        }),
        (:Developer {
          id: "dev-003",
          name: "Sarah Ahmed",
          title: "Frontend Engineer",
          location: "Karachi"
        }),
        (:Developer {
          id: "dev-004",
          name: "David Wilson",
          title: "Platform Engineer",
          location: "Manchester"
        }),
        (:Developer {
          id: "dev-005",
          name: "Emma Brown",
          title: "Full Stack Engineer",
          location: "Berlin"
        }),
        (:Developer {
          id: "dev-006",
          name: "Omar Hassan",
          title: "Backend Engineer",
          location: "Dubai"
        }),
        (:Developer {
          id: "dev-007",
          name: "Maya Patel",
          title: "Data Engineer",
          location: "Bangalore"
        }),
        (:Developer {
          id: "dev-008",
          name: "James Taylor",
          title: "Cloud Engineer",
          location: "London"
        }),
        (:Developer {
          id: "dev-009",
          name: "Nadia Ali",
          title: "Software Engineer",
          location: "Islamabad"
        }),
        (:Developer {
          id: "dev-010",
          name: "Daniel Garcia",
          title: "Machine Learning Engineer",
          location: "Madrid"
        })
    CYPHER

    # Developer -> Skill
    session.run(<<~CYPHER)
      MATCH
        (alice:Developer {id: "dev-001"}),
        (bob:Developer {id: "dev-002"}),
        (sarah:Developer {id: "dev-003"}),
        (david:Developer {id: "dev-004"}),
        (emma:Developer {id: "dev-005"}),
        (omar:Developer {id: "dev-006"}),
        (maya:Developer {id: "dev-007"}),
        (james:Developer {id: "dev-008"}),
        (nadia:Developer {id: "dev-009"}),
        (daniel:Developer {id: "dev-010"}),

        (rails:Skill {id: "skill-001"}),
        (ruby:Skill {id: "skill-002"}),
        (react:Skill {id: "skill-003"}),
        (typescript:Skill {id: "skill-004"}),
        (postgres:Skill {id: "skill-005"}),
        (redis:Skill {id: "skill-006"}),
        (graphql:Skill {id: "skill-007"}),
        (python:Skill {id: "skill-008"}),
        (fastapi:Skill {id: "skill-009"}),
        (aws:Skill {id: "skill-010"}),
        (docker:Skill {id: "skill-011"}),
        (ml:Skill {id: "skill-012"})

      CREATE
        (alice)-[:HAS_SKILL {level: "expert", years: 6}]->(rails),
        (alice)-[:HAS_SKILL {level: "expert", years: 7}]->(ruby),
        (alice)-[:HAS_SKILL {level: "advanced", years: 5}]->(react),
        (alice)-[:HAS_SKILL {level: "advanced", years: 5}]->(postgres),
        (alice)-[:HAS_SKILL {level: "advanced", years: 4}]->(redis),

        (bob)-[:HAS_SKILL {level: "expert", years: 7}]->(ruby),
        (bob)-[:HAS_SKILL {level: "expert", years: 6}]->(postgres),
        (bob)-[:HAS_SKILL {level: "advanced", years: 4}]->(redis),
        (bob)-[:HAS_SKILL {level: "advanced", years: 4}]->(docker),

        (sarah)-[:HAS_SKILL {level: "expert", years: 5}]->(react),
        (sarah)-[:HAS_SKILL {level: "expert", years: 4}]->(typescript),
        (sarah)-[:HAS_SKILL {level: "advanced", years: 3}]->(graphql),

        (david)-[:HAS_SKILL {level: "expert", years: 6}]->(aws),
        (david)-[:HAS_SKILL {level: "expert", years: 5}]->(docker),
        (david)-[:HAS_SKILL {level: "advanced", years: 4}]->(redis),

        (emma)-[:HAS_SKILL {level: "advanced", years: 4}]->(rails),
        (emma)-[:HAS_SKILL {level: "advanced", years: 4}]->(react),
        (emma)-[:HAS_SKILL {level: "advanced", years: 3}]->(typescript),
        (emma)-[:HAS_SKILL {level: "advanced", years: 3}]->(postgres),

        (omar)-[:HAS_SKILL {level: "expert", years: 6}]->(python),
        (omar)-[:HAS_SKILL {level: "expert", years: 5}]->(fastapi),
        (omar)-[:HAS_SKILL {level: "advanced", years: 4}]->(postgres),
        (omar)-[:HAS_SKILL {level: "advanced", years: 3}]->(docker),

        (maya)-[:HAS_SKILL {level: "expert", years: 5}]->(python),
        (maya)-[:HAS_SKILL {level: "expert", years: 4}]->(ml),
        (maya)-[:HAS_SKILL {level: "advanced", years: 4}]->(postgres),

        (james)-[:HAS_SKILL {level: "expert", years: 7}]->(aws),
        (james)-[:HAS_SKILL {level: "expert", years: 5}]->(docker),
        (james)-[:HAS_SKILL {level: "advanced", years: 4}]->(redis),

        (nadia)-[:HAS_SKILL {level: "advanced", years: 4}]->(rails),
        (nadia)-[:HAS_SKILL {level: "advanced", years: 3}]->(ruby),
        (nadia)-[:HAS_SKILL {level: "advanced", years: 3}]->(postgres),
        (nadia)-[:HAS_SKILL {level: "intermediate", years: 2}]->(react),

        (daniel)-[:HAS_SKILL {level: "expert", years: 6}]->(python),
        (daniel)-[:HAS_SKILL {level: "expert", years: 5}]->(ml),
        (daniel)-[:HAS_SKILL {level: "advanced", years: 4}]->(aws)
    CYPHER

    # Developer -> Project
    session.run(<<~CYPHER)
      MATCH
        (alice:Developer {id: "dev-001"}),
        (bob:Developer {id: "dev-002"}),
        (sarah:Developer {id: "dev-003"}),
        (david:Developer {id: "dev-004"}),
        (emma:Developer {id: "dev-005"}),
        (omar:Developer {id: "dev-006"}),
        (maya:Developer {id: "dev-007"}),
        (james:Developer {id: "dev-008"}),
        (nadia:Developer {id: "dev-009"}),
        (daniel:Developer {id: "dev-010"}),

        (ecommerce:Project {id: "project-001"}),
        (analytics:Project {id: "project-002"}),
        (learning:Project {id: "project-003"}),
        (payment:Project {id: "project-004"}),
        (recommendations:Project {id: "project-005"}),
        (healthcare:Project {id: "project-006"})

      CREATE
        (alice)-[:WORKED_ON {role: "Lead Developer"}]->(ecommerce),
        (alice)-[:WORKED_ON {role: "Full Stack Engineer"}]->(learning),

        (bob)-[:WORKED_ON {role: "Backend Engineer"}]->(payment),
        (bob)-[:WORKED_ON {role: "Backend Engineer"}]->(ecommerce),

        (sarah)-[:WORKED_ON {role: "Frontend Engineer"}]->(ecommerce),
        (sarah)-[:WORKED_ON {role: "Frontend Engineer"}]->(learning),

        (david)-[:WORKED_ON {role: "Platform Engineer"}]->(payment),
        (david)-[:WORKED_ON {role: "Cloud Engineer"}]->(analytics),

        (emma)-[:WORKED_ON {role: "Full Stack Engineer"}]->(learning),
        (emma)-[:WORKED_ON {role: "Frontend Engineer"}]->(analytics),

        (omar)-[:WORKED_ON {role: "Backend Engineer"}]->(analytics),
        (omar)-[:WORKED_ON {role: "Backend Engineer"}]->(healthcare),

        (maya)-[:WORKED_ON {role: "Data Engineer"}]->(analytics),
        (maya)-[:WORKED_ON {role: "ML Engineer"}]->(recommendations),

        (james)-[:WORKED_ON {role: "Cloud Engineer"}]->(payment),
        (james)-[:WORKED_ON {role: "Platform Engineer"}]->(recommendations),

        (nadia)-[:WORKED_ON {role: "Backend Engineer"}]->(ecommerce),
        (nadia)-[:WORKED_ON {role: "Full Stack Engineer"}]->(healthcare),

        (daniel)-[:WORKED_ON {role: "ML Engineer"}]->(recommendations),
        (daniel)-[:WORKED_ON {role: "ML Engineer"}]->(analytics)
    CYPHER

    # Project -> Skill
    session.run(<<~CYPHER)
      MATCH
        (ecommerce:Project {id: "project-001"}),
        (analytics:Project {id: "project-002"}),
        (learning:Project {id: "project-003"}),
        (payment:Project {id: "project-004"}),
        (recommendations:Project {id: "project-005"}),
        (healthcare:Project {id: "project-006"}),

        (rails:Skill {id: "skill-001"}),
        (ruby:Skill {id: "skill-002"}),
        (react:Skill {id: "skill-003"}),
        (typescript:Skill {id: "skill-004"}),
        (postgres:Skill {id: "skill-005"}),
        (redis:Skill {id: "skill-006"}),
        (graphql:Skill {id: "skill-007"}),
        (python:Skill {id: "skill-008"}),
        (fastapi:Skill {id: "skill-009"}),
        (aws:Skill {id: "skill-010"}),
        (docker:Skill {id: "skill-011"}),
        (ml:Skill {id: "skill-012"})

      CREATE
        (ecommerce)-[:REQUIRES_SKILL {importance: "required"}]->(rails),
        (ecommerce)-[:REQUIRES_SKILL {importance: "required"}]->(postgres),
        (ecommerce)-[:REQUIRES_SKILL {importance: "required"}]->(react),
        (ecommerce)-[:REQUIRES_SKILL {importance: "preferred"}]->(redis),

        (analytics)-[:REQUIRES_SKILL {importance: "required"}]->(python),
        (analytics)-[:REQUIRES_SKILL {importance: "required"}]->(postgres),
        (analytics)-[:REQUIRES_SKILL {importance: "required"}]->(typescript),
        (analytics)-[:REQUIRES_SKILL {importance: "preferred"}]->(aws),

        (learning)-[:REQUIRES_SKILL {importance: "required"}]->(rails),
        (learning)-[:REQUIRES_SKILL {importance: "required"}]->(react),
        (learning)-[:REQUIRES_SKILL {importance: "preferred"}]->(graphql),

        (payment)-[:REQUIRES_SKILL {importance: "required"}]->(ruby),
        (payment)-[:REQUIRES_SKILL {importance: "required"}]->(postgres),
        (payment)-[:REQUIRES_SKILL {importance: "required"}]->(docker),
        (payment)-[:REQUIRES_SKILL {importance: "preferred"}]->(redis),

        (recommendations)-[:REQUIRES_SKILL {importance: "required"}]->(python),
        (recommendations)-[:REQUIRES_SKILL {importance: "required"}]->(ml),
        (recommendations)-[:REQUIRES_SKILL {importance: "preferred"}]->(aws),

        (healthcare)-[:REQUIRES_SKILL {importance: "required"}]->(rails),
        (healthcare)-[:REQUIRES_SKILL {importance: "required"}]->(postgres),
        (healthcare)-[:REQUIRES_SKILL {importance: "preferred"}]->(react),
        (healthcare)-[:REQUIRES_SKILL {importance: "preferred"}]->(graphql)
    CYPHER

    # Developer -> Company
    session.run(<<~CYPHER)
      MATCH
        (alice:Developer {id: "dev-001"}),
        (bob:Developer {id: "dev-002"}),
        (sarah:Developer {id: "dev-003"}),
        (david:Developer {id: "dev-004"}),
        (emma:Developer {id: "dev-005"}),
        (omar:Developer {id: "dev-006"}),
        (maya:Developer {id: "dev-007"}),
        (james:Developer {id: "dev-008"}),
        (nadia:Developer {id: "dev-009"}),
        (daniel:Developer {id: "dev-010"}),

        (techworks:Company {id: "company-001"}),
        (cloudlabs:Company {id: "company-002"}),
        (dataflow:Company {id: "company-003"}),
        (fintech:Company {id: "company-004"}),
        (healthstack:Company {id: "company-005"})

      CREATE
        (alice)-[:WORKED_AT {role: "Senior Engineer"}]->(techworks),
        (bob)-[:WORKED_AT {role: "Backend Engineer"}]->(fintech),
        (sarah)-[:WORKED_AT {role: "Frontend Engineer"}]->(techworks),
        (david)-[:WORKED_AT {role: "Platform Engineer"}]->(cloudlabs),
        (emma)-[:WORKED_AT {role: "Full Stack Engineer"}]->(techworks),
        (omar)-[:WORKED_AT {role: "Backend Engineer"}]->(healthstack),
        (maya)-[:WORKED_AT {role: "Data Engineer"}]->(dataflow),
        (james)-[:WORKED_AT {role: "Cloud Engineer"}]->(cloudlabs),
        (nadia)-[:WORKED_AT {role: "Software Engineer"}]->(healthstack),
        (daniel)-[:WORKED_AT {role: "ML Engineer"}]->(dataflow)
    CYPHER

    puts "DevGraph seed complete."
  ensure
    session&.close
  end
end