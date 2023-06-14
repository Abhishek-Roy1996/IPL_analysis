create database IPL_db;

use IPL_db;

-- 1. Create a table named 'matches' with appropriate data types for columns.

Create table matches
(id INT,
City varchar(100),
dates varchar(100),
player_of_the_match varchar(100),
venue varchar(100),	
neutral_venue INT,
team1 varchar(100),
team2 varchar(100),
toss_winner varchar(100),
toss_decision varchar(100),
winner varchar(100),
result varchar(100),	
result_margin INT,
eliminator varchar(100),
method varchar(100),	
umpire1 varchar(100),	
umpire2 varchar(100));

-- 2. Create a table named 'deliveries' with appropriate data types for columns.

create table deliveries 
(id INT,
inning INT,	
overs INT,
ball INT,	
batsman varchar(100),
non_striker varchar(100),
bowler varchar(100),
batsman_runs INT,	
extra_runs INT,	
total_runs INT,
is_wicket INT,
dismissal_kind varchar(100),
player_dismissed varchar(100),	
fielder varchar(100),	
extras_type	varchar(100),
batting_team varchar(100),	
bowling_team varchar(100),
venue varchar(100),
match_date varchar(100));

-- New Ball by ball table without venue and match_date.
create table ball 
(id INT,
inning INT,	
overs INT,
ball INT,	
batsman varchar(100),
non_striker varchar(100),
bowler varchar(100),
batsman_runs INT,	
extra_runs INT,	
total_runs INT,
is_wicket INT,
dismissal_kind varchar(100),
player_dismissed varchar(100),	
fielder varchar(100),	
extras_type	varchar(100),
batting_team varchar(100),	
bowling_team varchar(100));



select * from deliveries limit 20;
select * from matches limit 20;
select * from ball limit 20;
select * from ball_v02 limit 20;
select * from ball_v03 limit 20;


Alter table matches
add column new_date date;

desc matches;

Update matches
set new_date=str_to_date(left(dates,10),"%d-%m-%Y");

Alter table matches
drop column dates;

Alter table deliveries
add column new_match_date date;

Update deliveries
set new_match_date=str_to_date(left(match_date,10),"%d-%m-%Y");

-- 3. Import data from csv file 'IPL_matches.csv'attached in resources to 'matches'.
-- 4. Import data from csv file 'IPL_Ball.csv' attached in resources to 'deliveries/ball.
-- 5. Select the top 20 rows of the ball table. 

select * 
from ball
limit 20;

-- 6. Select the top 20 rows of the matches table.

select *
from matches
limit 20;

-- 7. Fetch data of all the matches played on 2nd May 2013.

select * 
from matches
where new_date="2013-05-02";

-- 8. Fetch data of all the matches where the margin of victory is more than 100 runs. 

select *
from matches
where result_margin>100;

-- 9. Fetch data of all the matches where the final scores of both teams tied 
-- and order it in descending order of the date. 

select *
from matches
where result="tie"
order by new_date desc;

-- 10. Get the count of cities that have hosted an IPL match. 

select city,count(*) as NoOFMatches
from matches
group by city;


-- 11. Create table deliveries_v02 with all the columns of deliveries and an additional column ball_result 
-- containing value boundary, dot or other depending on the total_run 
-- (boundary for >= 4, dot for 0 and other for any other number) 

Create table ball_v02 as Select *,
case when total_runs>=4 then "Boundary"
when total_runs=0 then "Dot"
else "other"
end as ball_result
from ball;

-- 12. Write a query to fetch the total number of boundaries and dot balls.

select count(*) as `Count`, ball_result
from ball_v02
group by ball_result;

-- 13. Write a query to fetch the total number of boundaries scored by each team.

select count(ball_result) as CountOfBoundaries, batting_team
from ball_v02
where ball_result="boundary"
group by batting_team;

select batsman_runs,count(batsman_runs) as CntofBoundaries,batting_team
from ball
where batsman_runs=4 or batsman_runs=6
group by 1,3;

-- 14. Write a query to fetch the total number of dot balls bowled by each team.

select count(ball_result) as CntofDotBalls,bowling_team
from ball_v02
where ball_result=0
group by bowling_team;

-- 15. Write a query to fetch the total number of dismissals by dismissal kinds. 

select count(dismissal_kind) as TotalNumberOfDismissal,dismissal_kind
from ball
group by dismissal_kind;

-- 16. Write a query to get the top 5 bowlers who conceded maximum extra runs 

select Bowler,sum(extra_runs) as Extras
from ball
group by bowler
order by extras desc limit 5;

-- 17. Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table 
-- and two additional column (named venue and match_date) of venue and date from table matches 

create table ball_v03
select bl2.*,m.new_date,m.venue
from ball_v02 as bl2 
join matches m on bl2.id=m.id;

-- 18. Write a query to fetch the total runs scored for each venue and order it in the descending order 
-- of total runs scored

select sum(total_runs) as TotalRunsScored,venue
from ball_v03
group by venue
order by TotalRunsScored desc;

-- 19. Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the 
-- descending order of total runs scored

select year(new_date) as 'Year',sum(total_runs) as TotalRunsScored
from ball_v03
where venue="eden gardens"
group by year(new_date)
order by TotalRunsScored desc;

-- 20. Get unique team1 names from the matches table, you will notice that there are two entries 
-- for Rising Pune Supergiant one with Rising Pune Supergiant and another one with Rising Pune Supergiants. 
-- Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr 
-- containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. 
-- Now analyse these newly created columns.

create table matches_corrected as select * 
from matches;

Alter table matches_corrected
add column team1_corr Varchar(50),
add column team2_corr varchar(50);

select * from matches_corrected;

update matches_corrected
set team1_corr= if(team1="Rising Pune Supergiant","Rising Pune supergiants","Rising Pune Supergiant"),
	team2_corr= if(team1="Rising Pune Supergiant","Rising Pune supergiants","Rising Pune Supergiant");

-- 21. Create a new table deliveries_v04 with the first column as ball_id containing information of match_id,
-- inning, over and ball separated by'(For ex. 335982-1-0-1 match_idinning-over-ball) and 
-- rest of the columns same as deliveries_v03) 

create table ball_v04 as select *, concat(id,"-",inning,"-",overs,"-",ball) as ball_id
from ball_v03;

-- 22. Compare the total count of rows and total count of distinct ball_id in deliveries_v04; 

select count(*) as CountOfRows, count(distinct(ball_id)) as TotalCountofDistinctBall
from ball_v04;

-- 23. Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for 
-- row number partition over ball_id. (HINT : row_number() over (partition by ball_id) as r_num) 

create table ball_v05 as select *, row_number () over (partition by ball_id) as r_num
from ball_v04;

-- 24. Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. 
-- (HINT : select * from deliveries_v05 WHERE r_num=2;) 

select * from ball_v05 WHERE r_num=2;

-- 25. Use subqueries to fetch data of all the ball_id which are repeating. 
-- (HINT: SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2);

SELECT * FROM ball_v05 WHERE ball_id in (select BALL_ID from ball_v05 WHERE r_num=2); 



