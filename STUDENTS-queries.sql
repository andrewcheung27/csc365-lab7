-- Lab 7 - STUDENTS
-- Name: Andrew Cheung
-- Email: acheun29@calpoly.edu


USE `STUDENTS`;
-- Q1
WITH numstudents AS
    (SELECT classroom, COUNT(*) AS NumStudents
    FROM teachers JOIN list USING(classroom)
    GROUP BY classroom)
SELECT t.Last, t.First, NumStudents
FROM teachers AS t JOIN numstudents USING(classroom)
GROUP BY classroom
HAVING NumStudents = (SELECT MIN(NumStudents) FROM numstudents);


USE `STUDENTS`;
-- Q2
WITH
numstudents AS
    (SELECT grade, COUNT(*) AS NumStudents
    FROM list JOIN teachers USING(classroom)
    GROUP BY grade),
numclassrooms AS
    (SELECT grade, COUNT(DISTINCT classroom) AS NumClassrooms
    FROM list JOIN teachers USING(classroom)
    GROUP BY grade)
SELECT grade, NumStudents / NumClassrooms AS avgSize
FROM numstudents JOIN numclassrooms USING(grade)
GROUP BY grade
HAVING avgSize = (SELECT MAX(NumStudents / NumClassrooms) FROM numstudents JOIN numclassrooms USING(grade));


USE `STUDENTS`;
-- Q3
SELECT grade, FirstName, LastName
FROM list JOIN teachers USING(classroom)
GROUP BY FirstName, LastName
HAVING LENGTH(CONCAT(FirstName, LastName)) =
    (SELECT MAX(LENGTH(CONCAT(FirstName, LastName)))
        FROM list JOIN teachers USING(classroom));


USE `STUDENTS`;
-- Q4
WITH numclassrooms AS
    (SELECT classroom, COUNT(*) AS NumStudents
    FROM list JOIN teachers USING(classroom)
    GROUP BY classroom)
SELECT c1.classroom AS classroom1, c2.classroom AS classroom2, c1.NumStudents
FROM numclassrooms AS c1, numclassrooms AS c2
WHERE c1.classroom < c2.classroom
    AND c1.NumStudents = c2.NumStudents
ORDER BY c1.NumStudents;


USE `STUDENTS`;
-- Q5
WITH numstudents AS  -- numstudents: number of students per classroom
    (SELECT classroom, grade, COUNT(*) AS NumStudents
    FROM teachers JOIN list USING(classroom)
    GROUP BY classroom, grade),

maxstudents AS  -- maxstudents: largest class per grade
    (WITH numstudents AS
        (SELECT classroom, grade, COUNT(*) AS NumStudents
        FROM teachers JOIN list USING(classroom)
        GROUP BY classroom, grade)
    SELECT grade, MAX(NumStudents) AS MaxStudents
    FROM numstudents
    GROUP BY grade)

SELECT grade, teachers.Last AS teacher
FROM numstudents JOIN maxstudents USING(grade) JOIN teachers USING(classroom)
WHERE NumStudents = MaxStudents
    -- grade has more than one classroom
    AND grade IN((SELECT grade
                    FROM teachers JOIN list USING(classroom)
                    GROUP BY grade
                    HAVING COUNT(DISTINCT classroom) > 1))
ORDER BY grade;
