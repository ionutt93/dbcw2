require 'faker'
require 'rubystats'

n = 500

puts 'INSERT INTO "gameAch" 
(achID,gameID,value,show,descrBefore,descrAfter,icon) VALUES '
n.times do |i|
	achID = rand(30-1)+1
	gameID = rand(100-1)+1
	value =  [[Rubystats::NormalDistribution.new(50,20).rng.round,100].min,0].max
	show = if rand(2) == 1 then 'TRUE' else 'FALSE' end
	descrBefore = Faker::Lorem.sentences(1)
	descrAfter = Faker::Lorem.sentences(1)
	icon = Faker::Internet.url

	prep = "('#{achID}','#{gameID}','#{value}','#{show}','#{descrBefore}','#{descrAfter}',\'#{icon}\')"+
	(if i < (n-1) then ', ' else '' end)
	    puts prep
end