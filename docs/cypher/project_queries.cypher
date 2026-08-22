-- 1. List projects and their required skills
MATCH (p:Project)-[r:REQUIRES_SKILL]->(s:Skill)
RETURN
  p.name AS project,
  s.name AS skill,
  r.importance AS importance
ORDER BY p.name, s.name;


-- 2. Find developers who match a project's required skills
MATCH (p:Project {id: $project_id})-[:REQUIRES_SKILL]->(required:Skill)
MATCH (d:Developer)-[hs:HAS_SKILL]->(required)
WITH p, d, count(required) AS matched_skills,
     collect({
       name: required.name,
       level: hs.level,
       years: hs.years
     }) AS skills
MATCH (p)-[:REQUIRES_SKILL]->(all_required:Skill)
WITH p, d, matched_skills, skills,
     count(DISTINCT all_required) AS total_skills
RETURN
  d.name AS developer,
  matched_skills,
  total_skills,
  round(100.0 * matched_skills / total_skills) AS match_percentage,
  skills
ORDER BY match_percentage DESC;


-- 3. Multi-hop: developers connected to a project
-- through the project's required skills.
MATCH (p:Project {id: $project_id})
      -[:REQUIRES_SKILL]->
      (s:Skill)
      <-[:HAS_SKILL]-
      (d:Developer)
RETURN
  d.name AS developer,
  count(DISTINCT s) AS shared_skills
ORDER BY shared_skills DESC;