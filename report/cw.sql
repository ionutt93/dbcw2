-- Tested on PostgreSQL 9.1.10

-- DROP TABLE IF EXISTS Invoice CASCADE;
-- DROP TABLE IF EXISTS EmployedOn CASCADE;
-- DROP TABLE IF EXISTS Department CASCADE;
-- DROP TABLE IF EXISTS Staff;

CREATE TABLE Department (
    "DName" varchar(100) NOT NULL,
    "DNumber" integer NOT NULL PRIMARY KEY,
    "Address" varchar(255) NOT NULL,
    CONSTRAINT uq_dname UNIQUE ("DName")
);

CREATE TABLE Staff (
    "NINo" char(9) NOT NULL PRIMARY KEY,
    "First" varchar(100) NOT NULL,
    "Surname" varchar(100) NOT NULL,
    "DOB" date NOT NULL,
    "Address" varchar(255) NOT NULL,
    "Gender" char(1) NOT NULL,
    "Salary" numeric NOT NULL,
    "SuperNINo" char(9),
    "DNo" integer NOT NULL, 

    CONSTRAINT ck_NINo CHECK ("NINo" ~* '^[a-zA-Z]{2}[0-9]{6}[a-zA-Z]{1}$'),
    CONSTRAINT ck_Gender CHECK ("Gender" ~* '^[MF]$'),
    CONSTRAINT ck_SuperNINo CHECK ("SuperNINo" ~* '^[a-zA-Z]{2}[0-9]{6}[a-zA-Z]{1}$'),
    CONSTRAINT fk_staff_dep FOREIGN KEY ("DNo") 
        REFERENCES Department ("DNumber") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Invoice (
    "IName" varchar(100) NOT NULL,
    "INum" integer NOT NULL PRIMARY KEY,
    "DNo" integer NOT NULL, 
    "InvStartDate" date NOT NULL,
    "InvEndDate" date,

    CONSTRAINT uq_iname UNIQUE ("IName"),
    CONSTRAINT fk_inv_dep FOREIGN KEY ("DNo") 
        REFERENCES Department ("DNumber") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_inv_date CHECK ("InvStartDate" <= "InvEndDate")
);

CREATE TABLE EmployedOn (
    "ESSN" char(9) NOT NULL,
    "InNo" integer NOT NULL,
    "Hours" real NOT NULL,

    CONSTRAINT fk_eon_staff FOREIGN KEY ("ESSN") 
        REFERENCES Staff ("NINo") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_eon_inv FOREIGN KEY ("InNo") 
        REFERENCES Invoice ("INum") ON DELETE RESTRICT ON UPDATE CASCADE
);
