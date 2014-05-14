-- Question 4
CREATE OR REPLACE FUNCTION q4(IN username varchar(255), IN gamename character varying) 
RETURNS table(op varchar(255)) AS $$ 
DECLARE
    op character varying;
    totalu int;
    ranku int;
    highscoreu int;
    pc int;
    pctext character varying;
BEGIN 
    totalu := count(highscore) FROM gameOwn JOIN game ON game.name = q4.gamename 
        AND game.id = gameOwn.gameid;
    SELECT INTO ranku,highscoreu sq.rank,sq.highscore FROM
    (SELECT row_number() OVER (ORDER BY highscore DESC) AS rank,
        highscore,u.username FROM gameOwn
    JOIN "user" u ON u.id = gameOwn.userid
    JOIN game ON game.id = gameown.gameid AND game.name = q4.gamename) AS sq 
    WHERE sq.username = q4.username;
    pc := 100*ranku/CAST(totalu AS double precision);
    pctext := 'Top';
    IF pc > 50 THEN
        pc := 100 - pc;
        pctext := 'Bottom';
    END IF;
    q4.op := format('%s points - %s (%s %s%%)',highscoreu,ranku,pctext,pc);
    RETURN next;
END;
$$ LANGUAGE plpgsql;


-- Question 10
CREATE OR REPLACE FUNCTION send_friend_request(
    IN username1 character varying, 
    IN username2 character varying,
    IN email character varying) 
RETURNS void AS $$
DECLARE
    target_id int;
    friend_status friendStatus;

BEGIN 
    SELECT INTO target_id id FROM "user" AS u 
    WHERE u.username = send_friend_request.username2 OR 
        u.email = send_friend_request.email;
    IF target_id IS NULL THEN
        RAISE EXCEPTION 'Cannot find user';
    END IF;

    SELECT friend.status INTO friend_status FROM friend
    JOIN "user" u1 ON u1.id = friend.userid1 AND u1.username = 
        send_friend_request.username1 AND friend.userid2 = target_id;

    IF friend_status IS NOT NULL THEN
        RAISE EXCEPTION 'Cannot send friend request, last attempt status is %', friend_status;
    END IF;
    INSERT INTO friend(userid1,userid2) VALUES (
        (SELECT id FROM "user" AS u WHERE u.username = send_friend_request.username1),
        target_id);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION friend_request_action(
    IN username1 character varying, -- my username
    IN username2 character varying, -- user who sent the request
    IN action friendStatus)
RETURNS void AS $$
DECLARE
    friend_id int;
BEGIN 
    SELECT friend.id INTO friend_id FROM friend
    JOIN "user" u1 ON u1.id = friend.userid1 AND u1.username = 
        friend_request_action.username2
    JOIN "user" u2 ON u2.id = friend.userid2 AND u2.username = 
        friend_request_action.username1 
    WHERE friend.status = 'awaiting'::friendStatus;

    IF friend_id IS NULL THEN
        RAISE EXCEPTION 'Cannot find request';
    END IF;
    UPDATE friend SET status = friend_request_action.action WHERE id = friend_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION me_or_game_friends(
    IN username character varying, -- my username
    IN gamename character varying) -- game name
RETURNS character varying[] AS $$
DECLARE
    friends text[];
BEGIN
    friends := array(
    SELECT 
        (array_remove(ARRAY[u1.username,u2.username],me_or_game_friends.username))[1]
    FROM friend
        JOIN "user" u1 ON u1.id = friend.userid1
        JOIN "user" u2 ON u2.id = friend.userid2
        WHERE me_or_game_friends.username IN (u1.username,u2.username));
    friends := array_append(friends,me_or_game_friends.username::text);
    RETURN friends;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION friend_leaderboard(
    IN username character varying, -- my username
    IN gamename character varying) -- game name
RETURNS TABLE(trank bigint, thighscore int, tusername character varying) AS $$
DECLARE
    myuid int;
    totalu int;
    friends character varying[];
BEGIN 
    friends :=  me_or_game_friends(friend_leaderboard.username,friend_leaderboard.gamename);
    SELECT INTO totalu count(highscore) FROM gameOwn JOIN game ON game.name = friend_leaderboard.gamename 
        AND game.id = gameOwn.gameid;
    SELECT INTO myuid id FROM "user" AS u WHERE u.username = friend_leaderboard.username;


    RETURN QUERY SELECT row_number() OVER (ORDER BY highscore DESC) AS rank,
        highscore,u.username FROM gameOwn
    JOIN "user" u ON u.id = gameOwn.userid
    JOIN game ON game.id = gameown.gameid AND game.name = friend_leaderboard.gamename
    WHERE u.username =  ANY(friends);
END;
$$ LANGUAGE plpgsql;

-- Question 13
DROP FUNCTION show_achievements(character varying,integer);
CREATE OR REPLACE FUNCTION show_achievements(
    IN username_f character varying, --username
    IN gameid_f int) --game name
RETURNS character varying AS $$ 
DECLARE
    total_achievements int;
    user_achievements int;
    user_id int;
    game_own_ach_id int;
    total_value int;

BEGIN
    -- count how many achievements a given game has
    SELECT count(ID) INTO total_achievements FROM "gameAch" WHERE "gameAch".ID=gameid_f;
    -- find user ID given username
    SELECT ID INTO user_id FROM "user" WHERE "user".username=username_f;
    -- select id from gameOwn
    SELECT ID INTO game_own_ach_id FROM gameOwn WHERE userID = user_id AND gameOwn.gameID = gameid_f;
    -- count how many achievements the user has unlocked
    SELECT COUNT(achID) INTO user_achievements from "gameOwnAch" WHERE "gameOwnAch".gameOwn = game_own_ach_id;
    -- count number of points the user has for this game
    total_value := COUNT(value) FROM "gameAch" WHERE achID IN (SELECT achID from "gameOwnAch" WHERE "gameOwnAch".gameOwn = game_own_ach_id);
    RETURN format('%s of %s achievements (%s points)', user_achievements, total_achievements, total_value);
END;
$$ LANGUAGE plpgsql;