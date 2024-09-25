SELECT *, SUBSTR(ReleaseDate, -2) FROM Albums where ReleaseDate > date('Now');

alter table Albums add COLUMN ReleaseDateFormatted date;

-- Update the New Column
UPDATE Albums SET ReleaseDateFormatted =
CASE
    -- Handle dates with two-digit year (00-99)
    WHEN LENGTH(SUBSTR(ReleaseDate, -2)) = 2 THEN
    CASE
        -- Convert years 00-23 to 2000-2023
        WHEN CAST(SUBSTR(ReleaseDate, -2) AS INTEGER) < 24 THEN
            '20' || SUBSTR(ReleaseDate, -2) || '-' ||
            SUBSTR('0' || REPLACE(SUBSTR(ReleaseDate, 1, INSTR(ReleaseDate, '/') - 1), '/', ''), -2) || '-' ||
            SUBSTR('0' || REPLACE(SUBSTR(SUBSTR(ReleaseDate, INSTR(ReleaseDate, '/') + 1), 1, INSTR(SUBSTR(ReleaseDate, INSTR(ReleaseDate, '/') + 1), '/') - 1), '/', ''), -2)
        -- Convert years 24-99 to 1924-1999
        ELSE
            '19' || SUBSTR(ReleaseDate, -2) || '-' ||
            SUBSTR('0' || REPLACE(SUBSTR(ReleaseDate, 1, INSTR(ReleaseDate, '/') - 1), '/', ''), -2) || '-' ||
            SUBSTR('0' || REPLACE(SUBSTR(SUBSTR(ReleaseDate, INSTR(ReleaseDate, '/') + 1), 1, INSTR(SUBSTR(ReleaseDate, INSTR(ReleaseDate, '/') + 1), '/') - 1), '/', ''), -2)
    END
    ELSE NULL
END
WHERE ReleaseDate IS NOT NULL;

--set default values for nulls
update Albums set ReleaseDateFormatted = '9999-12-31' where ReleaseDateFormatted is NULL;

SELECT ReleaseDate, ReleaseDateFormatted from Albums where ReleaseDateFormatted is NULL;

update Albums set ReleaseDateFormatted = 'YYYY-MM-DD' where ReleaseDate = 'MM/DD/YY';

create table Albums_New (
	AlbumID integer PRIMARY Key,
	Title text not null,
	ReleaseDate Date,
	ArtistID INTEGER,
	FOREIGN KEY(ArtistID) REFERENCES Artists(ArtistID),
	check(title is not NULL)
);

INSERT into Albums_New(AlbumID, Title, ArtistID, ReleaseDate)
select DISTINCT AlbumID, Title, ArtistID, ReleaseDateFormatted
from Albums;

PRAGMA FOREIGN_keys = off;
drop table Albums;

PRAGMA FOREIGN_keys = off;
ALTER TABLE Albums_New Rename to Albums;

create index idx_album_title on Albums(Title);

Select * from Albums where ReleaseDate > date('Now');

-- 2. Validating foreign key REFERENCES
select * from Albums Where ArtistID not in (select ArtistID from Artists);

-- 3. Validating Artists Bday
select * from Artists Where BirthDate > date('Now');

alter table Artists add COLUMN BirthDateFormatted date;

UPDATE Artists SET BirthDateFormatted =
CASE
    -- Handle dates with two-digit year (00-99)
    WHEN LENGTH(SUBSTR(BirthDate, -2)) = 2 THEN
    CASE
        -- Convert years 00-23 to 2000-2023
        WHEN CAST(SUBSTR(BirthDate, -2) AS INTEGER) < 24 THEN
            '20' || SUBSTR(BirthDate, -2) || '-' ||
            SUBSTR('0' || REPLACE(SUBSTR(BirthDate, 1, INSTR(BirthDate, '/') - 1), '/', ''), -2) || '-' ||
            SUBSTR('0' || REPLACE(SUBSTR(SUBSTR(BirthDate, INSTR(BirthDate, '/') + 1), 1, INSTR(SUBSTR(BirthDate, INSTR(BirthDate, '/') + 1), '/') - 1), '/', ''), -2)
        -- Convert years 24-99 to 1924-1999
        ELSE
            '19' || SUBSTR(BirthDate, -2) || '-' ||
            SUBSTR('0' || REPLACE(SUBSTR(BirthDate, 1, INSTR(BirthDate, '/') - 1), '/', ''), -2) || '-' ||
            SUBSTR('0' || REPLACE(SUBSTR(SUBSTR(BirthDate, INSTR(BirthDate, '/') + 1), 1, INSTR(SUBSTR(BirthDate, INSTR(BirthDate, '/') + 1), '/') - 1), '/', ''), -2)
    END
    ELSE NULL
END
WHERE BirthDate IS NOT NULL;

update Artists set BirthDateFormatted = '9999-12-31' where BirthDateFormatted is NULL;

select BirthDate, BirthDateFormatted from Artists where BirthDateFormatted is Null;

Update Artists Set BirthDateFormatted = 'YYYY-MM-DD' where BirthDate = 'MM/DD/YY';

create table Artists_New (
	ArtistID integer PRIMARY Key,
	Name text not null,
	BirthDate Date,
	GenreID INTEGER,
	FOREIGN KEY(GenreID) REFERENCES Genres(GenreID)
);


INSERT into Artists_New(ArtistID, Name, GenreID, BirthDate) 
select DISTINCT ArtistID, Name, GenreID, BirthDateFormatted
from Artists;

drop table Artists;
alter TABLE Artists_New RENAME to Artists;


-- error handling

create TRIGGER error_handling_insert
before INSERT on Albums
for each ROW
begin 
	select 
	CASE
	when NEW.ArtistID Not in (SELECT ArtistID from Artist) then RAISE(ABORT, 'Invalid ArtistID')
	end;
end;