--Coding challenge-Crime Management 

drop table if exists crime,victim,suspect;


--creating tables


create table crime (
crimeid int primary key,
incidenttype varchar(255),
incidentdate date,
location varchar(255),
description text,
status varchar(20));

create table victim (
victimid int primary key,
crimeid int,
name varchar(255),
contactinfo varchar(255),
injuries varchar(255),
age int,
foreign key (crimeid) references crime(crimeid));

create table suspect (
suspectid int primary key,
crimeid int,
name varchar(255),
description text,
criminalhistory text,
age int,
foreign key (crimeid) references crime(crimeid));

--inserting values

insert into crime values
(1, 'robbery', '2023-09-15', '123 main st, cityville', 'armed robbery at a convenience store', 'open'),
(2, 'homicide', '2023-09-20', '456 elm st, townsville', 'investigation into a murder case', 'under investigation'),
(3, 'theft', '2023-09-10', '789 oak st, villagetown', 'shoplifting incident at a mall', 'closed');

insert into victim values
(1, 1, 'john doe', 'johndoe@example.com', 'minor injuries', 30),
(2, 2, 'jane smith', 'janesmith@example.com', 'deceased', 35),
(3, 3, 'alice johnson', 'alicejohnson@example.com', 'none', 25);

insert into suspect values
(1, 1, 'robber 1', 'armed and masked robber', 'previous robbery convictions', 40),
(2, 2, 'unknown', 'investigation ongoing', null, 34),
(3, 3, 'suspect 1', 'shoplifting suspect', 'prior shoplifting arrests', 29);

select * from crime;
select * from victim;
select * from suspect;


--Queries

--1.Select all open incidents

select * from crime where status = 'open';


--2.Find the total number of incidents

select count(*) as total_incidents from crime;


--3.List all unique incident types

select distinct incidenttype from crime;


--4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'
select * from crime
where incidentdate between '2023-09-01' and '2023-09-10';


--5.List persons involved in incidents in descending order of age

select name,age from victim
union
select name,age from suspect
order by age desc;


--6.Find the average age of persons involved in incidents

select avg(age) as avg_age 
from 
(select age from victim
union all
select age from suspect) as all_persons;


--7.List incident types and their counts, only for open cases

select incidenttype, count(*) as incidentcounts
from crime
where status = 'open'
group by incidenttype;

--8.Find persons with names containing 'Doe'
select name from victim 
where name like '%doe%'
union
select name from suspect 
where name like '%doe%';

--9.Retrieve the names of persons involved in open cases and closed cases

select v.name from victim v
join crime c on v.crimeid = c.crimeid
where c.status in ('open', 'closed')
union
select s.name from suspect s
join crime c on s.crimeid = c.crimeid
where c.status in ('open', 'closed');

--or (using or operator)

select v.name from victim v
join crime c on v.crimeid=c.crimeid
where c.status='open' or c.status='closed'
union 
select s.name from suspect s
join crime c on s.crimeid=c.crimeid
where c.status='open' or c.status='closed';

--10.List incident types where there are persons aged 30 or 35 involved

select distinct c.incidenttype
from crime c
join victim v on c.crimeid = v.crimeid
where v.age in (30, 35)
union
select distinct c.incidenttype
from crime c
join suspect s on c.crimeid = s.crimeid
where s.age in (30, 35);

--or (using or operator)
select c.incidenttype as incidenttypes
from crime c
join victim v on v.crimeid=c.crimeid
where v.age = 30 or v.age=35
union
select c.incidenttype as incidenttypes
from crime c
join suspect s on s.crimeid=c.crimeid
where s.age = 30 or s.age=35

--11.Find persons involved in incidents of the same type as 'Robbery'

select v.name 
from victim v
join crime c on c.crimeid=v.crimeid
where c.incidenttype='robbery'
union 
select s.name 
from suspect s
join crime c on c.crimeid=s.crimeid
where c.incidenttype='robbery';


--12.List incident types with more than one open case

select incidenttype, count(*) as counts
from crime
where status = 'open'
group by incidenttype
having count(*) > 1;  --(result-empty-crime table has only one open case)


--13.List all incidents with suspects whose names also appear as victims in other incidents
select c.*
from crime c
join suspect s on c.crimeid = s.crimeid
where s.name in (select name from victim);   --(result-empty-no such data in the given schema,victims and suspect names are different)

--14.Retrieve all incidents along with victim and suspect details

select c.crimeid, c.incidenttype, c.status, v.name as victim_name, s.name as suspect_name
from crime c
left join victim v on c.crimeid = v.crimeid
left join suspect s on c.crimeid = s.crimeid;

--or (display by adding suspect and victim name to crime table)
select c.*, v.name as victim_name, s.name as suspect_name
from crime c
left join victim v on c.crimeid = v.crimeid
left join suspect s on c.crimeid = s.crimeid;

--15. Find incidents where the suspect is older than any victim

select c.*
from crime c
join suspect s on c.crimeid = s.crimeid
where s.age > all (select v.age
				   from victim v
				   where v.crimeid = c.crimeid);


--16. Find suspects involved in multiple incidents

select name, count(*) as incident_count
from suspect
group by name
having count(*) > 1;  --(result-empty-only one incident in the given scheme)

--17.List incidents with no suspects involved

select * from crime
where crimeid not in (select distinct crimeid from suspect); --(result-empty-all incidents has a suspect)

--18.List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery'

select *
from crime
where 
not exists (
    select 1 from crime
    where incidenttype not in ('robbery', 'homicide'))
and exists (
    select 1 from crime
    where incidenttype = 'homicide');  --(result-empty-has "theft" as a incident type)

  
--19.. Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none
 
select c.crimeid, c.incidenttype, 
coalesce(s.name, 'no suspect') as suspect_name
from crime c
left join suspect s on c.crimeid = s.crimeid;

--20.List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault'

select s.name
from suspect s
join crime c on s.crimeid = c.crimeid
where c.incidenttype in ('robbery', 'assault');