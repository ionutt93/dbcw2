require 'faker'

100.times do |i|
	puts 'INSERT INTO "user" 
	(username, first, last, email, password, status, creationDate, lastLogin, loggedIn, online, avatar) VALUES
	(' + Faker::Internet.user_name + ',
	 ' + Faker::Name.first_name + ',
	 ' + Faker::Name.last_name + ',
	 ' + 'a'*40 + ',
	 ' + Faker::Lorem.words(20).join(" ") + ',
	 ' + 'Date Thing' + ',
	 ' + 'Time Thing' + ',
	 ' + if rand(2) == 1 then 'true' else 'false' end + ',
	 ' + if rand(2) == 1 then 'true' else 'false' end + ',
	 ' + Faker::Internet.url + ');'
end


