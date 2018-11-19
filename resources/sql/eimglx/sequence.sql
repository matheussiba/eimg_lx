CREATE SEQUENCE IF NOT EXISTS  eimg_raw_polys_seq_id  INCREMENT  BY  1 
	MINVALUE 1   NO MAXVALUE
    START WITH 92 
    OWNED BY eimg_raw_polys.id;

ALTER TABLE eimg_raw_polys ALTER COLUMN id SET DEFAULT nextval('eimg_raw_polys_seq_id');
--INSERT INTO eimg_raw_polys (eval_nr) VALUES (2);
--select * from eimg_raw_polys order by id desc;
--DELETE FROM eimg_raw_polys WHERE id is null;