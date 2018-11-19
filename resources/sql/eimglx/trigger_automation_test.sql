CREATE OR REPLACE FUNCTION update_eimg_raw_polys () RETURNS trigger AS $$
	BEGIN
		CASE tg_op --variable that contains the type of operation that triggers the function
			WHEN 'INSERT' THEN
				UPDATE eimg_raw_polys SET
				NEW.timestamp_tz = now();
		END CASE;
	END;
$$ LANGUAGE plpgsql;