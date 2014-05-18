require 'faker'
require 'digest/sha1'
require 'rubystats'
salt = 'saltysalt'

n = 30

puts 'INSERT INTO "category" 
(name, rating) VALUES '
n.times do |i|
    name = Faker::Company.name.gsub("'","\\'\\'")
    rating = [Rubystats::NormalDistribution.new(3.5,1).rng.round,5].min

    puts "('#{name}','#{rating}')" +
      (if i < (n-1) then ', ' else '' end)
end
