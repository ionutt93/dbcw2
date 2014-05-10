-- For the second question
DROP TRIGGER IF EXISTS check_update ON gameOwn;
CREATE TRIGGER check_update
	AFTER UPDATE OR INSERT OF rating ON gameOwn
	FOR EACH ROW
	EXECUTE PROCEDURE check_rating_update();

CREATE OR REPLACE FUNCTION check_rating_update() RETURNS trigger AS $$
BEGIN 
	UPDATE game SET
        avgRate = (SELECT AVG(rating) FROM gameOwn WHERE gameOwn.gameId = NEW.gameId)
    WHERE id = NEW.gameId
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
