--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 10.5

-- Started on 2018-12-17 12:52:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12387)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 21227)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- TOC entry 1926 (class 1247 OID 26712)
-- Name: agg_areaweightedstats; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agg_areaweightedstats AS (
	count integer,
	distinctcount integer,
	geom public.geometry,
	totalarea double precision,
	meanarea double precision,
	totalperimeter double precision,
	meanperimeter double precision,
	weightedsum double precision,
	weightedmean double precision,
	maxareavalue double precision,
	minareavalue double precision,
	maxcombinedareavalue double precision,
	mincombinedareavalue double precision,
	sum double precision,
	mean double precision,
	max double precision,
	min double precision
);


--
-- TOC entry 1929 (class 1247 OID 26715)
-- Name: agg_areaweightedstatsstate; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agg_areaweightedstatsstate AS (
	count integer,
	distinctvalues double precision[],
	unionedgeom public.geometry,
	totalarea double precision,
	totalperimeter double precision,
	weightedsum double precision,
	maxareavalue double precision[],
	minareavalue double precision[],
	combinedweightedareas double precision[],
	sum double precision,
	max double precision,
	min double precision
);


--
-- TOC entry 1932 (class 1247 OID 26757)
-- Name: geomvaltxt; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.geomvaltxt AS (
	geom public.geometry,
	val double precision,
	txt text
);


--
-- TOC entry 1448 (class 1255 OID 26719)
-- Name: _st_areaweightedsummarystats_finalfn(public.agg_areaweightedstatsstate); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_areaweightedsummarystats_finalfn(aws public.agg_areaweightedstatsstate) RETURNS public.agg_areaweightedstats
    LANGUAGE plpgsql
    AS $_$
    DECLARE
        a RECORD;
        maxarea double precision = 0.0;
        minarea double precision = (($1).combinedweightedareas)[1];
        imax int := 1;
        imin int := 1;
        ret agg_areaweightedstats;
    BEGIN
        -- Search for the max and the min areas in the array of all distinct values
        FOR a IN SELECT n, (($1).combinedweightedareas)[n] warea
                 FROM generate_series(1, array_length(($1).combinedweightedareas, 1)) n LOOP
            IF a.warea > maxarea THEN
                imax := a.n;
                maxarea = a.warea;
            END IF;
            IF a.warea < minarea THEN
                imin := a.n;
                minarea = a.warea;
            END IF;
        END LOOP;

        ret := (($1).count,
                array_length(($1).distinctvalues, 1),
                ($1).unionedgeom,
                ($1).totalarea,
                ($1).totalarea / ($1).count,
                ($1).totalperimeter,
                ($1).totalperimeter / ($1).count,
                ($1).weightedsum,
                ($1).weightedsum / ($1).totalarea,
                (($1).maxareavalue)[2],
                (($1).minareavalue)[2],
                (($1).distinctvalues)[imax],
                (($1).distinctvalues)[imin],
                ($1).sum,
                ($1).sum / ($1).count,
                ($1).max,
                ($1).min
               )::agg_areaweightedstats;
        RETURN ret;
    END;
$_$;


