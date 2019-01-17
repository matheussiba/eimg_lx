CREATE OR REPLACE FUNCTION update_eimg_raw_polys() RETURNS trigger AS $$
	BEGIN
		CASE tg_op --variable that contains the type of operation that triggers the function
			WHEN 'INSERT' THEN
				UPDATE eimg_raw_polys SET
				NEW.centroid = ST_Centroid(geom_4326),
				NEW.timestamp_tz = now(),
				NEW.area_sqm = ST_Area(ST_SnapToGrid( ST_Transform(geom_4326,27493), 0.00001)),
				NEW.geom_27493 = ST_SnapToGrid( ST_Transform(geom_4326,27493), 0.00001);
		END CASE;
	END;
$$ LANGUAGE plpgsql;
--DROP FUNCTION update_eimg_raw_polys()

CREATE TRIGGER trigger_update_eimg_raw_polys AFTER INSERT OR UPDATE OR DELETE ON
eimg_raw_polys FOR EACH ROW EXECUTE PROCEDURE update_eimg_raw_polys();
--DROP TRIGGER IF EXISTS trigger_update_eimg_raw_polys on eimg_raw_polys 