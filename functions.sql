-- Question 1
CREATE OR REPLACE FUNCTION q1(IN game_id INTEGER)
RETURNS table( username character varying ) AS $$
BEGIN
    RETURN QUERY
        SELECT "user".username FROM "user", game, gameOwn WHERE 
            game.id = q1.game_id AND
            game.id = gameOwn.gameId AND
            gameOwn.userId = "user".id; 
END
$$ LANGUAGE plpgsql;

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

-- Question 7
CREATE OR REPLACE FUNCTION q7(IN param character varying)
RETURNS TABLE (
    f_game_name character varying,
    f_user_name character varying,
    f_highScore integer
    ) AS $$
BEGIN
    RETURN QUERY 
        SELECT game.name, username, "d_highScore" FROM
            (SELECT game.id as "d_gameId", MAX(highScore) as "d_highScore"
            FROM game, "user", gameOwn WHERE
                game.id = gameOwn.gameId AND
                "user".id = gameOwn.userId AND
                (CASE q7.param  
                    WHEN 'weekly' THEN date_ach::date >= (current_date - integer '7')
                    WHEN 'daily'  THEN date_ach::date = current_date END)
            GROUP BY game.id) as d_table, game, "user", gameOwn WHERE
                game.id = "d_gameId" AND
                gameId = game.id AND
                userId = "user".id AND
                highScore = "d_highScore"
            ORDER BY highScore DESC;
END
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


-- Question 11
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

-- Question 12
CREATE OR REPLACE FUNCTION my_friends(
    IN username character varying) -- my username
RETURNS character varying[] AS $$
DECLARE
    friends text[];
BEGIN
    friends := array(
    SELECT 
        (array_remove(ARRAY[u1.username,u2.username],my_friends.username))[1]
    FROM friend
        JOIN "user" u1 ON u1.id = friend.userid1
        JOIN "user" u2 ON u2.id = friend.userid2
        WHERE my_friends.username IN (u1.username,u2.username));
    RETURN friends;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION last_played(
    IN username character varying) -- my username
RETURNS character varying AS $$
DECLARE
    games character varying[];
BEGIN
    games := array(SELECT game.name FROM gameOwn
        JOIN game ON game.id = gameOwn.gameid
        JOIN "user" u ON u.id = gameOwn.userid
        ORDER BY lastplayed DESC
        LIMIT 1);
    IF array_length(games,1) = 0 THEN
        RETURN '';
    ELSE
        RETURN games[1];
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION friend_games(
    IN musername character varying) -- my username
RETURNS TABLE(fusername character varying,
    floggedin boolean,
    flastlogin timestamp with time zone,
    flastplayed character varying) AS $$
BEGIN
    RETURN QUERY SELECT username,
        loggedin,
        (CASE loggedin WHEN TRUE THEN NULL ELSE lastlogin END),
        (CASE loggedin WHEN TRUE THEN NULL ELSE last_played(u.username) END) 
        FROM "user" AS u 
        WHERE u.username = ANY(my_friends(friend_games.musername));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION q14(
    IN my_user_id integer)
RETURNS TABLE (
    n_username character varying,
    n_status text,
    n_games bigint,
    n_ach_points bigint,
    n_friends bigint
    ) AS $$
BEGIN
    RETURN QUERY
        SELECT firstT.username, firstT.status, firstT."gameNo", secondT."Total achievement points", secondT."No of friends" FROM (SELECT "user".username, "user".status, COUNT(gameOwn.gameId) AS "gameNo" FROM "user", gameOwn WHERE
        "user".id = q14.my_user_id AND
        gameOwn.userId = "user".id
        GROUP BY username, status) as firstT
    JOIN 
    (SELECT username, SUM("gameAch".value) AS "Total achievement points", COUNT(DISTINCT(friend.userId2)) AS "No of friends" FROM "user", gameOwn, "gameAch", "gameOwnAch", friend WHERE
        "user".id = q14.my_user_id AND
        gameOwn.userId = "user".id AND
        "gameOwnAch".gameOwn = gameOwn.id AND
        "gameOwnAch".achId = "gameAch".achId AND
        gameOwn.gameId = "gameAch".gameId AND
        friend.userId1 = "user".id AND
        friend.status = 'accepted'
        GROUP BY username) AS secondT
    ON firstT.userName = secondT.userName;
END
$$ LANGUAGE plpgsql;

DROP IF EXISTS FUNCTION q15(character varying,character varying);
CREATE OR REPLACE FUNCTION q15(
    IN my_user_id integer,
    IN my_game_id integer)
RETURNS TABLE (
    f_ach_title character varying,
    f_ach_value integer,
    f_description text,
    f_date_achieved timestamp with time zone) AS $$
BEGIN
    RETURN QUERY
        SELECT  ach.title,
                "gameAch".value,
                (CASE "gameOwnAch".dateAchieved != NULL WHEN TRUE THEN "gameAch".descrAfter ELSE "gameAch".descrBefore END),
                "gameOwnAch".dateAchieved
        FROM "user", game, "gameOwnAch", gameOwn, ach, "gameAch"
        WHERE "user".id = q15.my_user_id AND
             game.id = q15.my_game_id AND 
             "user".id = gameOwn.userId AND
              game.id = gameOwn.gameId AND
              gameOwn.id = "gameOwnAch".gameOwn AND
              "gameOwnAch".achId = ach.id AND
              "gameAch".achId = ach.id AND
              game.id = "gameAch".gameId AND
              "gameAch".show = true
        ORDER BY "gameOwnAch".dateAchieved;
END
$$ LANGUAGE plpgsql




