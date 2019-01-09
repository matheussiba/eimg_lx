DELETE FROM data_sus WHERE user_id=207

UPDATE data_sus
SET
    question1 = copytbl.question1,
	question2 = copytbl.question2,
	question3 = copytbl.question3,
	question4 = copytbl.question4,
	question5 = copytbl.question5,
	question6 = copytbl.question6,
	question7 = copytbl.question7,
	question8 = copytbl.question8,
	question9 = copytbl.question9,
	question10 = copytbl.question10,
	question11 = copytbl.question11,
	question12 = copytbl.question12
FROM
    (
    SELECT
        user_id,
        question1,
        question2,
		question3,
		question4,
		question5,
		question6,
		question7,
		question8,
		question9,
		question10,
		question11,
		question12
    FROM data_sus
    WHERE
        user_id = 46
    ) copytbl
WHERE
    data_sus.user_id = 52;


INSERT INTO data_sus (user_id) VALUES (52);


UPDATE data_sus SET question1 = copytbl.question1, question2 = copytbl.question2, 
question3 = copytbl.question3, question4 = copytbl.question4, question5 = copytbl.question5, 
question6 = copytbl.question6, question7 = copytbl.question7, question8 = copytbl.question8, 
question9 = copytbl.question9, question10 = copytbl.question10, question11 = copytbl.question11, 
question12 = copytbl.question12 FROM ( SELECT user_id, question1, question2, question3, question4, 
question5, question6, question7, question8, question9, question10, question11, question12 
FROM data_sus WHERE user_id = 46 ) copytbl WHERE data_sus.user_id = 52;

INNER JOIN 
SELECT e.*, d.type_interview
FROM eimg_raw_polys e
INNER JOIN data_demographics d ON e.user_id=d.user_id
WHERE type_interview LIKE 'face-to-face';
