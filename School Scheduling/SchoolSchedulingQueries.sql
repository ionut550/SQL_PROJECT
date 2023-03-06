-- For this Script to work you need to run SchoolSchedulingStructure.sql and SchoolSchedulingData.sql first.

SET search_path TO Schoolscheduling;

-- Can we view complete class information?
CREATE VIEW Class_Information AS
SELECT *
FROM schoolscheduling.classes;

-- Give me a list of the buildings on campus and the number of floors for
-- each building. Sort the list by building in ascending order.
CREATE VIEW Building_List AS 
SELECT buildingname, numberoffloors
FROM schoolscheduling.buildings
ORDER BY buildingname ASC;

-- Show me a complete list of all the subjects we offer.
CREATE VIEW Subject_List AS
SELECT *
FROM schoolscheduling.subjects;

-- What kinds of titles are associated with our faculty?
CREATE VIEW Faculty_Titles AS
SELECT DISTINCT title
FROM schoolscheduling.faculty;

-- List the names and phone numbers of all our staff, and sort them by last name and first name.
CREATE VIEW Staff_Phone_List AS
SELECT stflastname, stffirstname, stfphonenumber
FROM schoolscheduling.staff
ORDER BY stflastname, stffirstname;

-- List how many complete years each staff member has been with the
-- school as of October 1, 2017, and sort the result by last name and first name.
CREATE VIEW Length_Of_Service AS 
SELECT StfLastName || ', ' || StfFirstName AS Staff,
	DateHired,
	CAST(CAST('2017-10-01' - DateHired AS INTEGER) / 365 AS INTEGER) AS YearsWithSchool
FROM Staff
ORDER BY StfLastName, StfFirstName;

-- Show me a list of staff members, their salaries, and a proposed 7 percent bonus for each staff member.
CREATE VIEW Proposed_Bonuses AS
SELECT stflastname || ' ' || stffirstname AS Staff_Name,
	salary, 
	salary * 0.07 AS Bonus
FROM schoolscheduling.staff;

-- Give me a list of staff members, and show them in descending order of salary.
CREATE VIEW Staff_List_By_Salary AS
SELECT stflastname || ' ' || stffirstname AS Staff_Name,
	salary
FROM schoolscheduling.staff
ORDER BY salary DESC;

-- List the names of all our students, and order them by the cities they live in.
CREATE VIEW Students_By_City AS
SELECT studfirstname, studlastname, studcity
FROM schoolscheduling.students
ORDER BY studcity;

-- Show me an alphabetical list of all the staff members and their salaries
-- if they make between $40,000 and $50,000 a year.
CREATE VIEW Staff_Salaries_40k_To_50k AS
SELECT StfFirstName, StfLastName, Salary
FROM Staff
WHERE Salary BETWEEN 40000 AND 50000
ORDER BY StfLastname, StfFirstName;

-- Show me a list of students whose last name is ‘Kennedy’ or who live in Seattle.
CREATE VIEW Students_From_Seattle_Or_Students_Named_Kennedy AS
SELECT StudFirstName, StudLastName, StudCity
FROM Students
WHERE StudLastName = 'Kennedy' OR StudCity = 'Seattle';

-- Show me which staff members use a post office box as their address.
CREATE VIEW Staff_Using_POBoxes AS 
SELECT stffirstname, stflastname, stfstreetaddress 
FROM schoolscheduling.staff
WHERE stfstreetaddress ILIKE '%box%';

-- Can you show me which students live outside of the Pacific Northwest?
CREATE VIEW Students_Residing_Outside_PNW AS
SELECT studfirstname || ' ' || studlastname AS Student_Name,
	studareacode,
	studphonenumber,
	studstate
FROM schoolscheduling.students
WHERE studstate NOT IN ('ID', 'OR','WA');

-- List all the subjects that have a subject code starting ‘MUS’.
CREATE VIEW Subjects_With_MUS AS
SELECT subjectname, categoryid
FROM schoolscheduling.subjects
WHERE categoryid = 'MUS';

