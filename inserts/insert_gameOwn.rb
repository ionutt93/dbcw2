require 'faker'
require 'digest/sha1'
require 'rubystats'
salt = 'saltysalt'

n = 100

date_min = Date.new(2010,01,01).to_time.to_i
date_max = Date.new(2014,01,01).to_time.to_i
puts 'INSERT INTO gameOwn 
(userID,gameID,rating,comment,lastPlayed,highScore) VALUES '
n.times do |i|
    date_released = Time.at(rand(date_max - date_min) + date_min).strftime "%Y-%m-%d"
    last_played =  Time.at(rand(date_max - date_min) + date_min).strftime "%Y-%m-%d %H:%M:%S"
    comment = Faker::Lorem.words(20).join(" ")
    high = Rubystats::NormalDistribution.new(100,20).rng.round
    rating = [1,[Rubystats::NormalDistribution.new(3.5,1).rng.round,5].min].max

    user_id = ((i+1) / 10).floor
    game_id = i+1 
    
    puts "(#{user_id},#{game_id},#{rating},'#{comment}','#{last_played} BST' :: timestamp with time zone,#{high})" +
      (if i < (n-1) then ', ' else '' end)

end


