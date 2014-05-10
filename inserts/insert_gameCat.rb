require 'faker'

n = 500

puts 'INSERT INTO "gameCat" 
(catID,gameID) VALUES '
n.times do |i|
	catID = rand(15-1)+1
	gameID = rand(100-1)+1

	prep = "('#{catID}','#{gameID}')"+
	(if i < (n-1) then ', ' else '' end)
	    puts prep
end