-- Produce a list of the ID numbers all the Associate Professors who are employed full time.
CREATE VIEW Full_Time_Associate_Professors AS
SELECT staffid, title, status
FROM schoolscheduling.faculty
WHERE title = 'Associate Professor' AND status = 'Full Time';

-- List the subjects taught on Wednesday.
CREATE VIEW Subjects_On_Wednesday AS
SELECT DISTINCT Subjects.SubjectName
FROM Subjects
INNER JOIN Classes
ON Subjects.SubjectID = Classes.SubjectID
WHERE Classes.WednesdaySchedule = 1;

-- Show me the students and teachers who have the same first name.
CREATE VIEW Students_Staff_Same_FirstName AS
SELECT (Students.StudFirstName || ' ' || Students.StudLastName) AS StudFullName,
(Staff.StfFirstName || ' ' || Staff.StfLastName) AS StfFullName
FROM Students
INNER JOIN Staff
ON Students.StudFirstName = Staff.StfFirstName;

-- Display buildings and all the classrooms in each building.
CREATE VIEW Building_Classrooms AS
SELECT buildingname, classroomid 
FROM schoolscheduling.buildings
NATURAL JOIN schoolscheduling.class_rooms;

-- List students and all the classes in which they are currently enrolled.
CREATE VIEW Student_Enrollments AS
SELECT studfirstname || ' ' || studlastname AS Student_Name,
	subjectid
FROM schoolscheduling.students
NATURAL JOIN schoolscheduling.student_schedules
NATURAL JOIN schoolscheduling.classes
NATURAL JOIN schoolscheduling.student_class_status
WHERE classstatusdescription = 'Enrolled';

-- List the faculty staff and the subject each teaches.
CREATE VIEW Staff_Subjects AS
SELECT stffirstname || ' ' || stflastname AS Staff_Name,
	subjectname
FROM schoolscheduling.staff
NATURAL JOIN schoolscheduling.faculty_subjects
NATURAL JOIN schoolscheduling.subjects;

-- Show me the students who have a grade of 85 or better in art and
-- who also have a grade of 85 or better in any computer course.
CREATE VIEW Good_Art_CS_Studetns AS
SELECT studfirstname|| ' ' || studlastname AS Student_Name
FROM (
	SELECT studfirstname, studlastname
	FROM schoolscheduling.students
	NATURAL JOIN schoolscheduling.student_schedules
	NATURAL JOIN schoolscheduling.classes
	NATURAL JOIN schoolscheduling.subjects
	WHERE categoryid = 'ART' AND grade >=85 ) AS art85
NATURAL JOIN (
	SELECT studfirstname, studlastname
	FROM schoolscheduling.students
	NATURAL JOIN schoolscheduling.student_schedules
	NATURAL JOIN schoolscheduling.classes
	NATURAL JOIN schoolscheduling.subjects
	WHERE categoryid IN ('CIS','CSC') AND grade >= 85) AS com85;
	
-- List the faculty members not teaching a class.
CREATE VIEW Staff_Not_Teaching AS
SELECT Staff.StfFirstName, Staff.StfLastName
FROM Staff 
LEFT OUTER JOIN Faculty_Classes
ON Staff.StaffID = Faculty_Classes.StaffID
WHERE Faculty_Classes.ClassID IS NULL;

-- Display students who have never withdrawn from a class.
CREATE VIEW Students_Never_Withdrawn AS
SELECT Students.StudLastName || ', ' || Students.StudFirstName AS StudFullName
FROM Students
LEFT OUTER JOIN(
	SELECT Student_Schedules.StudentID
	FROM Student_Class_Status
	INNER JOIN Student_Schedules
	ON Student_Class_Status.ClassStatus = Student_Schedules.ClassStatus
	WHERE Student_Class_Status.ClassStatusDescription = 'withdrew') AS Withdrew
ON Students.StudentID = Withdrew.StudentID
WHERE Withdrew.StudentID IS NULL;

