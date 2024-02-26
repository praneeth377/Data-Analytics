select * from RayPitching.Dbo.LastPitchRays
select * from RayPitching.Dbo.RaysPitchingStats

--Question 1 AVG Pitches Per at Bat Analysis

--1a AVG Pitches Per At Bat (LastPitchRays)

select avg(1.00 * pitch_number) as AvgPitchesPerBat from RayPitching.Dbo.LastPitchRays

--1b AVG Pitches Per At Bat Home Vs Away (LastPitchRays) -> Union

select 'Home' as TypeofGame, avg(1.00 * pitch_number) as AvgPitchesPerBat from RayPitching.Dbo.LastPitchRays where home_team = 'TB'
union
select 'Away' as TypeofGame, avg(1.00 * pitch_number) as AvgPitchesPerBat from RayPitching.Dbo.LastPitchRays where away_team = 'TB'

--1c AVG Pitches Per At Bat Lefty Vs Righty  -> Case Statement

select avg(case when Batter_position = 'L' then 1.00*pitch_number end) as AvgLeftyPitches, 
avg(case when Batter_position = 'R' then 1.00*pitch_number end) as AvgRightyPitches
from RayPitching.Dbo.LastPitchRays

--1d AVG Pitches Per At Bat Lefty Vs Righty Pitcher | Each Away Team -> Partition By

select distinct home_team, Pitcher_position, avg(1.00*pitch_number) over(partition by home_team, Pitcher_position) 
from RayPitching.Dbo.LastPitchRays where away_team = 'TB'

--1e Top 3 Most Common Pitch for at bat 1 through 10, and total amounts (LastPitchRays)

with t1 as (
select distinct pitch_name, pitch_number, count(pitch_name) over(partition by pitch_name, pitch_number) as PitchFrequency
from RayPitching.Dbo.LastPitchRays where pitch_number < 11
),
t2 as (
select *, rank() over (partition by pitch_number order by PitchFrequency desc) as PitchFrequencyRank from t1
)
select * from t2 where PitchFrequencyRank < 4 

--1f AVG Pitches Per at Bat Per Pitcher with 20+ Innings | Order in descending (LastPitchRays + RaysPitchingStats)

select a.Name, avg(1.00*b.pitch_number) as AvgPitches from RayPitching.Dbo.RaysPitchingStats a join RayPitching.Dbo.LastPitchRays b on a.pitcher_id = b.pitcher
where IP >= 20 group by a.Name order by AvgPitches desc

--Question 2 Last Pitch Analysis

--2a Count of the Last Pitches Thrown in Desc Order (LastPitchRays)

select pitch_name, count(*) as TimesThrown from RayPitching.Dbo.LastPitchRays group by pitch_name order by TimesThrown desc

--2b Count of the different last pitches Fastball or Offspeed (LastPitchRays)

select sum(case when pitch_name in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) as Fastball_Pitches,
sum(case when pitch_name not in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) as Offspeed_Pitches
from RayPitching.Dbo.LastPitchRays

--2c Percentage of the different last pitches Fastball or Offspeed (LastPitchRays)

select 100.0*sum(case when pitch_name in ('4-Seam Fastball', 'Cutter') then 1 else 0 end)/count(*) as Fastball_Pitches_Percentage,
100.0*sum(case when pitch_name not in ('4-Seam Fastball', 'Cutter') then 1 else 0 end)/count(*) as Offspeed_Pitches_Percentage
from RayPitching.Dbo.LastPitchRays

--2d Top 5 Most common last pitch for a Relief Pitcher vs Starting Pitcher (LastPitchRays + RaysPitchingStats)

select top 5 a.Pos as Position, b.pitch_name as Pitch_Name, count(b.pitch_name) as PitchesCount
from RayPitching.Dbo.RaysPitchingStats a join RayPitching.Dbo.LastPitchRays b
on a.pitcher_id = b.pitcher group by a.Pos, b.pitch_name having a.Pos = 'SP' order by PitchesCount desc

