DELETE FROM friend;
SELECT send_friend_request('yvonne','billy','');
SELECT send_friend_request('yvonne','sherwood','');
SELECT send_friend_request('yvonne','sasha.hartmann','');
SELECT send_friend_request('yvonne','river.wolf','');
SELECT send_friend_request('yvonne','gilda','');

SELECT send_friend_request('dameon','billy','');
SELECT send_friend_request('dameon','sherwood','');
SELECT send_friend_request('dameon','gilda','');
SELECT send_friend_request('sasha.hartmann','dameon','');
SELECT send_friend_request('river.wolf','dameon','');


-- friend_leaderboard test
SELECT send_friend_request('gilda','billy','');
SELECT send_friend_request('gilda','murl','');
SELECT send_friend_request('gilda','linda','');
SELECT send_friend_request('gilda','liana','');
SELECT send_friend_request('gilda','arden','');
UPDATE friend SET status = 'accepted'::friendStatus;;