-- Show me all subject categories and any classes for all subjects.
CREATE VIEW All_Categories_All_Subjects_Any_Classes AS
SELECT Categories.CategoryDescription,
	Subjects.SubjectName, 
	Classes.ClassroomID,
	Classes.StartDate, 
	Classes.StartTime,
	Classes.Duration
FROM Categories
LEFT OUTER JOIN Subjects
ON Categories.CategoryID = Subjects.CategoryID
LEFT OUTER JOIN Classes
ON Subjects.SubjectID = Classes.SubjectID;

-- Show me classes that have no students enrolled.
CREATE VIEW Classes_No_Students_Enrolled AS
SELECT subjectname, classes.classid
FROM schoolscheduling.subjects
INNER JOIN schoolscheduling.classes
USING (subjectid)
LEFT OUTER JOIN (
	SELECT *
	FROM schoolscheduling.student_schedules
	INNER JOIN schoolscheduling.student_class_status
	USING (classstatus)
	WHERE classstatusdescription = 'Enrolled') AS t1
ON classes.classid = t1.classid
WHERE t1.classid IS NULL;

-- Display subjects with no faculty assigned.
CREATE VIEW Subjects_No_Faculty AS
SELECT subjectname
FROM schoolscheduling.subjects
LEFT OUTER JOIN schoolscheduling.faculty_subjects
ON subjects.subjectid = faculty_subjects.subjectid
WHERE faculty_subjects.subjectid IS NULL;

-- List students not currently enrolled in any classes.
CREATE VIEW Students_Not_Currently_Enrolled AS
SELECT DISTINCT studfirstname|| ' ' || studlastname AS Student_Name
FROM schoolscheduling.students
INNER JOIN schoolscheduling.student_schedules
ON students.studentid = student_schedules.studentid
LEFT OUTER JOIN (
	SELECT *
	FROM schoolscheduling.student_schedules
	NATURAL JOIN schoolscheduling.student_class_status
	WHERE classstatusdescription = 'Enrolled') AS t1
ON student_schedules.studentid = t1.studentid
WHERE t1.studentid IS NULL;

-- Display all faculty and the classes they are scheduled to teach.
CREATE VIEW All_Faculty_And_Any_Classes AS
SELECT stffirstname || ' ' || stflastname AS Staff_Name,
	subjectname
FROM schoolscheduling.staff
LEFT OUTER JOIN (
	SELECT *
	FROM schoolscheduling.faculty_classes
	INNER JOIN schoolscheduling.classes
	ON faculty_classes.classid = classes.classid
	INNER JOIN schoolscheduling.subjects
	ON subjects.subjectid = classes.subjectid) t1
ON staff.staffid = t1.staffid;

-- Show me the students who have a grade of 85 or better in Art
-- together with the faculty members who teach Art and have a proficiency rating of 9 or better.
CREATE VIEW Good_Art_Students_And_Faculty AS
SELECT Students.StudFirstName AS FirstName,
	Students.StudLastName AS LastName,
	Student_Schedules.Grade AS Score, 
	'Student' AS Type
FROM Students 
INNER JOIN Student_Schedules
ON Students.StudentID = Student_Schedules.StudentID
INNER JOIN Student_Class_Status
ON Student_Class_Status.ClassStatus = Student_Schedules.ClassStatus
INNER JOIN Classes
ON Classes.ClassID = Student_Schedules.ClassID
INNER JOIN Subjects
ON Subjects.SubjectID = Classes.SubjectID
WHERE Student_Class_Status.ClassStatusDescription = 'Completed'
	AND Student_Schedules.Grade >= 85
	AND Subjects.CategoryID = 'ART'
	
UNION

SELECT Staff.StfFirstName, Staff.StfLastName,
	Faculty_Subjects.ProficiencyRating AS Score,
	'Faculty' AS Type
