require 'faker'
require 'rubystats'

n = 30

puts 'INSERT INTO "gameAch" 
(achID,gameID,value,show,descrBefore,descrAfter,icon) VALUES '
n.times do |i|
	gameID = i + 1

	used_ach = []
	(rand(30) + 1).times do 
		achID = rand(30)+1
		while used_ach.include?(achID)
			achID = rand(30)+1
		end
		used_ach.unshift(achID)

		value =  [[Rubystats::NormalDistribution.new(50,20).rng.round,100].min,0].max
		show = if rand(2) == 1 then 'TRUE' else 'FALSE' end
		descrBefore = Faker::Lorem.sentences(1)
		descrAfter = Faker::Lorem.sentences(1)
		icon = Faker::Internet.url

		prep = "('#{achID}','#{gameID}','#{value}','#{show}','#{descrBefore}','#{descrAfter}',\'#{icon}\'),"
		# (if i < (n-1) then ', ' else '' end)
		puts prep
	end
end