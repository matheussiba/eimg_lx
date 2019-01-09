ALTER TABLE data_sus ADD COLUMN sus_score numeric;
ALTER TABLE data_sus ADD COLUMN usefulness_score numeric;

UPDATE data_sus
SET    question1 = replace(question1, 'strong_disagree', '1')
     , question2 = replace(question2, 'strong_disagree', '1')
     , question3 = replace(question3, 'strong_disagree', '1')
     , question4 = replace(question4, 'strong_disagree', '1')
	 , question5 = replace(question5, 'strong_disagree', '1')
     , question6 = replace(question6, 'strong_disagree', '1')
     , question7 = replace(question7, 'strong_disagree', '1')
	 , question8 = replace(question8, 'strong_disagree', '1')
     , question9 = replace(question9, 'strong_disagree', '1')
     , question10 = replace(question10, 'strong_disagree', '1')
	 , question11 = replace(question11, 'strong_disagree', '1')
     , question12 = replace(question12, 'strong_disagree', '1');
	 
UPDATE data_sus
SET    question1 = replace(question1, 'strong_agree', '5')
	, question2 = replace(question2, 'strong_agree', '5')
	, question3 = replace(question3, 'strong_agree', '5')
	, question4 = replace(question4, 'strong_agree', '5')
 , question5 = replace(question5, 'strong_agree', '5')
	, question6 = replace(question6, 'strong_agree', '5')
	, question7 = replace(question7, 'strong_agree', '5')
 , question8 = replace(question8, 'strong_agree', '5')
	, question9 = replace(question9, 'strong_agree', '5')
	, question10 = replace(question10, 'strong_agree', '5')
 , question11 = replace(question11, 'strong_agree', '5')
	, question12 = replace(question12, 'strong_agree', '5');
	 
	 
UPDATE data_sus
SET    question1 = replace(question1, 'disagree', '2')
     , question2 = replace(question2, 'disagree', '2')
     , question3 = replace(question3, 'disagree', '2')
     , question4 = replace(question4, 'disagree', '2')
	 , question5 = replace(question5, 'disagree', '2')
     , question6 = replace(question6, 'disagree', '2')
     , question7 = replace(question7, 'disagree', '2')
	 , question8 = replace(question8, 'disagree', '2')
     , question9 = replace(question9, 'disagree', '2')
     , question10 = replace(question10, 'disagree', '2')
	 , question11 = replace(question11, 'disagree', '2')
     , question12 = replace(question12, 'disagree', '2');

 UPDATE data_sus
 SET    question1 = replace(question1, 'neutral', '3')
	  , question2 = replace(question2, 'neutral', '3')
	  , question3 = replace(question3, 'neutral', '3')
	  , question4 = replace(question4, 'neutral', '3')
	 , question5 = replace(question5, 'neutral', '3')
	  , question6 = replace(question6, 'neutral', '3')
	  , question7 = replace(question7, 'neutral', '3')
	 , question8 = replace(question8, 'neutral', '3')
	  , question9 = replace(question9, 'neutral', '3')
	  , question10 = replace(question10, 'neutral', '3')
	 , question11 = replace(question11, 'neutral', '3')
	  , question12 = replace(question12, 'neutral', '3');

UPDATE data_sus
SET    question1 = replace(question1, 'agree', '4')
   , question2 = replace(question2, 'agree', '4')
   , question3 = replace(question3, 'agree', '4')
   , question4 = replace(question4, 'agree', '4')
 , question5 = replace(question5, 'agree', '4')
   , question6 = replace(question6, 'agree', '4')
   , question7 = replace(question7, 'agree', '4')
 , question8 = replace(question8, 'agree', '4')
   , question9 = replace(question9, 'agree', '4')
   , question10 = replace(question10, 'agree', '4')
 , question11 = replace(question11, 'agree', '4')
   , question12 = replace(question12, 'agree', '4');

UPDATE data_sus SET sus_score = 
((question1::numeric - 1.0) + 
(5.0 - question2::numeric) + 
(question3::numeric - 1.0) + 
(5.0 - question4::numeric) + 
(question5::numeric - 1.0) + 
(5.0 - question6::numeric) + 
(question7::numeric - 1.0) + 
(5.0 - question8::numeric) + 
(question9::numeric - 1.0) + 
(5.0 - question10::numeric))*2.5;

UPDATE data_sus SET usefulness_score = 
((question11::numeric - 1.0) + 
 (question12::numeric - 1.0))*2.5;
 