FROM Staff INNER JOIN Faculty_Subjects
ON Staff.StaffID = Faculty_Subjects.StaffID
INNER JOIN Subjects
ON Subjects.SubjectID = Faculty_Subjects.SubjectID
WHERE Faculty_Subjects.ProficiencyRating > 8
	AND Subjects.CategoryID = 'ART';
	
-- Create a mailing list for students and staff, sorted by ZIP Code.
CREATE VIEW Student_Staff_Mailing_List AS
SELECT staff.stffirstname || ' ' || staff.stflastname AS Full_Name,
	stfstreetaddress,
	stfcity,
	stfstate,
	stfzipcode,
	stfareacode
FROM schoolscheduling.staff

UNION 

SELECT studfirstname || ' ' || studlastname AS Full_Name,
	studstreetaddress,
	studcity,
	studstate,
	studzipcode,
	studareacode
FROM schoolscheduling.students

ORDER BY 5;

-- Display all subjects and the count of classes for each subject on Monday.
CREATE VIEW Subjects_Monday_Count AS
SELECT Subjects.SubjectName,
(	SELECT COUNT(*)
	FROM Classes
	WHERE MondaySchedule = 1
		AND Classes.SubjectID = Subjects.SubjectID)AS MondayCount
FROM Subjects;

-- Display students who have never withdrawn from a class.
CREATE VIEW Students_Never_Withdrawn_Subquery AS
SELECT Students.StudentID,
	Students.StudFirstName,
	Students.StudLastName
FROM Students
WHERE Students.StudentID NOT IN
(	SELECT Student_Schedules.StudentID
	FROM Student_Schedules
	INNER JOIN Student_Class_Status
	ON Student_Schedules.ClassStatus = Student_Class_Status.ClassStatus
	WHERE Student_Class_Status.ClassStatusDescription = 'Withdrew');
	
-- List all staff members and the count of classes each teaches.
CREATE VIEW Staff_Class_Count AS
SELECT stffirstname || ' ' || stflastname AS Staff_Name,
(	SELECT COUNT(*)
	FROM schoolscheduling.faculty_classes
 	NATURAL JOIN schoolscheduling.classes
	WHERE staff.staffid = faculty_classes.staffid)
FROM schoolscheduling.staff;

-- Display students enrolled in a class on Tuesday.
CREATE VIEW Students_In_Class_Tuesdays AS
SELECT studfirstname || ' ' || studlastname As Student_Name
FROM schoolscheduling.students
WHERE students.studentid IN (
	SELECT student_schedules.studentid
	FROM schoolscheduling.student_schedules
	NATURAL JOIN schoolscheduling.classes
	WHERE tuesdayschedule = 1 );

-- List the subjects taught on Wednesday.
CREATE VIEW Subjects_On_Wednesday_Subquery AS
SELECT subjectname
FROM schoolscheduling.subjects
WHERE subjects.subjectid IN (
	SELECT classes.subjectid
	FROM schoolscheduling.classes
	WHERE wednesdayschedule = 1);
	
-- What is the largest salary we pay to any staff member?
CREATE VIEW Largest_Staff_Salary AS
SELECT Max(Salary) AS LargestStaffSalary
FROM Staff;

-- What is the current average class duration?
CREATE VIEW Average_Class_Duration AS
SELECT AVG(duration)
FROM schoolscheduling.classes;

-- List the last name and first name of each staff member who has
-- been with us since the earliest hire date.
CREATE VIEW Most_Senior_Staff_Members AS
SELECT stffirstname|| ' ' || stflastname AS Staff_Name,
	datehired
FROM schoolscheduling.staff
WHERE datehired = (
	SELECT MIN(datehired)
	FROM schoolscheduling.staff);
	
-- How many classes are held in room 3346?
CREATE VIEW Number_Of_Classes_Held_In_Room_3346 AS
SELECT COUNT(classid) AS Number_Of_Classes
FROM schoolscheduling.classes
WHERE classroomid = 3346;

-- For completed classes, list by category and student the category
-- name, the student name, and the student’s average grade of all classes taken in that category.
CREATE VIEW Student_Grade_Average_By_Category AS
SELECT Categories.CategoryDescription,
	Students.StudFirstName,
	Students.StudLastName,
	AVG(Student_Schedules.Grade) AS AvgOfGrade
