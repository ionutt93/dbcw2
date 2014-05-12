require 'faker'
require 'digest/sha1'
salt = 'saltysalt'

n = 50

puts 'INSERT INTO "friend" 
(userId1, userId2) VALUES '
n.times do |i|
    userId1 = i + 1
    userId2 = i + 51

    puts "('#{userId1}','#{userId2}')" +
      (if i < (n-1) then ', ' else '' end)
end