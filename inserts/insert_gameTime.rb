require 'faker'
require 'rubystats'

date_min = Date.new(2014,05,01).to_time.to_i
date_max = Date.new(2014,05,20).to_time.to_i

n = 300
puts 'INSERT INTO "gameTime" 
(gameOwnId, playedOn) VALUES '
n.times do |i|
	gameOwnId = i + 1

	(rand(50) + 1).times do
		playedOn =  Time.at(rand(date_max - date_min) + date_min).strftime "%Y-%m-%d %H:%M:%S"
		prep = "('#{gameOwnId}','#{playedOn}'),"
		puts prep
	end
end