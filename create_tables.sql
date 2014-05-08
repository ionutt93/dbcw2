CREATE TABLE ach (
    id serial PRIMARY KEY,
    title varchar(50) UNIQUE  
);

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

CREATE TABLE gameOwnAch (
    gameOwn integer NOT NULL REFERENCES gameOwn(id),
    achId integer NOT NULL REFERENCES ach(id),
    dateAchieved timestamp with time zone 
);