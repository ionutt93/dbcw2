-- Create table "user"
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
    avatar varchar(200)
);

-- Create table "friend"
DROP TABLE IF EXISTS friend;
CREATE TABLE friend (
    id serial PRIMARY KEY,
    userid1 integer NOT NULL,
    userid2 integer NOT NULL
);

-- Create table "ach"
DROP TABLE IF EXISTS "ach" CASCADE;
CREATE TABLE "ach" (
    id serial PRIMARY KEY,
    title varchar(50) UNIQUE
);

-- Create table "gameAch"
DROP TABLE IF EXISTS "gameAch";
CREATE TABLE "gameAch" (
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
DROP TABLE IF EXISTS "gameOwnAch";
CREATE TABLE "gameOwnAch" (
    gameOwn integer NOT NULL, --REFERENCES gameOwn(id),
    achId integer NOT NULL REFERENCES ach(id),
    dateAchieved timestamp with time zone 
);

DROP TABLE IF EXISTS "game", category, gameCat;
CREATE TABLE "game" (
    ID serial PRIMARY KEY,
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

CREATE TABLE category(
    ID serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    rating integer CHECK (rating >= 0 AND rating <= 5)
);

CREATE TABLE gameCat(
    ID serial PRIMARY KEY,
    catID integer REFERENCES category(ID),
    gameID integer REFERENCES "game"(ID),
    rank integer,
    UNIQUE (catID, gameID)
);

