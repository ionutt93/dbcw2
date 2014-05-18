-- 1.Given a game, list all the users who own that game 
SELECT * FROM q(10);

-- 2.Automatically update a game’s average rating whenever a user adds or updates their rating for that game
-- see triggers

-- 3.Change the database so that a game’s average rating only appears if it has been rated by 10 or more users.
-- see triggers

-- 4.Given a user and a game, display the user’s score, rank on that game’s leaderboard (even if they are outside the top 10) and an indication of where they appear relative to the average e.g. “85000 points - 1788 (Top 20%)” or “13000 points - 16364 (Bottom 40%)”.



-- 5.Create a list of the top 10 rated games in each genre/category.
SELECT category.name, game.name, "gameCat".rank FROM category, "gameCat", game WHERE
    category.id = "gameCat".catId AND
    "gameCat".gameId = game.id AND
    "gameCat".rank < 11 
ORDER BY category.name,"gameCat".rank;

-- 6


-- 7. Add daily and weekly leaderboards for each game showing the best scores achieved this day or week.
SELECT * FROM q7('weekly') -- for weekly leaderbords
SELECT * FROM q7('daily') -- for daily leaderbords

-- 8

-- 9.The client wants to add a ‘Hot List’ which shows the 10 games, which have been played most often in the past week – add the necessary fields, tables, queries, triggers and/or procedures to achieve this.
-- we assummed that past week refers to the past 7 days from the current date
SELECT game.name, COUNT("gameTime".playedOn::date) FROM game, gameOwn, "gameTime" WHERE
    game.id = gameOwn.gameId AND
    "gameTime".gameOwnId = gameOwn.id AND
    "gameTime".playedOn::date >= (current_date - integer '7') AND
    "gameTime".playedOn::date <= current_date
    GROUP BY game.name
    ORDER BY COUNT("gameTime".playedOn) DESC
LIMIT 10;

-- 10

-- 11

-- 12

-- 13

-- 14.Show a status screen for the player showing their username, status line, number of games owned, total number of achievement points and total number of friends.
-- see functions 
SELECT * FROM q14(11);

-- 15.Given a user and a game, list the achievements for that game (apart from ones which have the hidden flag set and the user hasn’t earned). They should be listed with ones the player has earned listed first. For each achievement, list the title, points, description (which will vary depending on whether the player has earned that title or not) and when the achievement was earned.
-- see functions
SELECT * FROM q15(1, 13);