--
-- TOC entry 1447 (class 1255 OID 26718)
-- Name: _st_areaweightedsummarystats_statefn(public.agg_areaweightedstatsstate, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_areaweightedsummarystats_statefn(aws public.agg_areaweightedstatsstate, geom public.geometry) RETURNS public.agg_areaweightedstatsstate
    LANGUAGE sql
    AS $_$
    SELECT _ST_AreaWeightedSummaryStats_StateFN($1, ($2, 1)::geomval);
$_$;


--
-- TOC entry 1445 (class 1255 OID 26716)
-- Name: _st_areaweightedsummarystats_statefn(public.agg_areaweightedstatsstate, public.geomval); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_areaweightedsummarystats_statefn(aws public.agg_areaweightedstatsstate, gv public.geomval) RETURNS public.agg_areaweightedstatsstate
    LANGUAGE plpgsql
    AS $_$
    DECLARE
        i int;
        ret agg_areaweightedstatsstate;
        newcombinedweightedareas double precision[] := ($1).combinedweightedareas;
        newgeom geometry := ($2).geom;
        geomtype text := GeometryType(($2).geom);
    BEGIN
        -- If the geometry is a GEOMETRYCOLLECTION extract the polygon part
        IF geomtype = 'GEOMETRYCOLLECTION' THEN
            newgeom := ST_CollectionExtract(newgeom, 3);
        END IF;
        -- Skip anything that is not a polygon
        IF newgeom IS NULL OR ST_IsEmpty(newgeom) OR geomtype = 'POINT' OR geomtype = 'LINESTRING' OR geomtype = 'MULTIPOINT' OR geomtype = 'MULTILINESTRING' THEN
            ret := aws;
        -- At the first iteration the state parameter is always NULL
        ELSEIF $1 IS NULL THEN
            ret := (1,                                 -- count
                    ARRAY[($2).val],                   -- distinctvalues
                    newgeom,                           -- unionedgeom
                    ST_Area(newgeom),                  -- totalarea
                    ST_Perimeter(newgeom),             -- totalperimeter
                    ($2).val * ST_Area(newgeom),       -- weightedsum
                    ARRAY[ST_Area(newgeom), ($2).val], -- maxareavalue
                    ARRAY[ST_Area(newgeom), ($2).val], -- minareavalue
                    ARRAY[ST_Area(newgeom)],           -- combinedweightedareas
                    ($2).val,                          -- sum
                    ($2).val,                          -- max
                    ($2).val                           -- min
                   )::agg_areaweightedstatsstate;
        ELSE
            -- Search for the new value in the array of distinct values
            SELECT n
            FROM generate_series(1, array_length(($1).distinctvalues, 1)) n
            WHERE (($1).distinctvalues)[n] = ($2).val
            INTO i;

            -- If the value already exists, increment the corresponding area with the new area
            IF NOT i IS NULL THEN
                newcombinedweightedareas[i] := newcombinedweightedareas[i] + ST_Area(newgeom);
            END IF;
            ret := (($1).count + 1,                                     -- count
                    CASE WHEN i IS NULL                                 -- distinctvalues
                         THEN array_append(($1).distinctvalues, ($2).val)
                         ELSE ($1).distinctvalues
                    END,
                    ST_Union(($1).unionedgeom, newgeom),                -- unionedgeom
                    ($1).totalarea + ST_Area(newgeom),                  -- totalarea
                    ($1).totalperimeter + ST_Perimeter(newgeom),        -- totalperimeter
                    ($1).weightedsum + ($2).val * ST_Area(newgeom),     -- weightedsum
                    CASE WHEN ST_Area(newgeom) > (($1).maxareavalue)[1] -- maxareavalue
                         THEN ARRAY[ST_Area(newgeom), ($2).val]
                         ELSE ($1).maxareavalue
                    END,
                    CASE WHEN ST_Area(newgeom) < (($1).minareavalue)[1] -- minareavalue
                         THEN ARRAY[ST_Area(newgeom), ($2).val]
                         ELSE ($1).minareavalue
                    END,
                    CASE WHEN i IS NULL                                 -- combinedweightedareas
                         THEN array_append(($1).combinedweightedareas, ST_Area(newgeom))
                         ELSE newcombinedweightedareas
                    END,
                    ($1).sum + ($2).val,                                -- sum
                    greatest(($1).max, ($2).val),                       -- max
                    least(($1).min, ($2).val)                           -- min
                   )::agg_areaweightedstatsstate;
        END IF;
        RETURN ret;
    END;
$_$;


--
-- TOC entry 1446 (class 1255 OID 26717)
-- Name: _st_areaweightedsummarystats_statefn(public.agg_areaweightedstatsstate, public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_areaweightedsummarystats_statefn(aws public.agg_areaweightedstatsstate, geom public.geometry, val double precision) RETURNS public.agg_areaweightedstatsstate
    LANGUAGE sql
    AS $_$
   SELECT _ST_AreaWeightedSummaryStats_StateFN($1, ($2, $3)::geomval);
$_$;


--
-- TOC entry 1457 (class 1255 OID 26732)
-- Name: _st_bufferedunion_finalfn(public.geomval); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_bufferedunion_finalfn(gv public.geomval) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT ST_Buffer(($1).geom, -($1).val, 'endcap=square join=mitre')
$_$;


--
-- TOC entry 1456 (class 1255 OID 26731)
-- Name: _st_bufferedunion_statefn(public.geomval, public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_bufferedunion_statefn(gv public.geomval, geom public.geometry, bufsize double precision DEFAULT 0.0) RETURNS public.geomval
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE WHEN $1 IS NULL AND $2 IS NULL THEN
                    NULL
                WHEN $1 IS NULL THEN
                    (ST_Buffer($2, CASE WHEN $3 IS NULL THEN 0.0 ELSE $3 END, 'endcap=square join=mitre'),
                     CASE WHEN $3 IS NULL THEN 0.0 ELSE $3 END
                    )::geomval
                WHEN $2 IS NULL THEN
                    $1
                ELSE (ST_Union(($1).geom,
                           ST_Buffer($2, CASE WHEN $3 IS NULL THEN 0.0 ELSE $3 END, 'endcap=square join=mitre')
                          ),
                  ($1).val
                 )::geomval
       END;
$_$;


--
-- TOC entry 1401 (class 1255 OID 26736)
-- Name: _st_differenceagg_statefn(public.geometry, public.geometry, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_differenceagg_statefn(geom1 public.geometry, geom2 public.geometry, geom3 public.geometry) RETURNS public.geometry
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
       newgeom geometry;
       differ geometry;
    BEGIN
        -- First pass: geom1 is NULL
        IF geom1 IS NULL AND NOT ST_IsEmpty(geom2) THEN 
            IF geom3 IS NULL OR ST_Area(geom3) = 0 THEN
                newgeom = geom2;
            ELSE
                newgeom = CASE
                              WHEN ST_Area(ST_Intersection(geom2, geom3)) = 0 OR ST_IsEmpty(ST_Intersection(geom2, geom3)) THEN geom2
                              ELSE ST_Difference(geom2, geom3)
                           END;
            END IF;
        ELSIF NOT ST_IsEmpty(geom1) AND ST_Area(geom3) > 0 THEN
            BEGIN
                differ = ST_Difference(geom1, geom3);
            EXCEPTION
            WHEN OTHERS THEN
                BEGIN
                    RAISE NOTICE 'ST_DifferenceAgg(): Had to buffer geometries by 0.000001 to compute the difference...';
                    differ = ST_Difference(ST_Buffer(geom1, 0.000001), ST_Buffer(geom3, 0.000001));
                EXCEPTION
                WHEN OTHERS THEN
                    BEGIN
                        RAISE NOTICE 'ST_DifferenceAgg(): Had to buffer geometries by 0.00001 to compute the difference...';
                        differ = ST_Difference(ST_Buffer(geom1, 0.00001), ST_Buffer(geom3, 0.00001));
                    EXCEPTION
                    WHEN OTHERS THEN
                        differ = geom1;
                    END;
                END;
            END;
            newgeom = CASE
                          WHEN ST_Area(ST_Intersection(geom1, geom3)) = 0 OR ST_IsEmpty(ST_Intersection(geom1, geom3)) THEN geom1
                          ELSE differ
                      END;
        ELSE
            newgeom = geom1;
        END IF;

        IF NOT ST_IsEmpty(newgeom) THEN
            newgeom = ST_CollectionExtract(newgeom, 3);
        END IF;

        IF newgeom IS NULL THEN
            newgeom = ST_GeomFromText('MULTIPOLYGON EMPTY', ST_SRID(geom2));
        END IF;

        RETURN newgeom;
    END;
$$;


--
-- TOC entry 1475 (class 1255 OID 26762)
-- Name: _st_removeoverlaps_finalfn(public.geomvaltxt[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_removeoverlaps_finalfn(gvtarray public.geomvaltxt[]) RETURNS public.geometry[]
    LANGUAGE sql
    AS $$
    WITH gvt AS (
         SELECT unnest(gvtarray) gvt
    ), geoms AS (
         SELECT ST_RemoveOverlaps(array_agg(((gvt).geom, (gvt).val)::geomval), max((gvt).txt)) geom
         FROM gvt
    )
    SELECT array_agg(geom) FROM geoms;
$$;


--
-- TOC entry 1472 (class 1255 OID 26759)
-- Name: _st_removeoverlaps_statefn(public.geomvaltxt[], public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry) RETURNS public.geomvaltxt[]
    LANGUAGE sql
    AS $_$
    SELECT _ST_RemoveOverlaps_StateFN($1, geom, NULL, 'NO_MERGE');
$_$;


--
-- TOC entry 1474 (class 1255 OID 26761)
-- Name: _st_removeoverlaps_statefn(public.geomvaltxt[], public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry, val double precision) RETURNS public.geomvaltxt[]
    LANGUAGE sql
    AS $_$
    SELECT _ST_RemoveOverlaps_StateFN($1, $2, $3, 'LARGEST_VALUE');
$_$;


--
-- TOC entry 1473 (class 1255 OID 26760)
-- Name: _st_removeoverlaps_statefn(public.geomvaltxt[], public.geometry, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry, mergemethod text) RETURNS public.geomvaltxt[]
    LANGUAGE sql
    AS $_$
    SELECT _ST_RemoveOverlaps_StateFN($1, $2, ST_Area($2), $3);
$_$;


--
-- TOC entry 1471 (class 1255 OID 26758)
-- Name: _st_removeoverlaps_statefn(public.geomvaltxt[], public.geometry, double precision, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry, val double precision, mergemethod text) RETURNS public.geomvaltxt[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        newgvtarray geomvaltxt[];
    BEGIN
        IF gvtarray IS NULL THEN
            RETURN array_append(newgvtarray, (geom, val, mergemethod)::geomvaltxt);
        END IF;
    RETURN array_append(gvtarray, (geom, val, mergemethod)::geomvaltxt);
    END;
$$;


--
-- TOC entry 1460 (class 1255 OID 26740)
-- Name: _st_splitagg_statefn(public.geometry[], public.geometry, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_splitagg_statefn(geomarray public.geometry[], geom1 public.geometry, geom2 public.geometry) RETURNS public.geometry[]
    LANGUAGE sql
    AS $_$
    SELECT _ST_SplitAgg_StateFN($1, $2, $3, 0.0);
$_$;


--
-- TOC entry 1459 (class 1255 OID 26739)
-- Name: _st_splitagg_statefn(public.geometry[], public.geometry, public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_splitagg_statefn(geomarray public.geometry[], geom1 public.geometry, geom2 public.geometry, tolerance double precision) RETURNS public.geometry[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        newgeomarray geometry[];
        geom3 geometry;
        newgeom geometry;
        geomunion geometry;
    BEGIN
        -- First pass: geomarray is NULL
       IF geomarray IS NULL THEN
            geomarray = array_append(newgeomarray, geom1);
        END IF;

        IF NOT geom2 IS NULL THEN
            -- 2) Each geometry in the array - geom2
            FOREACH geom3 IN ARRAY geomarray LOOP
                newgeom = ST_Difference(geom3, geom2);
                IF tolerance > 0 THEN
                    newgeom = ST_TrimMulti(newgeom, tolerance);
                END IF;
                IF NOT newgeom IS NULL AND NOT ST_IsEmpty(newgeom) THEN
                    newgeomarray = array_append(newgeomarray, newgeom);
                END IF;
            END LOOP;

        -- 3) gv1 intersecting each geometry in the array
            FOREACH geom3 IN ARRAY geomarray LOOP
                newgeom = ST_Intersection(geom3, geom2);
                IF tolerance > 0 THEN
                    newgeom = ST_TrimMulti(newgeom, tolerance);
                END IF;
                IF NOT newgeom IS NULL AND NOT ST_IsEmpty(newgeom) THEN
                    newgeomarray = array_append(newgeomarray, newgeom);
                END IF;
            END LOOP;
        ELSE
            newgeomarray = geomarray;
        END IF;
        RETURN newgeomarray;
    END;
$$;


--
-- TOC entry 1478 (class 1255 OID 28877)
-- Name: eimglx_raw_polys_multi(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.eimglx_raw_polys_multi(eimglx_table_name text) RETURNS TABLE(id integer, cat_liked integer, ct_disliked integer, geom public.geometry, area double precision, attnat integer, attopen integer, attorder integer, attupkeep integer, atthist integer)
    LANGUAGE plpgsql
    AS $$

BEGIN 
 RETURN QUERY EXECUTE 
	"SELECT 
		row_number() OVER () AS id,
		CASE WHEN a.eval_nr = 1 THEN 1 ELSE 0 END cat_liked,
		CASE WHEN a.eval_nr = 2 THEN 1 ELSE 0 END cat_disliked,
		unnest(ST_SplitAgg(a.geom, b.geom)) geom,
		ST_Area(ST_Transform( unnest(ST_SplitAgg(a.geom, b.geom)), 27493 )) area,
		a.att_nat attNat, a.att_open attOpen, 
		a.att_order attOrder, a.att_upkeep attUpkeep, a.att_hist attHist
	FROM "|| eimglx_table_name ||" a,
		 "|| eimglx_table_name ||" b
	WHERE ST_Equals(a.geom, b.geom) OR
		ST_Contains(a.geom, b.geom) OR
		ST_Contains(b.geom, a.geom) OR
		ST_Overlaps(a.geom, b.geom) AND
		(ST_isValid(a.geom) AND ST_isValid(b.geom))
	GROUP BY a.id, a.eval_nr , ST_AsEWKB(a.geom), attNat, attOpen, attOrder, attUpkeep, attHist";
	
END; $$;


--
-- TOC entry 1477 (class 1255 OID 28876)
-- Name: return_flatten_polygons(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.return_flatten_polygons(eimglx_table_name text) RETURNS TABLE(id integer, geom public.geometry, area bigint, category character varying, category_nr integer, ct_disliked integer, ct_nat integer, ct_ope integer, ct_ord integer, ct_upk integer, ct_his integer)
    LANGUAGE plpgsql
    AS $$

BEGIN 
 RETURN QUERY EXECUTE 
		"WITH  raw_polys_single AS 
		(
			WITH  raw_polys_multi AS 
			(
				SELECT 
					row_number() OVER () AS id,
					CASE WHEN a.eval_nr = 1 THEN 1 ELSE 0 END cat_liked,
					CASE WHEN a.eval_nr = 2 THEN 1 ELSE 0 END cat_disliked,
					unnest(ST_SplitAgg(a.geom, b.geom)) geom,
					ST_Area(ST_Transform( unnest(ST_SplitAgg(a.geom, b.geom)), 27493 )) area,
					a.att_nat attNat, a.att_open attOpen, 
					a.att_order attOrder, a.att_upkeep attUpkeep, a.att_hist attHist
				FROM "|| eimglx_table_name ||" a,
					 "|| eimglx_table_name ||" b
				WHERE ST_Equals(a.geom, b.geom) OR
					ST_Contains(a.geom, b.geom) OR
					ST_Contains(b.geom, a.geom) OR
					ST_Overlaps(a.geom, b.geom) AND
					(ST_isValid(a.geom) AND ST_isValid(b.geom))
				GROUP BY a.id, a.eval_nr , ST_AsEWKB(a.geom), attNat, attOpen, attOrder, attUpkeep, attHist
			)
			SELECT 
					row_number() OVER () AS id,
					ST_SnapToGrid((ST_Dump(raw_polys_multi.geom)).geom , 0.00001) geom,
					ST_Area(ST_Transform( (ST_Dump(raw_polys_multi.geom)).geom, 27493 )) area,
					id id_parent, cat_liked, cat_disliked, attNat, attOpen, attOrder, attUpkeep, attHist
			FROM raw_polys_multi
			WHERE raw_polys_multi.area > 10

		)
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
		FROM raw_polys_single
		WHERE raw_polys_single.area > 150
		GROUP BY ( ST_Area(ST_SnapToGrid( ST_Transform(geom,27493), 0.000001))*10 )::bigint
		ORDER BY area";
	
END; $$;


--
-- TOC entry 1476 (class 1255 OID 28875)
-- Name: return_flatten_polygons(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.return_flatten_polygons(eimglx_table_name character varying) RETURNS TABLE(id integer, geom public.geometry, area bigint, category character varying, category_nr integer, ct_disliked integer, ct_nat integer, ct_ope integer, ct_ord integer, ct_upk integer, ct_his integer)
    LANGUAGE plpgsql
    AS $$
BEGIN 
 RETURN QUERY EXECUTE 
		"WITH  raw_polys_single AS 
		(
			WITH  raw_polys_multi AS 
			(
				SELECT 
					row_number() OVER () AS id,
					CASE WHEN a.eval_nr = 1 THEN 1 ELSE 0 END cat_liked,
					CASE WHEN a.eval_nr = 2 THEN 1 ELSE 0 END cat_disliked,
					unnest(ST_SplitAgg(a.geom, b.geom)) geom,
					ST_Area(ST_Transform( unnest(ST_SplitAgg(a.geom, b.geom)), 27493 )) area,
					a.att_nat attNat, a.att_open attOpen, 
					a.att_order attOrder, a.att_upkeep attUpkeep, a.att_hist attHist
				FROM "|| eimglx_table_name ||" a,
					 "|| eimglx_table_name ||" b
				WHERE ST_Equals(a.geom, b.geom) OR
					ST_Contains(a.geom, b.geom) OR
					ST_Contains(b.geom, a.geom) OR
					ST_Overlaps(a.geom, b.geom) AND
					(ST_isValid(a.geom) AND ST_isValid(b.geom))
				GROUP BY a.id, a.eval_nr , ST_AsEWKB(a.geom), attNat, attOpen, attOrder, attUpkeep, attHist
			)
			SELECT 
					row_number() OVER () AS id,
					ST_SnapToGrid((ST_Dump(raw_polys_multi.geom)).geom , 0.00001) geom,
					ST_Area(ST_Transform( (ST_Dump(raw_polys_multi.geom)).geom, 27493 )) area,
					id id_parent, cat_liked, cat_disliked, attNat, attOpen, attOrder, attUpkeep, attHist
			FROM raw_polys_multi
			WHERE raw_polys_multi.area > 10

		)
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
		FROM raw_polys_single
		WHERE raw_polys_single.area > 150
		GROUP BY ( ST_Area(ST_SnapToGrid( ST_Transform(geom,27493), 0.000001))*10 )::bigint
		ORDER BY area";
	
END; $$;


--
-- TOC entry 1444 (class 1255 OID 26709)
-- Name: st_adduniqueid(name, name, boolean, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_adduniqueid(tablename name, columnname name, replacecolumn boolean DEFAULT false, indexit boolean DEFAULT true) RETURNS boolean
    LANGUAGE sql
    AS $_$
    SELECT ST_AddUniqueID('public', $1, $2, $3, $4)
$_$;


--
-- TOC entry 1443 (class 1255 OID 26708)
-- Name: st_adduniqueid(name, name, name, boolean, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_adduniqueid(schemaname name, tablename name, columnname name, replacecolumn boolean DEFAULT false, indexit boolean DEFAULT true) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    DECLARE
        seqname text;
        fqtn text;
    BEGIN
        IF replacecolumn IS NULL THEN
            replacecolumn = false;
        END IF;
        IF indexit IS NULL THEN
            indexit = true;
        END IF;
         -- Determine the complete name of the table
        fqtn := '';
        IF length(schemaname) > 0 THEN
            fqtn := quote_ident(schemaname) || '.';
        END IF;
        fqtn := fqtn || quote_ident(tablename);

        -- Check if the requested column name already exists
        IF ST_ColumnExists(schemaname, tablename, columnname) THEN
            IF replacecolumn THEN
                EXECUTE 'ALTER TABLE ' || fqtn || ' DROP COLUMN ' || columnname;
            ELSE
                RAISE NOTICE 'Column already exist. Set the ''replacecolumn'' argument to ''true'' if you want to replace the column.';
                RETURN false;
            END IF;
        END IF;

        -- Create a new sequence
        seqname = schemaname || '_' || tablename || '_seq';
        EXECUTE 'DROP SEQUENCE IF EXISTS ' || quote_ident(seqname);
        EXECUTE 'CREATE SEQUENCE ' || quote_ident(seqname);

        -- Add the new column and update it with nextval('sequence')
        EXECUTE 'ALTER TABLE ' || fqtn || ' ADD COLUMN ' || columnname || ' INTEGER';
        EXECUTE 'UPDATE ' || fqtn || ' SET ' || columnname || ' = nextval(''' || seqname || ''')';

        IF indexit THEN
            EXECUTE 'CREATE INDEX ' || tablename || '_' || columnname || '_idx ON ' || fqtn || ' USING btree(' || columnname || ');';
        END IF;

        RETURN true;
    END;
$$;


--
-- TOC entry 1389 (class 1255 OID 26735)
-- Name: st_bufferedsmooth(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_bufferedsmooth(geom public.geometry, bufsize double precision DEFAULT 0) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT ST_Buffer(ST_Buffer($1, $2), -$2)
$_$;


--
-- TOC entry 1441 (class 1255 OID 26704)
-- Name: st_columnexists(name, name); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_columnexists(tablename name, columnname name) RETURNS boolean
    LANGUAGE sql STRICT
    AS $_$
    SELECT ST_ColumnExists('public', $1, $2)
$_$;


--
-- TOC entry 1440 (class 1255 OID 26703)
-- Name: st_columnexists(name, name, name); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_columnexists(schemaname name, tablename name, columnname name) RETURNS boolean
    LANGUAGE plpgsql STRICT
    AS $$
    DECLARE
    BEGIN
        PERFORM 1 FROM information_schema.COLUMNS
        WHERE lower(table_schema) = lower(schemaname) AND lower(table_name) = lower(tablename) AND lower(column_name) = lower(columnname);
        RETURN FOUND;
    END;
$$;


--
-- TOC entry 1462 (class 1255 OID 26744)
-- Name: st_columnisunique(name, name); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_columnisunique(tablename name, columnname name) RETURNS boolean
    LANGUAGE sql STRICT
    AS $_$
    SELECT ST_ColumnIsUnique('public', $1, $2)
$_$;


--
-- TOC entry 1461 (class 1255 OID 26743)
-- Name: st_columnisunique(name, name, name); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_columnisunique(schemaname name, tablename name, columnname name) RETURNS boolean
    LANGUAGE plpgsql STRICT
    AS $$
    DECLARE
        newschemaname text;
        fqtn text;
        query text;
        isunique boolean;
    BEGIN
        newschemaname := '';
        IF length(schemaname) > 0 THEN
            newschemaname := schemaname;
        ELSE
            newschemaname := 'public';
        END IF;
        fqtn := quote_ident(newschemaname) || '.' || quote_ident(tablename);

        IF NOT ST_ColumnExists(newschemaname, tablename, columnname) THEN
            RAISE NOTICE 'ST_ColumnIsUnique(): Column ''%'' does not exist... Returning NULL', columnname;
            RETURN NULL;
        END IF;

        query = 'SELECT FALSE FROM ' || fqtn || ' GROUP BY ' || columnname || ' HAVING count(' || columnname || ') > 1 LIMIT 1';
        EXECUTE QUERY query INTO isunique;
        IF isunique IS NULL THEN
              isunique = TRUE;
        END IF;
        RETURN isunique;
    END;
$$;


--
-- TOC entry 1438 (class 1255 OID 26701)
-- Name: st_createindexraster(public.raster, text, integer, boolean, boolean, boolean, boolean, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_createindexraster(rast public.raster, pixeltype text DEFAULT '32BUI'::text, startvalue integer DEFAULT 0, incwithx boolean DEFAULT true, incwithy boolean DEFAULT true, rowsfirst boolean DEFAULT true, rowscanorder boolean DEFAULT true, colinc integer DEFAULT NULL::integer, rowinc integer DEFAULT NULL::integer) RETURNS public.raster
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        newraster raster := ST_AddBand(ST_MakeEmptyRaster(rast), pixeltype);
        x int;
        y int;
        w int := ST_Width(newraster);
        h int := ST_Height(newraster);
        rowincx int := Coalesce(rowinc, w);
        colincx int := Coalesce(colinc, h);
        rowincy int := Coalesce(rowinc, 1);
        colincy int := Coalesce(colinc, 1);
        xdir int := CASE WHEN Coalesce(incwithx, true) THEN 1 ELSE w END;
        ydir int := CASE WHEN Coalesce(incwithy, true) THEN 1 ELSE h END;
        xdflag int := Coalesce(incwithx::int, 1);
        ydflag int := Coalesce(incwithy::int, 1);
        rsflag int := Coalesce(rowscanorder::int, 1);
        newstartvalue int := Coalesce(startvalue, 0);
        newrowsfirst boolean := Coalesce(rowsfirst, true);
    BEGIN
        IF newrowsfirst THEN
            IF colincx <= (h - 1) * rowincy THEN
                RAISE EXCEPTION 'Column increment (now %) must be greater than the number of index on one column (now % pixel x % = %)...', colincx, h - 1, rowincy, (h - 1) * rowincy;
            END IF;
            --RAISE NOTICE 'abs([rast.x] - %) * % + abs([rast.y] - (% ^ ((abs([rast.x] - % + 1) % 2) | % # ))::int) * % + %', xdir::text, colincx::text, h::text, xdir::text, rsflag::text, ydflag::text, rowincy::text, newstartvalue::text;
            newraster = ST_SetBandNodataValue(
                          ST_MapAlgebra(newraster,
                                        pixeltype,
                                        'abs([rast.x] - ' || xdir::text || ') * ' || colincx::text ||
                                        ' + abs([rast.y] - (' || h::text || ' ^ ((abs([rast.x] - ' ||
                                        xdir::text || ' + 1) % 2) | ' || rsflag::text || ' # ' ||
                                        ydflag::text || '))::int) * ' || rowincy::text || ' + ' || newstartvalue::text),
                          ST_BandNodataValue(newraster)
                        );
        ELSE
            IF rowincx <= (w - 1) * colincy THEN
                RAISE EXCEPTION 'Row increment (now %) must be greater than the number of index on one row (now % pixel x % = %)...', rowincx, w - 1, colincy, (w - 1) * colincy;
            END IF;
            newraster = ST_SetBandNodataValue(
                          ST_MapAlgebra(newraster,
                                        pixeltype,
                                        'abs([rast.x] - (' || w::text || ' ^ ((abs([rast.y] - ' ||
                                        ydir::text || ' + 1) % 2) | ' || rsflag::text || ' # ' ||
                                        xdflag::text || '))::int) * ' || colincy::text || ' + abs([rast.y] - ' ||
                                        ydir::text || ') * ' || rowincx::text || ' + ' || newstartvalue::text),
                          ST_BandNodataValue(newraster)
                        );
        END IF;
        RETURN newraster;
    END;
$$;


--
-- TOC entry 1437 (class 1255 OID 26700)
-- Name: st_deleteband(public.raster, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_deleteband(rast public.raster, band integer) RETURNS public.raster
    LANGUAGE plpgsql
    AS $$
    DECLARE
        numband int := ST_NumBands(rast);
        bandarray int[];
    BEGIN
        IF rast IS NULL THEN
            RETURN NULL;
        END IF;
        IF band IS NULL OR band < 1 OR band > numband THEN
            RETURN rast;
        END IF;
        IF band = 1 AND numband = 1 THEN
            RETURN ST_MakeEmptyRaster(rast);
        END IF;

        -- Construct the array of band to extract skipping the band to delete
        SELECT array_agg(i) INTO bandarray
        FROM generate_series(1, numband) i
        WHERE i != band;

        RETURN ST_Band(rast, bandarray);
    END;
$$;


--
-- TOC entry 1449 (class 1255 OID 26723)
-- Name: st_extractpixelcentroidvalue4ma(double precision[], integer[], text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_extractpixelcentroidvalue4ma(pixel double precision[], pos integer[], VARIADIC args text[]) RETURNS double precision
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        pixelgeom text;
        result float4;
        query text;
    BEGIN
        -- args[1] = raster width
        -- args[2] = raster height
        -- args[3] = raster upperleft x
        -- args[4] = raster upperleft y
        -- args[5] = raster scale x
        -- args[6] = raster scale y
        -- args[7] = raster skew x
        -- args[8] = raster skew y
        -- args[9] = raster SRID
        -- args[10] = geometry or raster table schema name
        -- args[11] = geometry or raster table name
        -- args[12] = geometry or raster table geometry or raster column name
        -- args[13] = geometry table value column name
        -- args[14] = method

        -- Reconstruct the pixel centroid
        pixelgeom = ST_AsText(
                      ST_Centroid(
                        ST_PixelAsPolygon(
                          ST_MakeEmptyRaster(args[1]::integer,  -- raster width
                                             args[2]::integer,  -- raster height
                                             args[3]::float,    -- raster upperleft x
                                             args[4]::float,    -- raster upperleft y
                                             args[5]::float,    -- raster scale x
                                             args[6]::float,    -- raster scale y
                                             args[7]::float,    -- raster skew x
                                             args[8]::float,    -- raster skew y
                                             args[9]::integer   -- raster SRID
                                            ),
                                          pos[0][1]::integer, -- x coordinate of the current pixel
                                          pos[0][2]::integer  -- y coordinate of the current pixel
                                         )));

        -- Query the appropriate value
        IF args[14] = 'COUNT_OF_VALUES_AT_PIXEL_CENTROID' THEN
            query = 'SELECT count(' || quote_ident(args[13]) ||
                    ') FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ')';

        ELSEIF args[14] = 'MEAN_OF_VALUES_AT_PIXEL_CENTROID' THEN
            query = 'SELECT avg(' || quote_ident(args[13]) ||
                    ') FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ')';
        ----------------------------------------------------------------
        -- Methods for the ST_GlobalRasterUnion() function
        ----------------------------------------------------------------
        ELSEIF args[14] = 'COUNT_OF_RASTER_VALUES_AT_PIXEL_CENTROID' THEN
            query = 'SELECT count(ST_Value(' || quote_ident(args[12]) || ', ST_GeomFromText(' || quote_literal(pixelgeom) ||
                    ', ' || args[9] || ')))
                    FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ')';

        ELSEIF args[14] = 'FIRST_RASTER_VALUE_AT_PIXEL_CENTROID' THEN
            query = 'SELECT ST_Value(' || quote_ident(args[12]) || ', ST_GeomFromText(' || quote_literal(pixelgeom) ||
                    ', ' || args[9] || '))
                    FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ') LIMIT 1';

        ELSEIF args[14] = 'MIN_OF_RASTER_VALUES_AT_PIXEL_CENTROID' THEN
            query = 'SELECT min(ST_Value(' || quote_ident(args[12]) || ', ST_GeomFromText(' || quote_literal(pixelgeom) ||
                    ', ' || args[9] || ')))
                    FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ')';

        ELSEIF args[14] = 'MAX_OF_RASTER_VALUES_AT_PIXEL_CENTROID' THEN
            query = 'SELECT max(ST_Value(' || quote_ident(args[12]) || ', ST_GeomFromText(' || quote_literal(pixelgeom) ||
                    ', ' || args[9] || ')))
                    FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ')';

        ELSEIF args[14] = 'SUM_OF_RASTER_VALUES_AT_PIXEL_CENTROID' THEN
            query = 'SELECT sum(ST_Value(' || quote_ident(args[12]) || ', ST_GeomFromText(' || quote_literal(pixelgeom) ||
                    ', ' || args[9] || ')))
                    FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ')';

        ELSEIF args[14] = 'MEAN_OF_RASTER_VALUES_AT_PIXEL_CENTROID' THEN
            query = 'SELECT avg(ST_Value(' || quote_ident(args[12]) || ', ST_GeomFromText(' || quote_literal(pixelgeom) ||
                    ', ' || args[9] || ')))
                    FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ')';

        ELSEIF args[14] = 'STDDEVP_OF_RASTER_VALUES_AT_PIXEL_CENTROID' THEN
            query = 'SELECT stddev_pop(ST_Value(' || quote_ident(args[12]) || ', ST_GeomFromText(' || quote_literal(pixelgeom) ||
                    ', ' || args[9] || ')))
                    FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ')';

        ELSEIF args[14] = 'RANGE_OF_RASTER_VALUES_AT_PIXEL_CENTROID' THEN
            query = 'SELECT max(val) - min(val)
                     FROM (SELECT ST_Value(' || quote_ident(args[12]) || ', ST_GeomFromText(' || quote_literal(pixelgeom) ||
                    ', ' || args[9] || ')) val
                    FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                    quote_ident(args[12]) || ')) foo';

        ELSE
            query = 'SELECT NULL';
        END IF;
--RAISE NOTICE 'query = %', query;
        EXECUTE query INTO result;
        RETURN result;
    END;
$$;


--
-- TOC entry 1450 (class 1255 OID 26724)
-- Name: st_extractpixelvalue4ma(double precision[], integer[], text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_extractpixelvalue4ma(pixel double precision[], pos integer[], VARIADIC args text[]) RETURNS double precision
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        pixelgeom text;
        result float4;
        query text;
    BEGIN
        -- args[1] = raster width
        -- args[2] = raster height
        -- args[3] = raster upperleft x
        -- args[4] = raster upperleft y
        -- args[5] = raster scale x
        -- args[6] = raster scale y
        -- args[7] = raster skew x
        -- args[8] = raster skew y
        -- args[9] = raster SRID
        -- args[10] = geometry table schema name
        -- args[11] = geometry table name
        -- args[12] = geometry table geometry column name
        -- args[13] = geometry table value column name
        -- args[14] = method

--RAISE NOTICE 'val = %', pixel[1][1][1];
--RAISE NOTICE 'y = %, x = %', pos[0][1], pos[0][2];
        -- Reconstruct the pixel square
    pixelgeom = ST_AsText(
                  ST_PixelAsPolygon(
                    ST_MakeEmptyRaster(args[1]::integer, -- raster width
                                       args[2]::integer, -- raster height
                                       args[3]::float,   -- raster upperleft x
                                       args[4]::float,   -- raster upperleft y
                                       args[5]::float,   -- raster scale x
                                       args[6]::float,   -- raster scale y
                                       args[7]::float,   -- raster skew x
                                       args[8]::float,   -- raster skew y
                                       args[9]::integer  -- raster SRID
                                      ),
                                    pos[0][1]::integer, -- x coordinate of the current pixel
                                    pos[0][2]::integer  -- y coordinate of the current pixel
                                   ));
        -- Query the appropriate value
        IF args[14] = 'COUNT_OF_POLYGONS' THEN -- Number of polygons intersecting the pixel
            query = 'SELECT count(*) FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE (ST_GeometryType(' || quote_ident(args[12]) || ') = ''ST_Polygon'' OR
                             ST_GeometryType(' || quote_ident(args[12]) || ') = ''ST_MultiPolygon'') AND
                            ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                            || quote_ident(args[12]) || ') AND
                            ST_Area(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                            quote_ident(args[12]) || ')) > 0.0000000001';

        ELSEIF args[14] = 'COUNT_OF_LINESTRINGS' THEN -- Number of linestring intersecting the pixel
            query = 'SELECT count(*) FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE (ST_GeometryType(' || quote_ident(args[12]) || ') = ''ST_LineString'' OR
                             ST_GeometryType(' || quote_ident(args[12]) || ') = ''ST_MultiLineString'') AND
                             ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                             || quote_ident(args[12]) || ') AND
                             ST_Length(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), ' ||
                             quote_ident(args[12]) || ')) > 0.0000000001';

        ELSEIF args[14] = 'COUNT_OF_POINTS' THEN -- Number of points intersecting the pixel
            query = 'SELECT count(*) FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE (ST_GeometryType(' || quote_ident(args[12]) || ') = ''ST_Point'' OR
                             ST_GeometryType(' || quote_ident(args[12]) || ') = ''ST_MultiPoint'') AND
                             ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                             || quote_ident(args[12]) || ')';

        ELSEIF args[14] = 'COUNT_OF_GEOMETRIES' THEN -- Number of geometries intersecting the pixel
            query = 'SELECT count(*) FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                    || quote_ident(args[12]) || ')';

        ELSEIF args[14] = 'VALUE_OF_BIGGEST' THEN -- Value of the geometry covering the biggest area in the pixel
            query = 'SELECT ' || quote_ident(args[13]) ||
                    ' val FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                    || quote_ident(args[12]) ||
                    ') ORDER BY ST_Area(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '),
                                                        ' || quote_ident(args[12]) ||
                    ')) DESC, val DESC LIMIT 1';

        ELSEIF args[14] = 'VALUE_OF_MERGED_BIGGEST' THEN -- Value of the combined geometry covering the biggest area in the pixel
            query = 'SELECT val FROM (SELECT ' || quote_ident(args[13]) || ' val,
                                            sum(ST_Area(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom)
                                            || ', '|| args[9] || '), ' || quote_ident(args[12]) ||
                    '))) sumarea FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                    || quote_ident(args[12]) ||
                    ') GROUP BY val) foo ORDER BY sumarea DESC, val DESC LIMIT 1';

        ELSEIF args[14] = 'MIN_AREA' THEN -- Area of the geometry covering the smallest area in the pixel
            query = 'SELECT area FROM (SELECT ST_Area(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '
                                                      || args[9] || '), ' || quote_ident(args[12]) ||
                    ')) area FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                    || quote_ident(args[12]) ||
                    ')) foo WHERE area > 0.0000000001 ORDER BY area LIMIT 1';

        ELSEIF args[14] = 'VALUE_OF_MERGED_SMALLEST' THEN -- Value of the combined geometry covering the biggest area in the pixel
            query = 'SELECT val FROM (SELECT ' || quote_ident(args[13]) || ' val,
                                             sum(ST_Area(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '
                                             || args[9] || '), ' || quote_ident(args[12]) ||
                    '))) sumarea FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                    || quote_ident(args[12]) ||
                    ') AND ST_Area(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                                                                     || quote_ident(args[12]) || ')) > 0.0000000001
                      GROUP BY val) foo ORDER BY sumarea ASC, val DESC LIMIT 1';

        ELSEIF args[14] = 'SUM_OF_AREAS' THEN -- Sum of areas intersecting with the pixel (no matter the value)
            query = 'SELECT sum(ST_Area(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                                                                          || quote_ident(args[12]) ||
                    '))) sumarea FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                    || quote_ident(args[12]) ||
                    ')';

        ELSEIF args[14] = 'SUM_OF_LENGTHS' THEN -- Sum of lengths intersecting with the pixel (no matter the value)
            query = 'SELECT sum(ST_Length(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                                                                          || quote_ident(args[12]) ||
                    '))) sumarea FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                    || quote_ident(args[12]) ||
                    ')';

        ELSEIF args[14] = 'PROPORTION_OF_COVERED_AREA' THEN -- Proportion of the pixel covered by polygons (no matter the value)
            query = 'SELECT ST_Area(ST_Union(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                                                                               || quote_ident(args[12]) ||
                    ')))/ST_Area(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || ')) sumarea
                     FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                    ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                    || quote_ident(args[12]) ||
                    ')';

        ELSEIF args[14] = 'AREA_WEIGHTED_MEAN_OF_VALUES' THEN -- Mean of every geometry weighted by the area they cover
            query = 'SELECT CASE
                              WHEN sum(area) = 0 THEN 0
                              ELSE sum(area * val) /
                                   greatest(sum(area),
                                            ST_Area(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '))
                                           )
                            END
                     FROM (SELECT ' || quote_ident(args[13]) || ' val,
                                 ST_Area(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                                                         || quote_ident(args[12]) || ')) area
                           FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                         ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                         || quote_ident(args[12]) ||
                    ')) foo';

        ELSEIF args[14] = 'AREA_WEIGHTED_MEAN_OF_VALUES_2' THEN -- Mean of every geometry weighted by the area they cover
            query = 'SELECT CASE
                              WHEN sum(area) = 0 THEN 0
                              ELSE sum(area * val) / sum(area)
                            END
                     FROM (SELECT ' || quote_ident(args[13]) || ' val,
                                 ST_Area(ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                                                         || quote_ident(args[12]) || ')) area
                           FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                         ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                         || quote_ident(args[12]) ||
                    ')) foo';
        ----------------------------------------------------------------
        -- Methods for the ST_GlobalRasterUnion() function
        ----------------------------------------------------------------
        ELSEIF args[14] = 'AREA_WEIGHTED_SUM_OF_RASTER_VALUES' THEN -- Sum of every pixel value weighted by the area they cover
            query = 'SELECT sum(ST_Area((gv).geom) * (gv).val)
                     FROM (SELECT ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', ' ||
                                                                   args[9] || '), ' || quote_ident(args[12]) || ') gv
                           FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                         ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                         || quote_ident(args[12]) ||
                    ')) foo';

        ELSEIF args[14] = 'SUM_OF_AREA_PROPORTIONAL_RASTER_VALUES' THEN -- Sum of the proportion of pixel values intersecting with the pixel
            query = 'SELECT sum(ST_Area((gv).geom) * (gv).val / geomarea)
                     FROM (SELECT ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', ' ||
                                                                  args[9] || '), ' || quote_ident(args[12]) || ') gv, abs(ST_ScaleX(' || quote_ident(args[12]) || ') * ST_ScaleY(' || quote_ident(args[12]) || ')) geomarea
                           FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                         ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                         || quote_ident(args[12]) ||
                    ')) foo1';

        ELSEIF args[14] = 'AREA_WEIGHTED_MEAN_OF_RASTER_VALUES' THEN -- Mean of every pixel value weighted by the maximum area they cover
            query = 'SELECT CASE
                              WHEN sum(area) = 0 THEN NULL
                              ELSE sum(area * val) /
                                   greatest(sum(area),
                                            ST_Area(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '))
                                           )
                            END
                     FROM (SELECT ST_Area((gv).geom) area, (gv).val val
                           FROM (SELECT ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', ' ||
                                                                        args[9] || '), ' || quote_ident(args[12]) || ') gv
                                 FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                               ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                         || quote_ident(args[12]) ||
                    ')) foo1) foo2';

        ELSEIF args[14] = 'AREA_WEIGHTED_MEAN_OF_RASTER_VALUES_2' THEN -- Mean of every pixel value weighted by the area they cover
            query = 'SELECT CASE
                              WHEN sum(area) = 0 THEN NULL
                              ELSE sum(area * val) / sum(area)
                            END
                     FROM (SELECT ST_Area((gv).geom) area, (gv).val val
                           FROM (SELECT ST_Intersection(ST_GeomFromText(' || quote_literal(pixelgeom) || ', ' ||
                                                                        args[9] || '), ' || quote_ident(args[12]) || ') gv
                                 FROM ' || quote_ident(args[10]) || '.' || quote_ident(args[11]) ||
                               ' WHERE ST_Intersects(ST_GeomFromText(' || quote_literal(pixelgeom) || ', '|| args[9] || '), '
                         || quote_ident(args[12]) ||
                    ')) foo1) foo2';

        ELSE
            query = 'SELECT NULL';
        END IF;
--RAISE NOTICE 'query = %', query;
        EXECUTE query INTO result;
        RETURN result;
    END;
$$;


--
-- TOC entry 1454 (class 1255 OID 26729)
-- Name: st_extracttoraster(public.raster, name, name, name, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_extracttoraster(rast public.raster, schemaname name, tablename name, geomcolumnname name, method text DEFAULT 'MEAN_OF_VALUES_AT_PIXEL_CENTROID'::text) RETURNS public.raster
    LANGUAGE sql
    AS $_$
    SELECT ST_ExtractToRaster($1, 1, $2, $3, $4, NULL, $5)
$_$;


--
-- TOC entry 1453 (class 1255 OID 26728)
-- Name: st_extracttoraster(public.raster, integer, name, name, name, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_extracttoraster(rast public.raster, band integer, schemaname name, tablename name, geomcolumnname name, method text DEFAULT 'MEAN_OF_VALUES_AT_PIXEL_CENTROID'::text) RETURNS public.raster
    LANGUAGE sql
    AS $_$
    SELECT ST_ExtractToRaster($1, $2, $3, $4, $5, NULL, $6)
$_$;


--
-- TOC entry 1452 (class 1255 OID 26727)
-- Name: st_extracttoraster(public.raster, name, name, name, name, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_extracttoraster(rast public.raster, schemaname name, tablename name, geomcolumnname name, valuecolumnname name, method text DEFAULT 'MEAN_OF_VALUES_AT_PIXEL_CENTROID'::text) RETURNS public.raster
    LANGUAGE sql
    AS $_$
    SELECT ST_ExtractToRaster($1, 1, $2, $3, $4, $5, $6)
$_$;


--
-- TOC entry 1451 (class 1255 OID 26726)
-- Name: st_extracttoraster(public.raster, integer, name, name, name, name, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_extracttoraster(rast public.raster, band integer, schemaname name, tablename name, geomrastcolumnname name, valuecolumnname name, method text DEFAULT 'MEAN_OF_VALUES_AT_PIXEL_CENTROID'::text) RETURNS public.raster
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
    DECLARE
        query text;
        newrast raster;
        fct2call text;
        newvaluecolumnname text;
        intcount int;
    BEGIN
        -- Determine the name of the right callback function
        IF right(method, 5) = 'TROID' THEN
            fct2call = 'ST_ExtractPixelCentroidValue4ma';
        ELSE
            fct2call = 'ST_ExtractPixelValue4ma';
        END IF;

        IF valuecolumnname IS NULL THEN
            newvaluecolumnname = 'null';
        ELSE
            newvaluecolumnname = quote_literal(valuecolumnname);
        END IF;

        query = 'SELECT count(*) FROM "' || schemaname || '"."' || tablename || '" WHERE ST_Intersects($1, ' || geomrastcolumnname || ')';

        EXECUTE query INTO intcount USING rast;
        IF intcount = 0 THEN
            -- if the method should return 0 when there is no geometry involved, return a raster containing only zeros
            IF left(method, 6) = 'COUNT_' OR
               method = 'SUM_OF_AREAS' OR
               method = 'SUM_OF_LENGTHS' OR
               method = 'PROPORTION_OF_COVERED_AREA' THEN
                RETURN ST_AddBand(ST_DeleteBand(rast, band), ST_AddBand(ST_MakeEmptyRaster(rast), ST_BandPixelType(rast, band), 0, ST_BandNodataValue(rast, band)), 1, band);
            ELSE
                RETURN ST_AddBand(ST_DeleteBand(rast, band), ST_AddBand(ST_MakeEmptyRaster(rast), ST_BandPixelType(rast, band), ST_BandNodataValue(rast, band), ST_BandNodataValue(rast, band)), 1, band);
            END IF;
        END IF;

        query = 'SELECT ST_MapAlgebra($1,
                                      $2,
                                      ''' || fct2call || '(double precision[], integer[], text[])''::regprocedure,
                                      ST_BandPixelType($1, $2),
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      ST_Width($1)::text,
                                      ST_Height($1)::text,
                                      ST_UpperLeftX($1)::text,
                                      ST_UpperLeftY($1)::text,
                                      ST_ScaleX($1)::text,
                                      ST_ScaleY($1)::text,
                                      ST_SkewX($1)::text,
                                      ST_SkewY($1)::text,
                                      ST_SRID($1)::text,' ||
                                      quote_literal(schemaname) || ', ' ||
                                      quote_literal(tablename) || ', ' ||
                                      quote_literal(geomrastcolumnname) || ', ' ||
                                      newvaluecolumnname || ', ' ||
                                      quote_literal(upper(method)) || '
                                     ) rast';
--RAISE NOTICE 'query = %', query;
        EXECUTE query INTO newrast USING rast, band;
        RETURN ST_AddBand(ST_DeleteBand(rast, band), newrast, 1, band);
    END
$_$;


--
-- TOC entry 1463 (class 1255 OID 26745)
-- Name: st_geotablesummary(name, name, name, name, integer, text[], text[], text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_geotablesummary(schemaname name, tablename name, geomcolumnname name DEFAULT 'geom'::name, uidcolumn name DEFAULT NULL::name, nbinterval integer DEFAULT 10, dosummary text[] DEFAULT NULL::text[], skipsummary text[] DEFAULT NULL::text[], whereclause text DEFAULT NULL::text) RETURNS TABLE(summary text, idsandtypes text, countsandareas double precision, query text, geom public.geometry)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        fqtn text;
        query text;
        newschemaname name;
        summary text;
        vertex_summary record;
        area_summary record;
        findnewuidcolumn boolean := FALSE;
        newuidcolumn text;
        newuidcolumntype text;
        createidx boolean := FALSE;
        uidcolumncnt int := 0;
        whereclausewithwhere text := '';
        sval text[] = ARRAY['S1', 'IDDUP', 'S2', 'GDUP', 'GEODUP', 'S3', 'OVL', 'S4', 'GAPS', 'S5', 'TYPES', 'GTYPES', 'GEOTYPES', 'S6', 'VERTX', 'S7', 'VHISTO', 'S8', 'AREAS', 'AREA', 'S9', 'AHISTO', 'S10', 'SACOUNT', 'ALL'];
        dos1 text[] = ARRAY['S1', 'IDDUP', 'ALL'];
        dos2 text[] = ARRAY['S2', 'GDUP', 'GEODUP', 'ALL'];
        dos3 text[] = ARRAY['S3', 'OVL', 'ALL'];
        dos4 text[] = ARRAY['S4', 'GAPS', 'ALL'];
        dos5 text[] = ARRAY['S5', 'TYPES', 'GTYPES', 'GEOTYPES', 'ALL'];
        dos6 text[] = ARRAY['S6', 'VERTX', 'NPOINTS', 'ALL'];
        dos7 text[] = ARRAY['S7', 'VHISTO', 'ALL'];
        dos8 text[] = ARRAY['S8', 'AREAS', 'AREA', 'ALL'];
        dos9 text[] = ARRAY['S9', 'AHISTO', 'ALL'];
        dos10 text[] = ARRAY['S10', 'SACOUNT', 'ALL'];
        provided_uid_isunique boolean = FALSE;
        colnamearr text[];
        colnamearrlength int := 0;
        colnameidx int := 0;
        sum7nbinterval int;
        sum9nbinterval int;
        minarea double precision := 0;
        maxarea double precision := 0;
        minnp int := 0;
        maxnp int := 0;
        bydefault text;
    BEGIN
        IF geomcolumnname IS NULL THEN
            geomcolumnname = 'geom';
        END IF;
        IF nbinterval IS NULL THEN
            nbinterval = 10;
        END IF;
        IF whereclause IS NULL OR whereclause = '' THEN
            whereclause = '';
        ELSE
            whereclausewithwhere = ' WHERE ' || whereclause || ' ';
            whereclause = ' AND (' || whereclause || ')';
        END IF;
        newschemaname := '';
        IF length(schemaname) > 0 THEN
            newschemaname := schemaname;
        ELSE
            newschemaname := 'public';
        END IF;
        fqtn := quote_ident(newschemaname) || '.' || quote_ident(tablename);

        -- Validate the dosummary parameter
        IF (NOT dosummary IS NULL) THEN
            FOR i IN array_lower(dosummary, 1)..array_upper(dosummary, 1) LOOP
               dosummary[i] := upper(dosummary[i]);
            END LOOP;
            FOREACH summary IN ARRAY dosummary LOOP
                IF (NOT summary = ANY (sval)) THEN
                    RAISE EXCEPTION 'Invalid value ''%'' for the ''dosummary'' parameter...', summary;
                    RETURN;
                    EXIT;
                END IF;
            END LOOP;
        END IF;
        IF (NOT skipsummary IS NULL) THEN
            FOR i IN array_lower(skipsummary, 1)..array_upper(skipsummary, 1) LOOP
               skipsummary[i] := upper(skipsummary[i]);
            END LOOP;
            FOREACH summary IN ARRAY skipsummary LOOP
                IF (NOT summary = ANY (sval)) THEN
                    RAISE EXCEPTION 'Invalid value ''%'' for the ''skipsummary'' parameter...', summary;
                    RETURN;
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        newuidcolumn = lower(uidcolumn);
        IF newuidcolumn IS NULL THEN
            newuidcolumn = 'id';
        END IF;

        -----------------------------------------------
        -- Display the number of rows selected
        query = 'SELECT  ''NUMBER OF ROWS SELECTED''::text summary, ''''::text idsandtypes, count(*)::double precision countsandareas, ''query''::text, NULL::geometry geom  FROM ' || fqtn || whereclausewithwhere;
        RETURN QUERY EXECUTE query;
        -----------------------------------------------
        -- Summary #1: Check for duplicate IDs (IDDUP)
        IF (dosummary IS NULL OR dosummary && dos1) AND (skipsummary IS NULL OR NOT (skipsummary && dos1)) THEN
            query = E'SELECT 1::text summary,\n'
                 || E'       ' || newuidcolumn || E'::text idsandtypes,\n'
                 || E'       count(*)::double precision countsandareas,\n'
                 || E'       ''SELECT * FROM ' || fqtn || ' WHERE ' || newuidcolumn || ' = '' || ' || newuidcolumn || E' || '';''::text query,\n'
                 || E'       NULL::geometry geom\n'
                 || E'FROM ' || fqtn || E'\n'
                 || ltrim(whereclausewithwhere) || CASE WHEN whereclausewithwhere = '' THEN '' ELSE E'\n' END
                 || E'GROUP BY ' || newuidcolumn || E'\n'
                 || E'HAVING count(*) > 1\n'
                 || E'ORDER BY countsandareas DESC;';

            RETURN QUERY SELECT 'SUMMARY 1 - DUPLICATE IDs (IDDUP or S1)'::text, ('DUPLICATE IDs (' || newuidcolumn::text || ')')::text, NULL::double precision, query, NULL::geometry;
            RAISE NOTICE 'Summary 1 - Duplicate IDs (IDDUP or S1)...';

            IF ST_ColumnExists(newschemaname, tablename, newuidcolumn) THEN
                EXECUTE 'SELECT pg_typeof(' || newuidcolumn || ') FROM ' || fqtn || ' LIMIT 1' INTO newuidcolumntype;
                IF newuidcolumntype != 'geometry' AND newuidcolumntype != 'raster' THEN
                    RETURN QUERY EXECUTE query;
                    IF NOT FOUND THEN
                        RETURN QUERY SELECT '1'::text, 'No duplicate IDs...'::text, NULL::double precision, NULL::text, NULL::geometry;
                        provided_uid_isunique = TRUE;
                    END IF;
                ELSE
                    RETURN QUERY SELECT '1'::text, '''' || newuidcolumn::text || ''' is not of type numeric or text... Skipping Summary 1'::text, NULL::double precision, NULL::text, NULL::geometry;
                END IF;
            ELSE
                RETURN QUERY SELECT '1'::text, '''' || newuidcolumn::text || ''' does not exists... Skipping Summary 1'::text, NULL::double precision, NULL::text, NULL::geometry;
            END IF;
        ELSE
            RETURN QUERY SELECT 'SUMMARY 1 - DUPLICATE IDs (IDDUP or S1)'::text, 'SKIPPED'::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 1 - Skipping Duplicate IDs (IDDUP or S1)...';
        END IF;

        -----------------------------------------------
        -- Add a unique id column if it does not exists or if the one provided is not unique
        IF (dosummary IS NULL OR dosummary && dos2 OR dosummary && dos3 OR dosummary && dos4) AND (skipsummary IS NULL OR NOT (skipsummary && dos2 AND skipsummary && dos3 AND skipsummary && dos4)) THEN

            RAISE NOTICE 'Searching for the first column containing unique values...';

            -- Construct the list of available column names (integer only)
            query = 'SELECT array_agg(column_name::text) FROM information_schema.columns WHERE table_schema = ''' || newschemaname || ''' AND table_name = ''' || tablename || ''' AND data_type = ''integer'';';
            EXECUTE query INTO colnamearr;
            colnamearrlength = array_length(colnamearr, 1);

            RAISE NOTICE '  Checking ''%''...', newuidcolumn;

            -- Search for a unique id. Search first for 'id', if no uidcolumn name is provided, or for the provided name, then the list of available column names
            WHILE (ST_ColumnExists(newschemaname, tablename, newuidcolumn) OR (newuidcolumn = 'id' AND uidcolumn IS NULL)) AND
                  NOT provided_uid_isunique AND
                  (ST_ColumnIsUnique(newschemaname, tablename, newuidcolumn) IS NULL OR NOT ST_ColumnIsUnique(newschemaname, tablename, newuidcolumn)) LOOP
                IF uidcolumn IS NULL AND colnameidx < colnamearrlength THEN
                    colnameidx = colnameidx + 1;
                    RAISE NOTICE '  ''%'' is not unique. Checking ''%''...', newuidcolumn, colnamearr[colnameidx]::text;
                    newuidcolumn = colnamearr[colnameidx];
                ELSE
                    IF upper(left(newuidcolumn, 2)) != 'ID' AND upper(newuidcolumn) != 'ID' THEN
                        RAISE NOTICE '  ''%'' is not unique. Creating ''id''...', newuidcolumn;
                        newuidcolumn = 'id';
                        uidcolumn = newuidcolumn;
                    ELSE
                        uidcolumncnt = uidcolumncnt + 1;
                        RAISE NOTICE '  ''%'' is not unique. Checking ''%''...', newuidcolumn, newuidcolumn || '_' || uidcolumncnt::text;
                        newuidcolumn = newuidcolumn || '_' || uidcolumncnt::text;
                    END IF;
                END IF;
            END LOOP;

            IF NOT ST_ColumnExists(newschemaname, tablename, newuidcolumn) THEN
                RAISE NOTICE '  Adding new unique column ''%''...', newuidcolumn;

                --EXECUTE 'DROP SEQUENCE IF EXISTS ' || quote_ident(newschemaname || '_' || tablename || '_seq');
                --EXECUTE 'CREATE SEQUENCE ' || quote_ident(newschemaname || '_' || tablename || '_seq');

                -- Add the new column and update it with nextval('sequence')
                --EXECUTE 'ALTER TABLE ' || fqtn || ' ADD COLUMN ' || newuidcolumn || ' INTEGER';
                --EXECUTE 'UPDATE ' || fqtn || ' SET ' || newuidcolumn || ' = nextval(''' || newschemaname || '_' || tablename || '_seq' || ''')';

                --EXECUTE 'CREATE INDEX ON ' || fqtn || ' USING btree(' || newuidcolumn || ');';

                query = 'SELECT ST_AddUniqueID(''' || newschemaname || ''', ''' || tablename || ''', ''' || newuidcolumn || ''', NULL, true);';
                EXECUTE query;
            ELSE
               RAISE NOTICE '  Column ''%'' exists and is unique...', newuidcolumn;
            END IF;

            -- Create a temporary unique index
            IF NOT ST_HasBasicIndex(newschemaname, tablename, newuidcolumn) THEN
                RAISE NOTICE '  Creating % index on ''%''...', (CASE WHEN whereclausewithwhere = '' THEN 'an' ELSE 'a partial' END), newuidcolumn;
                EXECUTE 'CREATE INDEX ON ' || fqtn || ' USING btree (' || newuidcolumn || ')' || whereclausewithwhere || ';';
            END IF;
        END IF;

        -----------------------------------------------
        -- Summary #2: Check for duplicate geometries (GDUP, GEODUP)
        IF (dosummary IS NULL OR dosummary && dos2) AND (skipsummary IS NULL OR NOT (skipsummary && dos2)) THEN
                query = E'SELECT 2::text summary,\n'
                     || E'       id idsandtypes,\n'
                     || E'       cnt::double precision countsandareas,\n'
                     || E'       (''SELECT * FROM ' || fqtn || ' WHERE ' || newuidcolumn || E' = ANY(ARRAY['' || id || '']);'')::text query,\n'
                     || E'       geom\n'
                     || E'FROM (SELECT string_agg(' || newuidcolumn || '::text, '', ''::text ORDER BY ' || newuidcolumn || E') id,\n'
                     || E'             count(*) cnt,\n'
                     || E'             ST_AsEWKB(' ||              geomcolumnname || E')::geometry geom\n'
                     || E'      FROM ' || fqtn || E'\n'
                     || E'    ' || ltrim(whereclausewithwhere) || CASE WHEN whereclausewithwhere = '' THEN '' ELSE E'\n' END
                     || E'      GROUP BY ST_AsEWKB(' || geomcolumnname || E')) foo\n'
                     || E'WHERE cnt > 1\n'
                     || E'ORDER BY cnt DESC;';

                RETURN QUERY SELECT 'SUMMARY 2 - DUPLICATE GEOMETRIES (GDUP, GEODUP or S2)'::text, ('DUPLICATE GEOMETRIES IDS (' || newuidcolumn || ')')::text, NULL::double precision, query, NULL::geometry;
                RAISE NOTICE 'Summary 2 - Duplicate geometries (GDUP, GEODUP or S2)...';

                IF ST_ColumnExists(newschemaname, tablename, geomcolumnname) THEN
                    RETURN QUERY EXECUTE query;
                    IF NOT FOUND THEN
                        RETURN QUERY SELECT '2'::text, 'No duplicate geometries...'::text, NULL::double precision, NULL::text, NULL::geometry;
                    END IF;
                ELSE
                    RETURN QUERY SELECT '2'::text, '''' || geomcolumnname::text || ''' does not exists... Skipping Summary 2'::text, NULL::double precision, NULL::text, NULL::geometry;
                END IF;
            ELSE
            RETURN QUERY SELECT 'SUMMARY 2 - DUPLICATE GEOMETRIES (GDUP, GEODUP or S2)'::text, 'SKIPPED'::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 2 - Skipping Duplicate geometries (GDUP, GEODUP or S2)...';
        END IF;

        -----------------------------------------------
        -- Summary #3: Check for overlaps (OVL) - Skipped by default
        IF (dosummary && dos3) AND (skipsummary IS NULL OR NOT (skipsummary && dos3)) THEN
            query = E'SELECT 3::text summary,\n'
                 || E'       a.' || newuidcolumn || '::text || '', '' || b.' || newuidcolumn || E'::text idsandtypes,\n'
                 || E'       ST_Area(ST_Intersection(a.' || geomcolumnname || ', b.' || geomcolumnname || E')) countsandareas,\n'
                 || E'       ''SELECT * FROM ' || fqtn || ' WHERE ' || newuidcolumn || ' = ANY(ARRAY['' || a.' || newuidcolumn || ' || '', '' || b.' || newuidcolumn || E' || '']);''::text query,\n'
                 || E'       ST_CollectionExtract(ST_Intersection(a.' || geomcolumnname || ', b.' || geomcolumnname || E'), 3) geom\n'
                 || E'FROM (SELECT * FROM ' || fqtn || whereclausewithwhere || E') a,\n'
                 || E'     ' || fqtn || E' b\n'
                 || E'WHERE a.' || newuidcolumn || ' < b.' || newuidcolumn || E' AND\n'
                 || E'      (ST_Overlaps(a.' || geomcolumnname || ', b.' || geomcolumnname || E') OR\n'
                 || E'       ST_Contains(a.' || geomcolumnname || ', b.' || geomcolumnname || E') OR\n'
                 || E'       ST_Contains(b.' || geomcolumnname || ', a.' || geomcolumnname || E')) AND\n'
                 || E'       ST_Area(ST_Intersection(a.' || geomcolumnname || ', b.' || geomcolumnname || E')) > 0\n'
                 || E'ORDER BY ST_Area(ST_Intersection(a.' || geomcolumnname || ', b.' || geomcolumnname || ')) DESC;';

            RETURN QUERY SELECT 'SUMMARY 3 - OVERLAPPING GEOMETRIES (OVL or S3)'::text, ('OVERLAPPING GEOMETRIES IDS (' || newuidcolumn || ')')::text, NULL::double precision, query, NULL::geometry;
            RAISE NOTICE 'Summary 3 - Overlapping geometries (OVL or S3)...';

            IF ST_ColumnExists(newschemaname, tablename, geomcolumnname) THEN
                -- Create a temporary unique index
                IF NOT ST_HasBasicIndex(newschemaname, tablename, geomcolumnname) THEN
                    RAISE NOTICE '            Creating % spatial index on ''%''...', (CASE WHEN whereclausewithwhere = '' THEN 'a' ELSE 'a partial' END), geomcolumnname;
                    EXECUTE 'CREATE INDEX ON ' || fqtn || ' USING gist (' || geomcolumnname || ')' || whereclausewithwhere || ';';
                END IF;

                RAISE NOTICE '            Computing overlaps...';
                BEGIN
                    RETURN QUERY EXECUTE query;
                    IF NOT FOUND THEN
                        RETURN QUERY SELECT '3'::text, 'No overlapping geometries...'::text, NULL::double precision, NULL::text, NULL::geometry;
                    END IF;
                EXCEPTION
                WHEN OTHERS THEN
                    RETURN QUERY SELECT '3'::text, 'ERROR: Consider fixing invalid geometries and convert ST_GeometryCollection before testing for overlaps...'::text, NULL::double precision, NULL::text, NULL::geometry;
                END;
            ELSE
                RETURN QUERY SELECT '3'::text, '''' || geomcolumnname::text || ''' does not exists... Skipping Summary 3'::text, NULL::double precision, NULL::text, NULL::geometry;
            END IF;
        ELSE
            bydefault = '';
            IF dosummary IS NULL AND (skipsummary IS NULL OR NOT (skipsummary && dos3)) THEN
               bydefault = ' BY DEFAULT';
            END IF;

            RETURN QUERY SELECT 'SUMMARY 3 - OVERLAPPING GEOMETRIES (OVL or S3)'::text, ('SKIPPED' || bydefault)::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 3 - Skipping Overlapping geometries (OVL or S3)...';
        END IF;

        -----------------------------------------------
        -- Summary #4: Check for gaps (GAPS) - Skipped by default
        IF (dosummary && dos4) AND (skipsummary IS NULL OR NOT (skipsummary && dos4)) THEN
            query = E'SELECT 4::text summary,\n'
                 || E'       (ROW_NUMBER() OVER (PARTITION BY true ORDER BY ST_Area(' || geomcolumnname || E') DESC))::text idsandtypes,\n'
                 || E'       ST_Area(' || geomcolumnname || E') countsandareas,\n'
                 || E'       ''SELECT * FROM ' || fqtn || E' WHERE ' || newuidcolumn || E' = ANY(ARRAY['' || (SELECT string_agg(a.' || newuidcolumn || E'::text, '', '') FROM ' || fqtn || E' a WHERE ST_Intersects(ST_Buffer(foo.' || geomcolumnname || E', 0.000001), a.' || geomcolumnname || E')) || '']);''::text query,\n'
                 || E'       ' || geomcolumnname || E' geom\n'
                 || E'FROM (SELECT ST_Buffer(ST_SetSRID(ST_Extent(' || geomcolumnname || E')::geometry, min(ST_SRID(' || geomcolumnname || E'))), 0.01) buffer,\n'
                 || E'             (ST_Dump(ST_Difference(ST_Buffer(ST_SetSRID(ST_Extent(' || geomcolumnname || E')::geometry, min(ST_SRID(' || geomcolumnname || E'))), 0.01), ST_Union(' || geomcolumnname || E')))).*\n'
                 || E'      FROM ' || fqtn || whereclausewithwhere || E') foo\n'
                 || E'WHERE NOT ST_Intersects(geom, ST_ExteriorRing(buffer)) AND ST_Area(geom) > 0\n'
                 || E'ORDER BY countsandareas DESC;';

            RETURN QUERY SELECT 'SUMMARY 4 - GAPS (GAPS or S4)'::text, ('GAPS IDS (generated on the fly)')::text, NULL::double precision, query, NULL::geometry;
            RAISE NOTICE 'Summary 4 - Gaps (GAPS or S4)...';

            IF ST_ColumnExists(newschemaname, tablename, geomcolumnname) THEN
                RAISE NOTICE '            Computing gaps...';
                BEGIN
                    RETURN QUERY EXECUTE query;
                    IF NOT FOUND THEN
                        RETURN QUERY SELECT '4'::text, 'No gaps...'::text, NULL::double precision, NULL::text, NULL::geometry;
                    END IF;
                EXCEPTION
                WHEN OTHERS THEN
                    RETURN QUERY SELECT '4'::text, 'ERROR: Consider fixing invalid geometries and convert ST_GeometryCollection before testing for gaps...'::text, NULL::double precision, NULL::text, NULL::geometry;
                END;
            ELSE
                RETURN QUERY SELECT '4'::text, '''' || geomcolumnname::text || ''' does not exists... Skipping Summary 4'::text, NULL::double precision, NULL::text, NULL::geometry;
            END IF;
        ELSE
            bydefault = '';
            IF dosummary IS NULL AND (skipsummary IS NULL OR NOT (skipsummary && dos4)) THEN
               bydefault = ' BY DEFAULT';
            END IF;

            RETURN QUERY SELECT 'SUMMARY 4 - GAPS (GAPS or S4)'::text, ('SKIPPED' || bydefault)::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 4 - Skipping Gaps (GAPS or S4)...';
        END IF;

        -----------------------------------------------
        -- Summary #5: Check for number of NULL, INVALID, EMPTY, POINTS, LINESTRING, POLYGON, MULTIPOINT, MULTILINESTRING, MULTIPOLYGON, GEOMETRYCOLLECTION (TYPES)
        IF (dosummary IS NULL OR dosummary && dos5) AND (skipsummary IS NULL OR NOT (skipsummary && dos5)) THEN
            query = E'SELECT 5::text summary,\n'
                 || E'       CASE WHEN ST_GeometryType(' || geomcolumnname || E') IS NULL THEN ''NULL''\n'
                 || E'            WHEN ST_IsEmpty(' || geomcolumnname || ') THEN ''EMPTY '' || ST_GeometryType(' || geomcolumnname || E')\n'
                 || E'            WHEN NOT ST_IsValid(' || geomcolumnname || ') THEN ''INVALID '' || ST_GeometryType(' || geomcolumnname || E')\n'
                 || E'            ELSE ST_GeometryType(' || geomcolumnname || E')\n'
                 || E'       END idsandtypes,\n'
                 || E'       count(*)::double precision countsandareas,\n'
                 || E'       CASE WHEN ST_GeometryType(' || geomcolumnname || E') IS NULL\n'
                 || E'                 THEN ''SELECT * FROM ' || fqtn || ' WHERE ' || geomcolumnname || ' IS NULL' || whereclause || E';''\n'
                 || E'            WHEN ST_IsEmpty(' || geomcolumnname || E')\n'
                 || E'                 THEN ''SELECT * FROM ' || fqtn || ' WHERE ST_IsEmpty(' || geomcolumnname || ') AND ST_GeometryType(' || geomcolumnname || ') = '''''' || ST_GeometryType(' || geomcolumnname || ') || ''''''' || whereclause || E';''\n'
                 || E'            WHEN NOT ST_IsValid(' || geomcolumnname || E')\n'
                 || E'                 THEN ''SELECT * FROM ' || fqtn || ' WHERE NOT ST_IsValid(' || geomcolumnname || ') AND ST_GeometryType(' || geomcolumnname || ') = '''''' || ST_GeometryType(' || geomcolumnname || ') || ''''''' || whereclause || E';''\n'
                 || E'            ELSE ''SELECT * FROM ' || fqtn || ' WHERE ST_IsValid(' || geomcolumnname || ') AND NOT ST_IsEmpty(' || geomcolumnname || ') AND ST_GeometryType(' || geomcolumnname || ') = '''''' || ST_GeometryType(' || geomcolumnname || ') || ''''''' || whereclause || E';''\n'
                 || E'       END::text query,\n'
                 || E'       NULL::geometry geom\n'
                 || E'FROM ' || fqtn || E'\n'
                 || ltrim(whereclausewithwhere) || CASE WHEN whereclausewithwhere = '' THEN '' ELSE E'\n' END
                 || E'GROUP BY ST_IsValid(' || geomcolumnname || '), ST_IsEmpty(' || geomcolumnname || '), ST_GeometryType(' || geomcolumnname || E')\n'
                 || E'ORDER BY ST_GeometryType(' || geomcolumnname || ') DESC, NOT ST_IsValid(' || geomcolumnname || '), ST_IsEmpty(' || geomcolumnname || ');';

            RETURN QUERY SELECT 'SUMMARY 5 - GEOMETRY TYPES (TYPES or S5)'::text, 'TYPES'::text, NULL::double precision, query, NULL::geometry;
            RAISE NOTICE 'Summary 5 - Geometry types (TYPES or S5)...';
            IF ST_ColumnExists(newschemaname, tablename, geomcolumnname) THEN
                RETURN QUERY EXECUTE query;
                IF NOT FOUND THEN
                    RETURN QUERY SELECT '5'::text, 'No row selected...'::text, NULL::double precision, NULL::text, NULL::geometry;
                END IF;
            ELSE
                RETURN QUERY SELECT '5'::text, '''' || geomcolumnname::text || ''' does not exists... Skipping Summary 5'::text, NULL::double precision, NULL::text, NULL::geometry;
            END IF;
        ELSE
            RETURN QUERY SELECT 'SUMMARY 5 - GEOMETRY TYPES (TYPES or S5)'::text, 'SKIPPED'::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 5 - Skipping Geometry types (TYPES or S5)...';
        END IF;

        -----------------------------------------------
        -- Create an index on ST_NPoints(geom) if necessary so further queries are executed faster
        IF (dosummary IS NULL OR dosummary && dos6 OR dosummary && dos7) AND (skipsummary IS NULL OR NOT (skipsummary && dos6 AND skipsummary && dos7)) AND
           ST_ColumnExists(newschemaname, tablename, geomcolumnname) AND
           NOT ST_HasBasicIndex(newschemaname, tablename, NULL, 'st_npoints'::text) THEN
            RAISE NOTICE 'Creating % index on ''ST_NPoints(%)''...', (CASE WHEN whereclausewithwhere = '' THEN 'an' ELSE 'a partial' END), geomcolumnname;
            query = 'CREATE INDEX ' || left(tablename || '_' || geomcolumnname, 48) || '_st_npoints_idx ON ' || fqtn || ' USING btree (ST_NPoints(' || geomcolumnname || '))' || whereclausewithwhere || ';';
            EXECUTE query;
        END IF;

        -----------------------------------------------
        -- Summary #6: Check for polygon complexity - min number of vertexes, max number of vertexes, mean number of vertexes (VERTX).
        IF (dosummary IS NULL OR dosummary && dos6) AND (skipsummary IS NULL OR NOT (skipsummary && dos6)) THEN
            query = E'WITH points AS (SELECT ST_NPoints(' || geomcolumnname || ') nv FROM ' || fqtn || whereclausewithwhere || E'),\n'
                 || E'     agg    AS (SELECT min(nv) min, max(nv) max, avg(nv) avg FROM points)\n'
                 || E'SELECT 6::text summary,\n'
                 || E'       ''MIN number of vertexes''::text idsandtypes,\n'
                 || E'       min::double precision countsandareas,\n'
                 || E'       (''SELECT * FROM ' || fqtn || ' WHERE ST_NPoints(' || geomcolumnname || ') = '' || min::text || ''' || whereclause || E';'')::text query,\n'
                 || E'       NULL::geometry geom\n'
                 || E'FROM agg\n'
                 || E'UNION ALL\n'
                 || E'SELECT 6::text summary,\n'
                 || E'       ''MAX number of vertexes''::text idsandtypes,\n'
                 || E'       max::double precision countsandareas,\n'
                 || E'       (''SELECT * FROM ' || fqtn || ' WHERE ST_NPoints(' || geomcolumnname || ') = '' || max::text || ''' || whereclause || E';'')::text query,\n'
                 || E'       NULL::geometry geom\n'
                 || E'FROM agg\n'
                 || E'UNION ALL\n'
                 || E'SELECT 6::text summary,\n'
                 || E'       ''MEAN number of vertexes''::text idsandtypes,\n'
                 || E'       avg::double precision countsandareas,\n'
                 || E'       (''No usefull query'')::text query,\n'
                 || E'       NULL::geometry geom\n'
                 || E'FROM agg;';

            RETURN QUERY SELECT 'SUMMARY 6 - VERTEX STATISTICS (VERTX or S6)'::text, 'STATISTIC'::text, NULL::double precision, query, NULL::geometry;
            RAISE NOTICE 'Summary 6 - Vertex statistics (VERTX or S6)...';
            IF ST_ColumnExists(newschemaname, tablename, geomcolumnname) THEN
                RETURN QUERY EXECUTE query;
            ELSE
                RETURN QUERY SELECT '6'::text, '''' || geomcolumnname::text || ''' does not exists... Skipping Summary 6'::text, NULL::double precision, NULL::text, NULL::geometry;
            END IF;
        ELSE
            RETURN QUERY SELECT 'SUMMARY 6 - VERTEX STATISTICS (VERTX or S6)'::text, 'SKIPPED'::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 6 - Skipping Vertex statistics (VERTX or S6)...';
        END IF;

        -----------------------------------------------
        -- Summary #7: Build an histogram of the number of vertexes (VHISTO).
        IF (dosummary IS NULL OR dosummary && dos7) AND (skipsummary IS NULL OR NOT (skipsummary && dos7)) THEN
            RAISE NOTICE 'Summary 7 - Histogram of the number of vertexes (VHISTO or S7)...';

            sum7nbinterval = nbinterval;
            IF ST_ColumnExists(newschemaname, tablename, geomcolumnname) THEN

                -- Precompute the min and max number of vertexes so we can set the number of interval to 1 if they are equal
                query = 'SELECT min(ST_NPoints(' || geomcolumnname || ')), max(ST_NPoints(' || geomcolumnname || ')) FROM ' || fqtn || whereclausewithwhere;
                EXECUTE QUERY query INTO minnp, maxnp;

                IF minnp IS NULL AND maxnp IS NULL THEN
                    query = E'WITH npoints AS (SELECT ST_NPoints(' || geomcolumnname || ') np FROM ' || fqtn || whereclausewithwhere || E'),\n'
                         || E'     histo   AS (SELECT count(*) cnt FROM npoints)\n'
                         || E'SELECT 7::text summary,\n'
                         || E'       ''NULL''::text idsandtypes,\n'
                         || E'       cnt::double precision countsandareas,\n'
                         || E'       ''SELECT *, ST_NPoints(' || geomcolumnname || ') nbpoints FROM ' || fqtn || ' WHERE ' || geomcolumnname || ' IS NULL' || whereclause || E';''::text query,\n'
                         || E'       NULL::geometry geom\n'
                         || E'FROM histo;';
                ELSE
                    IF maxnp - minnp = 0 THEN
                        RAISE NOTICE 'Summary 7: maximum number of points - minimum number of points = 0. Will create only 1 interval instead of %...', sum7nbinterval;
                        sum7nbinterval = 1;
                    ELSEIF maxnp - minnp + 1 < sum7nbinterval THEN
                        RAISE NOTICE 'Summary 7: maximum number of points - minimum number of points < %. Will create only % interval instead of %...', sum7nbinterval, maxnp - minnp + 1, sum7nbinterval;
                        sum7nbinterval = maxnp - minnp + 1;
                    END IF;

                    -- Compute the histogram
                    query = E'WITH npoints AS (SELECT ST_NPoints(' || geomcolumnname || ') np FROM ' || fqtn || whereclausewithwhere || E'),\n'
                         || E'     bins    AS (SELECT np, CASE WHEN np IS NULL THEN -1 ELSE least(floor((np - ' || minnp || ')*' || sum7nbinterval || '::numeric/(' || (CASE WHEN maxnp - minnp = 0 THEN maxnp + 0.000000001 ELSE maxnp END) - minnp || ')), ' || sum7nbinterval || ' - 1) END bin, ' || (maxnp - minnp) || '/' || sum7nbinterval || E'.0 binrange FROM npoints),\n'
                         || E'     histo  AS (SELECT bin, count(*) cnt FROM bins GROUP BY bin)\n'
                         || E'SELECT 7::text summary,\n'
                         || E'       CASE WHEN serie = -1 THEN ''NULL''::text ELSE ''['' || round(' || minnp || ' + serie * binrange)::text || '' - '' || (CASE WHEN serie = ' || sum7nbinterval || ' - 1 THEN round(' || maxnp || ')::text || '']'' ELSE round(' || minnp || E' + (serie + 1) * binrange)::text || ''['' END) END idsandtypes,\n'
                         || E'       coalesce(cnt, 0)::double precision countsandareas,\n'
                         || E'      (''SELECT *, ST_NPoints(' || geomcolumnname || ') nbpoints FROM ' || fqtn || ' WHERE ST_NPoints(' || geomcolumnname || ')'' || (CASE WHEN serie = -1 THEN '' IS NULL'' || ''' || whereclause || ''' ELSE ('' >= '' || round(' || minnp || ' + serie * binrange)::text || '' AND ST_NPoints(' || geomcolumnname || ') <'' || (CASE WHEN serie = ' || sum7nbinterval || ' - 1 THEN ''= '' || ' || maxnp || '::float8::text ELSE '' '' || round(' || minnp || ' + (serie + 1) * binrange)::text END) || ''' || whereclause || ''' || '' ORDER BY ST_NPoints(' || geomcolumnname || E') DESC'') END) || '';'')::text query,\n'
                         || E'       NULL::geometry geom\n'
                         || E'FROM generate_series(-1, ' || sum7nbinterval || E' - 1) serie\n'
                         || E'     LEFT OUTER JOIN histo ON (serie = histo.bin),\n'
                         || E'    (SELECT * FROM bins LIMIT 1) foo\n'
                         || E'ORDER BY serie;';
                END IF;
                RETURN QUERY SELECT 'SUMMARY 7 - HISTOGRAM OF THE NUMBER OF VERTEXES (VHISTO or S7)'::text, 'NUMBER OF VERTEXES INTERVALS'::text, NULL::double precision, query, NULL::geometry;
                RETURN QUERY EXECUTE query;
            ELSE
                RETURN QUERY SELECT 'SUMMARY 7 - HISTOGRAM OF THE NUMBER OF VERTEXES (VHISTO or S7)'::text, 'NUMBER OF VERTEXES INTERVALS'::text, NULL::double precision, ''::text, NULL::geometry;
                RETURN QUERY SELECT '7'::text, '''' || geomcolumnname::text || ''' does not exists... Skipping Summary 7'::text, NULL::double precision, NULL::text, NULL::geometry;
            END IF;
        ELSE
            RETURN QUERY SELECT 'SUMMARY 7 - HISTOGRAM OF THE NUMBER OF VERTEXES (VHISTO or S7)'::text, 'SKIPPED'::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 7 - Skipping Histogram of the number of vertexes (VHISTO or S7)...';
        END IF;

        -----------------------------------------------
        -- Create an index on ST_Area(geom) if necessary so further queries are executed faster
        IF (dosummary IS NULL OR dosummary && dos8 OR dosummary && dos9 OR dosummary && dos10) AND (skipsummary IS NULL OR NOT (skipsummary && dos8 AND skipsummary && dos9 AND skipsummary && dos10)) AND
           ST_ColumnExists(newschemaname, tablename, geomcolumnname) AND
           NOT ST_HasBasicIndex(newschemaname, tablename, NULL, 'st_area'::text) THEN
            RAISE NOTICE 'Creating % index on ''ST_Area(%)''...', (CASE WHEN whereclausewithwhere = '' THEN 'an' ELSE 'a partial' END), geomcolumnname;
            query = 'CREATE INDEX ' || left(tablename || '_' || geomcolumnname, 51) || '_st_area_idx ON ' || fqtn || ' USING btree (ST_Area(' || geomcolumnname || '))' || whereclausewithwhere || ';';
            EXECUTE query;
        END IF;

        -----------------------------------------------
        -- Summary #8: Check for polygon areas - min area, max area, mean area (AREAS)
        IF (dosummary IS NULL OR dosummary && dos8) AND (skipsummary IS NULL OR NOT (skipsummary && dos8)) THEN
            query = E'WITH areas AS (SELECT ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || whereclausewithwhere || E'),\n'
                 || E'     agg    AS (SELECT min(area) min, max(area) max, avg(area) avg FROM areas)\n'
                 || E'SELECT 8::text summary,\n'
                 || E'       ''MIN area''::text idsandtypes,\n'
                 || E'       min::double precision countsandareas,\n'
                 || E'       (''SELECT * FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') < '' || min::text || '' + 0.000000001' || whereclause || E';'')::text query,\n'
                 || E'       NULL::geometry geom\n'
                 || E'FROM agg\n'
                 || E'UNION ALL\n'
                 || E'SELECT 8::text summary,\n'
                 || E'       ''MAX area''::text idsandtypes,\n'
                 || E'       max::double precision countsandareas,\n'
                 || E'       (''SELECT * FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') > '' || max::text || '' - 0.000000001 AND ST_Area(' || geomcolumnname || ') < '' || max::text || '' + 0.000000001' || whereclause || E';'')::text query,\n'
                 || E'       NULL::geometry geom\n'
                 || E'FROM agg\n'
                 || E'UNION ALL\n'
                 || E'SELECT 8::text summary,\n'
                 || E'       ''MEAN area''::text idsandtypes,\n'
                 || E'       avg::double precision countsandareas,\n'
                 || E'       (''No usefull query'')::text query,\n'
                 || E'       NULL::geometry geom\n'
                 || E'FROM agg';

            RETURN QUERY SELECT 'SUMMARY 8 - GEOMETRY AREA STATISTICS (AREAS, AREA or S8)'::text, 'STATISTIC'::text, NULL::double precision, query, NULL::geometry;
            RAISE NOTICE 'Summary 8 - Geometry area statistics (AREAS, AREA or S8)...';
            IF ST_ColumnExists(newschemaname, tablename, geomcolumnname) THEN
                RETURN QUERY EXECUTE query;
            ELSE
                RETURN QUERY SELECT '8'::text, '''' || geomcolumnname::text || ''' does not exists... Skipping Summary 8'::text, NULL::double precision, NULL::text, NULL::geometry;
            END IF;
        ELSE
            RETURN QUERY SELECT 'SUMMARY 8 - GEOMETRY AREA STATISTICS (AREAS, AREA or S8)'::text, 'SKIPPED'::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 8 - Skipping Geometry area statistics (AREAS, AREA or S8)...';
        END IF;

        -----------------------------------------------
        -- Summary #9: Build an histogram of the areas (AHISTO)
        IF (dosummary IS NULL OR dosummary && dos9) AND (skipsummary IS NULL OR NOT (skipsummary && dos9)) THEN
            RAISE NOTICE 'Summary 9 - Histogram of areas (AHISTO or S9)...';

            sum9nbinterval = nbinterval;
            IF ST_ColumnExists(newschemaname, tablename, geomcolumnname) THEN

                -- Precompute the min and max values so we can set the number of interval to 1 if they are equal
                query = 'SELECT min(ST_Area(' || geomcolumnname || ')), max(ST_Area(' || geomcolumnname || ')) FROM ' || fqtn || whereclausewithwhere;
                EXECUTE QUERY query INTO minarea, maxarea;
                IF maxarea IS NULL AND minarea IS NULL THEN
                    query = E'WITH values AS (SELECT ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || whereclausewithwhere || E'),\n'
                         || E'    histo  AS (SELECT count(*) cnt FROM values)\n'
                         || E'SELECT 9::text summary,\n'
                         || E'      ''NULL''::text idsandtypes,\n'
                         || E'      cnt::double precision countsandareas,\n'
                         || E'      ''SELECT *, ST_Area(' || geomcolumnname || ') FROM ' || fqtn || ' WHERE ' || geomcolumnname || ' IS NULL' || whereclause || E';''::text query,\n'
                         || E'      NULL::geometry\n'
                         || E'FROM histo;';

                    RETURN QUERY SELECT 'SUMMARY 9 - HISTOGRAM OF AREAS (AHISTO or S9)'::text, 'AREAS INTERVALS'::text, NULL::double precision, query, NULL::geometry;
                    RETURN QUERY EXECUTE query;
                ELSE
                    IF maxarea - minarea = 0 THEN
                        RAISE NOTICE 'maximum area - minimum area = 0. Will create only 1 interval instead of %...', nbinterval;
                        sum9nbinterval = 1;
                    END IF;

                    -- We make sure double precision values are converted to text using the maximum number of digits before
                    SET extra_float_digits = 3;

                    -- Compute the histogram
                    query = E'WITH areas AS (SELECT ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || whereclausewithwhere || E'),\n'
                         || E'    bins AS (SELECT area, CASE WHEN area IS NULL THEN -1 ELSE least(floor((area - ' || minarea || ')*' || sum9nbinterval || '::numeric/(' || (CASE WHEN maxarea - minarea = 0 THEN maxarea + 0.000000001 ELSE maxarea END) - minarea || ')), ' || sum9nbinterval || ' - 1) END bin, ' || (maxarea - minarea) || '/' || sum9nbinterval || E'.0 binrange FROM areas),\n'
                         || E'    histo AS (SELECT bin, count(*) cnt FROM bins GROUP BY bin)\n'
                         || E'SELECT 9::text summary,\n'
                         || E'      CASE WHEN serie = -1 THEN ''NULL''::text ELSE ''['' || (' || minarea || ' + serie * binrange)::float8::text || '' - '' || (CASE WHEN serie = ' || sum9nbinterval || ' - 1 THEN ' || maxarea || '::float8::text || '']'' ELSE (' || minarea || E' + (serie + 1) * binrange)::float8::text || ''['' END) END idsandtypes,\n'
                         || E'      coalesce(cnt, 0)::double precision countsandareas,\n'
                         || E'      (''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ')'' || (CASE WHEN serie = -1 THEN '' IS NULL'' || ''' || whereclause || ''' ELSE ('' >= '' || (' || minarea || ' + serie * binrange)::float8::text || '' AND ST_Area(' || geomcolumnname || ') <'' || (CASE WHEN serie = ' || sum9nbinterval || ' - 1 THEN ''= '' || ' || maxarea || '::float8::text ELSE '' '' || (' || minarea || ' + (serie + 1) * binrange)::float8::text END) || ''' || whereclause || ''' || '' ORDER BY ST_Area(' || geomcolumnname || E') DESC'') END) || '';'')::text query,\n'
                         || E'      NULL::geometry geom\n'
                         || E'FROM generate_series(-1, ' || sum9nbinterval || E' - 1) serie\n'
                         || E'    LEFT OUTER JOIN histo ON (serie = histo.bin),\n'
                         || E'    (SELECT * FROM bins LIMIT 1) foo\n'
                         || E'ORDER BY serie;';

                    RETURN QUERY SELECT 'SUMMARY 9 - HISTOGRAM OF AREAS (AHISTO or S9)'::text, 'AREAS INTERVALS'::text, NULL::double precision, E'SET extra_float_digits = 3;\n' || query, NULL::geometry;
                    RETURN QUERY EXECUTE query;
                    RESET extra_float_digits;
                END IF;
            ELSE
                RETURN QUERY SELECT 'SUMMARY 9 - HISTOGRAM OF AREAS (AHISTO or S9)'::text, 'AREAS INTERVALS'::text, NULL::double precision, ''::text, NULL::geometry;
                RETURN QUERY SELECT '9'::text, '''' || geomcolumnname::text || ''' does not exists... Skipping Summary 9'::text, NULL::double precision, NULL::text, NULL::geometry;
            END IF;
        ELSE
            RETURN QUERY SELECT 'SUMMARY 9 - HISTOGRAM OF AREAS (AHISTO or S9)'::text, 'SKIPPED'::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 9 - Skipping Histogram of areas (AHISTO or S9)...';
        END IF;

        -----------------------------------------------
        -- Summary #10: Build a list of the small areas (SACOUNT) < 0.1 units. Skipped by default
        IF (dosummary && dos10) AND (skipsummary IS NULL OR NOT (skipsummary && dos10)) THEN
            query = E'WITH areas AS (SELECT ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE (ST_Area(' || geomcolumnname || ') IS NULL OR ST_Area(' || geomcolumnname || ') < 0.1) ' || whereclause || E'),\n'
                 || E'     bins  AS (SELECT area,\n'
                 || E'                      CASE WHEN area IS NULL THEN -1\n'
                 || E'                           WHEN area = 0.0 THEN 0\n'
                 || E'                           WHEN area < 0.0000001 THEN 1\n'
                 || E'                           WHEN area < 0.000001 THEN 2\n'
                 || E'                           WHEN area < 0.00001 THEN 3\n'
                 || E'                           WHEN area < 0.0001 THEN 4\n'
                 || E'                           WHEN area < 0.001 THEN 5\n'
                 || E'                           WHEN area < 0.01 THEN 6\n'
                 || E'                           WHEN area < 0.1 THEN 7\n'
                 || E'                      END bin\n'
                 || E'               FROM areas),\n'
                 || E'    histo AS (SELECT bin, count(*) cnt FROM bins GROUP BY bin)\n'
                 || E'SELECT 10::text summary,\n'
                 || E'       CASE WHEN serie = -1 THEN ''NULL''\n'
                 || E'            WHEN serie = 0 THEN ''[0]''\n'
                 || E'            WHEN serie = 1 THEN '']0 - 0.0000001[''\n'
                 || E'            WHEN serie = 2 THEN ''[0.0000001 - 0.000001[''\n'
                 || E'            WHEN serie = 3 THEN ''[0.000001 - 0.00001[''\n'
                 || E'            WHEN serie = 4 THEN ''[0.00001 - 0.0001[''\n'
                 || E'            WHEN serie = 5 THEN ''[0.0001 - 0.001[''\n'
                 || E'            WHEN serie = 6 THEN ''[0.001 - 0.01[''\n'
                 || E'            WHEN serie = 7 THEN ''[0.01 - 0.1[''\n'
                 || E'       END idsandtypes,\n'
                 || E'       coalesce(cnt, 0)::double precision countsandareas,\n'
                 || E'       CASE WHEN serie = -1 THEN ''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') IS NULL' || whereclause || E';''::text\n'
                 || E'            WHEN serie = 0 THEN ''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') = 0' || whereclause || E';''::text\n'
                 || E'            WHEN serie = 1 THEN ''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') > 0 AND ST_Area(' || geomcolumnname || ') < 0.0000001' || whereclause || ' ORDER BY ST_Area(' || geomcolumnname || E') DESC;''::text\n'
                 || E'            WHEN serie = 2 THEN ''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') >= 0.0000001 AND ST_Area(' || geomcolumnname || ') < 0.000001' || whereclause || ' ORDER BY ST_Area(' || geomcolumnname || E') DESC;''::text\n'
                 || E'            WHEN serie = 3 THEN ''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') >= 0.000001 AND ST_Area(' || geomcolumnname || ') < 0.00001' || whereclause || ' ORDER BY ST_Area(' || geomcolumnname || E') DESC;''::text\n'
                 || E'            WHEN serie = 4 THEN ''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') >= 0.00001 AND ST_Area(' || geomcolumnname || ') < 0.0001' || whereclause || ' ORDER BY ST_Area(' || geomcolumnname || E') DESC;''::text\n'
                 || E'            WHEN serie = 5 THEN ''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') >= 0.0001 AND ST_Area(' || geomcolumnname || ') < 0.001' || whereclause || ' ORDER BY ST_Area(' || geomcolumnname || E') DESC;''::text\n'
                 || E'            WHEN serie = 6 THEN ''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') >= 0.001 AND ST_Area(' || geomcolumnname || ') < 0.01' || whereclause || ' ORDER BY ST_Area(' || geomcolumnname || E') DESC;''::text\n'
                 || E'            WHEN serie = 7 THEN ''SELECT *, ST_Area(' || geomcolumnname || ') area FROM ' || fqtn || ' WHERE ST_Area(' || geomcolumnname || ') >= 0.01 AND ST_Area(' || geomcolumnname || ') < 0.1' || whereclause || ' ORDER BY ST_Area(' || geomcolumnname || E') DESC;''::text\n'
                 || E'       END query,\n'
                 || E'       NULL::geometry geom\n'
                 || E'FROM generate_series(-1, 7) serie\n'
                 || E'     LEFT OUTER JOIN histo ON (serie = histo.bin),\n'
                 || E'     (SELECT * FROM bins LIMIT 1) foo\n'
                 || E'ORDER BY serie;';

            RETURN QUERY SELECT 'SUMMARY 10 - COUNT OF SMALL AREAS (SACOUNT or S10)'::text, 'SMALL AREAS INTERVALS'::text, NULL::double precision, query, NULL::geometry;
            RAISE NOTICE 'Summary 10 - Count of small areas (SACOUNT or S10)...';

            IF ST_ColumnExists(newschemaname, tablename, geomcolumnname) THEN
                RETURN QUERY EXECUTE query;
                IF NOT FOUND THEN
                    RETURN QUERY SELECT '10'::text, 'No geometry smaller than 0.1...'::text, NULL::double precision, NULL::text, NULL::geometry;
                END IF;
            ELSE
                RETURN QUERY SELECT '10'::text, '''' || geomcolumnname::text || ''' does not exists... Skipping Summary 10'::text, NULL::double precision, NULL::text, NULL::geometry;
            END IF;
        ELSE
            bydefault = '';
            IF dosummary IS NULL AND (skipsummary IS NULL OR NOT (skipsummary && dos10)) THEN
               bydefault = ' BY DEFAULT';
            END IF;
            RETURN QUERY SELECT 'SUMMARY 10 - COUNT OF AREAS (SACOUNT or S10)'::text, ('SKIPPED' || bydefault)::text, NULL::double precision, NULL::text, NULL::geometry;
            RAISE NOTICE 'Summary 10 - Skipping Count of small areas (SACOUNT or S10)...';
        END IF;

        RETURN;
    END;
