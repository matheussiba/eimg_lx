--Delete table if exists
DROP TABLE IF EXISTS tblfoo_result;
CREATE TABLE tblfoo_result AS
(	
	WITH  result_table_overlayed AS
	(
		WITH  result_table_not_dumped AS
		(
			WITH  parts AS
			(
				SELECT a.att_value val,
					 CASE WHEN a.att_category = 'cat1' THEN 1 ELSE 0 END cat1,
					 CASE WHEN a.att_category = 'cat2' THEN 1 ELSE 0 END cat2,
					 unnest(ST_SplitAgg(a.geom, b.geom, 0.00001)) geom
				FROM tbl_foo_1 a,
				   tbl_foo_1 b
				WHERE ST_Equals(a.geom, b.geom) OR
					ST_Contains(a.geom, b.geom) OR
					ST_Contains(b.geom, a.geom) OR
					ST_Overlaps(a.geom, b.geom)
				GROUP BY a.id, a.att_category , ST_AsEWKB(a.geom), val
			)
			SELECT CASE WHEN sum(cat2) = 0 THEN 'cat1'
						WHEN sum(cat1) = 0 THEN 'cat2'
						ELSE 'cat3'
				   END category,
				   sum(val) sum_value, --sum(val*1.0): for the integer to become into float
				   sum(cat1) ct_overlap_cat1,
				   sum(cat2) ct_overlap_cat2,
				   ST_Union(geom) geom
			FROM parts
			GROUP BY ST_Centroid(geom)
		)
		SELECT category, sum_value, ct_overlap_cat1, ct_overlap_cat2,
		(ST_Dump(result_table_not_dumped.geom)).geom as geom
		FROM result_table_not_dumped
	)
	SELECT
		ST_Union(geom) 			geom,
		sum(sum_value) 			ct_values,
		sum(ct_overlap_cat1) 	ct_cat1,
		sum(ct_overlap_cat2) 	ct_cat2
	FROM result_table_overlayed
	GROUP BY ST_Centroid(geom)
);
