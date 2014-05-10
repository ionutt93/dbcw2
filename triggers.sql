-- For the second question
DROP TRIGGER IF EXISTS check_update ON "gameOwn";
CREATE TRIGGER check_update
	AFTER UPDATE OF rating ON "gameOwn"
	FOR EACH ROW
	EXECUTE PROCEDURE check_rating_update();

CREATE OR REPLACE FUNCTION check_rating_update() RETURNS trigger AS $$
BEGIN 
	insert into dimitri (name,rating) values ('Dimiri',NEW.rating);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
