CREATE SEQUENCE IF NOT EXISTS  data_demographics_seq_id  INCREMENT  BY  1 
	MINVALUE 1   NO MAXVALUE
    START WITH 1
    OWNED BY data_demographics.table_id;

ALTER TABLE data_demographics ALTER COLUMN table_id SET DEFAULT nextval('data_demographics_seq_id');
--INSERT INTO eimg_raw_polys (eval_nr) VALUES (2);
--select * from eimg_raw_polys order by id desc;
--DELETE FROM eimg_raw_polys WHERE id is null;