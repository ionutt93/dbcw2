-- For the second question
CREATE OR REPLACE FUNCTION check_rating_update() RETURNS trigger AS $$
BEGIN 
	UPDATE game SET
        avgRate = (SELECT AVG(rating) FROM gameOwn WHERE gameOwn.gameId = NEW.gameId)
    WHERE id = NEW.gameId;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_update ON gameOwn;
CREATE TRIGGER check_update
	AFTER UPDATE OR INSERT ON gameOwn
	FOR EACH ROW
	EXECUTE PROCEDURE check_rating_update();

-- For the third question
CREATE OR REPLACE FUNCTION count_rating() RETURNS trigger AS $$
BEGIN 
	RAISE NOTICE '(%)', TG_OP;
	IF (TG_OP = 'DELETE') THEN
		RAISE NOTICE 'DELETE before';
		IF (SELECT COUNT(*) FROM gameOwn WHERE gameOwn.gameID=OLD.ID ) <= 10 THEN
			UPDATE game SET
				avgRate = NULL
			WHERE id = OLD.gameID;
			RAISE NOTICE 'DELETE';
		END IF;
		RETURN OLD;
	ELSEIF(TG_OP = 'INSERT') THEN
		IF (SELECT COUNT(*) FROM gameOwn WHERE gameOwn.gameID=NEW.ID ) > 10 THEN
			UPDATE game SET
				avgRate = avgRate = (SELECT AVG(rating) FROM gameOwn WHERE gameOwn.gameId = NEW.gameId)
    		WHERE id = NEW.gameId;
    		RAISE NOTICE 'INSERT';
		END IF;
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS show_rating ON gameOwn;
CREATE TRIGGER show_rating
	BEFORE INSERT OR DELETE ON gameOwn
	FOR EACH ROW
	EXECUTE PROCEDURE count_rating();
