WITH  result_table AS (
    WITH  parts AS (
      SELECT a.att_value val,
             CASE WHEN a.att_category = 'cat1' THEN 1 ELSE 0 END cat1,
             CASE WHEN a.att_category = 'cat2' THEN 1 ELSE 0 END cat2,
             unnest(ST_SplitAgg(a.geom, b.geom, 0.00001)) geom
      FROM tbl_foo a,
           tbl_foo b
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
           sum(val*1.0) sum_value, 
           sum(cat1) ct_overlap_cat1, 
           sum(cat2) ct_overlap_cat2, 
           ST_Union(geom) geom
    FROM parts
    GROUP BY ST_Area(geom)
)
SELECT category, sum_value, ct_overlap_cat1, ct_overlap_cat2,
(ST_Dump(result_table.geom)).geom as geom
FROM result_table