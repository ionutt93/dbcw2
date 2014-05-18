require 'faker'

n = 30

puts 'INSERT INTO "gameCat" 
(catID,gameID,rank) VALUES '
ranks = []
ranks.fill(0, 0..30)
n.times do |i|
	gameID = i + 1;
	used_cat = []
	(rand(30) + 1).times do 
		catID = rand(30) + 1;
		while used_cat.include?(catID) do
			catID = rand(30) + 1;
		end
		used_cat[used_cat.count] = catID
		
		rank = ranks[catID] + 1;
		ranks[catID] += 1
		
		prep = "('#{catID}','#{gameID}','#{rank}')"+
		(if i < (n-1) then ', ' else '' end)
	    puts prep
	end
end