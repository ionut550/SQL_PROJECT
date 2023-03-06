-- For this Script to work you need to run 'BowlingLeagueStructure.sql' and 'BowlingLeagueData.sql' first.

SET search_path TO BowlingLeague;

-- Where are we holding our tournaments?
CREATE VIEW Tourney_Location AS
SELECT DISTINCT tournaments.tourneylocation
FROM bowlingleague.tournaments;

-- Give me a list of all tournament dates and locations. I need the dates
-- descending order and the locations in alphabetical order.
CREATE VIEW Tourney_Dates AS
SELECT tournaments.tourneydate, tournaments.tourneylocation
FROM bowlingleague.tournaments
ORDER BY tournaments.tourneydate DESC, tournaments.tourneylocation ASC;
-- Default order for 'ORDER BY' is Ascendent but I put it there for clarity

-- List all of the teams in alphabetical order.
CREATE VIEW Team_List_Asc AS
SELECT teams.teamname 
FROM bowlingleague.teams
ORDER BY teams.teamname ASC;

-- Show me all the bowling score information for each of our members.
CREATE VIEW Bowler_Score_Information AS
SELECT bowler_scores.matchid,
    bowler_scores.gamenumber,
    bowler_scores.bowlerid,
    bowler_scores.rawscore,
    bowler_scores.handicapscore,
    bowler_scores.wongame
FROM bowlingleague.bowler_scores;
-- You can achive the same result by using '*' after select.

-- Show me a list of bowlers and their addresses, and sort it in alphabetical order
CREATE VIEW Bowler_Name_Addresses AS 
SELECT bowlers.bowlerlastname, 
	bowlers.bowlerfirstname,
	bowlers.bowleraddress,
	bowlers.bowlercity,
	bowlers.bowlerstate,
	bowlers.bowlerzip
FROM bowlingleague.bowlers
ORDER BY bowlers.bowlerlastname, bowlers.bowlerfirstname;

--Display a list of all bowlers and addresses formatted suitably for a mailing list, sorted by ZIP Code.
CREATE VIEW Name_Address_For_Mailling AS
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Full_Name,
	bowlers.bowleraddress, 
	bowlers.bowlercity || ' ' || bowlers.bowlerstate || ' ' || bowlers.bowlerzip AS City_State_Zip,
	bowlers.bowlerzip
FROM bowlingleague.bowlers
ORDER BY bowlers.bowlerzip;
-- Instead of using the 'concat()' function I used the short form of it '||'

-- What was the point spread between a bowler’s handicap and raw score for each match and game played?
CREATE VIEW Handicap_vs_RawScore AS
SELECT bowler_scores.bowlerid, 
	bowler_scores.matchid,
	bowler_scores.gamenumber,
	bowler_scores.handicapscore,
	bowler_scores.rawscore,
	(bowler_scores.handicapscore - bowler_scores.rawscore) AS PointsDifference
FROM bowlingleague.bowler_scores
ORDER BY bowler_scores.bowlerid, bowler_scores.matchid, bowler_scores.gamenumber;

-- Show next year’s tournament date for each tournament location.
CREATE VIEW Next_Year_Tourney_Dates AS 
SELECT tournaments.tourneydate, 
	tournaments.tourneylocation, 
	(tournaments.tourneydate + 365) AS NextYear
FROM bowlingleague.tournaments;

-- List the name and phone number for each member of the league.
CREATE VIEW Phone_List AS
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Full_Name,
	bowlers.bowlerphonenumber
FROM bowlingleague.bowlers
ORDER BY bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname;

-- Give me a listing of each team’s lineup.
CREATE VIEW Team_Lineups AS
SELECT bowlers.teamid, bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Full_name
FROM bowlingleague.bowlers
ORDER BY bowlers.teamid, bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname;

-- List the ID numbers of the teams that won one or more of the first ten matches in Game 3.
CREATE VIEW Top_Ten_Matches AS 
SELECT match_games.winningteamid, 
	match_games.matchid,
	match_games.gamenumber
FROM bowlingleague.match_games
WHERE match_games.gamenumber = 3
	AND (match_games.matchid BETWEEN 1 AND 10);
	
