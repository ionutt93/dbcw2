CREATE TABLE game(
    ID serial PRIMARY KEY references gameCat(gameID),
    name varchar(255) PRIMARY KEY ,
    description text,
    releaseDate date NOT NULL,
    publisher varchar(255) NOT NULL,
    version integer,
    avgRate integer,
    rank integer,
    img varchar(255),
    website varchar(255),
);

CREATE TABLE category(
    ID serial PRIMARY KEY references gameCat(catID),
    name varchar(255) NOT NULL,
    rating integer CHECK (rating >= 0 && rating <= 5)
);

CREATE TABLE gameCat(
    ID serial PRIMARY KEY,
    catID integer REFERENCES category(ID) ,
    gameID integer REFERENCES game(ID),
    rank integer,
    UNIQUE (catID, gameID)
);