INSERT INTO eimglx_areas_demo (geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist) 
VALUES ( ST_SetSRID(ST_GeomFromGeoJSON(

'{"type":"MultiPolygon","coordinates":
	[[[[-9.127149581909181,38.72266597376711],
	[-9.14963722229004,38.71844713964948],[-9.128866195678713,38.71302255840357],
	[-9.126462936401369,38.71791139686126],[-9.127149581909181,38.72266597376711]]]]
}'

),4326), 
3, 'NA', 1, 1, 0, 0, 1 );
