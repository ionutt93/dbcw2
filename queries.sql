-- 1.Given a game, list all the users who own that game 
SELECT "user".username FROM "user", game, "gameOwn" WHERE 
    game.id = round((random() * 99) + 1) AND
    game.id = "gameOwn".gameId AND
    "gameOwn".userId = "user".id;

-- 2.Automatically update a game’s average rating whenever a user adds or updates their rating for that game