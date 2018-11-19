--By Centroid 
DROP TABLE IF EXISTS test_eimg_raw_polys_sample;
CREATE TABLE test_eimg_raw_polys_sample AS  
SELECT id, --ST_QuantizeCoordinates(geom::geometry, 3) geom
ST_SnapToGrid( ST_Transform(geom,27493), 0.00001) geom, 
ST_Area(ST_SnapToGrid( ST_Transform(geom,27493), 0.00001)) area,
eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist
FROM test_eimg_raw_polys; --WHERE id<=15;


DROP TABLE IF EXISTS test_eimg_raw_polys_multi;
CREATE TABLE test_eimg_raw_polys_multi AS  
SELECT 
	row_number() OVER () AS id,
	CASE WHEN a.eval_nr = 1 THEN 1 ELSE 0 END cat_liked, --eval_nr == 1 means a liked place 
	CASE WHEN a.eval_nr = 2 THEN 1 ELSE 0 END cat_disliked, --eval_nr == 2 means a disliked place 
	unnest(ST_SplitAgg(a.geom, b.geom)) geom, --function from: https://github.com/pedrogit/postgisaddons
											--more info: https://gis.stackexchange.com/a/301472/51141
	ST_Area(ST_Transform( unnest(ST_SplitAgg(a.geom, b.geom)), 27493 )) area,
	a.att_nat attNat, a.att_open attOpen, 
	a.att_order attOrder, a.att_upkeep attUpkeep, a.att_hist attHist
FROM test_eimg_raw_polys_sample a, -- test_eimg_raw_polys_sample
   test_eimg_raw_polys_sample b
WHERE ST_Equals(a.geom, b.geom) OR
	ST_Contains(a.geom, b.geom) OR
	ST_Contains(b.geom, a.geom) OR
	ST_Overlaps(a.geom, b.geom) AND
	(ST_isValid(a.geom) AND ST_isValid(b.geom)) --eliminates not valid geometries the user could have inserted
GROUP BY a.id, a.eval_nr , ST_AsEWKB(a.geom), attNat, attOpen, attOrder, attUpkeep, attHist;

					   
DROP TABLE IF EXISTS test_eimg_raw_polys_single;
CREATE TABLE test_eimg_raw_polys_single AS  
SELECT 
		row_number() OVER () AS id,
		ST_SnapToGrid((ST_Dump(test_eimg_raw_polys_multi.geom)).geom , 0.00001) geom,
		ST_Area(ST_Transform( (ST_Dump(test_eimg_raw_polys_multi.geom)).geom, 27493 )) area,
		id id_parent, cat_liked, cat_disliked, attNat, attOpen, attOrder, attUpkeep, attHist
FROM test_eimg_raw_polys_multi
WHERE test_eimg_raw_polys_multi.area > 10; -- eliminates ghost geometries criated in ST_SplitAgg()	



DROP TABLE IF EXISTS test_eimg_result;
CREATE TABLE test_eimg_result AS  
SELECT		
	row_number() OVER () AS id,
	ST_SnapToGrid( ST_Transform( ST_Union(geom) ,4326), 0.000001) geom,	   
	ST_AsText(ST_SnapToGrid( ST_Transform(ST_Centroid(geom),27493), 1)) centroid,
	CASE WHEN sum(cat_liked) = 0 THEN 'disliked'
		WHEN sum(cat_disliked) = 0 THEN 'liked'
		ELSE 'like/disliked'
	END category,
	CASE WHEN sum(cat_liked) = 0 THEN 2
		WHEN sum(cat_disliked) = 0 THEN 1
		ELSE 3
	END category_nr,
	--id_parent,
	sum(cat_liked) ct_liked, sum(cat_disliked) ct_disliked,
	sum(attNat) ct_nat, sum(attOpen) ct_ope, sum(attOrder) ct_ord, 
	sum(attUpkeep) ct_upk , sum(attHist) ct_his
FROM test_eimg_raw_polys_single
GROUP BY ST_SnapToGrid( ST_Transform(ST_Centroid(geom),27493), 1);


DROP TABLE test_eimg_raw_polys_sample;
DROP TABLE test_eimg_raw_polys_multi;
DROP TABLE test_eimg_raw_polys_single;


--****************************************************************************
--By Area, less precise								   				   
/*
DROP TABLE IF EXISTS test_eimg_result;
CREATE TABLE test_eimg_result AS  
SELECT		
	row_number() OVER () AS id,
	ST_SnapToGrid( ST_Transform( ST_Union(geom) ,4326), 0.000001) geom,	   
	( ST_Area(ST_SnapToGrid( ST_Transform(geom,27493), 0.000001))*10 )::bigint area,
	CASE WHEN sum(cat_liked) = 0 THEN 'disliked'
		WHEN sum(cat_disliked) = 0 THEN 'liked'
		ELSE 'like/disliked'
	END category,
	CASE WHEN sum(cat_liked) = 0 THEN 2
		WHEN sum(cat_disliked) = 0 THEN 1
		ELSE 3
	END category_nr,
	--id_parent,
	sum(cat_liked) ct_liked, sum(cat_disliked) ct_disliked,
	sum(attNat) ct_nat, sum(attOpen) ct_ope, sum(attOrder) ct_ord, 
	sum(attUpkeep) ct_upk , sum(attHist) ct_his
FROM test_eimg_raw_polys_single
WHERE test_eimg_raw_polys_single.area > 150 -- delete really small areas
GROUP BY ( ST_Area(ST_SnapToGrid( ST_Transform(geom,27493), 0.000001))*10 )::bigint
			--Increases the precision to compare the equal area 
ORDER BY area;
*/