-- 1.Given a game, list all the users who own that game 
SELECT "user".username FROM "user", game, "gameOwn" WHERE 
    game.id = round((random() * 99) + 1) AND
    game.id = "gameOwn".gameId AND
    "gameOwn".userId = "user".id;

-- 2.Automatically update a game’s average rating whenever a user adds or updates their rating for that game
-- see triggers

-- 3.Change the database so that a game’s average rating only appears if it has been rated by 10 or more users.
-- see triggers

-- 4.Given a user and a game, display the user’s score, rank on that game’s leaderboard (even if they are outside the top 10) and an indication of where they appear relative to the average e.g. “85000 points - 1788 (Top 20%)” or “13000 points - 16364 (Bottom 40%)”.



-- 5.Create a list of the top 10 rated games in each genre/category.
SELECT category.name, game.name, "gameCat".rank FROM category, "gameCat", game WHERE
    category.id = "gameCat".catId AND
    "gameCat".gameId = game.id  
GROUP BY category.name, game.name, "gameCat".rank
ORDER BY "gameCat".rank DESC;

-- 6


-- 7. Add daily and weekly leaderboards for each game showing the best scores achieved this day or week.
SELECT * FROM (SELECT game.name, "user".username, MAX(gameOwn.highScore) as Daily FROM game, "user", gameOwn WHERE
    game.id = gameOwn.gameId AND
    gameOwn.userId = "user".id AND
    gameOwn.lastPlayed = current_date
GROUP BY game.name, "user".username, gameOwn.highScore
ORDER BY gameOwn.highScore DESC) AS dailyTable

CROSS JOIN

 (SELECT game.name, "user".username, MAX(gameOwn.highScore) as Weekly FROM game, "user", gameOwn WHERE
    game.id = gameOwn.gameId AND
    gameOwn.userId = "user".id AND
    gameOwn.lastPlayed >= (current_date - integer '7') AND
    gameOwn.lastPlayed <= current_date
GROUP BY game.name, "user".username, gameOwn.highScore
ORDER BY gameOwn.highScore DESC) AS weeklyTable;

-- 8

-- 9.The client wants to add a ‘Hot List’ which shows the 10 games, which have been played most often in the past week – add the necessary fields, tables, queries, triggers and/or procedures to achieve this.
-- we assummed that past week refers to the past 7 days from the current date
SELECT game.name FROM game, gameOwn WHERE
    game.id = gameOwn.gameId AND
    gameOwn.lastPlayed >= (current_date - integer '7') AND
    gameOwn.lastPlayed <= current_date
    GROUP BY game.name
    ORDER BY COUNT(gameOwn.lastPlayed) DESC
LIMIT 10

-- 10

-- 11

-- 12

-- 13

-- 14.Show a status screen for the player showing their username, status line, number of games owned, total number of achievement points and total number of friends.
SELECT "user".username, "user".status, COUNT(gameOwn.gameId) AS "noGamesOwn", SUM("gameAch".value) as "noAchPoints", COUNT(DISTINCT(friend.userId2)) as "noFriends" FROM "user", "gameAch", gameOwn, "gameOwnAch",friend WHERE
    "user".id = 11 AND
    gameOwn.userId = "user".id AND
    "gameOwnAch".gameOwn = gameOwn.id AND
    "gameOwnAch".achId = "gameAch".achId AND
    friend.userId1 = "user".id
GROUP BY "user".username, "user".status;

-- 15.Given a user and a game, list the achievements for that game (apart from ones which have the hidden flag set and the user hasn’t earned). They should be listed with ones the player has earned listed first. For each achievement, list the title, points, description (which will vary depending on whether the player has earned that title or not) and when the achievement was earned.
-- see functions