-- List the bowlers in teams 3, 4, and 5 whose last names begin with the letter ‘H’.
CREATE VIEW Bowlers_Teams_3_Through_5 AS
SELECT bowlers.bowlerfirstname, bowlers.bowlerlastname, bowlers.teamid
FROM bowlingleague.bowlers
WHERE (bowlers.teamid IN (3,4,5))
	AND (bowlers.bowlerlastname LIKE 'H%');
-- I could use 'BETWEEN' coparation as well instead of 'IN'

-- Give me a list of the tournaments held during September 2017.
CREATE VIEW Tournament_Held_In_September_2017 AS
SELECT tournaments.tourneylocation, tournaments.tourneydate
FROM bowlingleague.tournaments
WHERE tournaments.tourneydate BETWEEN '2017-09-01' AND '2017-09-30';

-- What are the tournament schedules for Bolero, Red Rooster, and Thunderbird Lanes?
CREATE VIEW Bolero_RedRooster_Thunderbird_Schedules AS 
SELECT tournaments.tourneylocation, tournaments.tourneydate
FROM bowlingleague.tournaments
WHERE tournaments.tourneylocation IN ('Bolero Lanes', 'Red Rooster Lanes', 'Thunderbird Lanes')
ORDER BY tournaments.tourneydate;

-- List the bowlers who live on the Eastside (you know—Bellevue,Bothell, Duvall, Redmond, and Woodinville) and who are on teams 5, 6, 7, or 8.
CREATE VIEW Eastside_Bowlers_On_Teams_5_Through_8 AS
SELECT bowlers.bowlerfirstname,
	bowlers.bowlerlastname,
	bowlers.bowlercity,
	bowlers.teamid
FROM bowlingleague.bowlers
WHERE bowlers.bowlercity IN ('Bellevue', 'Bothell', 'Duvall', 'Redmond', 'Woodinville')
	AND (bowlers.teamid BETWEEN 5 AND 8)
ORDER BY bowlers.bowlerfirstname, bowlers.bowlerlastname;

-- Display bowling teams and the name of each team captain.
CREATE VIEW Captains_Teams AS
SELECT teams.teamname, bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS CaptainName
FROM bowlingleague.bowlers
INNER JOIN bowlingleague.teams
ON bowlers.bowlerid = teams.captainid;

-- List all the tournaments, the tournament matches, and the game results.
CREATE VIEW Match_Game_Results AS
SELECT tournaments.tourneyid AS Tourney,
	tournaments.tourneylocation AS Location,
	tourney_matches.matchid,
	tourney_matches.lanes,
	oddteam.teamname AS OddLaneTeam,
	eventeam.teamname AS EvenLaneTeam,
	match_games.gamenumber AS GameNo,
	Winner.Teamname AS Winner
FROM bowlingleague.tournaments
	INNER JOIN bowlingleague.tourney_matches
	ON tournaments.tourneyid = tourney_matches.tourneyid
	INNER JOIN bowlingleague.teams AS oddteam
	ON tourney_matches.oddlaneteamid = oddteam.teamid
	INNER JOIN bowlingleague.teams AS eventeam
	ON tourney_matches.evenlaneteamid = eventeam.teamid
	INNER JOIN bowlingleague.match_games
	ON tourney_matches.matchid = match_games.matchid
	INNER JOIN bowlingleague.teams AS winner
	ON winner.teamid = match_games.winningteamid;
-- To solve this problem I used the teams table 3 times and I assigned an alias each time

-- Find the bowlers who had a raw score of 170 or better at both Thunderbird Lanes and Bolero Lanes.
CREATE VIEW Bowlers_Over_170_Tbird_Bolero AS
SELECT DISTINCT table1.bowler_name
FROM (
	SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
		bowler_scores.rawscore,
		bowlers.bowlerid
	FROM bowlingleague.bowler_scores
		INNER JOIN bowlingleague.bowlers
		ON bowler_scores.bowlerid = bowlers.bowlerid
		INNER JOIN bowlingleague.tourney_matches
		ON bowler_scores.matchid = tourney_matches.matchid
		INNER JOIN bowlingleague.tournaments
		ON tourney_matches.tourneyid = tournaments.tourneyid
		WHERE bowler_scores.rawscore >= 170 
		AND tournaments.tourneylocation IN ('Thunderbird Lanes')
	) AS table1
	INNER JOIN (
	SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
		bowler_scores.rawscore,
		bowlers.bowlerid
	FROM bowlingleague.bowler_scores
		INNER JOIN bowlingleague.bowlers
		ON bowler_scores.bowlerid = bowlers.bowlerid
		INNER JOIN bowlingleague.tourney_matches
		ON bowler_scores.matchid = tourney_matches.matchid
		INNER JOIN bowlingleague.tournaments
		ON tourney_matches.tourneyid = tournaments.tourneyid
		WHERE bowler_scores.rawscore >= 170 
		AND tournaments.tourneylocation IN ('Bolero Lanes')
	) AS table2
	ON table1.bowlerid = table2.bowlerid;

