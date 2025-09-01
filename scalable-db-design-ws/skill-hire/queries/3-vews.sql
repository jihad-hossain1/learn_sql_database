-- For top freelancers
CREATE MATERIALIZED VIEW top_freelancers AS
SELECT 
    u.id,
    fp.name,
    u.average_rating,
    COUNT(p.id) as completed_projects
FROM users u
JOIN freelancer_profiles fp ON u.id = fp.id
LEFT JOIN projects p ON u.id = p.freelancer_id AND p.status = 'completed'
WHERE u.user_type = 'freelancer' AND u.account_status = 'active'
GROUP BY u.id, fp.name, u.average_rating
ORDER BY u.average_rating DESC, completed_projects DESC;

CREATE INDEX idx_top_freelancers_rating ON top_freelancers(average_rating);