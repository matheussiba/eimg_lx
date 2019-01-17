CREATE INDEX sidx_eimg_raw_polys_geom4326
	ON public.eimg_raw_polys USING gist
	(geom_4326)
	TABLESPACE pg_default;

CREATE INDEX sidx_eimg_raw_polys_geom27493
	ON public.eimg_raw_polys USING gist
	(geom_27493)
	TABLESPACE pg_default;

CREATE INDEX sidx_eimg_raw_polys_geog4326
	ON public.eimg_raw_polys USING gist
	(CAST (geom_4326 AS geography))
	TABLESPACE pg_default;