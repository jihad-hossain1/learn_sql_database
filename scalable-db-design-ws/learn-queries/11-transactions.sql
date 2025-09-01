-- Transaction skeleton
BEGIN;
-- SQL operations

ROLLBACK; -- Undo changes

COMMIT; -- Save changes



BEGIN;

INSERT INTO categories (name) VALUES ('Technology');
INSERT INTO categories (name) VALUES ('Science');

COMMIT;

BEGIN;

INSERT INTO categories (name) VALUES ('Temporary');
-- Oops, duplicate primary key or constraint error occurs

ROLLBACK;

-- Inserting a post and a view in a single transaction
BEGIN;

INSERT INTO posts (title, content, author_id) 
VALUES ('Transaction Demo', 'Content', 1)
RETURNING id;

-- Use returned id (assume it's 5)

INSERT INTO post_views (id, count) VALUES (5, 0);

COMMIT;


-- Savepoint
BEGIN;

INSERT INTO categories (name) VALUES ('Main Category');

SAVEPOINT step1;

-- This fails, but we only roll back to savepoint
INSERT INTO categories (id, name) VALUES (1, 'Duplicate');

ROLLBACK TO step1;

-- Continue transaction
INSERT INTO categories (name) VALUES ('Backup Category');

COMMIT;


-- Function by default is a transaction
CREATE OR REPLACE PROCEDURE simple_create_post_with_views(
    p_title TEXT,
    p_content TEXT,
    p_author_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_post_id INT;
BEGIN
    INSERT INTO posts (title, content, author_id)
    VALUES (p_title, p_content, p_author_id)
    RETURNING id INTO new_post_id;

    INSERT INTO post_views (id, count)
    VALUES (new_post_id, 0);

    -- Simulate failure
    IF p_title IS NULL THEN
        RAISE EXCEPTION 'Post title cannot be NULL';
    END IF;

    RAISE NOTICE 'Post and post_views inserted successfully with ID: %', new_post_id;
END;
$$;

-- We can have transactions inside functions but won't have that much control over them
CREATE OR REPLACE PROCEDURE create_post_with_views(
    p_title TEXT,
    p_content TEXT,
    p_author_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_post_id INT;
BEGIN
    -- Begin Transaction Block
    BEGIN
        INSERT INTO posts (title, content, author_id)
        VALUES (p_title, p_content, p_author_id)
        RETURNING id INTO new_post_id;

        INSERT INTO post_views (id, count)
        VALUES (new_post_id, 0);

        -- Simulate an error
        IF p_title IS NULL THEN
            RAISE EXCEPTION 'Post title cannot be NULL';
        END IF;

        -- If everything is fine, continue
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error occurred, rolling back this block';
            ROLLBACK;
            RETURN;
    END;

    -- Continue with other logic (this part won't run if rollback happens)
    RAISE NOTICE 'Post and view inserted successfully with ID: %', new_post_id;

END;
$$;

-- Partial Rollback
CREATE OR REPLACE PROCEDURE partial_rollback_demo(
    p_title TEXT,
    p_content TEXT,
    p_author_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_post_id INT;
BEGIN
    -- Always insert the post
    INSERT INTO posts (title, content, author_id)
    VALUES (p_title, p_content, p_author_id)
    RETURNING id INTO new_post_id;

    -- Try to insert post_views with error handling
    BEGIN
        INSERT INTO post_views (id, count)
        VALUES (new_post_id, 0);

        -- Simulate error for demonstration
        IF new_post_id % 2 = 0 THEN
            RAISE EXCEPTION 'Simulated post_views failure';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Failed to insert post_views, continuing...';
            -- Only post_views rollback
    END;

    RAISE NOTICE 'Procedure completed, post exists, post_views may or may not exist';
END;
$$;