DROP TABLE IF EXISTS "user", ach, game, "gameOwn", "gameCat" CASCADE;
DROP TABLE IF EXISTS friend, "gameAch", "gameOwnAch", category;

-- Create table "user"
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
    avatar varchar(255)
);

-- Create table "friend"
CREATE TABLE friend (
    id serial PRIMARY KEY,
    userId1 integer NOT NULL REFERENCES "user"(id),
    userId2 integer NOT NULL REFERENCES "user"(id)
);

-- Create table "ach"
CREATE TABLE ach (
    id serial PRIMARY KEY,
    title varchar(50) NOT NULL UNIQUE
);

-- Create table "gameAch"
CREATE TABLE "gameAch" (
    id serial PRIMARY KEY,
    achId integer NOT NULL REFERENCES ach(id),
    gameId integer NOT NULL,
    value integer NOT NULL,
    show boolean NOT NULL DEFAULT FALSE,
    descrBefore text,
    descrAfter text,
    icon varchar(255)
);

-- Create table "game"
CREATE TABLE game (
    id serial PRIMARY KEY,
    name varchar(255),
    description text,
    releaseDate date NOT NULL,
    publisher varchar(255) NOT NULL,
    version integer,
    avgRate integer,
    rank integer,
    img varchar(255),
    website varchar(255)
);

-- Create table "gameOwn"
CREATE TABLE "gameOwn" (
    id serial PRIMARY KEY,
    userID integer REFERENCES "user"(id),
    gameID integer REFERENCES game(id),
    rating integer CHECK (rating >= 0 AND rating <= 5),
    comment text,
    lastPlayed timestamp with time zone,
    highScore double precision NOT NULL DEFAULT 0,
    receiveNotif boolean NOT NULL DEFAULT TRUE
);

-- Create table "gameOwnAch"
CREATE TABLE "gameOwnAch" (
    gameOwn integer NOT NULL REFERENCES "gameOwn"(id),
    achId integer NOT NULL REFERENCES ach(id),
    dateAchieved timestamp with time zone 
);

-- Create table "category"
CREATE TABLE category(
    id serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    rating integer CHECK (rating >= 0 AND rating <= 5)
);

-- Create table "gameCat"
CREATE TABLE "gameCat"(
    id serial PRIMARY KEY,
    catId integer REFERENCES category(id),
    gameId integer REFERENCES game(id),
    rank integer,
    UNIQUE (catId, gameId)
);

