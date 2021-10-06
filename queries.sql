-- Solution - - - -  - - - -  - - - - - -

--1. Select all primary skills that contain more than one word (please note that both ‘-‘ and ‘ ’ could be used as a separator). – 0.2 points
SELECT s.primary_skill
FROM "students" as s
WHERE s.primary_skill SIMILAR TO '% %|%-%'
GROUP BY s.primary_skill


--2. Select all students who do not have a second name (it is absent or consists of only one letter/letter with a dot). – 0.2 points
SELECT s.*
FROM "students" as s
WHERE length(regexp_replace(s.surname, '\.', '')) <= 1


--3. Select number of students passed exams for each subject and order result by a number of student descending. – 0.2 points
SELECT COUNT(s),sub.name
FROM "examResults" as ex
	INNER JOIN "students" as s
	ON ex.student_id=s.id
	INNER JOIN "subjects" as sub
	ON sub.id=ex.subject_id
WHERE ex.mark > 3
GROUP BY sub.name
ORDER BY COUNT(s) DESC


--4. Select the number of students with the same exam marks for each subject. – 0.2 points



--5. Select students who passed at least two exams for different subjects. – 0.3 points
SELECT DISTINCT(sub.id),s.id as Student_ID,s.name,COUNT(ex)
FROM "students" as s
	INNER JOIN "examResults" as ex
	ON ex.student_id=s.id
	INNER JOIN "subjects" as sub
	ON sub.id=ex.subject_id
GROUP BY sub.id,s.id,s.name
HAVING COUNT(ex) > 2


--6. Select students who passed at least two exams for the same subject. – 0.3 points
SELECT s.id,s.name,sub.name,COUNT(ex)
FROM "students" as s
	INNER JOIN "examResults" as ex
	ON ex.student_id=s.id
	INNER JOIN "subjects" as sub
	ON sub.id=ex.subject_id
GROUP BY s.id,s.name,sub.name
HAVING COUNT(ex) > 2

--7. Select all subjects which exams passed only students with the same primary skills. – 0.3 points
SELECT subMain.*
FROM "subjects" as subMain
WHERE (
SELECT COUNT(DISTINCT(s.primary_skill))
FROM "examResults" as ex
	INNER JOIN "students" as s
	ON ex.student_id=s.id
	INNER JOIN "subjects" as sub
	ON sub.id=ex.subject_id
WHERE sub.id=subMain.id
) = 0

--8. Select all subjects which exams passed only students with the different primary skills. It means that all students passed the exam for the one subject must have different primary skill. – 0.4 points
SELECT subMain.*
FROM "subjects" as subMain
WHERE (
	SELECT COUNT(s.primary_skill)
	FROM "examResults" as ex
		INNER JOIN "students" as s
		ON ex.student_id=s.id
		INNER JOIN "subjects" as sub
		ON sub.id=ex.subject_id
	WHERE sub.id=subMain.id
	GROUP BY s.primary_skill
	HAVING COUNT(s.primary_skill) > 1
) IS NULL

--9. Select students who do not pass any exam using each of the following operator: – 0.5 points
-- - Outer join
SELECT s.*
FROM "students" as s
	LEFT OUTER JOIN "examResults" as ex
	ON ex.student_id=s.id
GROUP BY s.id,s.name
HAVING COUNT(ex) = 0


-- - Subquery with ‘not in’ clause
SELECT *
FROM "students" as s
WHERE s.id NOT IN (SELECT s.id
                    FROM "students" as s
                        INNER JOIN "examResults" as ex
                        ON ex.student_id=s.id)


-- - Subquery with ‘any ‘ clause Check which approach is faster for 1000, 10K, 100K exams and 10, 1K, 100K students
--10. Select all students whose average mark is bigger than the overall average mark. – 0.3 points
SELECT AVG(ex.mark) as Avarage_Mark,s.*
FROM "students" as s
	INNER JOIN "examResults" as ex
	ON ex.student_id=s.id
GROUP BY s.id,ex.mark
HAVING AVG(ex.mark) > (SELECT AVG(ex.mark) FROM "examResults" as ex)

--11. Select the top 5 students who passed their last exam better than average students. – 0.3 points
SELECT s.*
FROM "students" as s
WHERE (
    SELECT ex.mark
    FROM "examResults" as ex
    WHERE ex.student_id = s.id
    GROUP BY ex.created_at,ex.mark
    ORDER BY ex.created_at DESC LIMIT 1
    ) > (SELECT AVG(ex.mark) FROM "examResults" as ex)

--12. Select the biggest mark for each student and add text description for the mark (use COALESCE and WHEN operators) – 0.3 points
-- In case if the student has not passed any exam ‘not passed' should be returned.
-- If the student mark is 1,2,3 – it should be returned as ‘BAD’
-- If the student mark is 4,5,6 – it should be returned as ‘AVERAGE’
-- If the student mark is 7,8 – it should be returned as ‘GOOD’
-- If the student mark is 9,10 – it should be returned as ‘EXCELLENT’
SELECT s.id,
    CASE
        WHEN MAX(ex.mark) = 5 THEN 'EXCELLENT'
        WHEN MAX(ex.mark) = 4 THEN 'GOOD'
        WHEN MAX(ex.mark) = 3 THEN 'AVERAGE'
        WHEN MAX(ex.mark) = 2 THEN 'BAD'
        WHEN MAX(ex.mark) = 1 THEN 'BAD'
        ELSE 'not passed'
    END AS Mark_Level
FROM "students" as s
	INNER JOIN "examResults" as ex
	ON ex.student_id=s.id
GROUP BY s.id,ex.mark
ORDER BY ex.mark DESC


-- 13. Select the number of all marks for each mark type (‘BAD’, ‘AVERAGE’,…). – 0.4 points
SELECT
    COUNT(
        CASE
            WHEN ex.mark = 5 THEN 'EXCELLENT'
            WHEN ex.mark = 4 THEN 'GOOD'
            WHEN ex.mark = 3 THEN 'AVERAGE'
            WHEN ex.mark = 2 THEN 'BAD'
            WHEN ex.mark = 1 THEN 'BAD'
            ELSE 'not passed'
        END
    ) AS quantity,
    CASE
        WHEN ex.mark = 5 THEN 'EXCELLENT'
        WHEN ex.mark = 4 THEN 'GOOD'
        WHEN ex.mark = 3 THEN 'AVERAGE'
        WHEN ex.mark = 2 THEN 'BAD'
        WHEN ex.mark = 1 THEN 'BAD'
        ELSE 'not passed'
    END AS Mark_Level
FROM "examResults" as ex
GROUP BY ex.mark
ORDER BY ex.mark DESC
