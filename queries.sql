-- 1.Given a game, list all the users who own that game 
SELECT "user".username FROM "user", game, "gameOwn" WHERE 
	game.name = (SELECT game.name FROM game WHERE game.id = ((random() * 99) + 1)) AND
	game.id = "gameOwn".gameID AND
	"gameOwn".userID = user.ID

-- 2.Automatically update a game’s average rating whenever a user adds or updates their rating for that game