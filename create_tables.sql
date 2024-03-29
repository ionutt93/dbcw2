DROP TABLE IF EXISTS "user", ach, game, gameOwn,gameOwnAch,gameCat CASCADE;
DROP TABLE IF EXISTS friend, gameAch, category, gameTime CASCADE;

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

DROP TYPE IF EXISTS friendStatus CASCADE;
CREATE TYPE friendStatus AS ENUM ('rejected','awaiting','accepted');
-- Create table "friend"
CREATE TABLE friend (
    id serial PRIMARY KEY,
    userId1 integer NOT NULL REFERENCES "user"(id),
    userId2 integer NOT NULL REFERENCES "user"(id),
    status friendStatus NOT NULL DEFAULT 'awaiting'
);

-- Create table "ach"
CREATE TABLE ach (
    id serial PRIMARY KEY,
    title varchar(50) NOT NULL UNIQUE
);

-- Create table gameAch
CREATE TABLE gameAch (
    id serial PRIMARY KEY,
    achId integer NOT NULL REFERENCES ach(id),
    gameId integer NOT NULL,
    value integer NOT NULL CHECK (value <= 100 AND value >= 0),
    show boolean NOT NULL DEFAULT FALSE,
    descrBefore text,
    descrAfter text,
    icon varchar(255)
);


DROP TYPE IF EXISTS ordering CASCADE;
CREATE TYPE ordering AS ENUM ('asc','desc');
DROP TYPE IF EXISTS game_currency CASCADE;
CREATE TYPE game_currency AS ENUM ('int','time','money');
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
    website varchar(255),
    minimum integer DEFAULT 0,
    maximum integer,
    sorting ordering DEFAULT 'asc' NOT NULL,
    value_type game_currency DEFAULT 'int' NOT NULL
);

-- Create table gameOwn
CREATE TABLE gameOwn (
    id serial PRIMARY KEY,
    userID integer REFERENCES "user"(id),
    gameID integer REFERENCES game(id),
    rating integer CHECK (rating >= 0 AND rating <= 5),
    comment text,
    lastPlayed timestamp with time zone,
    date_ach timestamp with time zone,
    highScore integer NOT NULL DEFAULT 0,
    receiveNotif boolean NOT NULL DEFAULT TRUE,
    rank integer
);

-- Create table which shows game play times
CREATE TABLE gameTime (
    id serial PRIMARY KEY,
    gameOwnId integer REFERENCES gameOwn(id),
    playedOn timestamp with time zone
);

-- Create table gameOwnAch
CREATE TABLE gameOwnAch (
    gameOwn integer NOT NULL REFERENCES gameOwn(id),
    achId integer NOT NULL REFERENCES ach(id),
    dateAchieved timestamp with time zone 
);

-- Create table "category"
CREATE TABLE category(
    id serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    rating integer CHECK (rating >= 0 AND rating <= 5)
);

-- Create table gameCat
CREATE TABLE gameCat(
    id serial PRIMARY KEY,
    catId integer REFERENCES category(id),
    gameId integer REFERENCES game(id),
    rank integer,
    UNIQUE (catId, gameId)
);


