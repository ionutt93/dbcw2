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

-- Create table "ach"
DROP TABLE IF EXISTS ach;
CREATE TABLE ach (
    id serial PRIMARY KEY,
    title varchar(50) UNIQUE
);

-- Create table "gameAch"
DROP TABLE IF EXISTS gameAch;
CREATE TABLE gameAch (
    id serial PRIMARY KEY,
    achId integer NOT NULL REFERENCES ach(id),
    gameId integer NOT NULL,
    value integer,
    show boolean,
    descrBefore text,
    descrAfter text,
    icon varchar(255)
);

-- Create table "gameOwnAch"
DROP TABLE IF EXISTS gameOwnAch;
CREATE TABLE gameOwnAch (
    gameOwn integer NOT NULL REFERENCES gameOwn(id),
    achId integer NOT NULL REFERENCES ach(id),
    dateAchieved timestamp with time zone 
);