select top 5 a.Pos as Position, b.pitch_name as Pitch_Name, count(b.pitch_name) as PitchesCount 
from RayPitching.Dbo.RaysPitchingStats a join RayPitching.Dbo.LastPitchRays b
on a.pitcher_id = b.pitcher group by a.Pos, b.pitch_name having a.Pos = 'RP' order by PitchesCount desc

--Question 3 Homerun analysis

--3a What pitches have given up the most HRs (LastPitchRays) 

select pitch_name, count(pitch_Name) as HR_Count 
from RayPitching.Dbo.LastPitchRays where events = 'home_run' group by pitch_name order by HR_Count desc

--3b Show HRs given up by zone and pitch, show top 5 most common

select top 5 zone, pitch_name, count(*) as HR_Count from RayPitching.Dbo.LastPitchRays where events = 'home_run'
group by zone, pitch_name order by HR_Count desc

--3c Show HRs for each count type -> Balls/Strikes + Type of Pitcher

select a.Pos, b.balls, b.strikes, count(*) as HR_Count from RayPitching.Dbo.RaysPitchingStats a join RayPitching.Dbo.LastPitchRays b
on a.pitcher_id = b.pitcher where b.events = 'home_run' group by a.Pos, b.balls, b.strikes order by HR_Count desc

--3d Show Each Pitchers Most Common count to give up a HR (Min 30 IP)

select a.Name, count(b.events) as HR_Count from RayPitching.Dbo.RaysPitchingStats a join RayPitching.Dbo.LastPitchRays b 
on a.pitcher_id = b.pitcher where (b.events = 'home_run' and a.IP >= 30) group by a.Name order by HR_Count desc

--Question 4 Shane McClanahan

--4a AVG Release speed, spin rate,  strikeouts, most popular zone ONLY USING LastPitchRays

select 'Avg Release Speed' as Features, avg(1.00*launch_speed) as Value from RayPitching.Dbo.LastPitchRays where player_name = 'McClanahan, Shane'
union
select 'Avg Spin Rate' as Features, avg(1.00*release_spin_rate) as Value from RayPitching.Dbo.LastPitchRays where player_name = 'McClanahan, Shane'
union
select 'Avg Strike Outs' as Features, avg(1.00*strikes) as Value from RayPitching.Dbo.LastPitchRays where player_name = 'McClanahan, Shane'

select top 5 zone as Popular_Zones, count(zone) as Zone_Count 
from RayPitching.Dbo.LastPitchRays where player_name = 'McClanahan, Shane' group by zone order by Zone_Count desc

--4b top pitches for each infield position where total pitches are over 5, rank them

select * from (
select 'First Baseman' as Infield_Position, pitch_name, count(pitch_name) as CNT 
from RayPitching.Dbo.LastPitchRays where (player_name = 'McClanahan, Shane' and hit_location = 3) group by pitch_name
union
select 'Second Baseman' as Infield_Position, pitch_name, count(pitch_name) as CNT 
from RayPitching.Dbo.LastPitchRays where (player_name = 'McClanahan, Shane' and hit_location = 4) group by pitch_name
union
select 'Third Baseman' as Infield_Position, pitch_name, count(pitch_name) as CNT 
from RayPitching.Dbo.LastPitchRays where (player_name = 'McClanahan, Shane' and hit_location = 5) group by pitch_name
union
select 'Short Stop' as Infield_Position, pitch_name, count(pitch_name) as CNT 
from RayPitching.Dbo.LastPitchRays where (player_name = 'McClanahan, Shane' and hit_location = 6) group by pitch_name
) a
where CNT > 4 order by CNT desc

--4c Show different balls/strikes as well as frequency when someone is on base

select balls, strikes, count(*) as Frequency 
from RayPitching.Dbo.LastPitchRays where ((on_3b is not null) and (on_2b is not null) and (on_1b is not null)) and player_name = 'McClanahan, Shane'
group by balls, strikes order by Frequency desc

--4d What pitch causes the lowest launch speed

select top 1 pitch_name, avg(1.00*launch_speed) as Avg_Launch_Speeds from RayPitching.Dbo.LastPitchRays where player_name = 'McClanahan, Shane'
group by pitch_name order by Avg_Launch_Speeds