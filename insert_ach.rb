require 'faker'

n = 30

puts 'INSERT INTO "ach" 
(title) VALUES '
n.times do |i|
	title =  Faker::Name.title

prep = "('#{title}')" + (if i < (n-1) then ', ' else '' end)
    puts prep

end