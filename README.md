# DevGraph

A graph-powered developer matching application built with Ruby on Rails and CognoDB.

DevGraph helps teams explore projects, understand their required skills, and identify developers whose experience matches those requirements.

## Use Case

A project is not simply a collection of independent requirements. Projects need combinations of skills, developers possess combinations of skills, and developers can also be connected to projects and companies through their previous experience.

DevGraph models these relationships explicitly and uses graph traversal to answer questions such as:

- Which developers match the skills required by a project?
- What percentage of a project's required skills does each developer have?
- Which developers are connected to a project through shared skills?
- Which developers have worked on related projects or at related companies?

The application provides a simple UI for exploring these relationships.

## Why a Graph Database?

The important part of this use case is the relationships between entities.

A relational implementation could represent developers, skills, projects, and companies using several tables and join tables. However, queries involving multiple relationship paths become increasingly join-heavy and harder to express as the domain grows.

With a graph database, the relationships are first-class data:

```text
Developer ──HAS_SKILL──> Skill <──REQUIRES_SKILL── Project
    │                                      │
    ├──WORKED_AT──> Company                │
    │                                      │
    └──WORKED_ON──────────────────────────>┘
```

For example, finding developers connected to a project through a shared skill is naturally expressed as:

```cypher
MATCH (p:Project {id: $project_id})
      -[:REQUIRES_SKILL]->
      (s:Skill)
      <-[:HAS_SKILL]-
      (d:Developer)
RETURN d.name, count(DISTINCT s) AS shared_skills
ORDER BY shared_skills DESC;
```

This multi-hop traversal is one of the main reasons the graph model fits the problem.

## Data Model

```text
                         ┌─────────────┐
                         │   Company   │
                         └──────┬──────┘
                                │
                            WORKED_AT
                                │
                                ▼
┌─────────────┐             ┌─────────────┐
│  Developer  │────────────>│    Skill    │
└──────┬──────┘  HAS_SKILL  └──────▲──────┘
       │                            │
   WORKED_ON                        │
       │                       REQUIRES_SKILL
       ▼                            │
┌─────────────┐                     │
│   Project   │─────────────────────┘
└─────────────┘
```

### Nodes

| Label | Important properties |
|---|---|
| `Developer` | `id`, `name`, `title`, `location` |
| `Skill` | `id`, `name`, `category` |
| `Project` | `id`, `name`, `description`, `status` |
| `Company` | `id`, `name`, `industry` |

### Relationships

| Relationship | Properties |
|---|---|
| `HAS_SKILL` | `level`, `years` |
| `REQUIRES_SKILL` | `importance` |
| `WORKED_ON` | `role` |
| `WORKED_AT` | `role` |

## Architecture

```text
Browser
   │
   ▼
Rails Controller
   │
   ▼
Graph::QueryService
   │
   ▼
Neo4j Ruby Driver
   │
   ▼
CognoDB
```

The application uses the official Neo4j Ruby driver to communicate with CognoDB over Bolt.

The graph access is isolated in `Graph::QueryService`, keeping Cypher and database-specific logic separate from the controllers and views.

## Technology Stack

- Ruby 3.4.6
- Rails 8.1
- CognoDB
- Neo4j Ruby Driver
- ERB
- CSS
- Minitest

## Getting Started

### Requirements

- Ruby 3.4+
- Bundler
- A CognoDB Cloud instance

### 1. Clone the repository

```bash
git clone https://github.com/write-arsalan-nawaz/devgraph.git
cd devgraph
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Create a CognoDB instance

Create a free CognoDB Cloud instance from:

https://console.cognodb.com/signup

Create a free `c0` instance.

CognoDB provides a Bolt connection URI similar to:

```text
bolt+s://<instance-id>.databases.cognodb.cloud
```

The generated password for the `cognodb` user is shown once, so store it securely.

### 4. Configure environment variables

Copy the example environment file:

```bash
cp .env.example .env
```

Set:

```text
COGNODB_URI=bolt+s://<instance-id>.databases.cognodb.cloud
COGNODB_USERNAME=cognodb
COGNODB_PASSWORD=<your-password>
```

Do not commit `.env` or any database credentials.

### 5. Seed the graph

Run:

```bash
bin/rails graph:seed
```

The seed task creates realistic sample data containing:

- 5 companies
- 12 skills
- 6 projects
- 10 developers
- developer/skill relationships
- project/skill relationships
- developer/project relationships
- developer/company relationships

The seed task is located at:

```text
lib/tasks/graph.rake
```

### 6. Start the application

```bash
bin/rails server
```

Open:

```text
http://localhost:3000
```

## Main Graph Queries

The application uses parameterised Cypher queries through the Neo4j driver.

### List projects and required skills

Projects are matched with their required skills and relationship properties:

```cypher
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
```

### Developer skill matching

For a selected project, the application finds developers who have one or more of the required skills and calculates a match percentage.

The project ID is passed as a Cypher parameter:

```cypher
MATCH (p:Project {id: $project_id})-[:REQUIRES_SKILL]->(required:Skill)
```

The query then compares the project's required skills with each developer's `HAS_SKILL` relationships.

### Multi-hop developer connection

The application also traverses:

```text
Project → Skill → Developer
```

using:

```cypher
MATCH (p:Project {id: $project_id})
      -[:REQUIRES_SKILL]->
      (s:Skill)
      <-[:HAS_SKILL]-
      (d:Developer)
```

This identifies developers connected to a project through shared skills and counts the number of shared skills.

This is a graph-oriented traversal that would require relationship/join-table logic in a relational implementation.

## Parameterised Queries

Application queries never concatenate user input into Cypher.

For example:

```ruby
@session.run(query, project_id: project_id)
```

with Cypher using:

```cypher
$project_id
```

This keeps query structure separate from input values.

## Error Handling

Database operations are wrapped in a dedicated service error boundary.

If the graph database raises a Neo4j driver exception, the service logs the underlying error and raises a generic application-level `DatabaseError`.

The web layer then presents a user-friendly database unavailable message instead of exposing database errors to the user.

## Testing

Run the test suite with:

```bash
bin/rails test
```

Current test coverage verifies:

- seeded projects can be queried
- projects can be retrieved by ID
- developers can be matched by project skills
- developers can be discovered through shared graph connections

## Project Structure

```text
app/
├── controllers/
│   └── graph/
│       └── projects_controller.rb
├── services/
│   └── graph/
│       └── query_service.rb
└── views/
    └── graph/
        └── projects/
            ├── index.html.erb
            ├── show.html.erb
            └── not_found.html.erb

docs/
└── cypher/
    └── project_queries.cypher

lib/
└── tasks/
    └── graph.rake

test/
└── services/
    └── graph/
        └── query_service_test.rb
```

## Screenshots

### Project Explorer

_Add screenshot here._

### Project Details and Developer Matching

_Add screenshot here._

## Demo

Hosted demo:

_Add deployed application URL here._

## Submission

GitHub repository:

https://github.com/write-arsalan-nawaz/devgraph

The application is built specifically for the Wexa AI CognoDB take-home assignment.
