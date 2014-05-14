DELETE FROM friend;
SELECT send_friend_request('yvonne','billy','');
SELECT send_friend_request('yvonne','sherwood','');
SELECT send_friend_request('yvonne','sasha.hartmann','');
SELECT send_friend_request('yvonne','river.wolf','');
UPDATE friend SET status = 'accepted'::friendStatus;;

