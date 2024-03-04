select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;

--How many olympics games have been held?--
select count(distinct games)as Total_games from OLYMPICS_HISTORY;

--2. List down all Olympics games held so far.
--Problem Statement: Write a SQL query to list down all the Olympic Games held so far.
select distinct oh.season,oh.year,oh.city
from olympics_history oh
order by year;
 
 --3. Mention the total no of nations who participated in each olympics game?
--Problem Statement: SQL query to fetch total no of countries participated in each olympic games.
with cte as (
	select games,nr.region from olympics_history oh 
inner join olympics_history_noc_regions nr 
on oh.noc=nr.noc 
group by games,nr.region)
select games,count(region)as total_no_of_nations from cte group by 1 order by 1 ;

--4. Which year saw the highest and lowest no of countries participating in olympics
--Problem Statement: Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.
(select games,count(distinct nr.region)total_countries
from olympics_history oh inner join olympics_history_noc_regions nr on oh.noc=nr.noc 
group by 1 order by 2  desc limit 1)
union
(select games,count(distinct nr.region)total_countries 
from olympics_history oh inner join olympics_history_noc_regions nr on oh.noc=nr.noc 
group by 1 order by 2  asc limit 1)

--5. Which nation has participated in all of the olympic games
--Problem Statement: 
--SQL query to return the list of countries who have been part of every Olympics games.
with cte as (select nr.region,count(distinct games)total_participated_games
from  olympics_history oh inner join olympics_history_noc_regions nr on oh.noc=nr.noc
group by 1 )
select * from cte where total_participated_games =(select max(total_participated_games) from cte )

--6. Identify the sport which was played in all summer olympics.
--Problem Statement:
--SQL query to fetch the list of all sports which have been part of every olympics.
with cte1 as (select count(distinct games)as total_summer_games 
from olympics_history where season='Summer' ),
cte2 as (select sport,count(distinct games)as total_no_of_games from olympics_history 
			  where season='Summer' group by 1 order by 2)
select * from cte2 join cte1 on cte1.total_summer_games=cte2.total_no_of_games
			  
--7. Which Sports were just played only once in the olympics.
--Problem Statement: 
--Using SQL query, Identify the sport which were just played once in all of olympics.	
with cte as (select sport,count(distinct games) as total_no_of_games from olympics_history group by sport)
select * from cte where total_no_of_games=1

--8. Fetch the total no of sports played in each olympic games.
--Problem Statement: 
--Write SQL query to fetch the total no of sports played in each olympics.
select games,count(distinct sport)as no_of_sports from olympics_history group by 1 order by 2 desc
   
--9. Fetch oldest athletes to win a gold medal
--Problem Statement: 
--SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.
with cte as (select name,sex,cast(case when age='NA' then '0' else age end as int)as age,
team,games,city,sport,event,medal from  olympics_history),
cte2 as (select *,rank() over(order by age desc)as rnk from cte where medal='Gold')
select * from cte2 where rnk=1

--10.10. Find the Ratio of male and female athletes participated in all olympic games.
--Problem Statement:
--Write a SQL query to get the ratio of male and female participants.
select round(sum(case when sex='M' then 1 else 0 end)::numeric/
			 sum(case when sex='F' then 1 else 0 end)::numeric),2 as ratio 
from olympics_history;
select sum(case when sex='M' then 1 else 0 end )as cnt/count(*)  from olympics_history
with cte as ( 
SELECT
    count(case when sex = 'M' then 1 else null end)as t1,
	count(case when sex = 'F' then 1 else null end) as t2
FROM
    olympics_history)
	select concat('1 : ', round(t1::decimal/t2), 2)as ratio from cte 

--11.Fetch the top 5 athletes who have won the most gold medals.
--Problem Statement: 
--SQL query to fetch the top 5 athletes who have won the most gold medals.
with t1 as (select * from olympics_history where medal='Gold'),
t2 as (select name,team,count(medal)as total_no_gold,
	   dense_rank() over (order by count(medal) desc) as rnk from t1 group by name,team)
select name,team,total_no_gold from t2 where rnk<=5 order by total_no_gold desc 

--12.Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals
--(Medals include gold, silver and bronze).
with cte as (select * from olympics_history where medal in ('Gold','Silver','Bronze')),
cte2 as (select name,count(medal) as total_no_of_medal,team,
		 dense_rank() over (order by count(medal) desc) as rnk from cte group by name,team)
select name,team,total_no_of_medal from cte2 where rnk<=5 order by total_no_of_medal desc

--13.Write a SQL query to fetch the top 5 most successful countries in olympics.
--(Success is defined by no of medals won).
select * from olympics_history;
select * from OLYMPICS_HISTORY_NOC_REGIONS;
with cte as (select * from olympics_history where medal in ('Gold','Silver','Bronze')),
cte2 as (select nr.region,count(cte.medal)as total_medals,
		 dense_rank() over (order by count(cte.medal)desc) as rnk from cte inner join 
OLYMPICS_HISTORY_NOC_REGIONS nr on cte.noc=nr.noc group by 1)
select * from cte2 where rnk<6