-- List the bowling teams and all the team members.
CREATE VIEW Teams_And_Bowlers AS
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	teams.teamname
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.teams
	ON bowlers.teamid = teams.teamid;
	
-- Display the bowlers, the matches they played in, and the bowler game scores.
CREATE VIEW Bowlers_Game_Scores AS
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	teams.teamname AS Team,
	bowler_scores.matchid AS Match,
	bowler_scores.gamenumber AS GameNO,
	bowler_scores.rawscore
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
	INNER JOIN bowlingleague.teams
	ON bowlers.teamid = teams.teamid;
	
-- Find the bowlers who live in the same ZIP Code.
CREATE VIEW Bowler_Same_Zip_Multiple_Condition_Join AS
SELECT bowler1.bowlerfirstname || ' ' || bowler1.bowlerlastname AS First_Bowler,
	bowler2.bowlerfirstname || ' ' || bowler2.bowlerlastname AS Second_Bowler,
	bowler1.bowlerzip
FROM bowlingleague.bowlers AS bowler1
	INNER JOIN bowlingleague.bowlers AS bowler2
	ON (bowler1.bowlerzip = bowler2.bowlerzip AND bowler1.bowlerid <> bowler2.bowlerid);
-- Here I use multiple condition on JOIN.
CREATE VIEW Bowler_Same_Zip_Join_And_Filter AS
SELECT bowler1.bowlerfirstname || ' ' || bowler1.bowlerlastname AS First_Bowler,
	bowler2.bowlerfirstname || ' ' || bowler2.bowlerlastname AS Second_Bowler,
	bowler1.bowlerzip
FROM bowlingleague.bowlers AS bowler1
	INNER JOIN bowlingleague.bowlers AS bowler2
	ON bowler1.bowlerzip = bowler2.bowlerzip
WHERE bowler1.bowlerid <> bowler2.bowlerid;
-- And here is the same result but first we join and then we filter.

-- Show me tournaments that haven’t been played yet.
CREATE VIEW Tourney_Not_Played_Yet AS
SELECT tournaments.tourneyid, 
	tournaments.tourneydate,
	tournaments.tourneylocation
FROM bowlingleague.tournaments
	LEFT OUTER JOIN bowlingleague.tourney_matches
	ON tournaments.tourneyid = tourney_matches.tourneyid
WHERE tourney_matches.matchid IS NULL;

-- List all bowlers and any games they bowled over 180.
CREATE VIEW All_Bowlers_And_Scores_Over_180 AS
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	table1.tourneydate, 
	table1.tourneylocation,
	table1.matchid,
	table1.rawscore
FROM bowlingleague.bowlers
LEFT OUTER JOIN (
	SELECT tournaments.tourneydate,
		tournaments.tourneylocation,
		bowler_scores.matchid,
		bowler_scores.bowlerid,
		bowler_scores.rawscore
	FROM bowlingleague.bowler_scores
		INNER JOIN bowlingleague.tourney_matches
		ON bowler_scores.matchid = tourney_matches.matchid
		INNER JOIN bowlingleague.tournaments
		ON tournaments.tourneyid = tourney_matches.tourneyid
	WHERE bowler_scores.rawscore > 180
) AS table1
ON bowlers.bowlerid = table1.bowlerid;
-- First I querie for all the bowlers who have more than 180 score and then i left join with all the bowlers 

-- Display matches with no game data.
CREATE VIEW Matches_Not_Played_Yet AS
SELECT tourney_matches.matchid,
    tourney_matches.tourneyid,
    teams.teamname AS oddlaneteam,
    teams_1.teamname AS evenlaneteam
FROM bowlingleague.teams teams_1
INNER JOIN (bowlingleague.teams
	INNER JOIN (bowlingleague.tourney_matches
		LEFT OUTER JOIN bowlingleague.match_games 
	 	ON tourney_matches.matchid = match_games.matchid)
	ON teams.teamid = tourney_matches.oddlaneteamid) 
