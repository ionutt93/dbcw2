-- Create tabe "user"
DROP TABLE IF EXISTS "user";
CREATE TABLE "user"(
    id serial PRIMARY KEY,
    username varchar(50) NOT NULL UNIQUE,
    first varchar(25) NOT NULL,
    last varchar(25) NOT NULL,
    email varchar(50) NOT NULL UNIQUE,
    password varchar(50) NOT NULL,
    status text,
    creationDate date NOT NULL,
    lastLogin timestamp with time zone,
    loggedIn boolean NOT NULL,
    online boolean NOT NULL,
    avatar varchar(200) );

-- Create table "friend"
DROP TABLE IF EXISTS friend;
CREATE TABLE friend (
    id serial PRIMARY KEY,
    userid1 integer NOT NULL,
    userid2 integer NOT NULL
);