FROM Categories
INNER JOIN Subjects
ON Categories.CategoryID = Subjects.CategoryID
INNER JOIN Classes
ON Subjects.SubjectID = Classes.SubjectID
INNER JOIN Student_Schedules
ON Classes.ClassID = Student_Schedules.ClassID
INNER JOIN Student_Class_Status
ON Student_Class_Status.ClassStatus = Student_Schedules.ClassStatus
INNER JOIN Students
ON Students.StudentID = Student_Schedules.StudentID
WHERE Student_Class_Status.ClassStatusDescription = 'Completed'
GROUP BY Categories.CategoryDescription,
	Students.StudFirstName,
	Students.StudLastName;

-- Display by category the category name and the count of classes offered.
CREATE VIEW Category_Class_Count AS
SELECT categories.categorydescription, COUNT(classes.classid)
FROM schoolscheduling.categories
NATURAL JOIN schoolscheduling.subjects
NATURAL JOIN schoolscheduling.classes
GROUP BY categories.categorydescription;

-- List each staff member and the count of classes each is scheduled to teach.
CREATE VIEW Staff_Class_Count_Group AS
SELECT stffirstname || ' ' || stflastname AS Staff_Name, COUNT(classes.classid)
FROM schoolscheduling.staff
NATURAL JOIN schoolscheduling.faculty_classes
NATURAL JOIN schoolscheduling.classes
GROUP BY stffirstname, stflastname;
-- Same problem but solved with subquery
CREATE VIEW Staff_Class_Count_Subquery AS
SELECT stffirstname || ' ' || stflastname AS Staff_Name, 
(	SELECT COUNT(*)
 	FROM schoolscheduling.faculty_classes
 	NATURAL JOIN schoolscheduling.classes
 	WHERE staff.staffid = faculty_classes.staffid)
FROM schoolscheduling.staff;
-- It fetch 27 raws becouse we have all the staff even if they don't teach any classes.
CREATE VIEW Staff_Class_Count_Group_All_Staff AS
SELECT stffirstname || ' ' || stflastname AS Staff_Name, COUNT(classes.classid)
FROM schoolscheduling.staff
NATURAL LEFT JOIN (schoolscheduling.faculty_classes
NATURAL JOIN schoolscheduling.classes)
GROUP BY stffirstname, stflastname;
-- Here I modify the group by query to fetch the same amount of raws as the subquery did.

-- Show me the subject categories that have fewer than three full professors teaching that subject.
CREATE VIEW Subjects_Fewer_3_Professors AS
SELECT Categories.CategoryDescription,
	(SELECT COUNT(Faculty.StaffID)
	FROM Faculty
	INNER JOIN Faculty_Categories
	ON Faculty.StaffID = Faculty_Categories.StaffID
	INNER JOIN Categories AS C2
	ON C2.CategoryID = Faculty_Categories.CategoryID
	WHERE C2.CategoryID = Categories.CategoryID
	AND Faculty.Title = 'Professor') AS ProfCount
FROM Categories
WHERE(
	SELECT COUNT(Faculty.StaffID)
	FROM Faculty
	INNER JOIN Faculty_Categories
	ON Faculty.StaffID = Faculty_Categories.StaffID
	INNER JOIN Categories AS C3
	ON C3.CategoryID = Faculty_Categories.CategoryID
	WHERE C3.CategoryID = Categories.CategoryID
	AND Faculty.Title = 'Professor') < 3;
	
-- For completed classes, list by category and student the category
-- name, the student name, and the student’s average grade of all
-- classes taken in that category for those students who have an average higher than 90.
CREATE VIEW A_Grade_Students AS
SELECT Categories.CategoryDescription,
	Students.StudFirstName,
	Students.StudLastName,
	AVG(Student_Schedules.Grade) AS AvgOfGrade
