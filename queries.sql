/* 
There's been a Murder in SQL City! The SQL Murder Mystery is designed to be 
both a self-directed lesson to learn SQL concepts and commands and a fun game 
for experienced SQL users to solve an intriguing crime.

New to SQL?
This exercise is meant more as a way to practice SQL skills than a full tutorial. 
If you've never used SQL at all, try the walkthrough. If you really want to learn 
a lot about SQL, you may prefer a complete tutorial like Select Star SQL.

If you're comfortable with SQL, you can dive in below!

Experienced SQL sleuths start here
A crime has taken place and the detective needs your help. The detective gave you 
the crime scene report, but you somehow lost it. You vaguely remember that the crime 
was a ​murder​ that occurred sometime on ​Jan.15, 2018​ and that it took place in ​SQL City​. 
Start by retrieving the corresponding crime scene report from the police department’s database.

Exploring the Database Structure
Experienced SQL users can often use database queries to infer the structure of a database. 
But each database system has different ways of managing this information. The SQL Murder Mystery 
is built using SQLite. Use this SQL command to find the tables in the Murder Mystery database.
*/            

-- crime scene report
SELECT *
FROM crime_scene_report
WHERE date = 20180115
	AND city = 'SQL City'
	AND type = 'murder';
/* Info: Security footage shows that there were 2 witnesses. The first witness lives at the last house 
on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave".
*/

-- First Witness
SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;
/* id: 14887, name: Morty Schapiro, license_id: 118009, address_number: 4919, 
address_street_name: Northwestern Dr, ssn: 1115649490
*/

-- Second Witness
SELECT *
FROM person
WHERE address_street_name = 'Franklin Ave'
	AND name like 'Annabel%';
/* id: 16371, name: Annabel Miller, license_id: 490173, address_number: 103, 
address_street_name: Northwestern Dr, ssn: 318771143
*/

/* With these two witnesses information, I can look at the transcript of their 
respective interviews to see if I can find a lead. I'm thinking I can also find 
out where they were on the day of the murder when looking into the tables related
to check-ins: get_fit_now and facebook_event
*/

-- Interview responses
SELECT person_id, name, transcript
FROM interview
JOIN person
	ON person.id=interview.person_id
WHERE person_id = 14887 
	OR person_id = 16371
/*
Morty Schapiro: I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. 
The membership number on the bag started with "48Z". Only gold members have those bags. 
The man got into a car with a plate that included "H42W".

Annabel Miller: I saw the murder happen, and I recognized the killer from my gym when I was 
working out last week on January the 9th.
*/

-- Get-fit-now member report details: Morty
SELECT *
FROM get_fit_now_member
JOIN person
	ON get_fit_now_member.person_id=person.id
JOIN drivers_license
	ON person.license_id=drivers_license.id
WHERE get_fit_now_member.id like '48Z%'
	AND membership_status = 'gold'
/* id	person_id	name	membership_start_date	membership_status	id	name	license_id	address_number	address_street_name	ssn	id	age	height	eye_color	hair_color	gender	plate_number	car_make	car_model
48Z7A	28819	Joe Germuska	20160305	gold	28819	Joe Germuska	173289	111	Fisk Rd	138909730	null	null	null	null	null	null	null	null	null
48Z55	67318	Jeremy Bowers	20160101	gold	67318	Jeremy Bowers	423327	530	Washington Pl, Apt 3A	871539279	423327	30	70	brown	brown	male	0H42W2	Chevrolet	Spark LS
*/

-- Get-fit-now member report details: Annabel
SELECT *
FROM get_fit_now_check_in
JOIN get_fit_now_member
	ON get_fit_now_check_in.membership_id=get_fit_now_member.id
WHERE check_in_date = 20180109
	AND check_in_time between '1400' and '1800'
/* imembership_id	check_in_date	check_in_time	check_out_time	id	person_id	name	membership_start_date	membership_status
48Z7A	20180109	1600	1730	48Z7A	28819	Joe Germuska	20160305	gold
48Z55	20180109	1530	1700	48Z55	67318	Jeremy Bowers	20160101	gold
*/

-- facebook checkin activity for all suspects
SELECT *
FROM facebook_event_checkin
JOIN person
	ON facebook_event_checkin.person_id=person.id
LEFT JOIN drivers_license
	ON person.license_id=drivers_license.id
WHERE name = 'Jeremy Bowers'
	OR name = 'Joe Germuska'
	OR name = 'Annabel Miller'
	OR name = 'Morty Schapiro'
/* 
person_id	event_id	event_name	date	id	name	license_id	address_number	address_street_name	ssn	id	age	height	eye_color	hair_color	gender	plate_number	car_make	car_model
14887	4719	The Funky Grooves Tour	20180115	14887	Morty Schapiro	118009	4919	Northwestern Dr	111564949	118009	64	84	blue	white	male	00NU00	Mercedes-Benz	E-Class
16371	4719	The Funky Grooves Tour	20180115	16371	Annabel Miller	490173	103	Franklin Ave	318771143	490173	35	65	green	brown	female	23AM98	Toyota	Yaris
67318	4719	The Funky Grooves Tour	20180115	67318	Jeremy Bowers	423327	530	Washington Pl, Apt 3A	871539279	423327	30	70	brown	brown	male	0H42W2	Chevrolet	Spark LS
67318	1143	SQL Symphony Concert	20171206	67318	Jeremy Bowers	423327	530	Washington Pl, Apt 3A	871539279	423327	30	70	brown	brown	male	0H42W2	Chevrolet	Spark LS
*/

-- Interview info for suspects
SELECT *
FROM person
LEFT JOIN interview
	ON interview.person_id=person.id
WHERE name = 'Jeremy Bowers'
	OR name = 'Joe Germuska'
/*
id	name	license_id	address_number	address_street_name	ssn	person_id	transcript
28819	Joe Germuska	173289	111	Fisk Rd	138909730	null	null
67318	Jeremy Bowers	423327	530	Washington Pl, Apt 3A	871539279	67318	

I was hired by a woman with a lot of money. 
I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she 
drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.
*/

-- Killer's boss description
SELECT *
FROM person
LEFT JOIN drivers_license
	ON person.license_id=drivers_license.id
LEFT JOIN income
	ON income.ssn=person.ssn
LEFT JOIN facebook_event_checkin as fb
	ON fb.person_id=person.id
WHERE gender = 'female'
	AND height between 65 and 67
	AND hair_color = 'red'
	AND car_make = 'Tesla'
	AND car_model = 'Model S'
	AND fb.date like '201712%'
/*
id	name	license_id	address_number	address_street_name	ssn	id	age	height	eye_color	hair_color	gender	plate_number	car_make	car_model	ssn	annual_income	person_id	event_id	event_name	date
99716	Miranda Priestly	202298	1883	Golden Ave	987756388	202298	68	66	green	red	female	500123	Tesla	Model S	987756388	310000	99716	1143	SQL Symphony Concert	20171206
99716	Miranda Priestly	202298	1883	Golden Ave	987756388	202298	68	66	green	red	female	500123	Tesla	Model S	987756388	310000	99716	1143	SQL Symphony Concert	20171212
99716	Miranda Priestly	202298	1883	Golden Ave	987756388	202298	68	66	green	red	female	500123	Tesla	Model S	987756388	310000	99716	1143	SQL Symphony Concert	20171229
*/