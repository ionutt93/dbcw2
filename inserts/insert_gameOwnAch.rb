require 'faker'
require 'digest/sha1'
salt = 'saltysalt'

n = 300

date_min = Date.new(2010,01,01).to_time.to_i
date_max = Date.new(2014,01,01).to_time.to_i
puts 'INSERT INTO "gameOwnAch" 
(gameOwn, achId, dateAchieved) VALUES '
n.times do |i|
    gameOwn = i + 1

    used_ach = []
    (rand(30) + 1).times do 
    	achId = rand(30) + 1
    	while used_ach.include?(achId)
    		achId = rand(30) + 1
    	end
    	used_ach.unshift(achId)

    	dateAchieved = Time.at(rand(date_max - date_min) + date_min).strftime "%Y-%m-%d"
    	puts "('#{gameOwn}','#{achId}',\'#{dateAchieved}\'::date),"
      	# (if i < (n-1) then ', ' else '' end)
    end
end