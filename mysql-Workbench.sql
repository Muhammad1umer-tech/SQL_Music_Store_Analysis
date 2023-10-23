/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/* Q2: Which countries have the most Invoices? */

select COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT invoice.customer_id, customer.first_name, SUM(invoice.total) as total
FROM invoice
JOIN customer ON invoice.customer_id = customer.customer_id
GROUP BY invoice.customer_id, customer.first_name
ORDER BY total DESC;



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

use test;
select customer.first_name, customer.last_name, customer.email, DUMM.customer_id, DUMM.invoice_id, DUMM.track_id from customer join
(
select invoice.customer_id, DUM.invoice_id, DUM.track_id from invoice join
(
	SELECT invoice_line.invoice_id, invoice_line.track_id, AA.genre_id
FROM invoice_line
JOIN (
    SELECT * FROM track WHERE genre_id = 1
) AS AA
ON invoice_line.track_id = AA.track_id
) AS DUM
on invoice.invoice_id = DUM.invoice_id
) AS DUMM

on DUMM.customer_id = customer.customer_id


order by customer.email asc;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

use test;
select artist.name, count(dumm.track_id) as Total_Track from artist join
(
	select album2.artist_id, dum.album_id, dum.track_id from album2 join 
(
	select track_id, album_id from track where genre_id = 1
) as dum
	on album2.album_id = dum.album_id
) as dumm
on artist.artist_id = dumm.artist_id
group by artist.name
order by Total_Track desc;



/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

/* Variable */
SET @averageMilliseconds = (SELECT AVG(milliseconds) FROM test.track);
SELECT @averageMilliseconds;
SELECT name, milliseconds
FROM track
WHERE milliseconds > @averageMilliseconds;





/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

use test;

WITH best_selling_artist AS  (select dummm.artist_id, artist.name, dummm.TotalP as Total from artist join 
(
	Select album2.artist_id, SUM(dumm.TotalPrice) AS TotalP from album2 join
(
	Select track.album_id, sum(dum.Total) as TotalPrice from track join
(
	select track_id, SUM(unit_price*quantity) as Total from invoice_line
	group by track_id
) as dum
on dum.track_id = track.track_id
group by track.album_id
) as dumm
on dumm.album_id = album2.album_id
group by artist_id
) 
as dummm
on artist.artist_id = dummm.artist_id
order by Total desc
limit 1)

select best_selling_artist.name, dummmmm.first_name, SUM(dummmmm.unit_price*dummmmm.quantity) as Total
from best_selling_artist join
(
select album2.artist_id, dummmm.first_name, dummmm.unit_price, dummmm.quantity from album2 join 
(
select track.album_id, dummm.first_name, dummm.unit_price, dummm.quantity from track join 
(
select invoice_line.track_id, dumm.first_name, invoice_line.unit_price, invoice_line.quantity from invoice_line join 
(
	select customer.first_name, invoice.invoice_id from customer 
	join invoice on customer.customer_id = invoice.customer_id
) as dumm
on dumm.invoice_id = invoice_line.invoice_id
) as dummm
on track.track_id = dummm.track_id
) as dummmm
on album2.album_id = dummmm.album_id
) as dummmmm
on dummmmm.artist_id = best_selling_artist.artist_id
group by dummmmm.first_name, best_selling_artist.name;



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */
-- we use ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC) AS RowNo
-- because if we want highest Total purchases from each country, then we want to use this.
USE test;

SELECT billing_country, first_name, Total, RowNo
FROM (
    SELECT invoice.billing_country, customer.first_name, SUM(invoice.total) AS Total,
        ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC) AS RowNo
    FROM customer
    JOIN invoice ON invoice.customer_id = customer.customer_id
    GROUP BY invoice.billing_country, customer.first_name
) AS SubQuery
WHERE RowNo = 1
ORDER BY billing_country ASC, Total DESC;