ON teams_1.teamid = tourney_matches.evenlaneteamid
WHERE match_games.matchid IS NULL;

-- Display all tournaments and any matches that have been played.
CREATE VIEW All_Tourneys_And_Matches AS
SELECT tournaments.tourneydate,
	tournaments.tourneylocation,
	match_games.matchid AS Match,
	match_games.gamenumber AS GameNo
FROM bowlingleague.tournaments
	LEFT OUTER JOIN (bowlingleague.tourney_matches
		INNER JOIN bowlingleague.match_games
		ON tourney_matches.matchid = match_games.matchid)
	ON tournaments.tourneyid = tourney_matches.tourneyid;
-- Becouse some tourney haven't started yet I used a left join on it to appear in the query\

-- List the tourney matches, team names, and team captains for the
-- teams starting on the odd lane together with the tourney matches,
-- team names, and team captains for the teams starting on the even
-- lane, and sort by tournament date and match number.
CREATE VIEW Bowling_Schedule AS
SELECT tournaments.tourneylocation,
	tournaments.tourneydate,
	tourney_matches.matchid,
	teams.teamname,
	bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Captain,
	'Odd Lane' AS Lane
FROM bowlingleague.tournaments 
	INNER JOIN bowlingleague.tourney_matches
	ON tournaments.tourneyid = tourney_matches.tourneyid
	INNER JOIN bowlingleague.teams
	ON tourney_matches.oddlaneteamid = teams.teamid
	INNER JOIN bowlingleague.bowlers
	ON bowlers.bowlerid = teams.captainid

UNION ALL 

SELECT tournaments.tourneylocation,
	tournaments.tourneydate,
	tourney_matches.matchid,
	teams.teamname,
	bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Captain,
	'Even Lane' AS Lane
FROM bowlingleague.tournaments 
	INNER JOIN bowlingleague.tourney_matches
	ON tournaments.tourneyid = tourney_matches.tourneyid
	INNER JOIN bowlingleague.teams
	ON tourney_matches.evenlaneteamid = teams.teamid
	INNER JOIN bowlingleague.bowlers
	ON bowlers.bowlerid = teams.captainid
	
ORDER BY 2,3; 
-- I used 'UNION ALL' becouse a team is never going to compete againt itself, and I sort
-- by column number instead of column name(TourneyDate and MatchID).

-- Find the bowlers who had a raw score of 165 or better at Thunderbird
-- Lanes combined with bowlers who had a raw score of 150 or
-- better at Bolero Lanes.
CREATE VIEW Good_Bowlers_UNION AS 
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	bowler_scores.rawscore AS Score,
	tournaments.tourneylocation AS Location
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
	INNER JOIN bowlingleague.tourney_matches
	ON bowler_scores.matchid = tourney_matches.matchid
	INNER JOIN bowlingleague.tournaments
	ON tourney_matches.tourneyid = tournaments.tourneyid
WHERE bowler_scores.rawscore >= 165 AND tournaments.tourneylocation = 'Thunderbird Lanes'

UNION 

SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	bowler_scores.rawscore AS Score,
	tournaments.tourneylocation AS Location
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
	INNER JOIN bowlingleague.tourney_matches
	ON bowler_scores.matchid = tourney_matches.matchid
	INNER JOIN bowlingleague.tournaments
	ON tourney_matches.tourneyid = tournaments.tourneyid
WHERE bowler_scores.rawscore >= 150 AND tournaments.tourneylocation = 'Bolero Lanes';
-- I used 'UNION' instead of 'UNION ALL' becouse it filters for duplicates.

-- Display the bowlers and the highest game each bowled.
CREATE VIEW Bowler_High_Score AS 
SELECT bowlers.bowlerfirstname, 
	bowlers.bowlerlastname,
	(SELECT MAX(rawscore)
	 FROM bowlingleague.bowler_scores
	 WHERE bowler_scores.bowlerid = bowlers.bowlerid
	) AS HighScore
FROM bowlingleague.bowlers;
-- Here I used a subquery to fetch the high score for each bowler. 

-- Display team captains with a handicap score higher than all other members on their teams.
CREATE VIEW Team_Captains_High_Score AS 
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Captain_Name,
	teams.teamname, 
	bowler_scores.handicapscore