FROM Categories
INNER JOIN Subjects
ON Categories.CategoryID = Subjects.CategoryID
INNER JOIN Classes
ON Subjects.SubjectID = Classes.SubjectID
INNER JOIN Student_Schedules
ON Classes.ClassID = Student_Schedules.ClassID
INNER JOIN Student_Class_Status
ON Student_Class_Status.ClassStatus = Student_Schedules.ClassStatus
INNER JOIN Students
ON Students.StudentID = Student_Schedules.StudentID
WHERE Student_Class_Status.ClassStatusDescription = 'Completed'
GROUP BY Categories.CategoryDescription,
	Students.StudFirstName,
	Students.StudLastName
HAVING AVG(Student_Schedules.Grade) > 90;

-- List each staff member and the count of classes each is scheduled to
-- teach for those staff members who teach at least one but fewer than three classes.
CREATE VIEW Staff_Class_Count_1_To_3 AS
SELECT Staff.StfFirstName, Staff.StfLastName,
	COUNT(*) AS ClassCount
FROM Staff
INNER JOIN Faculty_Classes
ON Staff.StaffID = Faculty_Classes.StaffID
GROUP BY Staff.StfFirstName, Staff.StfLastName
HAVING COUNT(*) < 3;

-- Display by category the category name and the count of classes
-- offered for those categories that have three or more classes.
CREATE VIEW Category_Class_Count_3_Or_More AS
SELECT categories.categorydescription, COUNT(classes.classid) 
FROM schoolscheduling.categories
NATURAL JOIN schoolscheduling.subjects
NATURAL JOIN schoolscheduling.classes
GROUP BY categories.categorydescription
HAVING COUNT(classes.classid) >= 3;

-- List each staff member and the count of classes each is scheduled
-- to teach for those staff members who teach fewer than three classes.
CREATE VIEW Staff_Teaching_Less_Than_3_Classes AS
SELECT stffirstname || ' ' || stflastname AS Staff_Name, 
   (SELECT COUNT(classid)
 	FROM schoolscheduling.faculty_classes
 	WHERE staff.staffid = faculty_classes.staffid) AS Classes_Teach
FROM schoolscheduling.staff
WHERE (SELECT COUNT(classid)
 	FROM schoolscheduling.faculty_classes
 	WHERE staff.staffid = faculty_classes.staffid) < 3;
	
-- Show me the subject categories that have fewer than three full professors teaching that subject.
CREATE VIEW Subjects_Fewer_3_Professors_GROUP AS
SELECT categories.categorydescription, COUNT(*)
FROM schoolscheduling.categories
LEFT OUTER JOIN ( 
	SELECT faculty_categories.categoryid
	FROM schoolscheduling.faculty_categories
	INNER JOIN schoolscheduling.faculty
	USING (staffid)
	WHERE faculty.title = 'Professor') AS t1
ON categories.categoryid = t1.categoryid
GROUP BY categories.categorydescription
HAVING COUNT(*) < 3;

-- Count the classes taught by every staff member.
CREATE VIEW Staff_Class_Count_Incorrect_Result AS
SELECT stffirstname || ' ' || stflastname AS Staff_Name, COUNT(*)
FROM schoolscheduling.staff
LEFT OUTER JOIN (schoolscheduling.faculty_classes
	INNER JOIN schoolscheduling.classes
	ON faculty_classes.classid = classes.classid)
ON staff.staffid = faculty_classes.staffid
GROUP BY stffirstname, stflastname;
-- This query show an incorrect result becouse 'GROUP BY' and 'COUNT' will show that 
-- proffesors with no classes have 1 class. 
CREATE VIEW Staff_Class_Count_Correct AS
SELECT stffirstname || ' ' || stflastname AS Staff_Name, 
	(SELECT COUNT(*)
	 FROM schoolscheduling.faculty_classes
	 NATURAL JOIN schoolscheduling.classes
	 WHERE faculty_classes.staffid = staff.staffid) AS Number_Of_Classes
FROM schoolscheduling.staff;