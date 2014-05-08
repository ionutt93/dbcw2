-- Create table "friend"
DROP TABLE IF EXISTS friend;
CREATE TABLE friend (
    id serial PRIMARY KEY,
    userid1 integer NOT NULL,
    userid2 integer NOT NULL
);
