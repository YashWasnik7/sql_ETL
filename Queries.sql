-- Top artists by number of Albums
select 
	ar.Name, 
	count(ab.AlbumID) as AlbumCount
FROM 
	Artists ar
join 
	Albums ab on ar.ArtistID = ab.ArtistID
group by 
	ar.Name
order by 
	AlbumCount DESC;
	
-- Popular Genres
select 
	g.Name,
	count(*) as ArtistCount
FROM 
	Artists ar
join 
	Genres g on ar.GenreID = g.GenreID
group by 
	g.Name
order by 
	ArtistCount desc;

-- most played tracks
select 
	Title,
	sum(Duration) as TotalDurationPlayed
FROM Tracks 
group by 
	Title
order by 
	TotalDurationPlayed desc
limit 10;
	