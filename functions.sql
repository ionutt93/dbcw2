-- Question 4
CREATE OR REPLACE FUNCTION q4(IN username varchar(255), IN gamename character varying) 
RETURNS table(op varchar(255)) AS $$
DECLARE
    op character varying;
    totalu int;
    ranku int;
    highscoreu int;
BEGIN 
    totalu := count(highscore) FROM gameOwn JOIN game ON game.name = q4.gamename 
        AND game.id = gameOwn.gameid;
    SELECT INTO ranku,highscoreu sq.rank,sq.highscore FROM
    (SELECT row_number() OVER (ORDER BY highscore DESC) AS rank,
        highscore,u.username FROM gameOwn
    JOIN "user" u ON u.id = gameOwn.userid
    JOIN game ON game.id = gameown.gameid AND game.name = q4.gamename) AS sq 
    WHERE sq.username = q4.username;
    q4.op := format('%s points - %s',highscoreu,ranku);
    RETURN next;
END;
$$ LANGUAGE plpgsql;
