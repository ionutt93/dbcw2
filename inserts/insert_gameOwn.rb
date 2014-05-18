require 'faker'
require 'digest/sha1'
require 'rubystats'
salt = 'saltysalt'

n = 100

date_min = Date.new(2014,05,01).to_time.to_i
date_max = Date.new(2014,05,20).to_time.to_i
puts 'INSERT INTO gameOwn 
(userID,gameID,rating,comment,lastPlayed,date_ach,highScore) VALUES '
n.times do |i|
    user_id = i+1
    games_owned = []
    rand(10).times do
    	game_id = rand(30) + 1
    	while games_owned.include?(game_id)
    		game_id = rand(30) + 1
    	end
    	games_owned[games_owned.count] = game_id

    	last_played =  Time.at(rand(date_max - date_min) + date_min).strftime "%Y-%m-%d %H:%M:%S"
        date_ach =  Time.at(rand(date_max - date_min) + date_min).strftime "%Y-%m-%d %H:%M:%S"
	    comment = Faker::Lorem.words(20).join(" ")
	    
	    high = Rubystats::NormalDistribution.new(100,20).rng.round
	    rating = [1,[Rubystats::NormalDistribution.new(3.5,1).rng.round,5].min].max
    	
    	puts "(#{user_id},#{game_id},#{rating},'#{comment}','#{last_played} BST' :: timestamp with time zone,'#{date_ach} BST' :: timestamp with time zone,#{high}),"
      	# (if i < (n-1) then ', ' else '' end)
    end
end


