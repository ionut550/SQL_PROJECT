-- For this Script to work you need to run 'RecipeStructure.sql' and 'RecipeData.sql' first.

SET search_path TO recipes;

-- What types of recipes do we have, and what are the names of the
-- recipes we have for each type? Can you sort the information by type and recipe name?
CREATE VIEW Recipe_Classes_And_Titles AS
SELECT recipes.RecipeClassID, recipes.RecipeTitle
FROM recipes.recipes
ORDER BY RecipeClassID ASC, RecipeTitle ASC;

-- Show me a list of unique recipe class IDs in the recipes table.
CREATE VIEW Recipe_Class_Ids AS
SELECT DISTINCT recipes.recipeclassid
FROM recipes.recipes;

-- Show me a list of all the ingredients we currently keep track of.
CREATE VIEW Complete_Ingredient_List AS
SELECT ingredients.ingredientname
FROM recipes.ingredients;

-- Show me all the main recipe information, and sort it by the name of the recipe in alphabetical order.
CREATE VIEW Main_Recipe_Information AS
SELECT *
FROM recipes.recipes
ORDER BY recipes.recipetitle;

-- List the recipes that have no notes.
CREATE VIEW Recipes_With_No_Notes AS
SELECT *
FROM recipes.recipes
WHERE recipes.notes IS NULL;

-- Show the ingredients that are meats (ingredient class is 2) but that aren’t chicken.
CREATE VIEW Meats_That_Are_Not_Chiken AS
SELECT ingredients.ingredientname
FROM recipes.ingredients
WHERE (ingredients.ingredientclassid = 2) 
	AND (ingredients.ingredientname NOT ILIKE '%chicken%');
-- I used 'ILIKE' becouse some times chicken can be the first word or in the middle of the title
-- and PostgreSQL is case-sensitive.

-- List all recipes that are main courses (recipe class is 1) and that have notes.
CREATE VIEW Main_Courses_With_Notes AS
SELECT recipes.recipetitle, recipes.notes
FROM recipes.recipes
WHERE recipes.recipeclassid = 1 AND recipes.notes IS NOT NULL;

-- Display the first five recipes.
CREATE VIEW First_5_Recipes AS 
SELECT *
FROM recipes.recipes
LIMIT 5; 
-- Instead of create a condition on the primary key I just limit the output of the query.

-- Show me the recipe title, preparation, and recipe class description of all recipes in my database.
CREATE VIEW All_Recipes AS
SELECT recipes.recipetitle, 
	recipes.preparation, 
	recipe_classes.recipeclassdescription
FROM recipes.recipes
INNER JOIN recipes.recipe_classes
ON recipe_classes.recipeclassid = recipes.recipeclassid;
-- Here I used the normal JOIN
CREATE VIEW All_Recipe_USING AS
SELECT recipes.recipetitle, 
	recipes.preparation, 
	recipe_classes.recipeclassdescription
FROM recipes.recipes
INNER JOIN recipes.recipe_classes
USING(recipeclassid);
-- Here I used 'USING' and specify the column with the same name
CREATE VIEW All_Recipes_Natural_Join AS
SELECT recipes.recipetitle, 
	recipes.preparation, 
	recipe_classes.recipeclassdescription
FROM recipes.recipes
NATURAL INNER JOIN recipes.recipe_classes;
-- And here I used the 'NATURAL JOIN' becouse the only column with the same name are the linking column

-- I need the recipe type, recipe name, preparation instructions, ingredient
-- names, ingredient step numbers, ingredient quantities, and ingredient
-- measurements from my recipes database, sorted in step number sequence.
CREATE VIEW Recipes_Instructions AS
SELECT Recipe_Classes.RecipeClassDescription,
	Recipes.RecipeTitle, Recipes.Preparation,
	Ingredients.IngredientName,
	Recipe_Ingredients.RecipeSeqNo,
	Recipe_Ingredients.Amount,
	Measurements.MeasurementDescription
FROM recipes.recipe_classes
INNER JOIN recipes.recipes
ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
INNER JOIN recipes.recipe_ingredients
ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
INNER JOIN recipes.ingredients
ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
INNER JOIN recipes.measurements
ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID
ORDER BY recipes.RecipeTitle, recipe_ingredients.RecipeSeqNo;

-- Show me the recipes that have beef or garlic.
CREATE VIEW Recipes_With_Beef_Or_Garlic AS
SELECT DISTINCT Recipes.RecipeTitle
FROM recipes.recipes
INNER JOIN recipes.recipe_ingredients
ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
WHERE Recipe_Ingredients.IngredientID IN (1, 9);
-- Insetead of using an other JOIN I just used the ingredientid for beef and garlic.

