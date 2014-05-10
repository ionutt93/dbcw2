require 'faker'
require 'digest/sha1'
salt = 'saltysalt'

n = 100

date_min = Date.new(2010,01,01).to_time.to_i
date_max = Date.new(2014,01,01).to_time.to_i
puts 'INSERT INTO "user" 
(username, first, last, email, password, status, creationDate, lastLogin, loggedIn, online, avatar) VALUES '
n.times do |i|
    date_created = Time.at(rand(date_max - date_min) + date_min).strftime "%Y-%m-%d"
    last_login =  Time.at(rand(date_max - date_min) + date_min).strftime "%Y-%m-%d %H:%M:%S"
    username =  Faker::Internet.user_name
    first =  Faker::Name.first_name
    last =  Faker::Name.last_name.gsub("'","\\'\\'")
    hash =  Digest::SHA1.hexdigest(salt + Faker::Internet.user_name)
    status = Faker::Lorem.words(20).join(" ")
    logged_in = if rand(2) == 1 then 'TRUE' else 'FALSE' end
    online = if rand(2) == 1 then 'TRUE' else 'FALSE' end
    avatar =  Faker::Internet.url
    email = Faker::Internet.email

    prep = "('#{username}','#{first}','#{last}','#{email}','#{hash}','#{status}',\'#{date_created}\'::date,\'#{last_login} BST\' :: timestamp with time zone,
    #{logged_in},#{online},\'#{avatar}\')" + (if i < (n-1) then ', ' else '' end)
    puts prep
end