FROM bowlingleague.bowlers 
	INNER JOIN bowlingleague.teams
	ON bowlers.bowlerid = teams.captainid
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
WHERE bowler_scores.handicapscore > ALL ( 
	SELECT b1.handicapscore 
	FROM bowlingleague.bowler_scores b1
		INNER JOIN bowlingleague.bowlers AS b2
		ON b2.bowlerid = b1.bowlerid
	WHERE b2.bowlerid <> bowlers.bowlerid AND b2.teamid = bowlers.teamid);
-- Here I create a subquery as a filter which return the handicapscore of the team without the captain 
-- becouse if the captain was in that list the 'ALL' condition will be false.

-- Show me all the bowlers and a count of games each bowled.
CREATE VIEW Bowlers_And_Count_Games AS
SELECT bowlers.bowlerfirstname|| ' ' || bowlers.bowlerlastname AS Bowler_Name,
	(SELECT COUNT(*)
	 FROM bowlingleague.bowler_scores
	 WHERE bowlers.bowlerid =bowler_scores.bowlerid
	) AS NoGames
FROM bowlingleague.bowlers;

-- List all the bowlers who have a raw score that’s less than all of the other bowlers on the same team.
CREATE VIEW Bowlers_Low_Score_Team AS
SELECT DISTINCT bowlers.bowlerfirstname|| ' ' || bowlers.bowlerlastname AS Bowler_Name,
	bowler_scores.rawscore
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
WHERE bowler_scores.rawscore < ALL (
	SELECT bs1.rawscore
	FROM bowlingleague.bowler_scores AS bs1
		INNER JOIN bowlingleague.bowlers AS b1
		ON bs1.bowlerid = b1.bowlerid
	WHERE b1.bowlerid <> bowlers.bowlerid AND b1.teamid = bowlers.teamid);
	
-- How many tournaments have been played at Red Rooster Lanes?
CREATE VIEW Number_Of_Tournaments_As_Red_Rooster_Lanes As
SELECT COUNT(tourneylocation) AS NumberOfTurnaments
FROM bowlingleague.tournaments
WHERE tourneylocation = 'Red Rooster Lanes';

-- What is the largest handicap held by any bowler at the current time?
CREATE VIEW Current_Highest_Handicap AS 
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	bowler_scores.handicapscore
FROM bowlingleague.bowlers 
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
WHERE bowler_scores.handicapscore = (
	SELECT MAX(bs1.handicapscore)
	FROM bowlingleague.bowler_scores AS bs1);

-- Which locations hosted tournaments on the earliest tournament date?
CREATE VIEW Tourney_Location_For_Earliest_Date AS
SELECT tournaments.tourneylocation, tournaments.tourneydate
FROM bowlingleague.tournaments
WHERE tournaments.tourneydate = (
	SELECT MIN(t1.tourneydate)
	FROM bowlingleague.tournaments AS t1);
	
-- What is the last tournament date we have on our schedule?
CREATE VIEW Last_Tourney_Date AS
SELECT tournaments.tourneylocation, tournaments.tourneydate
FROM bowlingleague.tournaments
WHERE tournaments.tourneydate = (
	SELECT MAX(t1.tourneydate)
	FROM bowlingleague.tournaments AS t1);
	
-- Show me for each tournament and match the tournament ID, the tournament
-- location, the match number, the name of each team, and the
-- total of the handicap score for each team.
CREATE VIEW Tournament_Mathc_Team_Results_HandicapScore AS
SELECT tournaments.tourneyid, 
	tournaments.tourneylocation,
	tourney_matches.matchid,
	teams.teamname,
	SUM(bowler_scores.handicapscore) AS TotHandicapScore
FROM bowlingleague.tournaments
	INNER JOIN bowlingleague.tourney_matches
	ON tournaments.tourneyid = tourney_matches.tourneyid
	INNER JOIN bowlingleague.match_games
	ON tourney_matches.matchid = match_games.matchid
	INNER JOIN bowlingleague.bowler_scores
	ON (match_games.matchid = bowler_scores.matchid AND match_games.gamenumber = bowler_scores.gamenumber)
	INNER JOIN bowlingleague.bowlers
	ON bowlers.bowlerid = bowler_scores.bowlerid
	INNER JOIN bowlingleague.teams
	ON teams.teamid = bowlers.teamid