-- Show me the main course recipes and list all the ingredients.
CREATE VIEW Main_Courses_Ingredietns AS
SELECT Recipes.RecipeTitle,
	Ingredients.IngredientName,
	Measurements.MeasurementDescription,
	Recipe_Ingredients.Amount
FROM recipes.Recipe_Classes
INNER JOIN recipes.Recipes
ON Recipes.RecipeClassID = Recipe_Classes.RecipeClassID
INNER JOIN recipes.Recipe_Ingredients
ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
INNER JOIN recipes.Ingredients
ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
INNER JOIN recipes.Measurements
ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID
WHERE Recipe_Classes.RecipeClassDescription = 'Main course';

-- Display all the ingredients for recipes that contain carrots.
CREATE VIEW Recipes_Containing_Carrots AS
SELECT Recipes.RecipeID, 
	Recipes.RecipeTitle,
	Ingredients.IngredientName
FROM recipes.Recipes
INNER JOIN recipes.Recipe_Ingredients
ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
INNER JOIN recipes.Ingredients
ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
INNER JOIN(
	SELECT Recipe_Ingredients.RecipeID
	FROM recipes.Ingredients
	INNER JOIN recipes.Recipe_Ingredients
	ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
	WHERE Ingredients.IngredientName = 'Carrot') AS Carrots
ON Recipes.RecipeID = Carrots.RecipeID;
-- First we find the recipes which contains carrots and after we join on the recipeid 
-- to find out all the ingredients of recipes which contains carrots.

-- List all the recipes for salads.
CREATE VIEW Salad_Recipe AS
SELECT recipes.recipetitle, recipe_classes.recipeclassdescription
FROM recipes.recipes
INNER JOIN recipes.recipe_classes
ON recipe_classes.recipeclassid = recipes.recipeclassid
WHERE recipe_classes.recipeclassdescription = 'Salad';

-- List all recipes that contain a dairy ingredient.
CREATE VIEW Recipes_Containing_Dairy AS
SELECT DISTINCT recipes.recipetitle, ingredient_classes.ingredientclassdescription
FROM recipes.recipes
INNER JOIN recipes.recipe_ingredients
ON recipes.recipeid = recipe_ingredients.recipeid
INNER JOIN recipes.ingredients
ON recipe_ingredients.ingredientid = ingredients.ingredientid
INNER JOIN recipes.ingredient_classes
ON ingredients.ingredientclassid = ingredient_classes.ingredientclassid
WHERE ingredientclassdescription = 'Dairy';

-- Find the ingredients that use the same default measurement amount.
CREATE VIEW Ingredietns_Same_Measure AS
SELECT ingredients.ingredientid ,i1.ingredientid AS Matching_Ingredient
FROM recipes.ingredients
INNER JOIN recipes.ingredients AS i1
ON ingredients.measureamountid = i1.measureamountid 
	AND ingredients.ingredientid <> i1.ingredientid;
-- I've made a self join on the measureamount and make sure that i don't compare the same ingredient

-- Show me the recipes that have beef and garlic.
CREATE VIEW Beef_And_Garlic_Recipes AS
SELECT recipes.recipetitle
FROM (
	SELECT recipe_ingredients.recipeid
	FROM recipes.recipe_ingredients
	INNER JOIN recipes.ingredients
	ON recipe_ingredients.ingredientid = ingredients.ingredientid
	WHERE ingredientname = 'Beef') AS beef
INNER JOIN (
	SELECT recipe_ingredients.recipeid
	FROM recipes.recipe_ingredients
	INNER JOIN recipes.ingredients
	ON recipe_ingredients.ingredientid = ingredients.ingredientid
	WHERE ingredientname = 'Garlic') AS garlic
ON beef.recipeid = garlic.recipeid
INNER JOIN recipes.recipes
ON recipes.recipeid = garlic.recipeid;

-- List the recipe classes that do not yet have any recipes.
CREATE VIEW No_Recipes AS
SELECT Recipe_Classes.RecipeClassDescription
FROM recipes.recipe_classes
LEFT OUTER JOIN recipes.recipes
ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
WHERE Recipes.RecipeID IS NULL;

