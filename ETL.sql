delete from Artists_Temp where GenreID not in (select GenreID from Genres_Temp);
delete from Albums_Temp where ArtistID not in (select ArtistID from Artists_Temp);
delete from Tracks_Temp where AlbumID not in (select AlbumID from Albums_Temp);


--Transform
CREATE TABLE Artists_Cleaned as SELECT * FROM Artists_Temp;
DELETE FROM Artists_Cleaned WHERE Name is NULL or Name = '';
DELETE FROM Artists_Cleaned WHERE ROWID not in (SELECT min(ROWID) FROM Artists_Cleaned GROUP by ArtistID);
UPDATE Artists_Cleaned SET Name = TRIM(Name);

DELETE FROM Albums_Temp where ArtistID not in (select ArtistID from Artists_Temp);

CREATE TABLE Albums_Cleaned as SELECT * FROM Albums_Temp;
DELETE FROM Albums_Cleaned WHERE Title is NULL or Title = '';
DELETE FROM Albums_Cleaned WHERE ROWID not in (SELECT min(ROWID) FROM Albums_Cleaned GROUP by AlbumID);
UPDATE Albums_Cleaned SET Title = TRIM(Title);

DELETE FROM Albums_Cleaned where ArtistID not in (select ArtistID from Artists_Cleaned);

CREATE TABLE Tracks_Cleaned as SELECT * FROM Tracks_Temp;
DELETE FROM Tracks_Cleaned WHERE Title is NULL or Title = '';
DELETE FROM Tracks_Cleaned WHERE Duration <=0;
UPDATE Tracks_Cleaned SET Duration = Duration * 60;

DELETE FROM Tracks_Cleaned WHERE AlbumID not in (select AlbumID from Albums_Cleaned);

CREATE TABLE Genres_Cleaned as SELECT * From Genres_Temp;
DELETE FROM Genres_Cleaned WHERE Name is NULL or Name = '';


PRAGMA foreign_keys = OFF;

--Load
INSERT into Genres(GenreID, Name)
select GenreID, Name from Genres_Cleaned;

INSERT into Artists(ArtistID, Name, BirthDate, GenreID)
select ArtistID, Name, BirthDate, GenreID from Artists_Cleaned;

INSERT into Albums(AlbumID, Title, Release_date, ArtistID)
select AlbumID, Title, ReleaseDate, ArtistID from Albums_Cleaned;

INSERT into Tracks(TrackID, AlbumID, Title, Duration)
select TrackID, AlbumID,  Title, Duration from Tracks_Cleaned;