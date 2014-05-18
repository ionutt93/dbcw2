require 'faker'
require 'digest/sha1'
salt = 'saltysalt'

n = 30
date_min = Date.new(2010,01,01).to_time.to_i
date_max = Date.new(2014,01,01).to_time.to_i
puts 'INSERT INTO "game" 
(name,releasedate,publisher,description,img,website) VALUES '
n.times do |i|
    date_released = Time.at(rand(date_max - date_min) + date_min).strftime "%Y-%m-%d"
    name =  Faker::Company.name.gsub("'","\\'\\'")
    publisher = Faker::Company.name.gsub("'","\\'\\'")
    description = Faker::Lorem.words(20).join(" ")
    img =  Faker::Internet.url
    website =  Faker::Internet.url
    puts "('#{name}','#{date_released}' :: date,'#{publisher}','#{description}','#{img}','#{website}')" +
      (if i < (n-1) then ', ' else '' end)

end