--14.Problem Statement: 
--Write a SQL query to list down the  total gold, silver and bronze medals won by each country.
select * from olympics_history;
select * from OLYMPICS_HISTORY_NOC_REGIONS;

with cte as (select * from olympics_history where medal in ('Gold','Silver','Bronze'))
select nr.region as country,sum(case when medal='Gold' then 1 else 0 end )as gold,
		   sum(case when medal='Silver' then 1 else 0 end )as silver,
		   sum(case when medal='Bronze' then 1 else 0 end )as Bronze
		   from olympics_history oh inner join OLYMPICS_HISTORY_NOC_REGIONS nr
		   on oh.noc=nr.noc group by 1 order by gold desc
--15.Problem Statement: 
--Write a SQL query to list down the  total gold, silver and bronze medals 
--won by each country corresponding to each olympic games.
select games,nr.region as country,sum(case when medal='Gold' then 1 else 0 end )as gold,
		   sum(case when medal='Silver' then 1 else 0 end )as silver,
		   sum(case when medal='Bronze' then 1 else 0 end )as Bronze
		   from olympics_history oh inner join OLYMPICS_HISTORY_NOC_REGIONS nr
		   on oh.noc=nr.noc group by 1 order by gold
--16Problem Statement: Write SQL query to display for each Olympic Games, 
--which country won the highest gold, silver and bronze medals.
with cte as (select * from olympics_history where medal in ('Gold','Silver','Bronze')),
cte2 as (select games,region as country,
		   sum(case when medal='Gold' then 1 else 0 end )as gold,
		   sum(case when medal='Silver' then 1 else 0 end )as silver,
		   sum(case when medal='Bronze' then 1 else 0 end )as Bronze
from cte  inner join OLYMPICS_HISTORY_NOC_REGIONS nr
on cte.noc=nr.noc group by 1,2 order by 1)
 select distinct games
    	, concat(first_value(country) over(partition by games order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
    	, concat(first_value(country) over(partition by games order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
    	, concat(first_value(country) over(partition by games order by Bronze desc)
    			, ' - '
    			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
    from cte2
    order by games;

--17:Problem Statement: Similar to the previous query, identify during each Olympic Games, 
--which country won the highest gold, silver and bronze medals. 
--Along with this, identify also the country with the most medals in each olympic games.

with cte as (select * from olympics_history where medal in ('Gold','Silver','Bronze')),
cte2 as (select games,region as country,sum(case when medal='Gold' then 1 else 0 end )as gold,
		   sum(case when medal='Silver' then 1 else 0 end )as silver,
		   sum(case when medal='Bronze' then 1 else 0 end )as Bronze,
		 sum(case when medal in('Gold','Silver','Bronze') then 1 else 0 end) as total_medal
		   from cte  inner join OLYMPICS_HISTORY_NOC_REGIONS nr
		   on cte.noc=nr.noc group by 1,2 order by 1)
 select distinct games
    	, concat(first_value(country) over(partition by games order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
    	, concat(first_value(country) over(partition by games order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
    	, concat(first_value(country) over(partition by games order by Bronze desc)
    			, ' - '
    			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
				, concat(first_value(country) over(partition by games order by total_medal desc)
    			, ' - '
    			, first_value(total_medal) over(partition by games order by total_medal desc)) as Max_medal
    from cte2
    order by games;
	
--18:Which countries have never won gold medal but have won silver/bronze medals?
--Problem Statement: Write a SQL Query to fetch details of countries which 
--have won silver or bronze medal but never won a gold medal.

with cte as (select * from olympics_history where medal in ('Gold','Silver','Bronze')),
cte2 as (select games,region as country,
		 sum(case when medal='Gold' then 1 else 0 end )as gold,
		   sum(case when medal='Silver' then 1 else 0 end )as silver,
		   sum(case when medal='Bronze' then 1 else 0 end )as Bronze
		   from cte  inner join OLYMPICS_HISTORY_NOC_REGIONS nr
		   on cte.noc=nr.noc group by 1,2 order by 1)
select country,gold,silver,bronze from cte2 where gold=0 and (silver > 0 or bronze >0);

--19.Problem Statement:
--Write SQL Query to return the sport which has won India the highest no of medals.

with cte as (select oh.sport,
 sum(case when medal in('Gold','Silver','Bronze') then 1 else 0 end) as total_medal
 from olympics_history oh inner join OLYMPICS_HISTORY_NOC_REGIONS nr
		  on oh.noc=nr.noc where region='India' group by 1)
		  
select sport,total_medal from cte where total_medal=(select max(total_medal)from cte)

--20.Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
--Problem Statement:
--Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 
with cte as  (select * from olympics_history where medal in ('Gold','Silver','Bronze'))
select team,sport,games,count(medal)as total_medals 
from cte where team='India' and sport='Hockey' group by 1,2,3 order by 4 desc
