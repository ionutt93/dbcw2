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

-- Question 13
DROP FUNCTION IF EXISTS show_achievements(character varying,integer);
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
    SELECT count(ID) INTO total_achievements FROM "gameAch" WHERE "gameAch".gameID=gameid_f;
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


-- Question 16
DROP FUNCTION common_games(character varying,character varying);
CREATE OR REPLACE FUNCTION common_games(
    IN user1 character varying, --username 1st user
    IN user2 character varying) --username 2nd user
RETURNS TABLE(game_name character varying, no_achievements1 int, no_achievements2 int) AS $$
DECLARE
    userid1_f int;
    userid2_f int;
    total int;
BEGIN
    -- get id for user1 & user2
    SELECT INTO userid1_f ID FROM "user" WHERE username = user1;
    SELECT INTO userid2_f ID FROM "user" WHERE username = user2;
    
    -- throw exception is users are not friends
    --IF (SELECT status FROM friend WHERE userId1 = userid1_f AND userId2 = userid2_f) != 'accepted' THEN
    --    RAISE EXCEPTION 'Users are not friends.';
    --END IF;

    --temporary tables
    DROP TABLE IF EXISTS game_first, game_second, common;
    CREATE TEMPORARY TABLE game_first(
        game_id int,
        achievement int
    );
    CREATE TEMPORARY TABLE game_second(
        game_id int,
        achievement int
    );
    CREATE TEMPORARY TABLE common(
        game_id int,
        game_name varchar(255),
        user_a_ach int DEFAULT NULL,
        user_b_ach int DEFAULT NULL
    );

    --game ids for first user
    INSERT INTO game_first (game_id) SELECT gameID FROM gameOwn WHERE userID = userid1_f;
    --game ids for second user
    INSERT INTO game_second(game_id) SELECT gameID FROM gameOwn WHERE userID = userid2_f;
    
    --common games id
    INSERT INTO common(game_id) SELECT game_first.game_id FROM game_first INNER JOIN game_second ON game_first.game_id = game_second.game_id;

    --games only first user owns
    INSERT INTO common(game_id) (SELECT game_first.game_id FROM game_first EXCEPT SELECT common.game_id FROM common);
    --games only second user owns
    INSERT INTO common(game_id) (SELECT game_second.game_id FROM game_second EXCEPT SELECT common.game_id FROM common);

    -- get game names
    UPDATE common SET game_name = (SELECT game.name FROM game WHERE common.game_id = game.ID);

    --calculate achievement points for common games for each user
    UPDATE common SET user_a_ach = (SELECT COUNT(value) FROM "gameAch" WHERE achID IN (SELECT achID from "gameOwnAch" WHERE "gameOwnAch".gameOwn IN (SELECT ID FROM gameOwn WHERE userID = userid1_f AND gameOwn.gameID = common.game_id)));
    UPDATE common SET user_b_ach = (SELECT COUNT(value) FROM "gameAch" WHERE achID IN (SELECT achID from "gameOwnAch" WHERE "gameOwnAch".gameOwn IN (SELECT ID FROM gameOwn WHERE userID = userid2_f AND gameOwn.gameID = common.game_id)));

    RETURN QUERY (SELECT common.game_name, common.user_a_ach, common.user_b_ach FROM common);
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

-- THE FOLLOWING FUNCTION IS NO LONGER NEEDED
-- BUT MAY BE USEFUL IN THE FUTURE
CREATE OR REPLACE FUNCTION mutual_friends(
    IN username1 character varying, -- my username
    IN username2 character varying)
RETURNS int AS $$
DECLARE
    no int;
BEGIN
    SELECT array_length( 
        array(
            SELECT unnest(my_friends(username1)) 
            INTERSECT 
            SELECT unnest(my_friends(username2))
    ),1) INTO no;
    IF no >= 0 THEN
        RETURN no;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Question 18
CREATE OR REPLACE FUNCTION common_games_users(
    IN username character varying) -- my username
RETURNS TABLE(no int, userid int) AS $$
DECLARE
    myuserid int;
BEGIN
    SELECT id INTO myuserid FROM "user" AS u WHERE u.username = common_games_users.username;
    RETURN QUERY SELECT count(g2.userid)::int AS count,
        g2.userid AS userid 
        FROM gameown AS g1,gameown AS g2 
        WHERE g1.gameid = g2.gameid 
        GROUP BY g2.userid,g1.userid 
        HAVING g1.userid = myuserid AND g2.userid != myuserid
        ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION common_friends_users(
    IN username character varying) -- my username
RETURNS TABLE(no int, userid int) AS $$
DECLARE
    myuserid int;
    added_friends int[];
BEGIN
    SELECT id INTO myuserid FROM "user" AS u WHERE u.username = common_friends_users.username;
    SELECT array_agg(userid2) INTO added_friends FROM friend WHERE userid1 = myuserid;
    RETURN QUERY 
        SELECT sum(q.count)::int,q.userid::int FROM (
            (SELECT count(g2.userid1)::int,g2.userid1 AS userid FROM friend AS g1,friend AS g2 
            WHERE g1.userid2 = g2.userid2 
            GROUP BY g2.userid1,g1.userid1 
            HAVING g1.userid1 = myuserid AND g2.userid1 != myuserid
            ORDER BY count DESC)
            UNION
            (SELECT count(g2.userid2)::int,g2.userid2 AS userid FROM friend AS g1,friend AS g2 
            WHERE g1.userid2 = g2.userid1 AND g2.userid1 = any(added_friends)
            GROUP BY g2.userid2
            ORDER BY count DESC)) AS q
        GROUP BY q.userid;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION suggest_friend(
    IN username character varying) -- my username
RETURNS TABLE(usernamer character varying,
    common_friends_no int, 
    common_games_no int) AS $$
BEGIN
    RETURN QUERY SELECT u.username,sum(q.cf)::int,sum(q.cg)::int FROM (
        SELECT 0 AS cf,no AS cg,userid FROM common_games_users(suggest_friend.username)
        UNION
        SELECT no AS cf,0 AS cg,userid FROM common_friends_users(suggest_friend.username)
    ) AS q
    JOIN "user" u ON u.id = q.userid 
    GROUP BY u.username
    ORDER BY (sum(q.cf)+sum(q.cg)) DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION suggest_game(
    IN username character varying) -- my username
RETURNS character varying AS $$
DECLARE
    friends text[];
    myuid int;
    gid int;
    mygameids int[];
    gamename character varying;
BEGIN
    SELECT INTO myuid id FROM "user" AS u WHERE u.username = suggest_game.username;
    IF myuid IS NULL THEN
        RAISE EXCEPTION 'User not found';
    END IF;
    SELECT INTO mygameids array_agg(gameOwn.gameid) FROM gameOwn WHERE gameOwn.userid = myuid;
    SELECT game.name INTO gamename
        FROM friend
        JOIN gameOwn ON gameOwn.userid = 
            (array_remove(array[friend.userid1,friend.userid2],myuid))[1]
            AND gameOwn.userid != myuid
        JOIN game ON game.id = gameOwn.gameid
        WHERE myuid IN (friend.userid1,friend.userid2) AND gameOwn.gameid != all(mygameids)
        GROUP BY game.name ORDER BY count(game.name) DESC LIMIT 1;
    IF gamename IS NULL THEN
        RAISE EXCEPTION 'Not enough friends or they all own the same games';
    END IF;
    RETURN gamename;
END;
$$ LANGUAGE plpgsql;