-- I need all the recipe types, and then the matching recipe names,
-- preparation instructions, ingredient names, ingredient step numbers,
-- ingredient quantities, and ingredient measurements from my recipes
-- database, sorted in recipe title and step number sequence.
CREATE VIEW All_Recipes_Types AS
SELECT Recipe_Classes.RecipeClassDescription,
	Recipes.RecipeTitle, Recipes.Preparation,
	Ingredients.IngredientName,
	Recipe_Ingredients.RecipeSeqNo,
	Recipe_Ingredients.Amount,
	Measurements.MeasurementDescription
FROM Recipe_Classes
LEFT OUTER JOIN (Recipes
	INNER JOIN Recipe_Ingredients
	ON Recipes.RecipeID = Recipe_Ingredients.RecipeID
	INNER JOIN Ingredients
	ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
	INNER JOIN Measurements
	ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID)
ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
ORDER BY RecipeTitle, RecipeSeqNo;

-- Show me all ingredients and any recipes they’re used in.
CREATE VIEW All_Ingredients_Any_Recipes AS
SELECT ingredients.ingredientname, recipes.recipetitle
FROM recipes.ingredients
LEFT OUTER JOIN (recipes.recipe_ingredients
	INNER JOIN recipes.recipes
	ON recipe_ingredients.recipeid = recipes.recipeid)
ON ingredients.ingredientid = recipe_ingredients.ingredientid;

-- List the salad, soup, and main course categories and any recipes.\
CREATE VIEW Salad_Soup_Main_Courses AS
SELECT  recipes.recipetitle, recipe_classes.recipeclassdescription
FROM recipes.recipes
RIGHT OUTER JOIN recipes.recipe_classes
ON recipes.recipeclassid = recipe_classes.recipeclassid
WHERE recipe_classes.recipeclassdescription IN ('Salad', 'Soup', 'Main course');

-- Display all recipe classes and any recipes.
CREATE VIEW All_Recipe_Classes_And_Matching_Recipes AS
SELECT  recipes.recipetitle, recipe_classes.recipeclassdescription
FROM recipes.recipes
FULL OUTER JOIN recipes.recipe_classes
ON recipes.recipeclassid = recipe_classes.recipeclassid;

-- Create an index list of all the recipe classes, recipe titles, and ingredients.
CREATE VIEW Classes_Recipes_Ingredients AS
SELECT Recipe_Classes.RecipeClassDescription AS IndexName, 'Recipe Class' AS Type
FROM Recipe_Classes

UNION

SELECT Recipes.RecipeTitle, 'Recipe' AS Type 
FROM Recipes

UNION

SELECT Ingredients.IngredientName, 'Ingredient' AS Type
FROM Ingredients;

-- Display a list of all ingredients and their default measurement
-- amounts together with ingredients used in recipes and the measurement amount for each recipe.”
CREATE VIEW Ingredient_Recipe_Measurements AS
SELECT ingredients.ingredientname, measurements.measurementdescription, 'Default' AS Quantity 
FROM recipes.ingredients
INNER JOIN recipes.measurements
ON ingredients.measureamountid = measurements.measureamountid

UNION 

SELECT ingredients.ingredientname, measurements.measurementdescription, 'Recipe' AS Quantity
FROM recipes.ingredients
INNER JOIN recipes.recipe_ingredients
ON ingredients.ingredientid = recipe_ingredients.ingredientid
INNER JOIN recipes.measurements
ON recipe_ingredients.measureamountid = measurements.measureamountid;

-- List all the meats and the count of recipes each appears in.
CREATE VIEW Meat_Ingredient_Recipe_Count AS
SELECT Ingredient_Classes.IngredientClassDescription,
	Ingredients.IngredientName,
	(SELECT COUNT(*)
	FROM Recipe_Ingredients
	WHERE Recipe_Ingredients.IngredientID = Ingredients.IngredientID) AS RecipeCount
FROM Ingredient_Classes
INNER JOIN Ingredients
ON Ingredient_Classes.IngredientClassID = Ingredients.IngredientClassID
WHERE Ingredient_Classes.IngredientClassDescription = 'Meat';

-- Display all the ingredients for recipes that contain carrots.
CREATE VIEW Recipes_Ingredints_With_Carrots AS
SELECT Recipes.RecipeTitle,
	Ingredients.IngredientName