GROUP BY tournaments.tourneyid, 
	tournaments.tourneylocation,
	tourney_matches.matchid,
	teams.teamname;

-- Display the highest raw score for each bowler.
CREATE VIEW Bowler_High_Score_Group_by AS 
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	MAX(bowler_scores.rawscore) AS HighScore
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
GROUP BY bowlers.bowlerfirstname,
	bowlers.bowlerlastname;
	
-- Display for each bowler the bowler name and the average of the bowler’s raw game scores.
CREATE VIEW Bowler_Averages_Scores AS  
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	AVG(bowler_scores.rawscore) AS Average
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
GROUP BY bowlers.bowlerfirstname,
	bowlers.bowlerlastname;
	
-- Calculate the current average and handicap for each bowler.”
CREATE VIEW Bowler_Average_Handicap AS
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	AVG(bowler_scores.rawscore) AS Average,
	AVG(bowler_scores.handicapscore) AS Average_Handicap
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
GROUP BY bowlers.bowlerfirstname,
	bowlers.bowlerlastname;
	
-- Display the highest raw score for each bowler, but solve it by using a subquery.
CREATE VIEW Bowler_High_Score_Subquery AS
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	(SELECT MAX(bs1.rawscore)
	FROM bowlingleague.bowler_scores AS bs1
	WHERE bs1.bowlerid = bowlers.bowlerid)
FROM bowlingleague.bowlers;

-- List the bowlers whose highest raw scores are more than 20 pins higher than their current averages.
CREATE VIEW Bowler_Big_High_Score AS
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	ROUND(AVG(bowler_scores.rawscore)) AS CurrentAverage,
	MAX(bowler_scores.rawscore) AS HighGame
FROM bowlingleague.bowler_scores
	INNER JOIN bowlingleague.bowlers
	ON bowlers.bowlerid = bowler_scores.bowlerid
GROUP BY bowlers.bowlerfirstname, bowlers.bowlerlastname
HAVING MAX(bowler_scores.rawscore) > (AVG(bowler_scores.rawscore)+20);

-- Do any team captains have a raw score that is higher than any other member of the team?
CREATE VIEW Captain_Who_Are_Hotshots AS 
SELECT bowlers.bowlerfirstname|| ' ' || bowlers.bowlerlastname AS Captain_Name,
	MAX(bowler_scores.rawscore) AS Max_RawScore,
	teams.teamid,
	bowlers.bowlerid
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
	INNER JOIN bowlingleague.teams
	ON bowlers.bowlerid = teams.captainid
GROUP BY bowlers.bowlerfirstname, 
	bowlers.bowlerlastname,
	bowler_scores.rawscore,
	teams.teamid,
	bowlers.bowlerid
HAVING MAX(bowler_scores.rawscore) > (
	SELECT MAX(bs1.rawscore)
	FROM bowlingleague.bowler_scores AS bs1
		INNER JOIN bowlingleague.bowlers as b1
		ON bs1.bowlerid = b1.bowlerid
		INNER JOIN bowlingleague.teams AS t1
		ON b1.teamid = t1.teamid
	WHERE b1.bowlerid <> bowlers.bowlerid AND t1.teamid = teams.teamid);
-- First we fetch the max score of each Captain and then we filter it with the max score from each team in the 'HAVING' clause.

-- Display for each bowler the bowler name and the average of the
-- bowler’s raw game scores for bowlers whose average is greater than 155.
CREATE VIEW Good_Bowlers AS
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	AVG(bowler_scores.rawscore)
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
GROUP BY bowlers.bowlerfirstname, bowlers.bowlerlastname
HAVING AVG(bowler_scores.rawscore) > 155;

-- List the last name and first name of every bowler whose average
-- raw score is greater than or equal to the overall average score.
CREATE VIEW Better_Than_Overall_Average AS 
SELECT bowlers.bowlerfirstname || ' ' || bowlers.bowlerlastname AS Bowler_Name,
	AVG(bowler_scores.rawscore)
FROM bowlingleague.bowlers
	INNER JOIN bowlingleague.bowler_scores
	ON bowlers.bowlerid = bowler_scores.bowlerid
GROUP BY bowlers.bowlerfirstname, bowlers.bowlerlastname
HAVING AVG(bowler_scores.rawscore) >= (
	SELECT AVG(bs1.rawscore)
	FROM bowlingleague.bowler_scores AS bs1);
