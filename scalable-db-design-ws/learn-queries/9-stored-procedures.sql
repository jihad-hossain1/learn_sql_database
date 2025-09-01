-- Skeleton for a function
CREATE OR REPLACE FUNCTION function_name(parameters)
RETURNS return_type AS $$
DECLARE
    -- Variable declarations
BEGIN
    -- SQL statements or logic
    RETURN some_value;
END;
$$ LANGUAGE plpgsql;


-- Post count for a user
CREATE OR REPLACE FUNCTION get_post_count(user_id INT)
RETURNS INT AS $$
DECLARE
    total_posts INT;
BEGIN
    SELECT COUNT(*) INTO total_posts FROM posts WHERE author_id = user_id;
    RETURN total_posts;
END;
$$ LANGUAGE plpgsql;


SELECT get_post_count(5);

-- Log a post view
CREATE OR REPLACE PROCEDURE log_post_view(p_post_id INT, p_user_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO post_view_logs (post_id, user_id) VALUES (p_post_id, p_user_id)
    ON CONFLICT DO NOTHING;
    
    UPDATE post_views
    SET count = count + 1
    WHERE id = p_post_id;
END;
$$;


CALL log_post_view(10, 3);

-- Recent Posts by a user
CREATE OR REPLACE FUNCTION recent_posts_by_user(p_user_id INT)
RETURNS TABLE(id INT, title TEXT, created_at TIMESTAMPTZ) AS $$
BEGIN
    RETURN QUERY
    SELECT id, title, created_at
    FROM posts
    WHERE author_id = p_user_id
    ORDER BY created_at DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM recent_posts_by_user(2);

-- Check user's role
CREATE OR REPLACE FUNCTION is_admin(p_user_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    user_role ROLE;
BEGIN
    SELECT role INTO user_role FROM users WHERE id = p_user_id;
    
    IF user_role = 'admin' THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT is_admin(1);



-- Triggers

-- Create a trigger function for create_post_view
CREATE OR REPLACE FUNCTION create_post_view()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO post_views (id, count)
  VALUE (NEW.id, 0);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER trigger_create_post_view
AFTER INSERT ON posts
FOR EACH ROW
EXECUTE FUNCTION create_post_view();

-- Test the trigger
INSERT INTO posts (title, content, author_id)
VALUES ('Test Post', 'Some content here', 1);

-- Drop the trigger and function
DROP TRIGGER trigger_create_post_view ON posts;
DROP FUNCTION create_post_view();


-- Trigger function for update_post_view_count
CREATE OR REPLACE FUNCTION update_post_view_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE post_views
  SET count = count + 1
  WHERE id = NEW.post_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_post_view_count
AFTER INSERT ON post_view_logs
FOR EACH ROW
EXECUTE FUNCTION update_post_view_count();