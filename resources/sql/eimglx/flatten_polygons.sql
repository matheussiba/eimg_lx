DROP TABLE IF EXISTS eimg_raw_polys_multi;
/*NOTE: The geometry used for the calculation is geom_27493 and not geom_4326 */
CREATE TABLE eimg_raw_polys_multi AS
      SELECT
      	row_number() OVER () AS id,
      	CASE WHEN a.eval_nr = 1 THEN 1 ELSE 0 END cat_liked, --eval_nr == 1 means a liked place
      	CASE WHEN a.eval_nr = 2 THEN 1 ELSE 0 END cat_disliked, --eval_nr == 2 means a disliked place
      	unnest(ST_SplitAgg(a.geom_27493, b.geom_27493)) geom,
      	ST_Area(unnest(ST_SplitAgg(a.geom_27493, b.geom_27493))) area,
      	a.att_nat attNat, a.att_open attOpen,
      	a.att_order attOrder, a.att_upkeep attUpkeep, a.att_hist attHist
      FROM eimg_raw_polys a, -- eimg_raw_polys
         eimg_raw_polys b
      WHERE ST_Equals(a.geom_27493, b.geom_27493) OR
      	ST_Contains(a.geom_27493, b.geom_27493) OR
      	ST_Contains(b.geom_27493, a.geom_27493) OR
      	ST_Overlaps(a.geom_27493, b.geom_27493) AND
      	(ST_isValid(a.geom_27493) AND ST_isValid(b.geom_27493)) --eliminates not valid geometries the user could have inserted
      GROUP BY a.id, a.eval_nr , ST_AsEWKB(a.geom_27493), attNat, attOpen, attOrder, attUpkeep, attHist;
	  

	  
DROP TABLE IF EXISTS eimg_raw_polys_single;
CREATE TABLE eimg_raw_polys_single AS
      SELECT
      		row_number() OVER () AS id,
      		ST_SnapToGrid((ST_Dump(eimg_raw_polys_multi.geom)).geom , 0.00001) geom,
      		ST_Area(ST_Transform( (ST_Dump(eimg_raw_polys_multi.geom)).geom, 27493 )) area,
      		id id_parent, cat_liked, cat_disliked, attNat, attOpen, attOrder, attUpkeep, attHist
      FROM eimg_raw_polys_multi
      WHERE eimg_raw_polys_multi.area > 10; -- eliminates ghost geometries criated in ST_SplitAgg()
	  

	  
DROP TABLE IF EXISTS eimg_result;
CREATE TABLE eimg_result AS
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
      FROM eimg_raw_polys_single
      GROUP BY ST_SnapToGrid( ST_Transform(ST_Centroid(geom),27493), 1);