$$;


--
-- TOC entry 1464 (class 1255 OID 26747)
-- Name: st_geotablesummary(name, name, name, name, integer, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_geotablesummary(schemaname name, tablename name, geomcolumnname name, uidcolumn name, nbinterval integer, dosummary text DEFAULT NULL::text, skipsummary text DEFAULT NULL::text, whereclause text DEFAULT NULL::text) RETURNS TABLE(summary text, idsandtypes text, countsandareas double precision, query text, geom public.geometry)
    LANGUAGE sql
    AS $_$
    SELECT ST_GeoTableSummary($1, $2, $3, $4, $5, regexp_split_to_array($6, E'\\s*\,\\s'), regexp_split_to_array($7, E'\\s*\,\\s'), $8)
$_$;


--
-- TOC entry 1455 (class 1255 OID 26730)
-- Name: st_globalrasterunion(name, name, name, text, text, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_globalrasterunion(schemaname name, tablename name, rastercolumnname name, method text DEFAULT 'FIRST_RASTER_VALUE_AT_PIXEL_CENTROID'::text, pixeltype text DEFAULT NULL::text, nodataval double precision DEFAULT NULL::double precision) RETURNS public.raster
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        query text;
        newrast raster;
        fct2call text;
        pixeltypetxt text;
        nodatavaltxt text;
    BEGIN
        IF right(method, 5) = 'TROID' THEN
            fct2call = 'ST_ExtractPixelCentroidValue4ma';
        ELSE
            fct2call = 'ST_ExtractPixelValue4ma';
        END IF;
        IF pixeltype IS NULL THEN
            pixeltypetxt = 'ST_BandPixelType(' || quote_ident(rastercolumnname) || ')';
        ELSE
            pixeltypetxt = '''' || pixeltype || '''::text';
        END IF;
        IF nodataval IS NULL THEN
            nodatavaltxt = 'ST_BandNodataValue(' || quote_ident(rastercolumnname) || ')';
        ELSE
            nodatavaltxt = nodataval;
        END IF;
        query = 'SELECT ST_MapAlgebra(rast,
                                      1,
                                      ''' || fct2call || '(double precision[], integer[], text[])''::regprocedure,
                                      ST_BandPixelType(rast, 1),
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      ST_Width(rast)::text,
                                      ST_Height(rast)::text,
                                      ST_UpperLeftX(rast)::text,
                                      ST_UpperLeftY(rast)::text,
                                      ST_ScaleX(rast)::text,
                                      ST_ScaleY(rast)::text,
                                      ST_SkewX(rast)::text,
                                      ST_SkewY(rast)::text,
                                      ST_SRID(rast)::text,' ||
                                      quote_literal(schemaname) || ', ' ||
                                      quote_literal(tablename) || ', ' ||
                                      quote_literal(rastercolumnname) || ',
                                      NULL' || ', ' ||
                                      quote_literal(upper(method)) || '
                                     ) rast
                 FROM (SELECT ST_AsRaster(ST_Union(rast::geometry),
                                          min(scalex),
                                          min(scaley),
                                          min(gridx),
                                          min(gridy),
                                          max(pixeltype),
                                          0,
                                          min(nodataval)
                                         ) rast
                       FROM (SELECT ' || quote_ident(rastercolumnname) || ' rast,
                                    ST_ScaleX(' || quote_ident(rastercolumnname) || ') scalex,
                                    ST_ScaleY(' || quote_ident(rastercolumnname) || ') scaley,
                                    ST_UpperLeftX(' || quote_ident(rastercolumnname) || ') gridx,
                                    ST_UpperLeftY(' || quote_ident(rastercolumnname) || ') gridy,
                                    ' || pixeltypetxt || ' pixeltype,
                                    ' || nodatavaltxt || ' nodataval
                             FROM ' || quote_ident(schemaname) || '.' || quote_ident(tablename) || '
                            ) foo1
                      ) foo2';
        EXECUTE query INTO newrast;
        RETURN newrast;
    END;
$$;


--
-- TOC entry 1378 (class 1255 OID 26707)
-- Name: st_hasbasicindex(name, name); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_hasbasicindex(tablename name, columnname name) RETURNS boolean
    LANGUAGE sql
    AS $_$
    SELECT ST_HasBasicIndex('public', $1, $2, NULL)
$_$;


--
-- TOC entry 1367 (class 1255 OID 26706)
-- Name: st_hasbasicindex(name, name, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_hasbasicindex(tablename name, columnname name, idxstring text) RETURNS boolean
    LANGUAGE sql
    AS $_$
    SELECT ST_HasBasicIndex('public', $1, $2, $3)
$_$;


--
-- TOC entry 1442 (class 1255 OID 26705)
-- Name: st_hasbasicindex(name, name, name, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_hasbasicindex(schemaname name, tablename name, columnname name, idxstring text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    DECLARE
        query text;
        coltype text;
        hasindex boolean := FALSE;
    BEGIN
        IF schemaname IS NULL OR schemaname = '' OR tablename IS NULL OR tablename = '' THEN
            RETURN NULL;
        END IF;
        -- Check if schemaname is not actually a table name and idxstring actually a column name.
        -- That's the only way to support a three parameters variant taking a schemaname, a tablename and a columnname
        IF ST_ColumnExists(tablename, columnname, idxstring) THEN
            schemaname = tablename;
            tablename = columnname;
            columnname = idxstring;
            idxstring = NULL;
        END IF;
        IF (columnname IS NULL OR columnname = '') AND (idxstring IS NULL OR idxstring = '') THEN
            RETURN NULL;
        END IF;
        IF NOT columnname IS NULL AND columnname != '' AND ST_ColumnExists(schemaname, tablename, columnname) THEN
            -- Determine the type of the column
            query := 'SELECT typname
                      FROM pg_namespace
                          LEFT JOIN pg_class ON (pg_namespace.oid = pg_class.relnamespace)
                          LEFT JOIN pg_attribute ON (pg_attribute.attrelid = pg_class.oid)
                          LEFT JOIN pg_type ON (pg_type.oid = pg_attribute.atttypid)
                      WHERE lower(nspname) = lower(''' || schemaname || ''') AND lower(relname) = lower(''' || tablename || ''') AND lower(attname) = lower(''' || columnname || ''');';
            EXECUTE QUERY query INTO coltype;
        END IF;

        IF coltype IS NULL AND (idxstring IS NULL OR idxstring = '') THEN
            RETURN NULL;
        ELSIF coltype = 'raster' THEN
            -- When column type is RASTER we ignore the column name and
            -- only check if the type of the index is gist since it is a functional
            -- index and it would be hard to check on which column it is applied
            query := 'SELECT TRUE
                      FROM pg_index
                      LEFT OUTER JOIN pg_class relclass ON (relclass.oid = pg_index.indrelid)
                      LEFT OUTER JOIN pg_namespace ON (pg_namespace.oid = relclass.relnamespace)
                      LEFT OUTER JOIN pg_class idxclass ON (idxclass.oid = pg_index.indexrelid)
                      LEFT OUTER JOIN pg_am ON (pg_am.oid = idxclass.relam)
                      WHERE relclass.relkind = ''r'' AND amname = ''gist''
                      AND lower(nspname) = lower(''' || schemaname || ''') AND lower(relclass.relname) = lower(''' || tablename || ''')';
            IF NOT idxstring IS NULL THEN
                query := query || ' AND lower(idxclass.relname) LIKE lower(''%' || idxstring || '%'');';
            END IF;
            EXECUTE QUERY query INTO hasindex;
        ELSE
            -- Otherwise we check for an index on the right column
            query := 'SELECT TRUE
                      FROM pg_index
                      LEFT OUTER JOIN pg_class relclass ON (relclass.oid = pg_index.indrelid)
                      LEFT OUTER JOIN pg_namespace ON (pg_namespace.oid = relclass.relnamespace)
                      LEFT OUTER JOIN pg_class idxclass ON (idxclass.oid = pg_index.indexrelid)
                      --LEFT OUTER JOIN pg_am ON (pg_am.oid = idxclass.relam)
                      LEFT OUTER JOIN pg_attribute ON (pg_attribute.attrelid = relclass.oid AND indkey[0] = attnum)
                      WHERE relclass.relkind = ''r''
                      AND lower(nspname) = lower(''' || schemaname || ''') AND lower(relclass.relname) = lower(''' || tablename || ''')';
            IF NOT idxstring IS NULL THEN
                query := query || ' AND lower(idxclass.relname) LIKE lower(''%' || idxstring || '%'')';
            END IF;
            IF NOT columnname IS NULL THEN
                query := query || ' AND indkey[0] != 0 AND lower(attname) = lower(''' || columnname || ''')';
            END IF;
 --RAISE NOTICE 'query = %', query;
            EXECUTE QUERY query INTO hasindex;
        END IF;
        IF hasindex IS NULL THEN
            hasindex = FALSE;
        END IF;
        RETURN hasindex;
    END;
$$;


--
-- TOC entry 1466 (class 1255 OID 26749)
-- Name: st_histogram(text, text, text, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_histogram(schemaname text, tablename text, columnname text, nbinterval integer DEFAULT 10, whereclause text DEFAULT NULL::text) RETURNS TABLE(intervals text, cnt integer, query text)
    LANGUAGE plpgsql
    AS $$
    DECLARE
    fqtn text;
    query text;
    newschemaname name;
    findnewcolumnname boolean := FALSE;
    newcolumnname text;
    columnnamecnt int := 0;
    whereclausewithwhere text := '';
    minval double precision := 0;
    maxval double precision := 0;
    columntype text;
    BEGIN
        IF nbinterval IS NULL THEN
            nbinterval = 10;
        END IF;
        IF nbinterval <= 0 THEN
            RAISE NOTICE 'nbinterval is smaller or equal to zero. Returning nothing...';
            RETURN;
        END IF;
        IF whereclause IS NULL OR whereclause = '' THEN
            whereclause = '';
        ELSE
            whereclausewithwhere = ' WHERE ' || whereclause || ' ';
            whereclause = ' AND (' || whereclause || ')';
        END IF;
        newschemaname := '';
        IF length(schemaname) > 0 THEN
            newschemaname := schemaname;
        ELSE
            newschemaname := 'public';
        END IF;
        fqtn := quote_ident(newschemaname) || '.' || quote_ident(tablename);

        -- Build an histogram with the column values.
        IF ST_ColumnExists(newschemaname, tablename, columnname) THEN

            -- Precompute the min and max values so we can set the number of interval to 1 if they are equal
            query = 'SELECT min(' || columnname || '), max(' || columnname || ') FROM ' || fqtn || whereclausewithwhere;
            EXECUTE QUERY query INTO minval, maxval;
            IF maxval IS NULL AND minval IS NULL THEN
                query = 'WITH values AS (SELECT ' || columnname || ' val FROM ' || fqtn || whereclausewithwhere || '),
                              histo  AS (SELECT count(*) cnt FROM values)
                         SELECT ''NULL''::text intervals,
                                cnt::int,
                                ''SELECT * FROM ' || fqtn || ' WHERE ' || columnname || ' IS NULL' || whereclause || ';''::text query
                         FROM histo;';
                RETURN QUERY EXECUTE query;
            ELSE
                IF maxval - minval = 0 THEN
                    RAISE NOTICE 'maximum value - minimum value = 0. Will create only 1 interval instead of %...', nbinterval;
                    nbinterval = 1;
                END IF;

                -- We make sure double precision values are converted to text using the maximum number of digits before computing summaries involving this type of values
                query = 'SELECT pg_typeof(' || columnname || ')::text FROM ' || fqtn || ' LIMIT 1';
                EXECUTE query INTO columntype;
                IF left(columntype, 3) != 'int' THEN
                    SET extra_float_digits = 3;
                END IF;

                -- Compute the histogram
                query = 'WITH values AS (SELECT ' || columnname || ' val FROM ' || fqtn || whereclausewithwhere || '),
                              bins   AS (SELECT val, CASE WHEN val IS NULL THEN -1 ELSE least(floor((val - ' || minval || ')*' || nbinterval || '::numeric/(' || (CASE WHEN maxval - minval = 0 THEN maxval + 0.000000001 ELSE maxval END) - minval || ')), ' || nbinterval || ' - 1) END bin, ' || (maxval - minval) || '/' || nbinterval || '.0 binrange FROM values),
                              histo  AS (SELECT bin, count(*) cnt FROM bins GROUP BY bin)
                         SELECT CASE WHEN serie = -1 THEN ''NULL''::text ELSE ''['' || (' || minval || ' + serie * binrange)::float8::text || '' - '' || (CASE WHEN serie = ' || nbinterval || ' - 1 THEN ' || maxval || '::float8::text || '']'' ELSE (' || minval || ' + (serie + 1) * binrange)::float8::text || ''['' END) END intervals,
                                coalesce(cnt, 0)::int cnt,
                                (''SELECT * FROM ' || fqtn || ' WHERE ' || columnname || ''' || (CASE WHEN serie = -1 THEN '' IS NULL'' || ''' || whereclause || ''' ELSE ('' >= '' || (' || minval || ' + serie * binrange)::float8::text || '' AND ' || columnname || ' <'' || (CASE WHEN serie = ' || nbinterval || ' - 1 THEN ''= '' || ' || maxval || '::float8::text ELSE '' '' || (' || minval || ' + (serie + 1) * binrange)::float8::text END) || ''' || whereclause || ''' || '' ORDER BY ' || columnname || ''') END) || '';'')::text query
                         FROM generate_series(-1, ' || nbinterval || ' - 1) serie
                              LEFT OUTER JOIN histo ON (serie = histo.bin),
                              (SELECT * FROM bins LIMIT 1) foo
                         ORDER BY serie;';
                RETURN QUERY EXECUTE query;
                IF left(columntype, 3) != 'int' THEN
                    RESET extra_float_digits;
                END IF;
            END IF;
        ELSE
            RAISE NOTICE '''%'' does not exists. Returning nothing...',columnname::text;
            RETURN;
        END IF;

        RETURN;
    END;
$$;


--
-- TOC entry 1458 (class 1255 OID 26734)
-- Name: st_nbiggestexteriorrings(public.geometry, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_nbiggestexteriorrings(ingeom public.geometry, nbrings integer, comptype text DEFAULT 'AREA'::text) RETURNS SETOF public.geometry
    LANGUAGE plpgsql
    AS $$
    DECLARE
    BEGIN
    IF upper(comptype) = 'AREA' THEN
        RETURN QUERY SELECT ring
                     FROM (SELECT ST_MakePolygon(ST_ExteriorRing((ST_Dump(ingeom)).geom)) ring
                          ) foo
                     ORDER BY ST_Area(ring) DESC LIMIT nbrings;
    ELSIF upper(comptype) = 'NBPOINTS' THEN
        RETURN QUERY SELECT ring
                     FROM (SELECT ST_MakePolygon(ST_ExteriorRing((ST_Dump(ingeom)).geom)) ring
                          ) foo
                     ORDER BY ST_NPoints(ring) DESC LIMIT nbrings;
    ELSE
        RAISE NOTICE 'ST_NBiggestExteriorRings: Unsupported comparison type: ''%''. Try ''AREA'' or ''NBPOINTS''.', comptype;
        RETURN;
    END IF;
    END;
$$;


--
-- TOC entry 1439 (class 1255 OID 26702)
-- Name: st_randompoints(public.geometry, integer, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_randompoints(geom public.geometry, nb integer, seed numeric DEFAULT NULL::numeric) RETURNS SETOF public.geometry
    LANGUAGE plpgsql
    AS $$
    DECLARE
        pt geometry;
        xmin float8;
        xmax float8;
        ymin float8;
        ymax float8;
        xrange float8;
        yrange float8;
        srid int;
        count integer := 0;
        gtype text;
    BEGIN
        SELECT ST_GeometryType(geom) INTO gtype;

        -- Make sure the geometry is some kind of polygon
        IF (gtype IS NULL OR (gtype != 'ST_Polygon') AND (gtype != 'ST_MultiPolygon')) THEN
            RAISE NOTICE 'Attempting to get random points in a non polygon geometry';
            RETURN NEXT NULL;
            RETURN;
        END IF;

        -- Compute the extent
        SELECT ST_XMin(geom), ST_XMax(geom), ST_YMin(geom), ST_YMax(geom), ST_SRID(geom)
        INTO xmin, xmax, ymin, ymax, srid;

        -- and the range of the extent
        SELECT xmax - xmin, ymax - ymin
        INTO xrange, yrange;

        -- Set the seed if provided
        IF seed IS NOT NULL THEN
            PERFORM setseed(seed);
        END IF;

        -- Find valid points one after the other checking if they are inside the polygon
        WHILE count < nb LOOP
            SELECT ST_SetSRID(ST_MakePoint(xmin + xrange * random(), ymin + yrange * random()), srid)
            INTO pt;

            IF ST_Contains(geom, pt) THEN
                count := count + 1;
                RETURN NEXT pt;
            END IF;
        END LOOP;
        RETURN;
    END;
$$;


--
-- TOC entry 1470 (class 1255 OID 26754)
-- Name: st_removeoverlaps(public.geometry[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_removeoverlaps(geomarray public.geometry[]) RETURNS SETOF public.geometry
    LANGUAGE sql
    AS $$
    WITH geoms AS (
        SELECT unnest(geomarray) geom
    )
    SELECT ST_RemoveOverlaps(array_agg((geom, null)::geomval), 'NO_MERGE') FROM geoms;
$$;


--
-- TOC entry 1469 (class 1255 OID 26753)
-- Name: st_removeoverlaps(public.geomval[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_removeoverlaps(gvarray public.geomval[]) RETURNS SETOF public.geometry
    LANGUAGE sql
    AS $$
    SELECT ST_RemoveOverlaps(gvarray, 'LARGEST_VALUE');
$$;


--
-- TOC entry 1468 (class 1255 OID 26752)
-- Name: st_removeoverlaps(public.geometry[], text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_removeoverlaps(geomarray public.geometry[], mergemethod text) RETURNS SETOF public.geometry
    LANGUAGE sql
    AS $$
    WITH geoms AS (
        SELECT unnest(geomarray) geom
    )
    SELECT ST_RemoveOverlaps(array_agg((geom, ST_Area(geom))::geomval), mergemethod) FROM geoms;
$$;


--
-- TOC entry 1467 (class 1255 OID 26751)
-- Name: st_removeoverlaps(public.geomval[], text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_removeoverlaps(gvarray public.geomval[], mergemethod text) RETURNS SETOF public.geometry
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
    DECLARE
        query text;
    BEGIN
        mergemethod = upper(mergemethod);
--RAISE NOTICE 'method = %', mergemethod;
        query = E'WITH geomvals AS (\n'
             || E'  SELECT unnest($1) gv\n'
             || E'), geoms AS (\n'
             || E'  SELECT row_number() OVER () id, ST_CollectionExtract((gv).geom, 3) geom';
        IF right(mergemethod, 4) = 'AREA' THEN
            query = query || E', ST_Area((gv).geom) val\n';
        ELSE
            query = query || E', (gv).val\n';
        END IF;
        query = query || E'  FROM geomvals\n'
                      || E'), polygons AS (\n'
                      || E'  SELECT id, (ST_Dump(geom)).geom geom\n'
                      || E'  FROM geoms\n'
                      || E'), rings AS (\n'
                      || E'  SELECT id, ST_ExteriorRing((ST_DumpRings(geom)).geom) geom\n'
                      || E'  FROM polygons\n'
                      || E'), extrings_union AS (\n'
                      || E'  SELECT ST_Union(geom) geom\n'
                      || E'  FROM rings\n'
                      || E'), parts AS (\n'
                      || E'  SELECT (ST_Dump(ST_Polygonize(geom))).geom \n'
                      || E'  FROM extrings_union\n'
                      || E'), assigned_parts AS (\n'
                      || E'  SELECT id, \n'
                      || E'         count(*) OVER (PARTITION BY ST_AsEWKB(geom)) cnt, \n'
                      || E'         val, geom\n'
                      || E'  FROM (SELECT id, val, parts.geom,\n'
                      || E'               ST_Area(ST_Intersection(ori_polys.geom, parts.geom)) intarea\n'
                      || E'        FROM parts,\n'
                      || E'             (SELECT id, val, geom FROM geoms) ori_polys\n'
                      || E'        WHERE ST_Intersects(ori_polys.geom, parts.geom)\n'
                      || E'       ) foo\n'
                      || E'  WHERE intarea > 0 AND abs(intarea - ST_Area(geom)) < 0.001\n';

         IF right(mergemethod, 5) = '_EDGE' THEN
             query = query || E'), edge_length AS (\n'
                           || E'  SELECT a.id, b.id bid, \n'
                           || E'         ST_Union(ST_AsEWKB(a.geom)::geometry) geom,\n'
                           || E'         sum(ST_Length(ST_CollectionExtract(ST_Intersection(a.geom, b.geom), 2))) val\n'
                           || E'  FROM (SELECT id, geom FROM assigned_parts WHERE cnt > 1) a \n'
                           || E'      LEFT OUTER JOIN assigned_parts b \n'
                           || E'   ON (ST_AsEWKB(a.geom) != ST_AsEWKB(b.geom) AND \n'
                           || E'       ST_Touches(a.geom, b.geom) AND\n'
                           || E'      ST_Length(ST_CollectionExtract(ST_Intersection(a.geom, b.geom), 2)) > 0)\n'
                           || E'  GROUP BY a.id, b.id, ST_AsEWKB(a.geom)\n'
                           || E'    ), keep_parts AS (\n'
                           || E'   SELECT DISTINCT ON (ST_AsEWKB(geom)) id, geom\n'
                           || E'   FROM edge_length\n'
                           || E'   ORDER BY ST_AsEWKB(geom), val ';
             IF left(mergemethod, 7) = 'LONGEST' THEN
                 query = query || E'DESC';
             END IF;
             query = query || E', abs(id - bid)\n';

         ELSEIF left(mergemethod, 8) != 'NO_MERGE' AND left(mergemethod, 4) != 'OVER' THEN
             query = query || E'), keep_parts AS (\n'
                           || E'   SELECT DISTINCT ON (ST_AsEWKB(geom)) id, val, geom\n'
                           || E'   FROM assigned_parts\n'
                           || E'   ORDER BY ST_AsEWKB(geom), val';


             IF left(mergemethod, 7) = 'LARGEST' THEN
                 query = query || E' DESC';
             END IF;
             query = query || E'\n';
         END IF;

         IF left(mergemethod, 8) = 'NO_MERGE' OR left(mergemethod, 13) = 'OVERLAPS_ONLY' THEN
             query = query || E')\n';
             IF right(mergemethod, 4) = '_DUP' THEN
                    query = query || E'(SELECT geom\n';
             ELSE
                    query = query || E'(SELECT DISTINCT ON (ST_AsEWKB(geom)) geom\n';
             END IF;
             query = query || E' FROM assigned_parts\n'
                           || E' WHERE cnt > 1)\n';
             IF left(mergemethod, 8) = 'NO_MERGE' THEN
                 query = query || E'UNION ALL\n'
                               || E'(SELECT ST_Union(geom) geom\n'
                               || E' FROM assigned_parts\n'
                               || E' WHERE cnt = 1\n'
                               || E' GROUP BY id);\n';
             END IF;

         ELSEIF right(mergemethod, 5) = '_EDGE' THEN
            query = query || E')\n'
                          || E'SELECT ST_Union(geom) geom\n'
                          || E'FROM (SELECT id, geom FROM keep_parts\n'
                          || E'      UNION ALL \n'
                          || E'      SELECT id, geom FROM assigned_parts WHERE cnt = 1) foo\n'
                          || E'GROUP BY id\n';

         ELSE -- AREA or VALUE
             query = query || E')\n'
                           || E'SELECT ST_Union(geom) geom\n'
                           || E'FROM keep_parts\n'
                           || E'GROUP BY id;\n';
         END IF;
 --RAISE NOTICE 'query = %', query;
         RETURN QUERY EXECUTE query USING gvarray;
    END;
$_$;


--
-- TOC entry 1465 (class 1255 OID 26748)
-- Name: st_splitbygrid(public.geometry, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_splitbygrid(ingeom public.geometry, xgridsize double precision, ygridsize double precision DEFAULT NULL::double precision, xgridoffset double precision DEFAULT 0.0, ygridoffset double precision DEFAULT 0.0) RETURNS TABLE(geom public.geometry, tid bigint, x integer, y integer, tgeom public.geometry)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        width int;
        height int;
        xminrounded double precision;
        yminrounded double precision;
        xmaxrounded double precision;
        ymaxrounded double precision;
        xmin double precision := ST_XMin(ingeom);
        ymin double precision := ST_YMin(ingeom);
        xmax double precision := ST_XMax(ingeom);
        ymax double precision := ST_YMax(ingeom);
        x int;
        y int;
        env geometry;
        xfloor int;
        yfloor int;
    BEGIN
        IF ingeom IS NULL OR ST_IsEmpty(ingeom) THEN
            RETURN QUERY SELECT ingeom, NULL::int8;
            RETURN;
        END IF;
        IF xgridsize IS NULL OR xgridsize <= 0 THEN
            RAISE NOTICE 'Defaulting xgridsize to 1...';
            xgridsize = 1;
        END IF;
        IF ygridsize IS NULL OR ygridsize <= 0 THEN
            ygridsize = xgridsize;
        END IF;
        xfloor = floor((xmin - xgridoffset) / xgridsize);
        xminrounded = xfloor * xgridsize + xgridoffset;
        xmaxrounded = ceil((xmax - xgridoffset) / xgridsize) * xgridsize + xgridoffset;
        yfloor = floor((ymin - ygridoffset) / ygridsize);
        yminrounded = yfloor * ygridsize + ygridoffset;
        ymaxrounded = ceil((ymax - ygridoffset) / ygridsize) * ygridsize + ygridoffset;

        width = round((xmaxrounded - xminrounded) / xgridsize);
        height = round((ymaxrounded - yminrounded) / ygridsize);

        FOR x IN 1..width LOOP
            FOR y IN 1..height LOOP
                env = ST_MakeEnvelope(xminrounded + (x - 1) * xgridsize, yminrounded + (y - 1) * ygridsize, xminrounded + x * xgridsize, yminrounded + y * ygridsize, ST_SRID(ingeom));
                IF ST_Intersects(env, ingeom) THEN
                     RETURN QUERY SELECT ST_Intersection(ingeom, env), ((xfloor::int8 + x) * 10000000 + (yfloor::int8 + y))::int8, xfloor + x, yfloor + y, env
                            WHERE ST_Dimension(ST_Intersection(ingeom, env)) = ST_Dimension(ingeom) OR
                                  ST_GeometryType(ST_Intersection(ingeom, env)) = ST_GeometryType(ingeom);
                 END IF;
            END LOOP;
        END LOOP;
    RETURN;
    END;
$$;


--
-- TOC entry 1419 (class 1255 OID 26738)
-- Name: st_trimmulti(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_trimmulti(geom public.geometry, minarea double precision DEFAULT 0.0) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT ST_Union(newgeom)
    FROM (SELECT ST_CollectionExtract((ST_Dump($1)).geom, 3) newgeom
         ) foo
    WHERE ST_Area(newgeom) > $2;
$_$;


--
-- TOC entry 1988 (class 1255 OID 26722)
-- Name: st_areaweightedsummarystats(public.geometry); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_areaweightedsummarystats(public.geometry) (
    SFUNC = public._st_areaweightedsummarystats_statefn,
    STYPE = public.agg_areaweightedstatsstate,
    FINALFUNC = public._st_areaweightedsummarystats_finalfn
);


--
-- TOC entry 1986 (class 1255 OID 26720)
-- Name: st_areaweightedsummarystats(public.geomval); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_areaweightedsummarystats(public.geomval) (
    SFUNC = public._st_areaweightedsummarystats_statefn,
    STYPE = public.agg_areaweightedstatsstate,
    FINALFUNC = public._st_areaweightedsummarystats_finalfn
);


--
-- TOC entry 1987 (class 1255 OID 26721)
-- Name: st_areaweightedsummarystats(public.geometry, double precision); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_areaweightedsummarystats(public.geometry, double precision) (
    SFUNC = public._st_areaweightedsummarystats_statefn,
    STYPE = public.agg_areaweightedstatsstate,
    FINALFUNC = public._st_areaweightedsummarystats_finalfn
);


--
-- TOC entry 1989 (class 1255 OID 26733)
-- Name: st_bufferedunion(public.geometry, double precision); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_bufferedunion(public.geometry, double precision) (
    SFUNC = public._st_bufferedunion_statefn,
    STYPE = public.geomval,
    FINALFUNC = public._st_bufferedunion_finalfn
);


--
-- TOC entry 1985 (class 1255 OID 26737)
-- Name: st_differenceagg(public.geometry, public.geometry); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_differenceagg(public.geometry, public.geometry) (
    SFUNC = public._st_differenceagg_statefn,
    STYPE = public.geometry
);


--
-- TOC entry 1994 (class 1255 OID 26765)
-- Name: st_removeoverlaps(public.geometry); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_removeoverlaps(public.geometry) (
    SFUNC = public._st_removeoverlaps_statefn,
    STYPE = public.geomvaltxt[],
    FINALFUNC = public._st_removeoverlaps_finalfn
);


--
-- TOC entry 1993 (class 1255 OID 26764)
-- Name: st_removeoverlaps(public.geometry, double precision); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_removeoverlaps(public.geometry, double precision) (
    SFUNC = public._st_removeoverlaps_statefn,
    STYPE = public.geomvaltxt[],
    FINALFUNC = public._st_removeoverlaps_finalfn
);


--
-- TOC entry 1995 (class 1255 OID 26766)
-- Name: st_removeoverlaps(public.geometry, text); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_removeoverlaps(public.geometry, text) (
    SFUNC = public._st_removeoverlaps_statefn,
    STYPE = public.geomvaltxt[],
    FINALFUNC = public._st_removeoverlaps_finalfn
);


--
-- TOC entry 1992 (class 1255 OID 26763)
-- Name: st_removeoverlaps(public.geometry, double precision, text); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_removeoverlaps(public.geometry, double precision, text) (
    SFUNC = public._st_removeoverlaps_statefn,
    STYPE = public.geomvaltxt[],
    FINALFUNC = public._st_removeoverlaps_finalfn
);


--
-- TOC entry 1991 (class 1255 OID 26742)
-- Name: st_splitagg(public.geometry, public.geometry); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_splitagg(public.geometry, public.geometry) (
    SFUNC = public._st_splitagg_statefn,
    STYPE = public.geometry[]
);


--
-- TOC entry 1990 (class 1255 OID 26741)
-- Name: st_splitagg(public.geometry, public.geometry, double precision); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_splitagg(public.geometry, public.geometry, double precision) (
    SFUNC = public._st_splitagg_statefn,
    STYPE = public.geometry[]
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 212 (class 1259 OID 34899)
-- Name: data_demographics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_demographics (
    table_id bigint NOT NULL,
    user_id bigint NOT NULL,
    sex character varying(100),
    age character varying(100),
    education character varying(100),
    job character varying(100),
    income character varying(100),
    type_user character varying(100),
    language character varying(10),
    is_mobile integer,
    type_interview character varying(100),
    num_areas integer,
    num_removals integer,
    num_edits integer,
    time_session numeric(15,3),
    time_demographics numeric(15,3),
    time_draw numeric(15,3),
    time_sus numeric(15,3),
    cnt_escape integer,
    cnt_geocoder integer,
    cnt_layerchange integer
);


--
-- TOC entry 213 (class 1259 OID 34911)
-- Name: data_demographics_seq_id; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_demographics_seq_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 213
-- Name: data_demographics_seq_id; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_demographics_seq_id OWNED BY public.data_demographics.table_id;


--
-- TOC entry 214 (class 1259 OID 34914)
-- Name: data_sus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_sus (
    table_id bigint NOT NULL,
    user_id bigint NOT NULL,
    question1 character varying(100),
    question2 character varying(100),
    question3 character varying(100),
    question4 character varying(100),
    question5 character varying(100),
    question6 character varying(100),
    question7 character varying(100),
    question8 character varying(100),
    question9 character varying(100),
    question10 character varying(100),
    question11 character varying(100),
    question12 character varying(100)
);


--
-- TOC entry 215 (class 1259 OID 34922)
-- Name: data_sus_seq_id; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_sus_seq_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 215
-- Name: data_sus_seq_id; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_sus_seq_id OWNED BY public.data_sus.table_id;


--
-- TOC entry 207 (class 1259 OID 29287)
-- Name: eimg_raw_polys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eimg_raw_polys (
    id bigint,
    geom_4326 public.geometry(MultiPolygon,4326),
    eval_nr integer,
    eval_str character varying(15),
    att_nat smallint,
    att_open smallint,
    att_order smallint,
    att_upkeep smallint,
    att_hist smallint,
    centroid public.geometry(Point,4326),
    area_sqm numeric(10,2),
    geom_27493 public.geometry,
    timestamp_tz timestamp with time zone DEFAULT now() NOT NULL,
    time_draw numeric(10,3),
    order_draw integer,
    comment text,
    cnt_ctrlz integer,
    cnt_enter integer,
    cnt_vertex integer,
    user_id bigint,
    current_basemap character varying(100)
);


--
-- TOC entry 216 (class 1259 OID 35466)
-- Name: eimg_raw_polys_multi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eimg_raw_polys_multi (
    id bigint,
    cat_liked integer,
    cat_disliked integer,
    geom public.geometry,
    area double precision,
    attnat smallint,
    attopen smallint,
    attorder smallint,
    attupkeep smallint,
    atthist smallint
);


--
-- TOC entry 208 (class 1259 OID 29990)
-- Name: eimg_raw_polys_seq_id; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.eimg_raw_polys_seq_id
    START WITH 92
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 208
-- Name: eimg_raw_polys_seq_id; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.eimg_raw_polys_seq_id OWNED BY public.eimg_raw_polys.id;


--
-- TOC entry 217 (class 1259 OID 35472)
-- Name: eimg_raw_polys_single; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eimg_raw_polys_single (
    id bigint,
    geom public.geometry,
    area double precision,
    id_parent bigint,
    cat_liked integer,
    cat_disliked integer,
    attnat smallint,
    attopen smallint,
    attorder smallint,
    attupkeep smallint,
    atthist smallint
);


--
-- TOC entry 218 (class 1259 OID 35478)
-- Name: eimg_result; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eimg_result (
    id bigint,
    geom public.geometry,
    centroid text,
    category text,
    category_nr integer,
    ct_liked bigint,
    ct_disliked bigint,
    ct_nat bigint,
    ct_ope bigint,
    ct_ord bigint,
    ct_upk bigint,
    ct_his bigint
);


--
-- TOC entry 201 (class 1259 OID 22773)
-- Name: eimglx_areas_demo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.eimglx_areas_demo_id_seq
    START WITH 7
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1;


--
-- TOC entry 211 (class 1259 OID 34896)
-- Name: general_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.general_info (
    cnt_access_app bigint NOT NULL,
    cnt_access_draw bigint NOT NULL,
    cnt_access_viewer bigint NOT NULL
);


--
-- TOC entry 205 (class 1259 OID 26806)
-- Name: public_test_adduniqueid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.public_test_adduniqueid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 206 (class 1259 OID 26815)
-- Name: public_test_geotablesummary_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.public_test_geotablesummary_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 210 (class 1259 OID 31258)
-- Name: study_area_4326; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_area_4326 (
    id integer NOT NULL,
    geom public.geometry(LineString,4326),
    objectid integer,
    cod_sig character varying,
    nome character varying,
    idtipo character varying,
    perimetro double precision,
    area_m2 double precision,
    freguesias character varying,
    globalid character varying,
    shape__are double precision,
    shape__len double precision
);


--
-- TOC entry 209 (class 1259 OID 31256)
-- Name: study_area_4326_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_area_4326_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 209
-- Name: study_area_4326_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_area_4326_id_seq OWNED BY public.study_area_4326.id;


--
-- TOC entry 3551 (class 2604 OID 34913)
-- Name: data_demographics table_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_demographics ALTER COLUMN table_id SET DEFAULT nextval('public.data_demographics_seq_id'::regclass);


--
-- TOC entry 3552 (class 2604 OID 34924)
-- Name: data_sus table_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_sus ALTER COLUMN table_id SET DEFAULT nextval('public.data_sus_seq_id'::regclass);


--
-- TOC entry 3549 (class 2604 OID 30014)
-- Name: eimg_raw_polys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eimg_raw_polys ALTER COLUMN id SET DEFAULT nextval('public.eimg_raw_polys_seq_id'::regclass);


--
-- TOC entry 3550 (class 2604 OID 31261)
-- Name: study_area_4326 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_area_4326 ALTER COLUMN id SET DEFAULT nextval('public.study_area_4326_id_seq'::regclass);


--
-- TOC entry 3695 (class 0 OID 34899)
-- Dependencies: 212
-- Data for Name: data_demographics; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3697 (class 0 OID 34914)
-- Dependencies: 214
-- Data for Name: data_sus; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3690 (class 0 OID 29287)
-- Dependencies: 207
-- Data for Name: eimg_raw_polys; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3699 (class 0 OID 35466)
-- Dependencies: 216
-- Data for Name: eimg_raw_polys_multi; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3700 (class 0 OID 35472)
-- Dependencies: 217
-- Data for Name: eimg_raw_polys_single; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3701 (class 0 OID 35478)
-- Dependencies: 218
-- Data for Name: eimg_result; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3694 (class 0 OID 34896)
-- Dependencies: 211
-- Data for Name: general_info; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.general_info VALUES (0, 0, 0);


--
-- TOC entry 3546 (class 0 OID 21536)
-- Dependencies: 187
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3693 (class 0 OID 31258)
-- Dependencies: 210
-- Data for Name: study_area_4326; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.study_area_4326 VALUES (1, '0102000020E61000001E0200001D8C913AD24122C061D984669F5A4340DD1FE8BF1D4322C013A2BFB4755A43409ACCD5E4024522C0E511EABD535A434029C5E0A34D4522C0C6E5430E6D5A4340C0C63DA1A24522C00200E369655A4340E74D2EE3FD4522C08B5D5F306D5A4340D6E2C2478D4922C090B9E0A0375A43407AE5946D484A22C0468E1BCD205A4340553D5B48224B22C0270CA0C9185A4340F8BB4BB0654B22C0880C0342385A43407D8D940F5F4C22C0BF623827495A434001F2252C3B4F22C01545D2202E5A434023EF5A1F1F4F22C0E47C41E9135A4340C51FC04ACF4F22C0841DD9FF075A43401D03287E615022C0BE861AD70C5A4340DD5591594D5122C09874318E055A43407801E493635122C0B115663CEC594340CF501998575122C0C25DCF10E2594340864C42F91C5022C0C578530BE9594340182C6E34685022C05F81A047D85943405AC6D2EC165322C07C874AAFB559434047B9BF316E5322C086F4FEB2955943401F73A9F1DA5922C0D8F95A6D47594340E99D776A135A22C07C1186FD7159434025DD4F7C0F5A22C0E0CBB4AF765943408561BF658D5922C0EF0E6D0E7C594340709044B3CE5922C03EF512ACC45943408F2B7A25D35922C058D23B9EC959434007CC45DAC95922C08F766AA8D059434095836C46C95922C0A9901017D1594340477BBFAEBE5922C0AB539E1DD9594340F4B43D3D595922C040F6B5EA255A4340E75C2C7D585922C0648DF97C265A43404C790539565922C0B2130533285A4340F06CF710275922C0867D3890525A43402AA56AF5235922C008A28C5A555A4340E0F67487235922C0489DC8BD555A43404860DEE4205922C0687C081B585A4340416AE1A9195922C08D7FD3D95D5A434014C4CE8F155922C06EEF346C615A434065E4DD4B135922C0BA538668635A4340236124400B5922C0E293F16B6A5A434049A8F0E8095922C0974D27486D5A4340AA8A0871095922C022FE5B4C6E5A43407B837BD8075922C0E8B57BB1715A4340338FEFFA025922C0F44AD1187C5A4340C523914B025922C08D2072887D5A4340CBC1F4FCFA5822C013A249DB8C5A43402CFA3390F05822C00D9C4FB1A25A4340D1B0CB92EC5822C09EA125FBAF5A4340399693B0EB5822C0748D02EDB25A434064DDD182F05822C000CC1F56C55A434035F82291F95822C028C3DB4BCB5A43405E9A435C155922C0B2D38B6BD95A4340998EF3CE475922C09C14560DF35A4340B26DF83C525922C0EA11E087F85A434021475D7B5C5922C08F55D9EBFD5A43404897E5A9AB5922C08334FB8D275B4340442F60E9B75922C06CFA63F02D5B4340E6D3CBB6BC5922C01FC1E575305B4340E42C1C48DC5922C0852C0140415B434081B4B344F15922C04ED982CD4C5B43403C62C26C065A22C0D1D99172585B4340EE2B3B0E155A22C0714092B0675B4340340DB261165A22C0991107D46B5B4340B3F118F4165A22C0F66B889D6D5B4340FD71B73B105A22C06DDC7F2C7D5B4340105B33360F5A22C05EE6F68E7F5B4340929951BF0E5A22C0AE19ABA2805B4340D92E5CAC045A22C00CDA4F7E8E5B4340BFCF998BC95922C0E5ECD44ABF5B4340AD5DEAB1A35922C00694143ADD5B43401BE418A1965922C0EE41AB8EE75B43406CE461168E5922C0965229E7EF5B4340EE14EFBF8C5922C0259351C6F25B4340C46DFE538B5922C002A908D6F55B43404ECBC9528A5922C0AA44AEB2FC5B4340A9FAD1A7895922C0A445F73D015C43407D1BAC2F8A5922C05D374D5D0A5C434070181069915922C01F0E975F165C4340865EAD06985922C00E4C85E51C5C4340B565439E9C5922C0AB1BCF6D215C4340C060F432AC5922C0A29B52B32A5C43404035528DB25922C00651BE7A2E5C43400D778AC4BF5922C08A634BB9375C4340CEBC8D00C95922C04E8CF02D3E5C43405BB28FF3D25922C050CC1AD6485C4340F056112ED45922C09BBFF7BC505C43403332773ED05922C0031188605D5C4340E05EC317CB5922C02D0EA91C625C43403D5934C5BA5922C0F00EDF0B6F5C4340C8E32D869E5922C0A2F73DF0815C434071F441339B5922C065B28329845C434007680F3C915922C0739058B3895C4340BE4F7E4B8E5922C01BE1BB568B5C43409B7AE190945922C0B7D1FCB58B5C4340D640F36C9C5922C06D68402D8C5C4340B2F55F6BF05922C012EB9829915C4340FF2424920D5B22C079D9B015A25C4340078A9E54195B22C0F76D29C8A25C4340C6258583225B22C0F5677753A35C434023B229A4325B22C0EE3BB948A45C4340F93D7D00335B22C073589231A75C4340F3E013A3335B22C035F25C74AC5C4340E8A68DBB335B22C09BFDF53EAD5C4340BD9D444C2C5B22C01C66D21BAF5C43403743A3EA1F5B22C03E44E435B25C434094D1FC10C55A22C05144AC38BB5C4340738E4C26BD5A22C0F69DAB01BC5C434070EEEDD87C5A22C0F5F7832CC05C434013525033C75922C0ED9A16F2CB5C4340CF802BE9805922C0ABBF7901D25C43403C5C3ACD7F5922C03274BB23D25C4340F0475E41715922C0AB60F1E4D35C4340A78C28EC525922C0E1B3A4EFDA5C434017273886355922C04F1E41F3E55C4340163BA398285922C071772905EB5C4340B49ED2311D5922C0ED4E06D3EF5C4340B640EB470A5922C0ED24CF3AFA5C4340DCB425C2035922C0F9C586B3FE5C4340CE51161D035922C0DEEAC998025D43401BE3EA3C045922C0034E479E045D43405A314F4E085922C0F8B11FED065D4340033E751B135922C08801A6930B5D4340B3653CCD2B5922C0515F3631155D4340E20FE8D13B5922C0893529CB195D4340302268BC915922C090BE1A51255D4340A03C1CE7E95922C06E83BF7A285D43407B8A28DD1D5A22C016CB4358305D4340180275114C5B22C036FC01B6735D4340E228EFA9DB5B22C06E6B4768955D4340FDC234D6295C22C0A5E40A79A65D434020ED377E3C5C22C0AE5EF6D7B25D4340BB727B47225C22C06377F4BCBA5D434013C1AF6CC85B22C05BAA2370C25D434018021B26435B22C0DC696CDACC5D434024BEAB22325B22C01C4CFA72CD5D4340BD709F9D295B22C0F59975A7CD5D434045239318215B22C0CD68F2DBCD5D4340643D6BC40C5B22C02F42E4ABCD5D43406CF31CCBF15A22C00E662612CD5D434073A2E4FFEB5A22C0C037DBCCCC5D4340CD47640EEB5A22C0AD6893C1CC5D43408B34B522EA5A22C0C3D290B6CC5D4340334299E8AF5A22C0552D20FDC95D4340FB4564166A5A22C0A1B571F5C65D43401472C4E6615A22C09E12779AC65D434039950E504D5A22C0F588B9DBC55D43406430C7C8475A22C0D3092B9CC55D4340B6116E65385A22C0D7714EEBC45D4340C3F3B64C285A22C0478B81F4C45D4340044FD696115A22C032BC4C90C55D4340B24586F9075A22C0A5650ED0C55D4340307B7A7FFF5922C053C63408C65D434033016AA8E85922C037C20101C75D4340A56A93C3C45922C043B2AAC9C95D4340A98F7E06AD5922C0BCBD60ADCC5D4340D4BFB2A7985922C086B8BD33D05D4340F5B13735945922C0282CB3F8D05D43406B1FBBB2925922C01E7C9751D15D434098CE2FF77A5922C0C0683CC6D65D4340E9060A026F5922C0EDC571E3D95D43400BC83449685922C06E6796A3DB5D4340BDB6BB08555922C08FC9899EE15D43408095DFA43E5922C03BF0C277E75D43409CAD251C3E5922C0564C779BE75D43405C1D0A6F385922C02CE10717E95D43408EA287FC275922C0A54864EAEF5D4340601E48B92A5922C02A8CC069F35D4340E731C1B52E5922C0FB513381F85D4340D1955FF73D5922C079258C96FD5D43405FE7AF0B565922C050B213E7005E434041BD71E4395922C07676503F475E434047E161A1045922C0A1FD6123935E4340C9329E76B25822C00C9DCDC59D5E4340BCA56A20725822C0221A6819A65E4340258AC3F0575822C05D05C35EA35E43403533A12C395822C027B5C68BA05E4340C6E396231F5822C0B72501B79E5E4340014656E7055822C0E059CCAD9D5E4340371D230DF65722C09EA37A459D5E43405C563638E65722C05CADD1379D5E4340742CB5B3D35722C0F8F697A49D5E4340DCF53274C35722C07705DA359E5E4340ABA7CC5EB35722C0947D76039F5E4340932FA80DA85722C06DDCDA9FA65E43409495AC43945722C0A7E4FF51B05E43401D79BFB88F5722C0280BDC92B25E43409AC8D7466C5722C06EA68741BF5E4340FCB257FA5E5722C08510EB4AC15E43409A7BABD94C5722C0BAB754D9C55E4340C0803AEE3C5722C085733D7CC95E4340C301DFE7205722C09DBDF6F2CE5E43400AF13F7FFF5622C04193A429D55E43401B1C0649FB5622C0963DA1D4D55E434061097751EE5622C0A65A05E3D75E4340CEE6AECF725622C049B10982E95E4340BC5BEDF74A5622C07EEC3F31EF5E43406B36994C3F5622C019A277DEEB5E43409B57CE473D5622C0A747494BEB5E43404D3E33C52D5622C0107A4E36E65E43407FBC2A78BA5522C0203DC06EC05E43408D251621AE5522C0F4561316BC5E43403C21506E9E5522C03C43958EB65E43401B006E97855522C0F609DECEAD5E43405171FE22555522C0EF5D4459A45E434093585787355522C0F9817BAD9E5E434006944998F45422C03C213CC7965E434001C703F9F25422C0670DB794965E4340F37220AE495422C0277B0FE48E5E43404943B443DB5322C086B002E0895E4340E687F949D15322C0C6D5FC6B895E43404220ED0A6C5322C0330976A9845E43407D1ABEF9475222C08AEB0DEE765E4340B0FA4F67335222C069286EF6755E4340EAE7EB28095222C02F5EF0F9735E4340A2EC39D9F95122C0C50AF99E745E434076EE0AFCE55122C0724B1375755E434062B874F8E35122C0FA4EC88A755E4340B4E9964BDD5122C0DADBBBD2755E4340A79602D5D15122C04589494E765E4340971133A1A45122C0B67211117B5E4340AF7FD0D29F5122C0A0EAA6927B5E434017389956935122C0204447E37C5E434084713F1C5D5122C088CB6499825E4340858484225B5122C05C30A7CE825E4340747F7C1D415122C04616338C855E43409C286117C15022C00469CB04935E4340A19B53F4A35022C092635F1C965E4340052E54A7365122C0B642F123C65E4340B26C948E4C5122C0430B564BCD5E4340580B0EB8565122C0BFD20D9DD05E434067C24DAB5F5122C0873D871CD45E4340B03B7C28615122C001F18FB1D45E43406597E36A625122C057468B2FD55E43404AF44084035222C02720E6FCD25E4340541F6CE9D25222C0C7880B88D25E4340EB9266B9045322C04C37471ED35E434034280F10105322C0A2EB5C6ED45E4340E0708FA6125322C0068412BBD45E434010794B7D175322C0B4BD7F4AD55E4340B51AAB02605322C052180BB0DD5E4340E2595569625322C06D02F007DE5E4340F616AFD17E5322C0D05EC117E25E43403DCDF68AF85422C01B761419185F4340A26047492B5522C000B7465A1F5F434094CD1ECD3C5522C0AE7653DB215F43401B97AE51F45222C0E085C370605F4340CD3C6A67F15222C07E75B0C0605F43403DD88E63E45222C0A91A6E25625F4340FFCE9A4FD95222C06DBF1755635F4340A52C1E61D55222C02DE8DEC0635F434087B7C116D25222C00BE83112645F434082E43DC0D35122C026537EA07C5F4340C676A515605122C0B641D22B865F43408321C0B9055122C07FA677A08D5F43406FD737F1CB5022C09ED117B1925F4340DDA3806D825022C0D515F994975F4340845516123A5022C0F9E51E659C5F4340C6F589DF335022C06C6112B79C5F4340FCF2BC3F9A4F22C046F04EA6A45F4340F1E5D50F9D4E22C0FD670418AE5F434065C45313924D22C07A5805CDB85F4340CA03E6A2754D22C074E2D7D4B95F4340BA0FABDBFC4C22C042F03C35BE5F4340806855B4EE4C22C06D2888B8BE5F43408693D7C2854C22C08FFA1586C25F434015EADE75014C22C0B481D0C2C65F4340DCF75F28FD4B22C0FBFCF1EEC65F43403925360EFA4B22C06D2BB30DC75F434073AF9131F54B22C0B87F0A1BC25F434087110B3FF04B22C0BE711312BD5F4340588D85A2984B22C0E38FD9E6635F43404D68F3F6974B22C014B33738635F43408A4C36C0974B22C0532E7D00635F4340356DDB3B914B22C08AB2025E5C5F434091934CF48E4B22C084C0E90B5A5F43407B489205884B22C0E6174C3C505F4340B1F8B35BEE4A22C07A776B6F575F434053ADED71804A22C0F03CB7955C5F43407F1B150B7F4A22C0A0DD13995C5F434034E260B76D4A22C011DBBBB05C5F4340DF18D3F3FE4922C062FD96945E5F4340639B36ABEA4922C0D5655A8F5E5F4340D66F0B785E4922C080141D6B5E5F4340C3FE27BF244922C097E62A5C5E5F4340888F74D7F74822C0A9CE87505E5F4340D65FEA54AB4822C0EEF4ACB05F5F43403CB3A7E76B4822C039BBFD79605F4340FDE0DEDDEE4722C0BA03CC29625F43403220E2A8CD4722C08EA318E6615F43402326BEDFCB4722C0F7CA73E2615F43402ECDC072914722C04D3BD921635F434070B983A5814722C0A3F378A3635F4340A870B6C47A4722C02DB54CC8635F43401E00962C624722C0F303F84B645F434042A0004E9D4622C0664F4277675F43403DBFAF57454622C05E102FF4685F4340B84FD581F54522C05C9628306A5F4340F564D7DCA04522C0BC26C1B26B5F434062AA8DBA0B4522C024D2C5E06D5F43403AF863B7F54422C05E2FF3906E5F4340F2E183CDF44422C09BE242986E5F43407E67EEF6B24322C0E27FCEA7785F43400B3D0FD0334322C08BBC0BF77A5F4340910F27EC304322C0A7B27C047B5F43404B1FF1C4FF4222C0846084EF7A5F4340BC6EBCD5CC4222C0B173C5D97A5F4340EB5BF2C4CC4222C0802675417B5F4340A0ECB7CDC94222C08783BBA68D5F4340FC0D5D21CD4222C0434D6DBA8D5F43402B729795DA4222C023AB200A8E5F434009FB36BAD94222C092B39676905F4340210FA75CD94222C0EAAC687F915F434087994DF9D74222C0E770F8E5955F434052F246EDCE4222C0A96151BEAB5F4340B416CE23CD4222C0B367FA2BB05F43408625B78FC94222C063F9CE08B95F434016C34B06C94222C0BBB79B0FBA5F434099724560C84222C0700E064DBB5F4340184E2F65C54222C04CF624FDC15F4340FBE5A414C54222C05DEE26B2C25F4340B5DA3147B34222C093D00C48C55F434070FADE61B14222C0FD23968EC55F434025491650B04222C0CF9D3404CC5F4340E3F1C717AF4222C005FFC562D35F43407CAEB817A84222C006137A65D35F434014920FD8A44222C0D905B666D35F43400AACC84A9C4222C0B676896AD35F4340183DCA5A974222C03FB25A7ED35F4340DC3DC82E954222C0A799FC87D35F434024867BF5884222C08FFF360ED35F4340C3AD2BE6834222C02C2252A6D25F43406E18F7897F4222C032AFA14CD25F43408449F342774222C02A56117CD15F43403FFFCDFD6A4222C06F5F3C2DD05F4340E56C2C695C4222C0EA833E43CE5F4340C3826462504222C0CB139374CC5F4340F50EDC54464222C0940CCB5DCA5F43407C7EB41C3D4222C066EBE20DC85F4340A09809C2324222C07FDB3669C55F4340B1524574294222C0C60FB398C15F4340BB7C33F9134222C07A209B18BB5F4340A680DF5E054222C01807FCACB65F43402E572BAA014222C0F8191E60B55F4340305001C9004222C0E4C5AB10B55F4340245600DBF44122C06F1FDAE0B05F43403CF6AF71CC4122C09B0A5994A45F4340B37406AABB4122C061131AE59E5F4340DFA7F0209E4122C0833A4E36965F4340F70A3B129D4122C05F288AE7955F43406E3EC4AD944122C067EB5849935F4340C86E96527F4122C0F18F3CA38C5F43405A992C956B4122C01E6D49F5845F434084D8CDC95F4122C0165C3A82805F4340EC4139F85D4122C0AC9D67D27F5F4340EC7A31F3394122C02107B149765F4340704B9808354122C04D2B33A2745F434022136FAF304122C03DFC3D76735F434030C572B22E4122C0A12620ED725F43408539773D2B4122C0C48F1551725F4340D4B8ADCB234122C03F3B1C01715F434050AA605F1A4122C0F8B39DCC6E5F43404D5598DB164122C0229017FA6D5F43400C36AD5A0D4122C07FC4F5046C5F4340B02E33A3074122C079B498D76A5F4340F158AE4E014122C0C29A26C5695F43409DF63353FB4022C0D8EF09C2685F4340AF7A93B2E24022C0BBB99C16655F4340EBB948B6DD4022C0D569A558645F434022DF9B40D34022C0933115CA625F4340FADEB25DBA4022C084C176575F5F4340D1C338C3984022C03DB9374E585F4340A41CB75B7B4022C04B472816545F4340CE9DA292774022C08A22548B535F43408F51BFD86F4022C07C1C1094525F4340AD4EC722624022C0BF598FDD505F43405414C7C2434022C03DABBDC34B5F43402C5E3BE5344022C0D56BA0DA495F4340089F30A9214022C0B6AEDBE3465F43407548C1D81E4022C09A9CCC74465F43406ED7C310E73F22C0880863933E5F43405C465413D13F22C02F8A0B3C3C5F43400C624D13AF3F22C0916BF915385F4340DF413183A13F22C056590C98365F43407667DAF0873F22C05EA89FC7335F43400132E1746D3F22C021217239325F4340D655CFF9583F22C07E0E2B45315F4340D4D84CCB573F22C03E752535315F4340A059A4E04D3F22C01F4CC8AE305F434093ACA92C3E3F22C04D4F17292F5F4340FC9DDFF9353F22C0CD980F572E5F4340893C52C2323F22C0DA5EC8042E5F4340709F78841A3F22C03CC360122B5F43406808FE50EB3E22C0022C0256255F4340A6E1AD97CD3E22C0BFC50E4B215F43400D905A919E3E22C00913091D195F43402C3879E7813E22C014D8F11E145F434064E6A3573C3E22C0D53FA67D095F4340E6C3C0E2043E22C034A6DDFFFC5E4340D8319FA0F53D22C02CC6F624F95E43400B3C034CEE3D22C00F353520F75E4340DB20026FEB3D22C0CD690056F65E43409ED3A7BCE83D22C05EEE8F97F55E43403FA15C38D83D22C0432ED30AF15E43403FFBFC3AAE3D22C076E86E38E85E43405ECAA0F09F3D22C0BD6E0738E55E43400864F2C59A3D22C07D0F683EE45E4340A9A578F7963D22C0C8F99986E35E43406C8E6D0B7E3D22C0F3DACAD2DE5E43402BA49CC8163D22C037FDDFB0C75E4340BD36A01D963C22C0E7CEF7D4A95E434019784E7C743C22C06318E7A7A15E4340C492F391583C22C039B1ADDE9A5E4340F5C283EF4D3C22C0677E7148985E4340B59459B9403C22C022A78598915E43405A8F90083D3C22C03E8BB0BA8F5E4340A11F13DC393C22C0D05E671D8D5E434030655076363C22C02B9AC0B8895E43400764F9CC303C22C0FF884A16845E434096E0C69C2B3C22C0BD6BA933805E43403A1E5FBB2A3C22C09B8F0EB87E5E4340F455B449293C22C04F237C4F7C5E4340B643A863273C22C0D6D49E677A5E4340FA91D597233C22C00130B3E7795E4340B1499A07223C22C0020BEAB5795E434049BBB46B203C22C0E4B3A582795E43408A688953EB3B22C0DE97FFE8725E43404BE3876BE43B22C0CB110F0D725E434063106833DA3B22C08353FDFA705E4340F980BBFCAB3B22C060A881246C5E4340BFCA54FE9E3B22C08A645EC86A5E43404DA97A9E943B22C0F3AE7DE7695E4340A93BA4BF583B22C0A8828CCD645E4340FDC8DB85573B22C0CBB0143F625E43401D0F6383563B22C097457754605E4340235DB938563B22C0E0E238C35D5E4340F9B7D55C553B22C00D2986D85B5E4340DD88693A543B22C0F6DCE1665A5E43406AC431E6513B22C00A5DC52A595E43403ECD5AFB4E3B22C0982AFC32585E4340F41D13414A3B22C05F1D9F34575E4340F0DB4B45383B22C0C8F570A4535E43407B6978D51C3B22C00F3898204E5E43404DE2D9B51A3B22C0F662C6E34D5E4340BC92CF12173B22C061EC0E8B4D5E43401E62F34D133B22C0457EC3FC4C5E4340615818C1113B22C0F23EE8C14C5E43405B03D3760F3B22C0EBE51F3B4C5E4340BFCAB1610E3B22C0B32641BB4B5E43408805455C063B22C0DF262FE74D5E4340A257AA61033B22C08B49068F4E5E4340CB347FFE003B22C05242A8014F5E43401616E9B0FD3A22C06C3AE33F4F5E4340996870AEFA3A22C0DCEC2C584F5E43406DF86B01F63A22C0AD35944B4F5E43406980FB53F13A22C055DE6D374F5E4340924D8E0AEC3A22C00F4862054F5E43403ABDD459E73A22C0F56ACAB44E5E434093753684D83A22C0155D14964D5E4340BA08D1F6C13A22C03BABF5EB4B5E43404932FB10B73A22C022413F1E4B5E43401AB04265AD3A22C035011CB24A5E43406A1D354DA63A22C0434F96884A5E4340839CFF249B3A22C0B86B7B7F4A5E4340CA135EFC8F3A22C0CF65D16E4A5E4340159B6171883A22C04329A6544A5E4340E631A1B4823A22C07ADF652A4A5E434014FF336B7D3A22C01C425AF8495E434057B18D84773A22C0B67ABD91495E4340C0D3FA89703A22C09BCCEAC1485E434027038243643A22C0192BB692475E4340FAD6EE045B3A22C02E8770AD465E4340DA76E450563A22C02C036720465E4340F066A26A533A22C012C9B77B455E4340D76D973F4D3A22C00CAF31F5425E4340BCC6008C493A22C00B15426E415E4340D89C8839453A22C0F32289943F5E4340D5CC85633F3A22C087B0679D3D5E43406BA01D773A3A22C09D7490CB3B5E43404DC7388B2F3A22C02EE8C6CD375E43401DB3D9F82A3A22C0F1C82B13365E4340519E18C5263A22C0A670A37C345E43404C2F9D0E233A22C07D29CFC0325E434013D887511F3A22C02ADD188C305E4340DE8C73AA1A3A22C07E668A2A2E5E43408C349C7B183A22C08357AED72C5E4340CF6635FA173A22C0C8E398DE2B5E43404FFD06E9183A22C048A4B0BC2A5E43408BECCAD0193A22C014B9E2A6295E434052DD8A2D0B3A22C0E0F7E69C265E4340E6DE4ACFD03922C03FF96980255E4340671F329DCF3922C0B6E5A269255E4340FF2B1E35A53922C0A7999F55225E4340A1E302512A3922C066BE1468195E4340E29C3384D13822C0ECFA652A115E43407C0B2733A73822C05CD3AC3C0D5E434068AA8852873822C07AFA3C470A5E4340DB9DC4AB033822C03B300C49FC5D4340D95D31BDE93722C0F6A68649025E4340EBA84D0FD03722C08F35DAD6065E4340828E4E75C13722C00E5F0A6D095E434056391A08AF3722C05B7B88770D5E43407DD66B49AE3722C0D831BDA00D5E43405C0E91F59B3722C0B232C8E80A5E43402CBF10BB633722C008673A91025E4340B68921BB2B3722C037803219FB5D4340A8938D3AC43622C03850AE76325E4340C2006994AA3622C059BBB22F405E434075A30E9F633622C05587EA22665E4340DE3F675F193622C04E8F5F7E515E43407314F7A0043622C09645091D4B5E43403E4AAF87A43522C0F94F3156455E4340CF4FC08C893522C0603409AC435E43407C9B6C5E743522C0232A605E425E4340791CDF3D683522C0E518BD98415E434001C025494C3522C0A7CAF0DD3F5E4340C6B6D3DA413522C0584F01363F5E43404CB8C0764E3522C0E3E43A8D375E4340B7B487C2573522C0EBF47311315E4340D8D89BAE393522C08B848B982F5E4340C30677250B3522C003F620A12D5E43405B505FA8193522C036501976205E43405E475008313522C01A8FA8640A5E4340E165F5C7393522C0BE089B6E025E43402571B65C2F3522C0C5FD2B8C015E434051864715013522C01B1AA49FFD5D4340E92A41B9FF3422C05CE29DBAF75D4340D77E3859FF3422C05DE67017F65D4340FAF4D4BEF53422C0D5569DF6F45D4340A2CE93128F3422C07FC218EBE85D43401A96BC41C83522C0AC8462846B5D43401F7420E5CE3522C082B5C4F8145D4340D718378FE23722C0AED0A1D9A25C43404B674A30453822C0B549A8BDB25C43406AC4ACFB1F3A22C0762E08073F5C4340112FB88F673B22C0BFEAA24FF05B4340B9D2DF46093C22C04EDE06D3C65B43401DE9B954763D22C023F75657855B4340D563E2486B3D22C0A51F79507F5B434091E5BB2F094022C028D0A4CFDB5A43401D8C913AD24122C061D984669F5A4340', 23, '105', 'Arroios', '4015', 8240.3799999999992, 2127871.8799999999, 'Anjos + Pena + SÃ£o Jorge de Arroios', '2eff2d79-e076-4a72-8df3-f2e7d49254b2', 3500783.45703125, 10572.552803265);


--
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 213
-- Name: data_demographics_seq_id; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.data_demographics_seq_id', 31, true);


--
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 215
-- Name: data_sus_seq_id; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.data_sus_seq_id', 21, true);


--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 208
-- Name: eimg_raw_polys_seq_id; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.eimg_raw_polys_seq_id', 209, true);


--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 201
-- Name: eimglx_areas_demo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.eimglx_areas_demo_id_seq', 124, true);


--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 205
-- Name: public_test_adduniqueid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.public_test_adduniqueid_seq', 3, true);


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 206
-- Name: public_test_geotablesummary_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.public_test_geotablesummary_seq', 12, true);


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 209
-- Name: study_area_4326_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.study_area_4326_id_seq', 1, true);


--
-- TOC entry 3560 (class 2606 OID 34906)
-- Name: data_demographics data_demographics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_demographics
    ADD CONSTRAINT data_demographics_pkey PRIMARY KEY (table_id);


--
-- TOC entry 3562 (class 2606 OID 34921)
-- Name: data_sus data_sus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_sus
    ADD CONSTRAINT data_sus_pkey PRIMARY KEY (table_id);


--
-- TOC entry 3558 (class 2606 OID 31263)
-- Name: study_area_4326 study_area_4326_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_area_4326
    ADD CONSTRAINT study_area_4326_pkey PRIMARY KEY (id);


--
-- TOC entry 3553 (class 1259 OID 29316)
-- Name: sidx_eimg_raw_polys_geog4326; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sidx_eimg_raw_polys_geog4326 ON public.eimg_raw_polys USING gist (((geom_4326)::public.geography));


--
-- TOC entry 3554 (class 1259 OID 29315)
-- Name: sidx_eimg_raw_polys_geom27493; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sidx_eimg_raw_polys_geom27493 ON public.eimg_raw_polys USING gist (geom_27493);


--
-- TOC entry 3555 (class 1259 OID 29314)
-- Name: sidx_eimg_raw_polys_geom4326; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sidx_eimg_raw_polys_geom4326 ON public.eimg_raw_polys USING gist (geom_4326);


--
-- TOC entry 3556 (class 1259 OID 31270)
-- Name: sidx_study_area_4326_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sidx_study_area_4326_geom ON public.study_area_4326 USING gist (geom);


-- Completed on 2018-12-17 12:52:17

--
-- PostgreSQL database dump complete
--

