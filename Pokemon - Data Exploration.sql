-- Data Alterations

DELETE FROM pokedex 
WHERE id LIKE '%.%'

ALTER TABLE pokedex 
RENAME COLUMN `Special Attack` TO `sp_attack`

ALTER TABLE pokedex 
RENAME COLUMN `Special Defense` TO `sp_defense`

ALTER TABLE evolution 
RENAME COLUMN `Evolving from` TO `evolving_from`

ALTER TABLE evolution 
RENAME COLUMN `Evolving to` TO `evolving_to`

ALTER TABLE evolution 
RENAME COLUMN `Evolution Type` TO `evolution_type`

ALTER TABLE moves 
RENAME COLUMN `Cat.` TO `category`

ALTER TABLE moves 
RENAME COLUMN `Acc.` TO `accuracy`

ALTER TABLE moves 
RENAME COLUMN `Prob. (%)` TO `prob`

UPDATE pokedex 
SET name = 'Gourgeist- Super Size'
WHERE name ='Gourgeist-Super Size'

-- Add Missing Data Into Table

INSERT INTO pokedex (id, Name, Type, Total, HP, Attack, Defense, sp_attack, sp_defense, Speed)
VALUES 
	('719', 'Diancie', 'ROCK', '600', '50', '100', '150', '100', '150', '50'),
	('719', 'Diancie', 'FAIRY', '600', '50', '100', '150', '100', '150', '50'),
	('720', 'Hoopa', 'PSYCHIC', '600', '80', '110', '60', '150', '130', '70'),
	('720', 'Hoopa', 'GHOST', '600', '80', '110', '60', '150', '130', '70'),
	('721', 'Volcanion', 'FIRE', '600', '80', '110', '120', '130', '90', '70'),
	('721', 'Volcanion', 'WATER', '600', '80', '110', '120', '130', '90', '70')
	

-- Pokemon Typing Per Generation

WITH dex AS 
	(
	SELECT id, SUBSTRING_INDEX(name, '- ', 1) AS real_dex FROM pokedex
	)
SELECT real_dex,
	CASE WHEN RIGHT(id, 3) < 152 THEN 'Generation 1'
		 WHEN RIGHT(id, 3) BETWEEN 152 AND 251 THEN 'Generation 2'
		 WHEN RIGHT(id, 3) BETWEEN 252 AND 386 THEN 'Generation 3'
		 WHEN RIGHT(id, 3) BETWEEN 387 AND 493 THEN 'Generation 4'
		 WHEN RIGHT(id, 3) BETWEEN 494 AND 649 THEN 'Generation 5'
		 ELSE 'Generation 6'
		 END AS 'generation'
FROM dex
GROUP BY 1, 2 


-- Generation With The Strongest Pokemon 

WITH dex AS 
	(
	SELECT total, id, SUBSTRING_INDEX(name, '- ', 1) AS real_dex FROM pokedex
	)
SELECT 
	CASE WHEN RIGHT(id, 3) < 152 THEN 'Generation 1'
		 WHEN RIGHT(id, 3) BETWEEN 152 AND 251 THEN 'Generation 2'
		 WHEN RIGHT(id, 3) BETWEEN 252 AND 386 THEN 'Generation 3'
		 WHEN RIGHT(id, 3) BETWEEN 387 AND 493 THEN 'Generation 4'
		 WHEN RIGHT(id, 3) BETWEEN 494 AND 649 THEN 'Generation 5'
		 ELSE 'Generation 6'
		 END AS 'generation',
	AVG(total) AS avg_base_stat	 
FROM dex
GROUP BY 1 
ORDER BY 2 DESC


-- Strongest and Weakest Pokemon By Base Stats

SELECT name, total,
	CASE WHEN total IN (SELECT MIN(total) FROM pokedex) THEN 'Worst'
		 WHEN total IN (SELECT MAX(total) FROM pokedex) THEN 'Best'
		 END AS ranking
FROM pokedex
HAVING ranking IS NOT NULL


-- Base Stats Per Typing 

WITH dex AS 
	(
	SELECT type, total,
		SUBSTRING_INDEX(name, '- ', 1) AS real_dex	
	FROM pokedex
	)
SELECT DISTINCT type, AVG(total) AS avg_base_stat
FROM dex
GROUP BY 1
ORDER BY 2 DESC


-- Which Pokemon Typing Has The Most Weaknesses? 

SELECT defense AS typing, COUNT(effectiveness) AS weaknesses_count
FROM typechart
WHERE effectiveness = 'Super Effective'
GROUP BY 1
ORDER BY 2 DESC


-- Which Fully Evolved Pokemon are the Strongest? 

WITH fullev AS 
	(
	SELECT DISTINCT a.evolving_to
	FROM evolution a
	JOIN evolution b 
		ON a.evolving_from <> b.evolving_to
	WHERE a.evolving_to NOT IN (SELECT evolving_from FROM evolution)
	AND a.evolving_from NOT IN ('')	
	)
SELECT DISTINCT f.evolving_to AS fully_evolved, p.total
FROM fullev f
LEFT JOIN pokedex p
	ON f.evolving_to = SUBSTRING_INDEX(p.name, '- ', 1)
ORDER BY 2 DESC


-- What Is The Most Common Highest Base Stat?

WITH rating AS 
	(
	SELECT DISTINCT SUBSTRING_INDEX(name, '- ', 1) AS real_dex,
		CASE WHEN ((hp > attack) AND (hp > defense) AND (hp > sp_attack) AND (hp > sp_defense) AND (hp > speed)) THEN 'HP'
			 WHEN ((attack > hp) AND (attack > defense) AND (attack > sp_attack) AND (attack > sp_defense) AND (attack > speed)) THEN 'Attack'	
			 WHEN ((defense > hp) AND (defense > attack) AND (defense > sp_attack) AND (defense > sp_defense) AND (defense > speed)) THEN 'Defense'	
			 WHEN ((sp_attack > hp) AND (sp_attack > attack) AND (sp_attack > defense) AND (sp_attack > sp_defense) AND (sp_attack > speed)) THEN 'Special_Attack'		
			 WHEN ((sp_defense > hp) AND (sp_defense > attack) AND (sp_defense > defense) AND (sp_defense > sp_attack) AND (sp_defense > speed)) THEN 'Special_Defense'	
			 WHEN ((speed > hp) AND (speed > attack) AND (speed > defense) AND (speed > sp_attack) AND (speed > sp_defense)) THEN 'Speed'	
			 ELSE 'Multiple_Stats'
			 END AS highest_rating
	FROM pokedex
	WHERE name <> 'Wormadam- Trash Cloak'
	)
SELECT highest_rating,
	COUNT(highest_rating)/(SELECT COUNT(DISTINCT SUBSTRING_INDEX(name, '- ', 1)) FROM pokedex)*100 AS highest_stat_percentage
FROM rating
GROUP BY highest_rating
ORDER BY 2 DESC


-- Strongest Physical and Special Moves Where Accuracy is 100% 

SELECT name AS move, type, power, pp
FROM moves 
WHERE power IS NOT NULL 
AND pp IS NOT NULL
AND accuracy = '100'
AND category = 'Physical'
ORDER BY power DESC 


SELECT name AS move, type, power, pp
FROM moves 
WHERE power IS NOT NULL 
AND pp IS NOT NULL
AND accuracy = '100'
AND category = 'Special'
ORDER BY power DESC 


-- Strongest Moves Per Typing

SELECT type, AVG(power) AS average_power
FROM moves 
GROUP BY 1
ORDER BY 2 DESC