FROM (Recipes
	INNER JOIN Recipe_Ingredients
	ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
	INNER JOIN Ingredients
	ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
WHERE Recipes.RecipeID IN (
	SELECT Recipe_Ingredients.RecipeID
	FROM Ingredients
	INNER JOIN Recipe_Ingredients
	ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
	WHERE Ingredients.IngredientName = 'Carrot');
	
-- Show me the types of recipes and the count of recipes in each type.
CREATE VIEW Count_Of_Recipes_Types AS
SELECT recipe_classes.recipeclassdescription , (
	SELECT COUNT(recipes.recipetitle)
	FROM recipes.recipes
	WHERE recipes.recipeclassid = recipe_classes.recipeclassid
) AS Number_Of_Recipes
FROM recipes.recipe_classes;

-- List the ingredients that are used in some recipe where the measurement
-- amount in the recipe is not the default measurement amount.
CREATE VIEW Ingredients_Using_NonStandard_Measure AS
SELECT DISTINCT ingredients.ingredientname, measurements.measurementdescription, (
	SELECT measurements.measurementdescription
	FROM recipes.ingredients
	INNER JOIN recipes.measurements
	ON ingredients.measureamountid = measurements.measureamountid
	WHERE ingredients.ingredientid = recipe_ingredients.ingredientid) AS Default
FROM recipes.ingredients
INNER JOIN recipes.recipe_ingredients
ON ingredients.ingredientid = recipe_ingredients.ingredientid
INNER JOIN recipes.measurements
ON recipe_ingredients.measureamountid = measurements.measureamountid
WHERE measurements.measurementdescription <> SOME (
	SELECT measurements.measurementdescription
	FROM recipes.ingredients
	INNER JOIN recipes.measurements
	ON ingredients.measureamountid = measurements.measureamountid
	WHERE ingredients.ingredientid = recipe_ingredients.ingredientid);
	
-- How many recipes contain a beef ingredient?
CREATE VIEW Recipes_With_Beef_Ingredient AS
SELECT COUNT(*) AS NumberOfRecipes
FROM Recipes
WHERE Recipes.RecipeID IN(
	SELECT RecipeID
	FROM Recipe_Ingredients
	INNER JOIN Ingredients 
	ON Recipe_Ingredients.IngredientID = Ingredients.IngredientID
	WHERE Ingredients.IngredientName LIKE '%Beef%');
	
-- How many ingredients are measured by the cup?
CREATE VIEW  Number_Of_Ingredients_Measured_By_The_Cup AS
SELECT COUNT(*) AS NumberOfIngredients
FROM Ingredients
INNER JOIN Measurements
ON Ingredients.MeasureAmountID = Measurements.MeasureAmountID
WHERE MeasurementDescription = 'Cup';

-- Which recipe requires the most cloves of garlic?
CREATE VIEW Recipe_With_Most_Cloves_Of_Garlic AS
SELECT recipes.recipetitle
FROM recipes.recipes
WHERE recipes.recipeid = (
	SELECT recipe_ingredients.recipeid
	FROM recipes.ingredients
	INNER JOIN recipes.recipe_ingredients
	ON ingredients.ingredientid = recipe_ingredients.ingredientid
	WHERE ingredients.ingredientname = 'Garlic' AND amount = (
		SELECT MAX(amount)
		FROM recipes.recipe_ingredients AS ri1
		WHERE ri1.ingredientid = recipe_ingredients.ingredientid));

-- Count the number of main course recipes.
CREATE VIEW Number_Of_Main_Course_Recipes AS
SELECT COUNT(*), 'Main Course' AS Recipe_type
FROM recipes.recipes
WHERE recipes.recipeclassid = (
	SELECT recipe_classes.recipeclassid 
	FROM recipes.recipe_classes
	WHERE recipe_classes.recipeclassdescription = 'Main course');
	
-- Calculate the total number of teaspoons of salt in all recipes.
CREATE VIEW Total_Salt_Used AS
SELECT 'Salt' AS Type ,SUM(amount)
FROM recipes.recipe_ingredients
WHERE recipe_ingredients.ingredientid = (
	SELECT ingredients.ingredientid
	FROM recipes.ingredients
	WHERE ingredients.ingredientname = 'Salt');
	
-- Show me how many recipes exist for each class of ingredient.
CREATE VIEW Ingredient_Class_Distinct_Recipe_Count AS
SELECT Ingredient_Classes.IngredientClassDescription,
	Count(DISTINCT RecipeID) AS CountOfRecipeID
FROM Ingredient_Classes
INNER JOIN Ingredients
ON Ingredient_Classes.IngredientClassID = Ingredients.IngredientClassID
INNER JOIN Recipe_Ingredients
ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
GROUP BY Ingredient_Classes.IngredientClassDescription;

-- If I want to cook all the recipes in my cookbook, how much of each ingredient must I have on hand?
CREATE VIEW Total_Ingredients_Needed AS
SELECT ingredients.ingredientname, 
	measurements.measurementdescription,
	sum(recipe_ingredients.amount)
FROM recipes.ingredients
INNER JOIN recipes.recipe_ingredients
ON ingredients.ingredientid = recipe_ingredients.ingredientid
INNER JOIN recipes.measurements
ON recipe_ingredients.measureamountid = measurements.measureamountid
GROUP BY ingredients.ingredientname, 
	measurements.measurementdescription
ORDER BY 1;

-- List all meat ingredients and the count of recipes that include each one.
CREATE VIEW Meat_Ingredient_Recipe_Count_Group AS
SELECT ingredients.ingredientname, count(*)
FROM recipes.ingredient_classes
INNER JOIN recipes.ingredients
ON ingredient_classes.ingredientclassid = ingredients.ingredientclassid 
INNER JOIN recipes.recipe_ingredients
ON ingredients.ingredientid = recipe_ingredients.ingredientid
INNER JOIN recipes.recipes
ON recipe_ingredients.recipeid = recipes.recipeid
WHERE ingredient_classes.ingredientclassdescription = 'Meat'
GROUP BY ingredients.ingredientname;
-- The same problem but solved with subqueries.
CREATE VIEW Meat_Ingredient_Recipe_Count_Subquery AS 
SELECT ingredients.ingredientname, (
	SELECT COUNT(*)
	FROM recipes.recipes
	INNER JOIN recipes.recipe_ingredients
	ON recipes.recipeid = recipe_ingredients.recipeid
	WHERE recipe_ingredients.ingredientid = ingredients.ingredientid) AS Recipe_Number
FROM recipes.ingredients
INNER JOIN recipes.ingredient_classes
ON ingredient_classes.ingredientclassid = ingredients.ingredientclassid
WHERE ingredient_classes.ingredientclassdescription = 'Meat';

-- Can you explain why the subquery solution returns seven more
-- rows? Is it possible to modify the query in question 2 to return
-- 11 rows? If so, how would you do it?
CREATE VIEW Meat_Ingredient_Recipe_Count_OUTER AS
SELECT ingredients.ingredientname, count(*)
FROM recipes.ingredients
LEFT OUTER JOIN recipes.ingredient_classes
ON ingredient_classes.ingredientclassid = ingredients.ingredientclassid
LEFT OUTER JOIN (recipes.recipe_ingredients
	NATURAL JOIN recipes.recipes)
ON ingredients.ingredientid = recipe_ingredients.ingredientid
WHERE ingredient_classes.ingredientclassdescription = 'Meat'
GROUP BY ingredients.ingredientname;
-- Becouse I used OUTER JOIN I fetch all the meats, but becouse we have one row for 
-- meats that aren't use in any recipes the COUNT function still counted as 1 which is wrong

-- List the recipes that contain both beef and garlic.
CREATE VIEW Recipes_Beef_And_Garlic AS
SELECT Recipes.RecipeTitle
FROM Recipes
WHERE Recipes.RecipeID IN (
	SELECT Recipe_Ingredients.RecipeID
	FROM Ingredients
	INNER JOIN Recipe_Ingredients
	ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
	WHERE Ingredients.IngredientName = 'Beef'
		OR Ingredients.IngredientName = 'Garlic'
	GROUP BY Recipe_Ingredients.RecipeID
	HAVING COUNT(Recipe_Ingredients.RecipeID) = 2);
	
-- Sum the amount of salt by recipe class, and display those recipe classes that require more than three teaspoons.
CREATE VIEW Recipe_Classes_Lots_Of_Salt AS 
SELECT recipe_classes.recipeclassdescription, sum(recipe_ingredients.amount)
FROM recipes.recipe_classes
INNER JOIN recipes.recipes
ON recipe_classes.recipeclassid = recipes.recipeclassid
INNER JOIN recipes.recipe_ingredients
ON recipes.recipeid = recipe_ingredients.recipeid
INNER JOIN recipes.ingredients
ON recipe_ingredients.ingredientid = ingredients.ingredientid
WHERE ingredients.ingredientname = 'Salt'
GROUP BY recipe_classes.recipeclassdescription
HAVING sum(recipe_ingredients.amount) > 3;

-- For what class of recipe do I have two or more recipes?
CREATE VIEW Recipe_Classes_Two_Or_More_Recipes AS
SELECT recipe_classes.recipeclassdescription, COUNT(recipes.recipetitle)
FROM recipes.recipe_classes
NATURAL JOIN recipes.recipes
GROUP BY recipe_classes.recipeclassdescription
HAVING COUNT(recipes.recipetitle) >= 2;