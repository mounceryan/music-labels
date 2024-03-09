CREATE TABLE Artist(
	aID		VARCHAR(5)	NOT NULL,
	aName	VARCHAR(25),
	age		INT,
	PRIMARY KEY (aID)
);

CREATE TABLE Label(
	lID		VARCHAR(5)	NOT NULL,
	lName	VARCHAR(25),
	address	VARCHAR(50),
	PRIMARY KEY (lID)
);

CREATE TABLE PerformsFor(
	aID		VARCHAR(5)	NOT NULL,
    ID		VARCHAR(5)	NOT NULL,
	since	DATE,
	PRIMARY KEY (aID, lID),
	FOREIGN KEY (aID) REFERENCES Artist(aID)
    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (lID) REFERENCES Label(lID)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Record(
	rID		VARCHAR(5)	NOT NULL,
	rName	VARCHAR(50),
	genre	VARCHAR(15),
	format	VARCHAR(15),
	PRIMARY KEY (rID)
);

CREATE TABLE Sells(
    lID		VARCHAR(5)	NOT NULL,
	rID		VARCHAR(5)	NOT NULL,
	copiesAvailable INT,
	copiesSold	INT,
	PRIMARY KEY (lID, rID),
    FOREIGN KEY (lID) REFERENCES Label(lID)
    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (rID) REFERENCES Record(rID)
    ON UPDATE CASCADE ON DELETE CASCADE,
);

SELECT DISTINCT lName
FROM Label L, Sells S, Record R
WHERE L.lID = S.lID AND S.rID = R.rID AND format = 'Digital';

SELECT lName
FROM Label L, Sells S, Record R
WHERE (L.lID = S.lID AND S.rID = R.rID) AND (genre = 'country')
INTERSECT
SELECT lName
FROM Label L, Sells S, Record R
WHERE (L.lID = S.lID AND S.rID = R.rID) AND (genre = 'rock');

SELECT L.lName
FROM Label L
WHERE L.lID IN (SELECT S.lID
FROM Record R, Sells S
WHERE R.rID = S.rID AND (copiesAvailable > 0 AND format = 'Vinyl')
HAVING count(distinct S.lID) = 1);

SELECT L.lID
FROM Label L
WHERE L.lID IN(SELECT S.lID
FROM Record R, Sells S
WHERE R.rID = S.rID AND format = 'Digital')
INTERSECT
(SELECT P.lID 
FROM Artist A, PerformsFor P
WHERE A.aID = P.aID and AGE <= 30
EXCEPT
SELECT P.lID 
FROM Artist A, PerformsFor P
WHERE A.aID = P.aID and AGE > 30);

SELECT lID, max(age)
FROM PerformsFor P, Artist A
WHERE P.aID = A.aID
GROUP BY lID;

SELECT aName
FROM Artist
WHERE age >(SELECT min(age)
FROM Artist A, Label L, PerformsFor P
WHERE A.aID = P.aID AND L.lID = P.lID AND lname = 'Bizarro Beats');

SELECT aName
FROM Artist A, PerformsFor P
WHERE A.aID = P.aID AND P.lID = (SELECT lID
FROM Record R, Sells S
WHERE R.rID = S.rID
GROUP BY lID
HAVING count(DISTINCT genre) >= 5);
