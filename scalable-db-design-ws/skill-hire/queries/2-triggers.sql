-- Trigger to update applications_count
CREATE OR REPLACE FUNCTION update_job_applications_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE jobs SET applications_count = applications_count + 1 WHERE id = NEW.job_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE jobs SET applications_count = applications_count - 1 WHERE id = OLD.job_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_applications_count
    AFTER INSERT OR DELETE ON applications
    FOR EACH ROW EXECUTE FUNCTION update_job_applications_count();