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
	IF (TG_OP = 'DELETE') THEN
		IF (SELECT COUNT(*) FROM gameOwn WHERE gameOwn.gameID=OLD.ID ) <= 10 THEN
			UPDATE game SET
				avgRate = NULL
			WHERE id = OLD.gameID;
		END IF;
		RETURN OLD;
	ELSEIF(TG_OP = 'INSERT') THEN
		IF (SELECT COUNT(*) FROM gameOwn WHERE gameOwn.gameID=NEW.ID ) > 10 THEN
			UPDATE game SET
				avgRate = avgRate = (SELECT AVG(rating) FROM gameOwn WHERE gameOwn.gameId = NEW.gameId)
    		WHERE id = NEW.gameId;
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

-- For question 4
-- CREATE OR REPLACE FUNCTION change_rank() RETURNS trigger AS $$
-- BEGIN 
-- 	-- Find the first user whose highScore is above the new highScore
-- 	-- TO BE TESTED
-- 	SELECT highScore,rank FROM (SELECT (*) FROM gameOwn WHERE highScore > NEW.highScore AND gameId = NEW.gameID) WHERE highScore = 
-- 	SELECT MIN(highScore) FROM (SELECT (*) FROM gameOwn WHERE highScore > NEW.highScore AND gameId = NEW.gameID) AND gameID = NEW.gameID

-- END;
-- $$ LANGUAGE plpgsql;

-- DROP TRIGGER IF EXISTS update_rank ON gameOwn;
-- CREATE TRIGGER update_rank
-- 	AFTER UPDATE OF highScore ON gameOwn
-- 	FOR EACH ROW 
-- 	EXECUTE PROCEDURE change_rank();

--Question 6
CREATE OR REPLACE FUNCTION check_score_range() RETURNS trigger AS $$
BEGIN 
	IF (SELECT highScore FROM gameOwn WHERE ID=NEW.ID) < (SELECT minimum FROM game WHERE ID=NEW.gameID) THEN
		RAISE NOTICE 'New Highscore is too low.';
	ELSEIF (SELECT highScore FROM gameOwn WHERE ID=NEW.ID) > (SELECT maximum FROM game WHERE ID=NEW.gameID) THEN
		RAISE NOTICE 'New Highscore is too high.';
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_score ON gameOwn;
CREATE TRIGGER check_score
	AFTER UPDATE OF highScore ON gameOwn
	FOR EACH ROW
	EXECUTE PROCEDURE check_score_range();