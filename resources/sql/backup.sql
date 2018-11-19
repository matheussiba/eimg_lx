--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 10.5

-- Started on 2018-11-13 19:45:43

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 21227)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- TOC entry 1934 (class 1247 OID 26712)
-- Name: agg_areaweightedstats; Type: TYPE; Schema: public; Owner: postgres
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


ALTER TYPE public.agg_areaweightedstats OWNER TO postgres;

--
-- TOC entry 1937 (class 1247 OID 26715)
-- Name: agg_areaweightedstatsstate; Type: TYPE; Schema: public; Owner: postgres
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


ALTER TYPE public.agg_areaweightedstatsstate OWNER TO postgres;

--
-- TOC entry 1940 (class 1247 OID 26757)
-- Name: geomvaltxt; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.geomvaltxt AS (
	geom public.geometry,
	val double precision,
	txt text
);


ALTER TYPE public.geomvaltxt OWNER TO postgres;

--
-- TOC entry 1447 (class 1255 OID 26719)
-- Name: _st_areaweightedsummarystats_finalfn(public.agg_areaweightedstatsstate); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public._st_areaweightedsummarystats_finalfn(aws public.agg_areaweightedstatsstate) OWNER TO postgres;

--
-- TOC entry 1446 (class 1255 OID 26718)
-- Name: _st_areaweightedsummarystats_statefn(public.agg_areaweightedstatsstate, public.geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._st_areaweightedsummarystats_statefn(aws public.agg_areaweightedstatsstate, geom public.geometry) RETURNS public.agg_areaweightedstatsstate
    LANGUAGE sql
    AS $_$
    SELECT _ST_AreaWeightedSummaryStats_StateFN($1, ($2, 1)::geomval);
$_$;


ALTER FUNCTION public._st_areaweightedsummarystats_statefn(aws public.agg_areaweightedstatsstate, geom public.geometry) OWNER TO postgres;

--
-- TOC entry 1444 (class 1255 OID 26716)
-- Name: _st_areaweightedsummarystats_statefn(public.agg_areaweightedstatsstate, public.geomval); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public._st_areaweightedsummarystats_statefn(aws public.agg_areaweightedstatsstate, gv public.geomval) OWNER TO postgres;

--
-- TOC entry 1445 (class 1255 OID 26717)
-- Name: _st_areaweightedsummarystats_statefn(public.agg_areaweightedstatsstate, public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._st_areaweightedsummarystats_statefn(aws public.agg_areaweightedstatsstate, geom public.geometry, val double precision) RETURNS public.agg_areaweightedstatsstate
    LANGUAGE sql
    AS $_$
   SELECT _ST_AreaWeightedSummaryStats_StateFN($1, ($2, $3)::geomval);
$_$;


ALTER FUNCTION public._st_areaweightedsummarystats_statefn(aws public.agg_areaweightedstatsstate, geom public.geometry, val double precision) OWNER TO postgres;

--
-- TOC entry 1456 (class 1255 OID 26732)
-- Name: _st_bufferedunion_finalfn(public.geomval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._st_bufferedunion_finalfn(gv public.geomval) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT ST_Buffer(($1).geom, -($1).val, 'endcap=square join=mitre')
$_$;


ALTER FUNCTION public._st_bufferedunion_finalfn(gv public.geomval) OWNER TO postgres;

--
-- TOC entry 1455 (class 1255 OID 26731)
-- Name: _st_bufferedunion_statefn(public.geomval, public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public._st_bufferedunion_statefn(gv public.geomval, geom public.geometry, bufsize double precision) OWNER TO postgres;

--
-- TOC entry 1400 (class 1255 OID 26736)
-- Name: _st_differenceagg_statefn(public.geometry, public.geometry, public.geometry); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public._st_differenceagg_statefn(geom1 public.geometry, geom2 public.geometry, geom3 public.geometry) OWNER TO postgres;

--
-- TOC entry 1474 (class 1255 OID 26762)
-- Name: _st_removeoverlaps_finalfn(public.geomvaltxt[]); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public._st_removeoverlaps_finalfn(gvtarray public.geomvaltxt[]) OWNER TO postgres;

--
-- TOC entry 1471 (class 1255 OID 26759)
-- Name: _st_removeoverlaps_statefn(public.geomvaltxt[], public.geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry) RETURNS public.geomvaltxt[]
    LANGUAGE sql
    AS $_$
    SELECT _ST_RemoveOverlaps_StateFN($1, geom, NULL, 'NO_MERGE');
$_$;


ALTER FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry) OWNER TO postgres;

--
-- TOC entry 1473 (class 1255 OID 26761)
-- Name: _st_removeoverlaps_statefn(public.geomvaltxt[], public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry, val double precision) RETURNS public.geomvaltxt[]
    LANGUAGE sql
    AS $_$
    SELECT _ST_RemoveOverlaps_StateFN($1, $2, $3, 'LARGEST_VALUE');
$_$;


ALTER FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry, val double precision) OWNER TO postgres;

--
-- TOC entry 1472 (class 1255 OID 26760)
-- Name: _st_removeoverlaps_statefn(public.geomvaltxt[], public.geometry, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry, mergemethod text) RETURNS public.geomvaltxt[]
    LANGUAGE sql
    AS $_$
    SELECT _ST_RemoveOverlaps_StateFN($1, $2, ST_Area($2), $3);
$_$;


ALTER FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry, mergemethod text) OWNER TO postgres;

--
-- TOC entry 1470 (class 1255 OID 26758)
-- Name: _st_removeoverlaps_statefn(public.geomvaltxt[], public.geometry, double precision, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public._st_removeoverlaps_statefn(gvtarray public.geomvaltxt[], geom public.geometry, val double precision, mergemethod text) OWNER TO postgres;

--
-- TOC entry 1459 (class 1255 OID 26740)
-- Name: _st_splitagg_statefn(public.geometry[], public.geometry, public.geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._st_splitagg_statefn(geomarray public.geometry[], geom1 public.geometry, geom2 public.geometry) RETURNS public.geometry[]
    LANGUAGE sql
    AS $_$
    SELECT _ST_SplitAgg_StateFN($1, $2, $3, 0.0);
$_$;


ALTER FUNCTION public._st_splitagg_statefn(geomarray public.geometry[], geom1 public.geometry, geom2 public.geometry) OWNER TO postgres;

--
-- TOC entry 1458 (class 1255 OID 26739)
-- Name: _st_splitagg_statefn(public.geometry[], public.geometry, public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public._st_splitagg_statefn(geomarray public.geometry[], geom1 public.geometry, geom2 public.geometry, tolerance double precision) OWNER TO postgres;

--
-- TOC entry 1443 (class 1255 OID 26709)
-- Name: st_adduniqueid(name, name, boolean, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_adduniqueid(tablename name, columnname name, replacecolumn boolean DEFAULT false, indexit boolean DEFAULT true) RETURNS boolean
    LANGUAGE sql
    AS $_$
    SELECT ST_AddUniqueID('public', $1, $2, $3, $4)
$_$;


ALTER FUNCTION public.st_adduniqueid(tablename name, columnname name, replacecolumn boolean, indexit boolean) OWNER TO postgres;

--
-- TOC entry 1442 (class 1255 OID 26708)
-- Name: st_adduniqueid(name, name, name, boolean, boolean); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_adduniqueid(schemaname name, tablename name, columnname name, replacecolumn boolean, indexit boolean) OWNER TO postgres;

--
-- TOC entry 1388 (class 1255 OID 26735)
-- Name: st_bufferedsmooth(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_bufferedsmooth(geom public.geometry, bufsize double precision DEFAULT 0) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT ST_Buffer(ST_Buffer($1, $2), -$2)
$_$;


ALTER FUNCTION public.st_bufferedsmooth(geom public.geometry, bufsize double precision) OWNER TO postgres;

--
-- TOC entry 1440 (class 1255 OID 26704)
-- Name: st_columnexists(name, name); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_columnexists(tablename name, columnname name) RETURNS boolean
    LANGUAGE sql STRICT
    AS $_$
    SELECT ST_ColumnExists('public', $1, $2)
$_$;


ALTER FUNCTION public.st_columnexists(tablename name, columnname name) OWNER TO postgres;

--
-- TOC entry 1439 (class 1255 OID 26703)
-- Name: st_columnexists(name, name, name); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_columnexists(schemaname name, tablename name, columnname name) OWNER TO postgres;

--
-- TOC entry 1461 (class 1255 OID 26744)
-- Name: st_columnisunique(name, name); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_columnisunique(tablename name, columnname name) RETURNS boolean
    LANGUAGE sql STRICT
    AS $_$
    SELECT ST_ColumnIsUnique('public', $1, $2)
$_$;


ALTER FUNCTION public.st_columnisunique(tablename name, columnname name) OWNER TO postgres;

--
-- TOC entry 1460 (class 1255 OID 26743)
-- Name: st_columnisunique(name, name, name); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_columnisunique(schemaname name, tablename name, columnname name) OWNER TO postgres;

--
-- TOC entry 1437 (class 1255 OID 26701)
-- Name: st_createindexraster(public.raster, text, integer, boolean, boolean, boolean, boolean, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_createindexraster(rast public.raster, pixeltype text, startvalue integer, incwithx boolean, incwithy boolean, rowsfirst boolean, rowscanorder boolean, colinc integer, rowinc integer) OWNER TO postgres;

--
-- TOC entry 1436 (class 1255 OID 26700)
-- Name: st_deleteband(public.raster, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_deleteband(rast public.raster, band integer) OWNER TO postgres;

--
-- TOC entry 1448 (class 1255 OID 26723)
-- Name: st_extractpixelcentroidvalue4ma(double precision[], integer[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_extractpixelcentroidvalue4ma(pixel double precision[], pos integer[], VARIADIC args text[]) OWNER TO postgres;

--
-- TOC entry 1449 (class 1255 OID 26724)
-- Name: st_extractpixelvalue4ma(double precision[], integer[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_extractpixelvalue4ma(pixel double precision[], pos integer[], VARIADIC args text[]) OWNER TO postgres;

--
-- TOC entry 1453 (class 1255 OID 26729)
-- Name: st_extracttoraster(public.raster, name, name, name, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_extracttoraster(rast public.raster, schemaname name, tablename name, geomcolumnname name, method text DEFAULT 'MEAN_OF_VALUES_AT_PIXEL_CENTROID'::text) RETURNS public.raster
    LANGUAGE sql
    AS $_$
    SELECT ST_ExtractToRaster($1, 1, $2, $3, $4, NULL, $5)
$_$;


ALTER FUNCTION public.st_extracttoraster(rast public.raster, schemaname name, tablename name, geomcolumnname name, method text) OWNER TO postgres;

--
-- TOC entry 1452 (class 1255 OID 26728)
-- Name: st_extracttoraster(public.raster, integer, name, name, name, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_extracttoraster(rast public.raster, band integer, schemaname name, tablename name, geomcolumnname name, method text DEFAULT 'MEAN_OF_VALUES_AT_PIXEL_CENTROID'::text) RETURNS public.raster
    LANGUAGE sql
    AS $_$
    SELECT ST_ExtractToRaster($1, $2, $3, $4, $5, NULL, $6)
$_$;


ALTER FUNCTION public.st_extracttoraster(rast public.raster, band integer, schemaname name, tablename name, geomcolumnname name, method text) OWNER TO postgres;

--
-- TOC entry 1451 (class 1255 OID 26727)
-- Name: st_extracttoraster(public.raster, name, name, name, name, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_extracttoraster(rast public.raster, schemaname name, tablename name, geomcolumnname name, valuecolumnname name, method text DEFAULT 'MEAN_OF_VALUES_AT_PIXEL_CENTROID'::text) RETURNS public.raster
    LANGUAGE sql
    AS $_$
    SELECT ST_ExtractToRaster($1, 1, $2, $3, $4, $5, $6)
$_$;


ALTER FUNCTION public.st_extracttoraster(rast public.raster, schemaname name, tablename name, geomcolumnname name, valuecolumnname name, method text) OWNER TO postgres;

--
-- TOC entry 1450 (class 1255 OID 26726)
-- Name: st_extracttoraster(public.raster, integer, name, name, name, name, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_extracttoraster(rast public.raster, band integer, schemaname name, tablename name, geomrastcolumnname name, valuecolumnname name, method text) OWNER TO postgres;

--
-- TOC entry 1462 (class 1255 OID 26745)
-- Name: st_geotablesummary(name, name, name, name, integer, text[], text[], text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_geotablesummary(schemaname name, tablename name, geomcolumnname name, uidcolumn name, nbinterval integer, dosummary text[], skipsummary text[], whereclause text) OWNER TO postgres;

--
-- TOC entry 1463 (class 1255 OID 26747)
-- Name: st_geotablesummary(name, name, name, name, integer, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_geotablesummary(schemaname name, tablename name, geomcolumnname name, uidcolumn name, nbinterval integer, dosummary text DEFAULT NULL::text, skipsummary text DEFAULT NULL::text, whereclause text DEFAULT NULL::text) RETURNS TABLE(summary text, idsandtypes text, countsandareas double precision, query text, geom public.geometry)
    LANGUAGE sql
    AS $_$
    SELECT ST_GeoTableSummary($1, $2, $3, $4, $5, regexp_split_to_array($6, E'\\s*\,\\s'), regexp_split_to_array($7, E'\\s*\,\\s'), $8)
$_$;


ALTER FUNCTION public.st_geotablesummary(schemaname name, tablename name, geomcolumnname name, uidcolumn name, nbinterval integer, dosummary text, skipsummary text, whereclause text) OWNER TO postgres;

--
-- TOC entry 1454 (class 1255 OID 26730)
-- Name: st_globalrasterunion(name, name, name, text, text, double precision); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_globalrasterunion(schemaname name, tablename name, rastercolumnname name, method text, pixeltype text, nodataval double precision) OWNER TO postgres;

--
-- TOC entry 1377 (class 1255 OID 26707)
-- Name: st_hasbasicindex(name, name); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_hasbasicindex(tablename name, columnname name) RETURNS boolean
    LANGUAGE sql
    AS $_$
    SELECT ST_HasBasicIndex('public', $1, $2, NULL)
$_$;


ALTER FUNCTION public.st_hasbasicindex(tablename name, columnname name) OWNER TO postgres;

--
-- TOC entry 1366 (class 1255 OID 26706)
-- Name: st_hasbasicindex(name, name, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_hasbasicindex(tablename name, columnname name, idxstring text) RETURNS boolean
    LANGUAGE sql
    AS $_$
    SELECT ST_HasBasicIndex('public', $1, $2, $3)
$_$;


ALTER FUNCTION public.st_hasbasicindex(tablename name, columnname name, idxstring text) OWNER TO postgres;

--
-- TOC entry 1441 (class 1255 OID 26705)
-- Name: st_hasbasicindex(name, name, name, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_hasbasicindex(schemaname name, tablename name, columnname name, idxstring text) OWNER TO postgres;

--
-- TOC entry 1465 (class 1255 OID 26749)
-- Name: st_histogram(text, text, text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_histogram(schemaname text, tablename text, columnname text, nbinterval integer, whereclause text) OWNER TO postgres;

--
-- TOC entry 1457 (class 1255 OID 26734)
-- Name: st_nbiggestexteriorrings(public.geometry, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_nbiggestexteriorrings(ingeom public.geometry, nbrings integer, comptype text) OWNER TO postgres;

--
-- TOC entry 1438 (class 1255 OID 26702)
-- Name: st_randompoints(public.geometry, integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_randompoints(geom public.geometry, nb integer, seed numeric) OWNER TO postgres;

--
-- TOC entry 1469 (class 1255 OID 26754)
-- Name: st_removeoverlaps(public.geometry[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_removeoverlaps(geomarray public.geometry[]) RETURNS SETOF public.geometry
    LANGUAGE sql
    AS $$
    WITH geoms AS (
        SELECT unnest(geomarray) geom
    )
    SELECT ST_RemoveOverlaps(array_agg((geom, null)::geomval), 'NO_MERGE') FROM geoms;
$$;


ALTER FUNCTION public.st_removeoverlaps(geomarray public.geometry[]) OWNER TO postgres;

--
-- TOC entry 1468 (class 1255 OID 26753)
-- Name: st_removeoverlaps(public.geomval[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_removeoverlaps(gvarray public.geomval[]) RETURNS SETOF public.geometry
    LANGUAGE sql
    AS $$
    SELECT ST_RemoveOverlaps(gvarray, 'LARGEST_VALUE');
$$;


ALTER FUNCTION public.st_removeoverlaps(gvarray public.geomval[]) OWNER TO postgres;

--
-- TOC entry 1467 (class 1255 OID 26752)
-- Name: st_removeoverlaps(public.geometry[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_removeoverlaps(geomarray public.geometry[], mergemethod text) RETURNS SETOF public.geometry
    LANGUAGE sql
    AS $$
    WITH geoms AS (
        SELECT unnest(geomarray) geom
    )
    SELECT ST_RemoveOverlaps(array_agg((geom, ST_Area(geom))::geomval), mergemethod) FROM geoms;
$$;


ALTER FUNCTION public.st_removeoverlaps(geomarray public.geometry[], mergemethod text) OWNER TO postgres;

--
-- TOC entry 1466 (class 1255 OID 26751)
-- Name: st_removeoverlaps(public.geomval[], text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_removeoverlaps(gvarray public.geomval[], mergemethod text) OWNER TO postgres;

--
-- TOC entry 1464 (class 1255 OID 26748)
-- Name: st_splitbygrid(public.geometry, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.st_splitbygrid(ingeom public.geometry, xgridsize double precision, ygridsize double precision, xgridoffset double precision, ygridoffset double precision) OWNER TO postgres;

--
-- TOC entry 1418 (class 1255 OID 26738)
-- Name: st_trimmulti(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_trimmulti(geom public.geometry, minarea double precision DEFAULT 0.0) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT ST_Union(newgeom)
    FROM (SELECT ST_CollectionExtract((ST_Dump($1)).geom, 3) newgeom
         ) foo
    WHERE ST_Area(newgeom) > $2;
$_$;


ALTER FUNCTION public.st_trimmulti(geom public.geometry, minarea double precision) OWNER TO postgres;

--
-- TOC entry 1990 (class 1255 OID 26722)
-- Name: st_areaweightedsummarystats(public.geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_areaweightedsummarystats(public.geometry) (
    SFUNC = public._st_areaweightedsummarystats_statefn,
    STYPE = public.agg_areaweightedstatsstate,
    FINALFUNC = public._st_areaweightedsummarystats_finalfn
);


ALTER AGGREGATE public.st_areaweightedsummarystats(public.geometry) OWNER TO postgres;

--
-- TOC entry 1988 (class 1255 OID 26720)
-- Name: st_areaweightedsummarystats(public.geomval); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_areaweightedsummarystats(public.geomval) (
    SFUNC = public._st_areaweightedsummarystats_statefn,
    STYPE = public.agg_areaweightedstatsstate,
    FINALFUNC = public._st_areaweightedsummarystats_finalfn
);


ALTER AGGREGATE public.st_areaweightedsummarystats(public.geomval) OWNER TO postgres;

--
-- TOC entry 1989 (class 1255 OID 26721)
-- Name: st_areaweightedsummarystats(public.geometry, double precision); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_areaweightedsummarystats(public.geometry, double precision) (
    SFUNC = public._st_areaweightedsummarystats_statefn,
    STYPE = public.agg_areaweightedstatsstate,
    FINALFUNC = public._st_areaweightedsummarystats_finalfn
);


ALTER AGGREGATE public.st_areaweightedsummarystats(public.geometry, double precision) OWNER TO postgres;

--
-- TOC entry 1991 (class 1255 OID 26733)
-- Name: st_bufferedunion(public.geometry, double precision); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_bufferedunion(public.geometry, double precision) (
    SFUNC = public._st_bufferedunion_statefn,
    STYPE = public.geomval,
    FINALFUNC = public._st_bufferedunion_finalfn
);


ALTER AGGREGATE public.st_bufferedunion(public.geometry, double precision) OWNER TO postgres;

--
-- TOC entry 1987 (class 1255 OID 26737)
-- Name: st_differenceagg(public.geometry, public.geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_differenceagg(public.geometry, public.geometry) (
    SFUNC = public._st_differenceagg_statefn,
    STYPE = public.geometry
);


ALTER AGGREGATE public.st_differenceagg(public.geometry, public.geometry) OWNER TO postgres;

--
-- TOC entry 1996 (class 1255 OID 26765)
-- Name: st_removeoverlaps(public.geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_removeoverlaps(public.geometry) (
    SFUNC = public._st_removeoverlaps_statefn,
    STYPE = public.geomvaltxt[],
    FINALFUNC = public._st_removeoverlaps_finalfn
);


ALTER AGGREGATE public.st_removeoverlaps(public.geometry) OWNER TO postgres;

--
-- TOC entry 1995 (class 1255 OID 26764)
-- Name: st_removeoverlaps(public.geometry, double precision); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_removeoverlaps(public.geometry, double precision) (
    SFUNC = public._st_removeoverlaps_statefn,
    STYPE = public.geomvaltxt[],
    FINALFUNC = public._st_removeoverlaps_finalfn
);


ALTER AGGREGATE public.st_removeoverlaps(public.geometry, double precision) OWNER TO postgres;

--
-- TOC entry 1997 (class 1255 OID 26766)
-- Name: st_removeoverlaps(public.geometry, text); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_removeoverlaps(public.geometry, text) (
    SFUNC = public._st_removeoverlaps_statefn,
    STYPE = public.geomvaltxt[],
    FINALFUNC = public._st_removeoverlaps_finalfn
);


ALTER AGGREGATE public.st_removeoverlaps(public.geometry, text) OWNER TO postgres;

--
-- TOC entry 1994 (class 1255 OID 26763)
-- Name: st_removeoverlaps(public.geometry, double precision, text); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_removeoverlaps(public.geometry, double precision, text) (
    SFUNC = public._st_removeoverlaps_statefn,
    STYPE = public.geomvaltxt[],
    FINALFUNC = public._st_removeoverlaps_finalfn
);


ALTER AGGREGATE public.st_removeoverlaps(public.geometry, double precision, text) OWNER TO postgres;

--
-- TOC entry 1993 (class 1255 OID 26742)
-- Name: st_splitagg(public.geometry, public.geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_splitagg(public.geometry, public.geometry) (
    SFUNC = public._st_splitagg_statefn,
    STYPE = public.geometry[]
);


ALTER AGGREGATE public.st_splitagg(public.geometry, public.geometry) OWNER TO postgres;

--
-- TOC entry 1992 (class 1255 OID 26741)
-- Name: st_splitagg(public.geometry, public.geometry, double precision); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.st_splitagg(public.geometry, public.geometry, double precision) (
    SFUNC = public._st_splitagg_statefn,
    STYPE = public.geometry[]
);


ALTER AGGREGATE public.st_splitagg(public.geometry, public.geometry, double precision) OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 22773)
-- Name: eimglx_areas_demo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.eimglx_areas_demo_id_seq
    START WITH 7
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1;


ALTER TABLE public.eimglx_areas_demo_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 201 (class 1259 OID 22761)
-- Name: eimglx_areas_demo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eimglx_areas_demo (
    id bigint DEFAULT nextval('public.eimglx_areas_demo_id_seq'::regclass) NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    eval_nr integer,
    eval_str character varying(15),
    att_nat smallint,
    att_open smallint,
    att_order smallint,
    att_upkeep smallint,
    att_hist smallint,
    centroid public.geometry(Point,4326),
    "timestamp" timestamp without time zone,
    area_sqm numeric(10,2)
);


ALTER TABLE public.eimglx_areas_demo OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 26956)
-- Name: eimglx_result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eimglx_result (
    geom public.geometry,
    category text,
    ct_overlap_liked bigint,
    ct_overlap_disliked bigint,
    sum_attnat numeric,
    sum_attopen numeric,
    sum_attorder numeric,
    sum_attupkeep numeric,
    sum_atthist numeric
);


ALTER TABLE public.eimglx_result OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 26950)
-- Name: eimglx_sample; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eimglx_sample (
    id bigint,
    geom public.geometry(MultiPolygon,4326),
    eval_nr integer,
    eval_str character varying(15),
    att_nat smallint,
    att_open smallint,
    att_order smallint,
    att_upkeep smallint,
    att_hist smallint,
    "timestamp" timestamp without time zone,
    area_sqm numeric(10,2)
);


ALTER TABLE public.eimglx_sample OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 24884)
-- Name: layer_styles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.layer_styles (
    id integer NOT NULL,
    f_table_catalog character varying,
    f_table_schema character varying,
    f_table_name character varying,
    f_geometry_column character varying,
    stylename character varying(30),
    styleqml xml,
    stylesld xml,
    useasdefault boolean,
    description text,
    owner character varying(30),
    ui xml,
    update_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.layer_styles OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 24882)
-- Name: layer_styles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.layer_styles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.layer_styles_id_seq OWNER TO postgres;

--
-- TOC entry 3705 (class 0 OID 0)
-- Dependencies: 203
-- Name: layer_styles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.layer_styles_id_seq OWNED BY public.layer_styles.id;


--
-- TOC entry 217 (class 1259 OID 27055)
-- Name: parts_singlefeat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parts_singlefeat (
    geom public.geometry,
    cat1 integer,
    cat2 integer,
    a_nat smallint,
    a_ope smallint,
    a_ord smallint,
    a_upk smallint,
    a_his smallint
);


ALTER TABLE public.parts_singlefeat OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 26806)
-- Name: public_test_adduniqueid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.public_test_adduniqueid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.public_test_adduniqueid_seq OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 26815)
-- Name: public_test_geotablesummary_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.public_test_geotablesummary_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.public_test_geotablesummary_seq OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 26828)
-- Name: tbl_foo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_foo (
    id bigint,
    geom public.geometry(MultiPolygon,4326),
    att_category character varying(15),
    att_value integer
);


ALTER TABLE public.tbl_foo OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 26819)
-- Name: tbl_foo_1; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_foo_1 (
    id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    att_category character varying(15),
    att_value integer
);


ALTER TABLE public.tbl_foo_1 OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 26834)
-- Name: tbl_foo_2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_foo_2 (
    id bigint,
    geom public.geometry(MultiPolygon,4326),
    att_category character varying(15),
    att_value integer
);


ALTER TABLE public.tbl_foo_2 OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 27049)
-- Name: tblfoo_allsingle_feat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblfoo_allsingle_feat (
    geom public.geometry,
    val integer
);


ALTER TABLE public.tblfoo_allsingle_feat OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 27043)
-- Name: tblfoo_result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblfoo_result (
    val integer,
    cat1 integer,
    cat2 integer,
    geom public.geometry
);


ALTER TABLE public.tblfoo_result OWNER TO postgres;

--
-- TOC entry 3551 (class 2604 OID 24887)
-- Name: layer_styles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.layer_styles ALTER COLUMN id SET DEFAULT nextval('public.layer_styles_id_seq'::regclass);


--
-- TOC entry 3682 (class 0 OID 22761)
-- Dependencies: 201
-- Data for Name: eimglx_areas_demo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (87, '0106000020E610000001000000010300000001000000040000009F8EC70C544E22C0B6662B2FF95B4340938B31B08E5322C098F90E7EE25A434088687407B14B22C0C286A757CA5A43409F8EC70C544E22C0B6662B2FF95B4340', 2, 'Disliked', 1, 1, 0, 0, 0, NULL, NULL, NULL);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (13, '0106000020E6100000010000000103000000010000000500000001000040BF4822C06E2B7B6E185B434001000000954922C031627F1FF35A434001000080244922C0B615DE65D45A4340010000400B4822C031627F1FF35A434001000040BF4822C06E2B7B6E185B4340', 2, 'Disliked', 1, 1, 0, 0, 1, '0101000020E61000003670F7BDD94822C072364851F55A4340', '2018-11-02 11:24:27.408703', 30111.11);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (14, '0106000020E6100000010000000103000000010000000700000001000080A04522C08430CDE6FB5A434017543611D94422C00D3C998DEF5A43404E9CDCEF504422C0A54929E8F65A434001000000F54322C0BA4506D9115B434001000080B14322C0B66012F6345B4340010000402D4422C0A8CE808B3B5B434001000080A04522C08430CDE6FB5A4340', 2, 'Disliked', 0, 0, 1, 1, 0, '0101000020E61000002C7C4D468B4422C0C28B6803125B4340', '2018-11-02 11:24:27.408703', 41023.82);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (16, '0106000020E610000001000000010300000001000000040000000180031D044922C07107E9F2395B43400080039DC04822C011F6ACE1B15A43400080031D6F4722C0E14E68F1EA5A43400180031D044922C07107E9F2395B4340', 2, 'Disliked', 1, 1, 1, 0, 0, '0101000020E61000000080039D664822C0CC6EFF41F25A4340', '2018-11-02 11:24:27.408703', 55948.64);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (18, '0106000020E610000001000000010300000001000000050000000180E9BFBC4322C013DDAE60EA5A43400180E91F4C4522C0875B15AD445A43400180E95F004222C0FAE4C859795A43400180E9BFAE4222C07F3EBC72F65A43400180E9BFBC4322C013DDAE60EA5A4340', 2, 'Disliked', 0, 1, 1, 1, 0, '0101000020E610000089F2A2FB794322C0B51161379B5A4340', '2018-11-02 11:24:27.408703', 173845.34);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (26, '0106000020E610000001000000010300000001000000050000000180FC627D4522C0B19983D6EA5B43400080FC22FC4222C00505375C1A5B43400180FC22754222C0CBE6F672975B43400080FC22FC4222C0EDC44381D05B43400180FC627D4522C0B19983D6EA5B4340', 2, 'Disliked', 1, 0, 0, 0, 0, '0101000020E61000000080FCE2A44322C0EDC8CABB975B4340', '2018-11-02 11:24:27.408703', 158912.55);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (27, '0106000020E610000001000000010300000001000000050000000080031D234822C0E9231425295C43400080031D184422C076D2954F365C43404E97C5C4E64322C048FE60E0B95B43400180031DDA4522C04CF65290D35B43400080031D234822C0E9231425295C4340', 2, 'Disliked', 1, 0, 1, 1, 1, '0101000020E6100000A1FFC71C7B4522C0BCF4F8A3025C4340', '2018-11-02 11:24:27.408703', 176621.21);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (28, '0106000020E6100000010000000103000000010000000400000000802434AB4B22C039CFDE8A3C5B434000802434244B22C0E8292CE8E95B4340008024B44B4922C0DC0C8C7DA15B434000802434AB4B22C039CFDE8A3C5B4340', 2, 'Disliked', 1, 1, 1, 1, 0, '0101000020E6100000008024B4B34A22C0FE01DDFA975B4340', '2018-11-02 11:24:27.408703', 103057.08);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (30, '0106000020E610000001000000010300000001000000060000000080039DDC4A22C091ED6B9BD05A43403813C0C4DC4822C005FA7543EB5A43402A6F47382D4822C0E65C8AABCA5A43400180035DA74722C0D3883377B85A43400180039D1A4922C06721AD59955A43400080039DDC4A22C091ED6B9BD05A4340', 2, 'Disliked', 0, 1, 1, 1, 1, '0101000020E6100000B3BECD032F4922C06C26A834C25A4340', '2018-11-02 11:24:27.408703', 79675.99);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (32, '0106000020E6100000010000000103000000010000000500000082FFAD64C74622C0176536C8245B43400180039D774622C01E8B6CC6DD5A43400080031D9F4422C06B3AF6AA095B43400080039D694522C0F9BC6964285B434082FFAD64C74622C0176536C8245B4340', 2, 'Disliked', 0, 1, 0, 0, 1, '0101000020E61000008657C06BDF4522C04F2D20F5095B4340', '2018-11-02 11:24:27.408703', 54549.37);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (33, '0106000020E61000000100000001030000000100000007000000373A34BFFD4B22C0A7A428D6C55A4340018019D7404B22C04A33BA3BE15A434001801997A04922C0AF29E0B3C45A4340018019D7D84922C0FAC5E7A38B5A4340018019D7E64A22C0FCDD12157A5A4340018019D7C74B22C00AA79B07905A4340373A34BFFD4B22C0A7A428D6C55A4340', 2, 'Disliked', 1, 1, 1, 1, 0, '0101000020E61000001888709BD54A22C01FE0586AAD5A4340', '2018-11-02 11:24:27.408703', 98540.06);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (34, '0106000020E61000000100000001030000000100000005000000018019175A4C22C0D091639FE55A4340018019D7E64A22C0F161503D305B4340D4D4B2B5BE4822C0D09B8A54185B434040C4CB8CCC4822C091F774D3CA5A4340018019175A4C22C0D091639FE55A4340', 2, 'Disliked', 0, 1, 1, 1, 0, '0101000020E6100000395FD968414A22C01884F596FB5A4340', '2018-11-02 11:24:27.408703', 135938.35);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (39, '0106000020E6100000010000000103000000010000000600000001800EFA034322C03A04F19A2B5C434001800E7A744322C0D373DEF0A75B434000800EBA634122C00B319562965B434001800E3A204122C0B0E6ADE2BD5B434001800EFA8D4022C09AE9E045115C434001800EFA034322C03A04F19A2B5C4340', 2, 'Disliked', 1, 0, 1, 1, 0, '0101000020E6100000EEB60F131A4222C038FD34DAE05B4340', '2018-11-02 11:24:27.408703', 173638.91);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (41, '0106000020E610000001000000010300000001000000080000006FA8E997CA4A22C09AE858FAF65A4340F0A2AF20CD4822C0E65C8AABCA5A4340018003DD254922C0F7B74C357D5A43400180039DBD4B22C0C900DC10655A43400080035DA14D22C0DF2C254CAB5A4340D483BD8E264D22C08A1211262D5B4340B476DB85E64A22C0F3AB3940305B43406FA8E997CA4A22C09AE858FAF65A4340', 2, 'Disliked', 0, 1, 0, 0, 0, '0101000020E61000008725CFE7694B22C00764E5D6C65A4340', '2018-11-02 11:24:27.408703', 382390.82);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (42, '0106000020E610000001000000010300000001000000050000000080031DAA4822C0467EFFDE625A43400180031D264522C0290E6C608A5A4340D97745F0BF4522C0164D6727835B4340EF7211DF894922C088BA0F406A5B43400080031DAA4822C0467EFFDE625A4340', 2, 'Disliked', 0, 1, 1, 0, 1, '0101000020E6100000A6BC0E874C4722C0853C5ECEF75A4340', '2018-11-02 11:24:27.408703', 551913.33);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (37, '0106000020E6100000010000000103000000010000000600000001804657654C22C04635CB94505A43402BF1786AE24B22C07FB5F676AA5A4340EE42739D464A22C0D1967329AE5A434001804657954922C08A2995B2735A434000804617984A22C0195B3C70385A434001804657654C22C04635CB94505A4340', 2, 'Disliked', 0, 1, 1, 0, 0, '0101000020E61000003A2148B3044B22C06FC90FFC755A4340', '2018-11-02 11:24:27.408703', 133127.11);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (89, '0106000020E610000001000000010300000001000000050000001E87C1FC155222C0BBEF181EFB5B4340C0046EDDCD5322C0105B7A34D55B434059FAD005F55522C0C26856B60F5B434064027E8D245122C08CBE8234635B43401E87C1FC155222C0BBEF181EFB5B4340', 1, 'Liked', 0, 0, 1, 1, 0, NULL, NULL, NULL);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (52, '0106000020E610000001000000010300000001000000060000004985B185204722C01DACFF73985B4340F068D25D934622C0EEBC3983F65A4340C1FF56B2634322C082AD122C0E5B4340E89E1C6CC14322C088954605905B43404C546F0D6C4522C0DD989EB0C45B43404985B185204722C01DACFF73985B4340', 2, 'Disliked', 1, 1, 1, 1, 1, '0101000020E6100000B857E6FA4B4522C0A4B8265C585B4340', '2018-11-02 11:24:27.408703', 324353.10);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (88, '0106000020E6100000010000000103000000010000000500000053CF8250DE4722C0E0F3C308E15B434049810530654822C001C3F2E7DB5A43405531957EC24122C03FFF3D78ED5A43406D57E883654422C0588CBAD6DE5B434053CF8250DE4722C0E0F3C308E15B4340', 1, 'Liked', 1, 1, 1, 0, 0, NULL, NULL, NULL);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (54, '0106000020E610000001000000010300000001000000060000000180C485F14022C05672BC28865B43400180C4854E3E22C0AAEA694C9E5B43400180C405A33C22C07700838B3B5B43403541D47D004222C074EACA67795A4340F715F395C34122C0EF08DFA4E45A43400180C485F14022C05672BC28865B4340', 2, 'Disliked', 1, 0, 0, 0, 1, '0101000020E610000075E98341AE3F22C0EFE2F94C255B4340', '2018-11-02 11:24:27.408703', 456548.50);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (55, '0106000020E6100000010000000103000000010000000700000037A6272CF14022C056D4601A865B43400080031D2C3F22C01E8187563E5B43407B2AD1A8D33E22C04A375732EC5A43400180035D913F22C0DF2C254CAB5A43400180035DF94022C05B56162AE25A43405D51682B1B4222C0366C7A95425B434037A6272CF14022C056D4601A865B4340', 2, 'Disliked', 1, 0, 0, 0, 1, '0101000020E6100000E53E7218574022C0F416408B1B5B4340', '2018-11-02 11:24:27.408703', 228148.65);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (1, '0106000020E6100000010000000103000000010000000C000000FB48FA5E684622C065786C635F5B434091DF59C3094622C09A4E501D425B434091DF59C3094622C09A4E501D425B43409AC56F9DE24522C0DCB40D91155B434081B58A024B4622C0D8437D051A5B434073DC69BB854622C06BB75AEE225B434064B29AFAC64622C0C92A1CD7245B434053371DC00E4722C00BB1B305285B43404A5107E6354722C0BA907891315B43404DF363D9284722C03950BA91465B4340DAA3AD63F14622C0C7B8EF915B5B4340FB48FA5E684622C065786C635F5B4340', 1, 'Liked', 0, 0, 0, 1, 1, '0101000020E6100000742F6ECA8C4622C092AC90413B5B4340', '2018-11-02 11:24:27.408703', 36681.78);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (3, '0106000020E6100000010000000103000000010000000C000000BF5DC705464522C0AFF0E177BC5A434010D22FBDF24322C01FD85BBDAF5A43400A8E76D60C4422C0042F1DA58E5A4340ED8A86CE884422C007624401725A43404BBD6216154522C0C8A79CD26E5A43408CEC4E561D4622C0D4B967BB705A4340BEF16BD5664722C0B64F92E9655A43409073FE922A4822C0A246AE2F6E5A43408F225019314822C05AAEAAA4805A43403C78E69E704722C0CBD92DD49F5A4340FAF74BE56E4622C030E22DECB95A4340BF5DC705464522C0AFF0E177BC5A4340', 1, 'Liked', 1, 0, 0, 1, 0, '0101000020E6100000530BB6C5FA4522C02AF899BF905A4340', '2018-11-02 11:24:27.408703', 151539.90);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (15, '0106000020E6100000010000000103000000010000000600000000001E404A4522C02891EA607E5B434001001EC08D4522C0B0D74B20435B434001001EC0174322C0D730E983475B434000001E80394322C02891EA607E5B434001001E80474422C0DC0C8C7DA15B434000001E404A4522C02891EA607E5B4340', 1, 'Liked', 0, 1, 0, 1, 0, '0101000020E6100000717B11B64B4422C079CBE4066A5B4340', '2018-11-02 11:24:27.408703', 95096.75);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (17, '0106000020E61000000100000001030000000100000005000000010030D78F4722C0ACD518C2D55B4340010030178A4922C0D19C9A3A6A5B43402D26361FD74622C04F58E201655B434001003017604622C0415B3A09B75B4340010030D78F4722C0ACD518C2D55B4340', 1, 'Liked', 0, 1, 0, 1, 0, '0101000020E6100000400338E7B14722C01563B443935B4340', '2018-11-02 11:24:27.408703', 118596.68);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (19, '0106000020E6100000010000000103000000010000000500000000801DFA184C22C011359B2D1C5C434001801DBACF4D22C0E62EC7573C5B434000801DFAFC4922C0015FFA8EE45A43400180215DE34722C079659E18EE5B434000801DFA184C22C011359B2D1C5C4340', 1, 'Liked', 1, 0, 1, 1, 0, '0101000020E61000006E6C3BCBE24A22C02080FD188A5B4340', '2018-11-02 11:24:27.408703', 638992.25);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (29, '0106000020E610000001000000010300000001000000060000001989CFB5634822C018ED5566055B43400180035DF34622C070FABF37CC5A43400180039D774622C041D15FBD995A4340D578E926314822C08351499D805A4340332489332D4822C02D73069ECA5A43401989CFB5634822C018ED5566055B4340', 1, 'Liked', 0, 1, 0, 1, 1, '0101000020E6100000F1070164934722C06BEBDB89B85A4340', '2018-11-02 11:24:27.408703', 75482.81);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (31, '0106000020E610000001000000010300000001000000060000000080031D644322C0DCA19A0E0E5B434089EFC4AC174322C0D00F2384475B43400180031DA24122C021E76773615B43400180031D1B4122C03D4E7A5D335B43400180031DA24122C025DCD8B1FE5A43400080031D644322C0DCA19A0E0E5B4340', 1, 'Liked', 1, 0, 1, 0, 1, '0101000020E610000078C7FBDC354222C0A7A270002D5B4340', '2018-11-02 11:24:27.408703', 86835.09);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (35, '0106000020E6100000010000000103000000010000000500000001801917E14C22C013CFA6E16F5B434091630B35CC4A22C0E500671FF75A43409308AF35604A22C0C2A8B46D2A5B434026C79DD2C14A22C01D7233DC805B434001801917E14C22C013CFA6E16F5B4340', 1, 'Liked', 1, 1, 0, 0, 0, '0101000020E6100000B82BE4F1574B22C0F8199A8E495B4340', '2018-11-02 11:24:27.408703', 100028.86);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (40, '0106000020E610000001000000010300000001000000050000001CF743D16E4822C0342D111A685B434066300C16E64822C0C4E70EE6FD5A43409FE57970774622C0F4E0EEACDD5A4340F5D6C056094622C097ADF545425B43401CF743D16E4822C0342D111A685B4340', 1, 'Liked', 0, 1, 0, 0, 0, '0101000020E61000001FE87955784722C0E6377D9C215B4340', '2018-11-02 11:24:27.408703', 152697.99);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (43, '0106000020E6100000010000000103000000010000000D0000006D148F7D014822C04C95B36E075B434016C1FF56B24322C03FC6DCB5845C4340E634B75F584622C04DA89197515C43401923C32AA74622C02EF8608BF15B4340008090CB6F4722C00EA78198AC5B43408E62C422954822C0ECBE959CE95B4340008090CB5E4922C0D94A03A6345C43400080900BA54A22C02DC5C500935C43400080900B3A4C22C0E59FDA28EF5C43400180908B314D22C0EDB51006D75C4340008090CB694D22C0629511E56F5C434003951D69294C22C0B2B406BA305C43406D148F7D014822C04C95B36E075B4340', 1, 'Liked', 1, 0, 1, 1, 1, '0101000020E6100000964ACD582E4922C010479AF6065C4340', '2018-11-02 11:24:27.408703', 839880.73);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (46, '0106000020E610000001000000010300000001000000060000005C8FC2F5284C22C0B1A206D3305C434001804697BC4B22C0013596F2D95B434001804657494A22C051AE82B2ED5B4340018046178A4922C0D0761BF86C5C434000804657DE4B22C09C1EA1A1A15C43405C8FC2F5284C22C0B1A206D3305C4340', 1, 'Liked', 1, 0, 1, 0, 1, '0101000020E6100000BE7223F3024B22C02039BCE53C5C4340', '2018-11-02 11:24:27.408703', 201697.57);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (79, '0106000020E610000001000000010300000001000000040000002F077808295222C0F5159DAA055B4340018097C5095222C019F783429F5A4340018097850F5022C0A74575BA825A43402F077808295222C0F5159DAA055B4340', 1, 'Liked', 1, 0, 0, 1, 0, '0101000020E610000010AD37716B5122C0E77087E2B75A4340', '2018-11-02 11:24:27.408703', 57274.44);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (66, '0106000020E610000001000000010300000001000000040000008CBE8234634122C048A7AE7C965B43400080031DA53E22C0F9937397C85B4340CA1AF5108D3E22C0D0F23CB83B5B43408CBE8234634122C048A7AE7C965B4340', 1, 'Liked', 1, 0, 0, 0, 1, '0101000020E610000072C8D320873F22C0B064CAEE885B4340', '2018-11-02 11:24:27.408703', 112519.98);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (83, '0106000020E610000001000000010300000001000000060000000180039D115222C04CF65290D35B43400080039D4F5022C09A096CF96A5C43400180039DD94D22C0F57BF295665C4340755240E15A4C22C0F1F37EB8FA5B4340587380608E4E22C048FE60E0B95B43400180039D115222C04CF65290D35B4340', 1, 'Liked', 0, 0, 1, 0, 0, '0101000020E6100000A4CB6CAC2E4F22C0C6A42B07105C4340', '2018-11-02 11:24:27.408703', 385402.96);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (36, '0106000020E61000000100000001030000000100000005000000018003DDCE4522C0B6597D6C0A5C43400180035D204722C095774150985B43400080039D1D4622C0E23AFFCF705B43400080039D3C4522C07AAC2F49A35B4340018003DDCE4522C0B6597D6C0A5C4340', 1, 'Liked', 0, 1, 0, 1, 0, '0101000020E6100000B17B2775164622C0D2D4DBB4B25B4340', '2018-11-02 11:24:27.408703', 82549.94);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (23, '0106000020E610000001000000010300000001000000050000000180129DB44522C0872F0F39BC5B43400180125DE74322C0BCBE4707BA5B43400180121D364422C0D5EFA12A835B4340018012DDBF4522C0D5EFA12A835B43400180129DB44522C0872F0F39BC5B4340', 2, 'Disliked', 1, 1, 0, 1, 0, '0101000020E61000004A8A942AE54422C055AF44E79F5B4340', '2018-11-02 11:24:27.408703', 53887.05);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (4, '0106000020E61000000100000001030000000100000008000000AFC79C14A84722C0B08E05EF5A5B4340AC254021B54722C02009F7D7785B4340440D4EFF4F4722C078640D35785B4340E1E7664AD74622C005D4A61D655B43405C1D339AE74622C07BB0657A415B4340440D4EFF4F4722C0BA907891315B4340A5E1863ACF4722C0BDE33A1D3B5B4340AFC79C14A84722C0B08E05EF5A5B4340', 2, 'Disliked', 0, 1, 0, 0, 1, '0101000020E6100000DFD96C69534722C02821974F555B4340', '2018-11-02 11:24:27.408703', 28828.59);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (5, '0106000020E6100000010000000103000000010000000600000042D74C3C3C4522C0554350D5C95A43404343A86C1B4322C0D18E8CBDB65A4340A517E1A79A4322C0CB228AD38A5A43407055BA7E784422C08FC6F8EA8F5A4340D5CB4FADEA4422C094E1A631AD5A434042D74C3C3C4522C0554350D5C95A4340', 2, 'Disliked', 0, 1, 0, 0, 1, '0101000020E61000004F2A6EDF234422C065DC6F82AA5A4340', '2018-11-02 11:24:27.408703', 43938.06);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (38, '0106000020E61000000100000001030000000100000006000000018046971C4622C05F658852985C434011E4A084994622C0AB09A2EE035C4340F7B63D5C0B4422C08E97375B155C43406ABC7493184422C00EDB1665365C4340018046D7B14322C0D939FA92845C4340018046971C4622C05F658852985C4340', 1, 'Liked', 1, 1, 0, 0, 1, '0101000020E610000086B1DCB8344522C024462FB74D5C4340', '2018-11-02 11:24:27.408703', 181001.30);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (50, '0106000020E61000000100000001030000000100000005000000B9AAECBB224822C078D15790665C43400DC347C4944822C08E1EBFB7E95B4340F6622827DA4522C01D3D7E6FD35B4340A1B1AED9334522C0E1B8F9CD325C4340B9AAECBB224822C078D15790665C4340', 1, 'Liked', 0, 1, 0, 0, 0, '0101000020E61000007877CFD2FD4622C027E73067175C4340', '2018-11-02 11:24:27.408703', 191040.59);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (51, '0106000020E610000001000000010300000001000000050000009EE321F5254A22C0D6C09A522B5C434065ADCEC0DA4722C0684C8F92D85A434070A8EC246C4522C052EA03CFC45B434011E4A084994622C0AB09A2EE035C43409EE321F5254A22C0D6C09A522B5C4340', 1, 'Liked', 1, 1, 1, 0, 1, '0101000020E6100000746DBBA0C24722C050A41BB8A35B4340', '2018-11-02 11:24:27.408703', 444061.78);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (24, '0106000020E61000000100000001030000000100000005000000018007009C4222C0E07BA9F13B5B434001800780C34022C092148915545B434001800700804022C06F3F8AFF255B4340018007801D4122C0AA18E777095B4340018007009C4222C0E07BA9F13B5B4340', 1, 'Liked', 0, 1, 0, 1, 1, '0101000020E6100000019B58E3574122C0A5A27293315B4340', '2018-11-02 11:24:27.408703', 47509.39);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (25, '0106000020E610000001000000010300000001000000070000000080035DAA4422C0AEC2FDCE5D5C43400180039D3F4222C024A7D1AB455C4340018003DD964122C04FF0F708065C43400080031D294222C05EEA1849F25B4340008003DD0C4422C0B6597D6C0A5C43400180031D264522C0B6597D6C0A5C43400080035DAA4422C0AEC2FDCE5D5C4340', 1, 'Liked', 1, 0, 1, 0, 1, '0101000020E6100000C7B87876664322C0D1D1E8E0265C4340', '2018-11-02 11:24:27.408703', 139002.89);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (6, '0106000020E61000000100000001030000000100000006000000E5DA71B7C34622C05E6ED04B3E5B434002DE61BF474622C0CBEE4A342B5B434081B58A024B4622C0DA737279025B434066034974C04622C0912AAF90005B43405095C0CC1B4722C0FAEE9162195B4340E5DA71B7C34622C05E6ED04B3E5B4340', 1, 'Liked', 1, 1, 1, 0, 1, '0101000020E6100000409CBB7FA44622C049D504331C5B4340', '2018-11-02 11:24:27.408703', 20148.79);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (85, '0106000020E610000001000000010300000001000000040000004772F90FE94F22C0228D0A9C6C5D434053B29C84D24F22C0A9F57EA31D5D4340D72FD80DDB4E22C046239F573C5D43404772F90FE94F22C0228D0A9C6C5D4340', 1, 'Liked', 0, 0, 0, 0, 1, NULL, NULL, NULL);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (47, '0106000020E6100000010000000103000000010000000500000000805597BB4C22C046D80D12AC5C43401EB26384F54B22C0A645BBCABC5B4340E78DA517A84922C060DA8CB8AF5B43406DCC9624344922C047BE7B66FC5B434000805597BB4C22C046D80D12AC5C4340', 1, 'Liked', 0, 1, 0, 1, 0, '0101000020E6100000E63687A8164B22C092200E87105C4340', '2018-11-02 11:24:27.408703', 256359.01);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (20, '0106000020E610000001000000010300000001000000050000000080039D334E22C069989DE59E5B43400080035D994622C0DA0735D7035C43400080031D234822C0F57BF295665C43400180031D0F4D22C0698092C1245C43400080039D334E22C069989DE59E5B4340', 1, 'Liked', 1, 0, 0, 0, 1, '0101000020E61000006A88BC577D4A22C05E481268075C4340', '2018-11-02 11:24:27.408703', 428571.87);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (78, '0106000020E610000001000000010300000001000000050000000180031D175422C06691C800245B4340ED507392FB5022C07EABB4A06F5B43409B0D67C3385022C0E3252A45E45A4340018003DDEF5122C0D72FD80DDB5A43400180031D175422C06691C800245B4340', 2, 'Disliked', 0, 0, 0, 0, 1, '0101000020E61000003EF0BF63D65122C03BBFC4AB1C5B4340', '2018-11-02 11:24:27.408703', 182890.67);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (80, '0106000020E61000000100000001030000000100000006000000F48DF3DA2B5022C0118410631D5B4340018003DD685122C0D260B842675A43400080039D144F22C092F16ACE295A43400180031DC34D22C0913B043C725A43400AD45E2A894D22C0EE9FF785C45A4340F48DF3DA2B5022C0118410631D5B4340', 2, 'Disliked', 1, 1, 0, 1, 0, '0101000020E610000005C2F9A16E4F22C0649474479C5A4340', '2018-11-02 11:24:27.408703', 327309.03);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (82, '0106000020E610000001000000010300000001000000040000000080031D854F22C004D6912E885A43400080035DA14D22C087DD9E88485A43403FACD2C61A4E22C0EEB003A2A65A43400080031D854F22C004D6912E885A4340', 2, 'Disliked', 1, 1, 0, 0, 1, '0101000020E610000015E49D156B4E22C07F21BC1D7D5A4340', '2018-11-02 11:24:27.408703', 42482.46);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (2, '0106000020E61000000100000001030000000100000008000000F3B2AD44564522C025A47EECE85A4340305BEA47514422C0E3F0E0ECF65A4340305BEA47514422C0E3F0E0ECF65A4340432716FC024422C046A1B603E75A4340D379BC79BE4322C01709DD19C25A4340B91829652D4422C0C50B6619B45A4340830554C2114522C0948089D3B25A4340F3B2AD44564522C025A47EECE85A4340', 2, 'Disliked', 0, 0, 1, 0, 0, '0101000020E6100000659461A78E4422C0F6411391D25A4340', '2018-11-02 11:24:27.408703', 45073.91);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (86, '0106000020E610000001000000010300000001000000040000004772F90FE94F22C0228D0A9C6C5D4340E36F7B82C44E22C0E8305F5E805D4340D72FD80DDB4E22C046239F573C5D43404772F90FE94F22C0228D0A9C6C5D4340', 2, 'Disliked', 1, 0, 0, 0, 0, NULL, NULL, NULL);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (44, '0106000020E61000000100000001030000000100000007000000D399D9974C4B22C054ECD8423C5C43409A081B9E5E4922C05CACA8C1345C43409A7860A7C34822C0EA2987285E5C434001805C51944922C0836C384F9D5C434001805C114B4B22C076FC9656925C4340939A8BD4A24C22C0B6F07DB3485C4340D399D9974C4B22C054ECD8423C5C4340', 2, 'Disliked', 1, 1, 1, 0, 0, '0101000020E6100000B6AFDAD6804A22C0D81E2EE0645C4340', '2018-11-02 11:24:27.408703', 153853.54);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (57, '0106000020E61000000100000001030000000100000005000000B8979453C34222C07C4398FB4E5B43402604928C443F22C04B4D1841DC5A434001805C918C3E22C0B3DA91BE3B5B434089C5C2DD944022C05BA9387F775B4340B8979453C34222C07C4398FB4E5B4340', 1, 'Liked', 1, 0, 0, 1, 0, '0101000020E610000030CC0165574022C034E2EDD3335B4340', '2018-11-02 11:24:27.408703', 180962.07);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (58, '0106000020E61000000100000001030000000100000005000000DAACFA5C6D4522C016F6B4C35F5B4340BC91DE084F4522C056BBAB0CCC5A4340CDF32157CC4222C0D46436CEA15A4340A97DAE27334122C058939E97F55A4340DAACFA5C6D4522C016F6B4C35F5B4340', 1, 'Liked', 0, 1, 1, 0, 0, '0101000020E6100000A3E46374B44322C017F93D5CF75A4340', '2018-11-02 11:24:27.408703', 256030.35);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (71, '0106000020E6100000010000000103000000010000000700000001809B28FE5022C01437ACA6335C434000809B28555422C061B89535A75B434001809B28DC5422C0FB97F9251F5B434001809BA85D5322C00F4B691DDB5A434000809B68DC5022C00F4B691DDB5A434001809B28585122C0CD736ECA5E5B434001809B28FE5022C01437ACA6335C4340', 1, 'Liked', 0, 1, 0, 0, 1, '0101000020E6100000BFD8D953A95222C058E36969665B4340', '2018-11-02 11:24:27.408703', 509427.95);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (72, '0106000020E610000001000000010300000001000000060000000180031D825222C02B76AA2B315B43400080039D225022C011F6ACE1B15A43400080031D4A4E22C01E8B6CC6DD5A4340018003DD984E22C0850933AC585B4340C272C665385122C0A08462E7AA5B43400180031D825222C02B76AA2B315B4340', 1, 'Liked', 0, 1, 1, 0, 0, '0101000020E6100000C07E8B5C445022C0B08DE7AB2A5B4340', '2018-11-02 11:24:27.408703', 361744.82);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (48, '0106000020E61000000100000001030000000100000006000000DE2CACAAB54722C0F3EE91A9215B43409FE57970774622C034BA83D8995A4340172993B2034322C054448734695A43401386C5C18E4222C07433158FDF5A43406B65C22FF54322C009E1D1C6115B4340DE2CACAAB54722C0F3EE91A9215B4340', 2, 'Disliked', 1, 0, 0, 0, 0, '0101000020E6100000A294CB8CE84422C0E7732604CE5A4340', '2018-11-02 11:24:27.408703', 349486.78);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (49, '0106000020E6100000010000000103000000010000000500000036A6D8076D4522C0CADEB5E65F5B4340C062F032D74522C0A346964BBB5A43400180031DA24122C01ECDE905CA5A43403A5F1C401C4222C0A87166242B5B434036A6D8076D4522C0CADEB5E65F5B4340', 2, 'Disliked', 1, 0, 1, 1, 1, '0101000020E6100000568526B0EC4322C01F26F353025B4340', '2018-11-02 11:24:27.408703', 282941.23);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (56, '0106000020E61000000100000001030000000100000006000000E4EC3050E94122C0FD390C99A25A434001805C51E93F22C036B31D2C8C5A434001805CD1A53F22C0B0B1B14BFE5A4340C68A1A4CC34022C017D9CEF7535B434018096D39974222C01630815B775B4340E4EC3050E94122C0FD390C99A25A4340', 2, 'Disliked', 1, 1, 1, 0, 1, '0101000020E6100000F1DF997D194122C09E0C4D50FB5A4340', '2018-11-02 11:24:27.408703', 257595.19);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (73, '0106000020E6100000010000000103000000010000000500000000804D91FF5222C0FCADF7AFA25B434001804DD10D5022C0F71B0CB7E65B4340F3F07CF7144C22C09ECD83F7E05B434067ACE979A54D22C0675887451B5B434000804D91FF5222C0FCADF7AFA25B4340', 1, 'Liked', 0, 1, 1, 0, 0, '0101000020E6100000CCD48F8E0E4F22C0C58678D0965B4340', '2018-11-02 11:24:27.408703', 448005.88);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (74, '0106000020E610000001000000010300000001000000050000000080039DD35322C0F88601D7655B43400080035D445022C06B78C96CBB5B434002BC0512144F22C057B26323105B43400080031D665022C0E14E68F1EA5A43400080039DD35322C0F88601D7655B4340', 1, 'Liked', 1, 0, 1, 1, 0, '0101000020E610000006423BF0115122C01DE507B0515B4340', '2018-11-02 11:24:27.408703', 288093.76);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (76, '0106000020E6100000010000000103000000010000000600000060EE46B4605322C0269F86EA555B43400180039D305122C024E5B80CBF5A434002BC0512144F22C057B26323105B4340796B5554535022C0026BB0C88E5B434057471681745222C08DA87CD5945B434060EE46B4605322C0269F86EA555B4340', 1, 'Liked', 1, 1, 0, 1, 0, '0101000020E610000002C9E5A1335122C0D18026D7375B4340', '2018-11-02 11:24:27.408703', 314507.54);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (77, '0106000020E610000001000000010300000001000000060000007A7AD1BE495122C03DFF2D0C825B4340F4DB1CB34F4E22C00D27C98D815B4340E429E4B1E44E22C07FB007D7E15A43409339B16F375122C0665916E6EB5A43405BC87894EA5222C0D999A118365B43407A7AD1BE495122C03DFF2D0C825B4340', 1, 'Liked', 0, 1, 0, 0, 1, '0101000020E6100000C428A75B595022C0938ED53B375B4340', '2018-11-02 11:24:27.408703', 308963.75);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (21, '0106000020E610000001000000010300000001000000070000000180129DD84E22C08A07FF3BEC5B43400180125DC24A22C0946FC4B4805B4340FD2FDA9E684922C088C36AF32D5B43400180129D464A22C02EDB3406AE5A4340018012DDF44C22C050C37855D35A43400180125D194E22C0AC6BCFC26A5B43400180129DD84E22C08A07FF3BEC5B4340', 2, 'Disliked', 0, 1, 0, 1, 0, '0101000020E61000006DA8E526084C22C0304837643F5B4340', '2018-11-02 11:24:27.408703', 509570.95);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (22, '0106000020E610000001000000010300000001000000060000000080039D284A22C09036C1ACA75B43400080039DC04822C0A1E5AC65C65B43400180031DC94722C095774150985B43400CB4E994794822C0309AFB2E685B43400080031D124A22C0A0D3C4FA7D5B43400080039D284A22C09036C1ACA75B4340', 2, 'Disliked', 0, 0, 1, 1, 1, '0101000020E610000053D2DBB2024922C0E7C384D8955B4340', '2018-11-02 11:24:27.408703', 81697.77);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (75, '0106000020E61000000100000001030000000100000004000000008015B4AB5222C0A7A9360DF55A4340B6B755B9F04F22C0297987C3F75A4340018015B4625022C07A4403AB3F5B4340008015B4AB5222C0A7A9360DF55A4340', 2, 'Disliked', 1, 0, 1, 0, 0, '0101000020E61000009392D5B5FF5022C06E22EBD30E5B4340', '2018-11-02 11:24:27.408703', 56840.92);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (63, '0106000020E610000001000000010300000001000000060000000080035D424322C01BF27E1C835C43400180031D674022C0E7D248D6525C43408F368E588B3F22C0E4310395F15B4340371AC05B204122C0F20703CFBD5B4340DEAB5626FC4222C0DDB5847CD05B43400080035D424322C01BF27E1C835C4340', 2, 'Disliked', 0, 0, 1, 0, 0, '0101000020E6100000518E8AE6A14122C0FFF63B16195C4340', '2018-11-02 11:24:27.408703', 283633.53);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (64, '0106000020E61000000100000001030000000100000005000000363CBD52964122C0800EF3E5055C43400180031D4B3E22C0823DB9ECE25B4340157CFC45D23D22C022F484A9815B43400180039DE83E22C021E76773615B4340363CBD52964122C0800EF3E5055C4340', 2, 'Disliked', 1, 1, 0, 1, 1, '0101000020E6100000AF5D3E5D543F22C09696AE0DBA5B4340', '2018-11-02 11:24:27.408703', 163697.26);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (67, '0106000020E610000001000000010300000001000000040000000080039D604E22C0DAA18AA4505C43400180039D414F22C0FC821A42AE5B4340FD9A8B728E4D22C0B1EC7C96A75B43400080039D604E22C0DAA18AA4505C4340', 2, 'Disliked', 0, 1, 0, 1, 0, '0101000020E6100000FE88DB8E654E22C0D805B629E25B4340', '2018-11-02 11:24:27.408703', 81110.16);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (59, '0106000020E61000000100000001030000000100000005000000016611AE6D4322C070763921D55B434021D9BFEF7B4422C0236DC1C4505B4340184339D1AE4222C082734694F65A4340FEB7921D1B4122C057091687335B4340016611AE6D4322C070763921D55B4340', 1, 'Liked', 0, 1, 1, 1, 1, '0101000020E6100000234E6E9DEB4222C0B1BC8988595B4340', '2018-11-02 11:24:27.408703', 210060.73);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (60, '0106000020E61000000100000001030000000100000005000000EA5BE674594C22C049F4328AE55A4340B1B61952B34C22C04531A4BB885A434060CDDA4B414A22C05E74AB694C5A4340B0A9CDE2BC4822C03710BB4D795A4340EA5BE674594C22C049F4328AE55A4340', 1, 'Liked', 0, 1, 1, 1, 1, '0101000020E61000006E3FE698044B22C0B11CE1A3905A4340', '2018-11-02 11:24:27.408703', 165316.80);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (61, '0106000020E610000001000000010300000001000000050000000180035D884822C04AB6910BE85C434051EDAA62274A22C0423E6ECF6E5C4340B9AAECBB224822C08065A549295C434093E3735AA74522C07CAB9CEA5E5C43400180035D884822C04AB6910BE85C4340', 1, 'Liked', 0, 1, 1, 1, 1, '0101000020E61000002D5E12DF114822C0B4BBC3F87C5C4340', '2018-11-02 11:24:27.408703', 245164.75);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (62, '0106000020E6100000010000000103000000010000000500000001809BE88B3F22C0977BDA8DF15B4340FEB7921D1B4122C057091687335B434018096D39974222C01630815B775B434001809B28B34122C00DC32A9CDB5B434001809BE88B3F22C0977BDA8DF15B4340', 1, 'Liked', 1, 1, 0, 0, 1, '0101000020E6100000762EA5C7254122C0B29C824E9C5B4340', '2018-11-02 11:24:27.408703', 168107.28);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (68, '0106000020E610000001000000010300000001000000050000000080035D904F22C042B6BA3A085C434045FE452D594C22C060DFC1E2345C43400A219FA7DD4B22C0506B66FD9D5B4340E7A90EB9194E22C0CF66D5E76A5B43400080035D904F22C042B6BA3A085C4340', 1, 'Liked', 0, 0, 0, 1, 1, '0101000020E6100000482404B6864D22C0FD03C4F0D45B4340', '2018-11-02 11:24:27.408703', 268474.19);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (69, '0106000020E61000000100000001030000000100000006000000B8C125A07B4D22C05394008C675B43400080039D144F22C0D9A16C40105B43400180035DAF4E22C0183DFD7DAD5A434016123F81384D22C0A135F40A9C5A4340EA5BE674594C22C049F4328AE55A4340B8C125A07B4D22C05394008C675B4340', 2, 'Disliked', 1, 0, 1, 0, 0, '0101000020E610000085F8C323BF4D22C02CE191FEF55A4340', '2018-11-02 11:24:27.408703', 196335.58);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (70, '0106000020E6100000010000000103000000010000000500000029F1EC648E4E22C05107C7D1B95B43400180039DF54F22C0FA03FCE44F5B43400080031D4A4E22C0C691324EFA5A434048BE3886774C22C08D61E60A585B434029F1EC648E4E22C05107C7D1B95B4340', 1, 'Liked', 0, 0, 1, 1, 0, '0101000020E6100000DD945F3E494E22C066F3E62F585B4340', '2018-11-02 11:24:27.408703', 193087.97);
INSERT INTO public.eimglx_areas_demo (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, centroid, "timestamp", area_sqm) VALUES (45, '0106000020E610000001000000010300000001000000050000000080031DB54C22C0250F25158E5C434086A86791AC4A22C09F3BBB9E445C4340CC8E31E4154A22C063ECC614065C43400180031DC34D22C0055A0A97175C43400080031DB54C22C0250F25158E5C4340', 2, 'Disliked', 0, 0, 1, 0, 1, '0101000020E6100000ADF5C744064C22C0057EB2973B5C4340', '2018-11-02 11:24:27.408703', 154803.84);


--
-- TOC entry 3692 (class 0 OID 26956)
-- Dependencies: 214
-- Data for Name: eimglx_result; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000070000000080035D904F22C042B6BA3A085C434045FE452D594C22C060DFC1E2345C4340F9F137FF374C22C0DB99535A0C5C4340FDAD3AB0484D22C07740273C815B43409F8EC70C544E22C0B6662B2FF95B4340E776B5910F4F22C07D4FFF24D25B43400080035D904F22C042B6BA3A085C4340', 'Liked', 1, 0, 0.0, 0.0, 0.0, 1.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000009000000970323E9734922C0A04BA4F06E5B4340616181E5E14722C0A11A4854C45B4340008090CB6F4722C00EA78198AC5B4340E8B9B48A1A4722C0062FEEE4C95B434001003017604622C0415B3A09B75B434018DCBB52BB4622C0056C192A785B43400EC4C028F24622C0187A3036655B4340A81554F7614922C0C117FBEC695B4340970323E9734922C0A04BA4F06E5B4340', 'Liked', 1, 0, 0.0, 1.0, 0.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000008000000024B4316FC4222C00328E37BD05B43400180FC22754222C0CBE6F672975B43406C13B616DD4222C07C00F620375B43406221B7E1704322C00DBEBB50405B43400180FC627D4522C0B19983D6EA5B434049334A28FC4222C0FB857B81D05B4340DEAB5626FC4222C0DDB5847CD05B4340024B4316FC4222C00328E37BD05B4340', 'Disliked', 0, 1, 1.0, 0.0, 0.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000110000000097C736084922C07AB83317975A4340018003DD254922C0F7B74C357D5A43400180039DBD4B22C0C900DC10655A43400080035DA14D22C0DF2C254CAB5A4340D483BD8E264D22C08A1211262D5B4340B476DB85E64A22C0F3AB3940305B4340AD81A782E64A22C0943EA839305B4340018019D7E64A22C0F161503D305B4340018019175A4C22C0D091639FE55A4340BE703C2C574B22C0052295FEDD5A4340373A34BFFD4B22C0A7A428D6C55A4340018019D7C74B22C00AA79B07905A4340018019D7E64A22C0FCDD12157A5A4340018019D7D84922C0FAC5E7A38B5A4340D9762C83BA4922C083FAF567AA5A43400180039D1A4922C06721AD59955A43400097C736084922C07AB83317975A4340', 'Disliked', 0, 1, 0.0, 1.0, 0.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000006000000E5C265A77B5122C0F0EA8512925B4340796B5554535022C0026BB0C88E5B434002BC0512144F22C057B26323105B4340358321E4B75022C0275DDC28D15A43400180031D825222C02B76AA2B315B4340E5C265A77B5122C0F0EA8512925B4340', 'Liked', 1, 0, 1.0, 1.0, 0.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000080000007363AA4E074A22C0E3D215A4195C434001804657494A22C051AE82B2ED5B434001804697BC4B22C0013596F2D95B43405C8FC2F5284C22C0B1A206D3305C4340CB12D06FF14B22C0A95E46C3845C4340A456A150254A22C0EBB9784B2B5C43409EE321F5254A22C0D6C09A522B5C43407363AA4E074A22C0E3D215A4195C4340', 'Liked', 1, 0, 1.0, 0.0, 1.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000070000009A081B9E5E4922C05CACA8C1345C4340D399D9974C4B22C054ECD8423C5C4340939A8BD4A24C22C0B6F07DB3485C434001805C114B4B22C076FC9656925C434001805C51944922C0836C384F9D5C43409A7860A7C34822C0EA2987285E5C43409A081B9E5E4922C05CACA8C1345C4340', 'Disliked', 0, 1, 1.0, 1.0, 1.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000A00000054F037AF534C22C0CB3F6A8C2E5C43406DB785F64C4B22C07BE249463C5C4340D399D9974C4B22C054ECD8423C5C434026858BF06A4A22C0DC213AD5385C4340A356A150254A22C0EBB9784B2B5C43409EE321F5254A22C0D6C09A522B5C43401AC69E369C4922C06FE224DCDB5B434090DAC1E8F34B22C0A06C9AC1BC5B43401EB26384F54B22C0A645BBCABC5B434054F037AF534C22C0CB3F6A8C2E5C4340', 'Liked', 1, 0, 1.0, 0.0, 0.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000E0000001B350E540F4C22C093BE1CA6F45A4340018019D7E64A22C0F161503D305B4340B4485860494922C01E39C3551E5B43408468E62B334922C0BFFFC332045B434001000000954922C031627F1FF35A434056779B535F4922C0934ED476E45A43406DDA40B7644A22C0CB9DECD9D65A43404E7B4621C44A22C08E7E8EA9D95A43400DCBBD20DD4A22C0BE871866DA5A4340018019D7404B22C04A33BA3BE15A4340C0703C2C574B22C0052295FEDD5A4340223E143AE64B22C0AA4C8635E25A4340233E143AE64B22C0AA4C8635E25A43401B350E540F4C22C093BE1CA6F45A4340', 'Disliked', 0, 1, 0.0, 1.0, 1.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000060000007161CFA4124822C0788FA6D0F85A43409EE321F5254A22C0D6C09A522B5C434011E4A084994622C0AB09A2EE035C434070A8EC246C4522C052EA03CFC45B434074D154ADAE4722C0E2BFD74BE95A43407161CFA4124822C0788FA6D0F85A4340', 'Liked', 1, 0, 1.0, 1.0, 1.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000B00000070FD5803DE4F22C08EBDD9CF815B43401D399CEEAB4F22C0FF610C9F655B43400180039DF54F22C0FA03FCE44F5B4340E613FB5A474F22C0177FB0012D5B434019A0A25D144F22C04FB4F34D105B43400080039D144F22C0D9A16C40105B4340A8A82C74144F22C0FBF39618105B43400080031D665022C0E14E68F1EA5A434068A01EB4BB5222C0A3A436A33E5B43407A7AD1BE495122C03DFF2D0C825B434070FD5803DE4F22C08EBDD9CF815B4340', 'Liked', 1, 0, 1.0, 0.0, 1.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000008000000807C9C148D3E22C06492A4CD3B5B434059D2DB27953E22C01911ED1B6B5B434089146176D23D22C0FA42EBA3815B43400180C405A33C22C07700838B3B5B43400FA652C1D33E22C081FD1849EC5A43405EE1E41EF13E22C03EFD2C8E075B434001805C918C3E22C0B3DA91BE3B5B4340807C9C148D3E22C06492A4CD3B5B4340', 'Disliked', 0, 1, 1.0, 0.0, 0.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000006000000016861FC8D4022C0817EF0B4765B434001805C918C3E22C0B3DA91BE3B5B43402604928C443F22C04B4D1841DC5A4340216C09997B4122C0BACD1BF6245B4340FEB7921D1B4122C057091687335B4340016861FC8D4022C0817EF0B4765B4340', 'Liked', 1, 0, 1.0, 0.0, 0.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000050000002CF72957A04C22C0713DA8268B5C434086A86791AC4A22C09F3BBB9E445C4340CC8E31E4154A22C063ECC614065C43403FF7C1A23A4C22C0CD63FE49105C43402CF72957A04C22C0713DA8268B5C4340', 'Disliked', 0, 1, 0.0, 0.0, 1.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000B000000C23F7649EA4022C0873FF0A3DC5B434001800E3A204122C0B0E6ADE2BD5B434000800EBA634122C00B319562965B434026FE09B7894222C019E66E25A05B43400080FC22FC4222C0EDC44381D05B4340A0419FE94E4322C09BEB75E7D35B434001800EFA034322C03A04F19A2B5C434001800EFA8D4022C09AE9E045115C43406FA3D47FB24022C0C9C9E872FC5B4340363CBD52964122C0800EF3E5055C4340C23F7649EA4022C0873FF0A3DC5B4340', 'Disliked', 0, 1, 1.0, 0.0, 1.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000400000000802434AB4B22C039CFDE8A3C5B434000802434244B22C0E8292CE8E95B4340008024B44B4922C0DC0C8C7DA15B434000802434AB4B22C039CFDE8A3C5B4340', 'Liked', 1, 0, 1.0, 0.0, 1.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000060000003363244F094222C0DDBFB4BDC95A4340CDF32157CC4222C0D46436CEA15A4340BC91DE084F4522C056BBAB0CCC5A4340DAACFA5C6D4522C016F6B4C35F5B4340DC2414F3424222C085B1D841105B43403363244F094222C0DDBFB4BDC95A4340', 'Liked', 1, 0, 0.0, 1.0, 1.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000900000037A6272CF14022C056D4601A865B43400080031D2C3F22C01E8187563E5B43407B2AD1A8D33E22C04A375732EC5A43400180035D913F22C0DF2C254CAB5A43400180035DF94022C05B56162AE25A4340E174E31DAC4122C079F3E1A21D5B4340FEB7921D1B4122C057091687335B43403E0567BCAD4122C0773F05615B5B434037A6272CF14022C056D4601A865B4340', 'Disliked', 0, 1, 1.0, 0.0, 0.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000080000008DB7FBE0414D22C088E60F2E7E5B434088687407B14B22C0C286A757CA5A4340938B31B08E5322C098F90E7EE25A4340A61AE004104F22C0C54D050DD25B43400180039D414F22C0FC821A42AE5B434097AA7DFAB44E22C068933E1AAC5B4340E7A90EB9194E22C0CF66D5E76A5B43408DB7FBE0414D22C088E60F2E7E5B4340', 'Disliked', 0, 1, 1.0, 1.0, 0.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000007000000858A479FE64F22C0068FA350545B434029F1EC648E4E22C05107C7D1B95B4340366870913D4D22C0009AF73E7C5B434091D974150D4D22C0BA16727E665B434063685F1AA54D22C0222DB0741B5B434018B536D7A54D22C04712C04E1B5B4340858A479FE64F22C0068FA350545B4340', 'Liked', 1, 0, 0.0, 0.0, 1.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000C000000376DB95DC64D22C0E2C584E4D05B43400080039D334E22C069989DE59E5B434050BE5961ED4C22C004D937D1AF5B434001801DBACF4D22C0E62EC7573C5B4340C031A546734D22C02D25090D345B434067ACE979A54D22C0675887451B5B434093F1B1507F4E22C08E395ACD305B4340018003DD984E22C0850933AC585B434041CB6CFF375122C0E00DDADAAA5B43404CBD8196295122C028F090EFCC5B4340587380608E4E22C048FE60E0B95B4340376DB95DC64D22C0E2C584E4D05B4340', 'Liked', 1, 0, 0.0, 1.0, 1.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000001A00000081E80464CD4522C0CBA3FBCE825B4340D97745F0BF4522C0164D6727835B4340F8BF884F714522C03B4CC1FD035B434001000080A04522C08430CDE6FB5A4340011D1E3B6A4522C0F683958AF85A43400955D9304F4522C07F1064CFCC5A4340BC91DE084F4522C056BBAB0CCC5A434051AE0AB54E4522C0152F2907CC5A43400180031D264522C0290E6C608A5A43400080031DAA4822C0467EFFDE625A43406984C8C30C4922C0E8B8A9FDD65A4340D192A9FDD54822C0A6F481F9DC5A43400080039DC04822C011F6ACE1B15A4340B203BEFBDA4722C006FA8EB4D85A434065ADCEC0DA4722C0684C8F92D85A4340011BD1EFD94722C0BA5EDBE1D85A434082F78F26714722C0AE8C3A99EA5A43409FE57970774622C0F4E0EEACDD5A43401380573D4F4622C01E36D867025B434081B58A024B4622C0DA737279025B4340D4EF8FAE4A4622C0C580EB91065B4340F5D6C056094622C097ADF545425B4340318A630EAA4622C0ED52F92E4C5B4340D5A017EC3C4622C0F6109697755B43400080039D1D4622C0E23AFFCF705B434081E80464CD4522C0CBA3FBCE825B4340', 'Disliked', 0, 1, 0.0, 1.0, 1.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000D0000004B8619ADB13F22C0AB261F3FEA5A434001805C51E93F22C036B31D2C8C5A4340E4EC3050E94122C0FD390C99A25A434099EF7F65084222C0DD4CDF9FC85A43400180031DA24122C01ECDE905CA5A43403FDBD288CE4122C063925F58ED5A43405531957EC24122C03FFF3D78ED5A4340D57D44A8D84122C06663FF64F55A43406B142715FC4122C074E24090115B4340735F6CE1B04122C0C9B8C3EA1C5B4340018007801D4122C0AA18E777095B4340ECE566A1EB4022C089F97880125B43404B8619ADB13F22C0AB261F3FEA5A4340', 'Disliked', 0, 1, 1.0, 1.0, 1.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000007000000C2855025BD4822C0572B0B46795A434060CDDA4B414A22C05E74AB694C5A4340B1B61952B34C22C04531A4BB885A434011ECC7F9714C22C04970C437CC5A4340B2837754B04A22C0D4AB92C5B35A4340CC74E933BD4822C08CCE3957795A4340C2855025BD4822C0572B0B46795A4340', 'Liked', 1, 0, 0.0, 1.0, 1.0, 1.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000110000009DC6C956D85422C0E59D7AFF225B4340156A4FFB585422C0B2BA305BA35B4340FD78DF5C485422C051A6A74FA95B4340E446815D9D5222C062DE1173EF5B43401E87C1FC155222C0BBEF181EFB5B4340A12EEA80EB5122C09615F062E05B43400180039D115222C04CF65290D35B43409835C057D45122C07F9B43D0D15B43401CDA7160B85122C08D6A9337C05B434000804D91FF5222C0FCADF7AFA25B434068E38C43735222C0EE8FF6D1945B434057471681745222C08DA87CD5945B4340D87AA7C9C55222C082AB992E7F5B43400080039DD35322C0F88601D7655B4340AEA260645F5322C015390C90555B434049126525155322C09FB45090415B43409DC6C956D85422C0E59D7AFF225B4340', 'Liked', 1, 0, 0.0, 1.0, 0.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000120000004B126525155322C09FB45090415B4340ED2160274D5422C0752E4E6D2C5B43409DC6C956D85422C0E59D7AFF225B4340156A4FFB585422C0B2BA305BA35B4340FC78DF5C485422C051A6A74FA95B4340E746815D9D5222C061DE1173EF5B43401E87C1FC155222C0BBEF181EFB5B4340A12EEA80EB5122C09615F062E05B43400180039D115222C04CF65290D35B43409735C057D45122C07F9B43D0D15B43401BDA7160B85122C08D6A9337C05B434000804D91FF5222C0FCADF7AFA25B43406AE38C43735222C0EE8FF6D1945B434057471681745222C08DA87CD5945B4340D87AA7C9C55222C082AB992E7F5B43400080039DD35322C0F88601D7655B4340AFA260645F5322C015390C90555B43404B126525155322C09FB45090415B4340', 'Liked', 1, 0, 0.0, 0.0, 1.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000008000000E8BB3FB8A24E22C0A1F5B48F285B4340B8C125A07B4D22C05394008C675B4340EA5BE674594C22C049F4328AE55A434016123F81384D22C0A135F40A9C5A43400180035DAF4E22C0183DFD7DAD5A4340786E8409E54E22C0B01583D8E15A4340E429E4B1E44E22C07FB007D7E15A4340E8BB3FB8A24E22C0A1F5B48F285B4340', 'Disliked', 0, 1, 1.0, 0.0, 1.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000002000000080000008340540AA34B22C08BA4DA690A5B43405F2A2505674C22C0D476B0FD1B5B4340FDAD3AB0484D22C07740273C815B434000801DFA184C22C011359B2D1C5C43400180215DE34722C079659E18EE5B4340526417F4824922C0AD280CD4205B4340018019D7E64A22C0F161503D305B43408340540AA34B22C08BA4DA690A5B43400400000000802434AB4B22C039CFDE8A3C5B4340008024B44B4922C0DC0C8C7DA15B434000802434244B22C0E8292CE8E95B434000802434AB4B22C039CFDE8A3C5B4340', 'Liked', 1, 0, 1.0, 0.0, 1.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000120000004B2B4BD0375122C02C1D8FF6EB5A4340CAD59429695122C0423A9A4DF65A4340B6B755B9F04F22C0297987C3F75A4340018015B4625022C07A4403AB3F5B43405F067D7FDF5122C0A5F30F190F5B43400180031D825222C02B76AA2B315B4340E303EFFA015222C0DCF9697A605B43407A7AD1BE495122C03DFF2D0C825B43406D0753C4325022C0176EE8DD815B4340DCED736ED04F22C061C7C6DB5A5B43400180039DF54F22C0FA03FCE44F5B4340C2F7AABD724F22C006E456B1355B4340E7ED3B72144F22C0B5288E49105B43400080039D144F22C0D9A16C40105B43400BFDAF70144F22C0753D3015105B4340140DD9A0245022C05FA93F40E75A43409339B16F375122C0665916E6EB5A43404B2B4BD0375122C02C1D8FF6EB5A4340', 'Liked', 1, 0, 0.0, 1.0, 1.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000D00000023AD5FD6FF5022C0BCE239AE2F5C43400080039D4F5022C09A096CF96A5C43400180039DD94D22C0F57BF295665C43403B46FC4C5E4D22C08D8030D5435C43400BA65DFEA94D22C0EC36349D225C4340B22503781F4E22C00583C33D1C5C43400080039D604E22C0DAA18AA4505C4340DE50AB6AB44E22C05AD33E29145C43400080035D904F22C042B6BA3A085C4340918AE9C03D4F22C072B7F289E55B434001804DD10D5022C0F71B0CB7E65B434069199183295122C027875C1CCD5B434023AD5FD6FF5022C0BCE239AE2F5C4340', 'Liked', 1, 0, 0.0, 0.0, 1.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000C000000D4B622C4C34822C0894F3B315E5C4340230C685E8E4922C0A6374E829B5C43400180035D884822C04AB6910BE85C4340A521667F364622C05CABCD8C795C434043051D1F584622C00E81709C515C4340E634B75F584622C04DA89197515C434043288ACC594622C089ACDADA4F5C43407FCDA91C934622C0FC4E77044B5C4340B9AAECBB224822C078D15790665C4340F2ADDAC9224822C038A61781665C43400080031D234822C0F57BF295665C4340D4B622C4C34822C0894F3B315E5C4340', 'Liked', 1, 0, 0.0, 1.0, 1.0, 1.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000080000006B142715FC4122C073E24090115B43400180031DA24122C01ECDE905CA5A4340C062F032D74522C0A346964BBB5A434036A6D8076D4522C0CADEB5E65F5B4340D0E2C5AB7B4422C0DC3B0CE6505B434021D9BFEF7B4422C0236DC1C4505B4340184339D1AE4222C082734694F65A43406B142715FC4122C073E24090115B4340', 'Disliked', 0, 1, 1.0, 0.0, 1.0, 1.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000007000000645BED2EDD4222C0563EFD8BEA5A434040D179DD8E4222C096DDF692DF5A4340EFEA04CB8E4222C02833B985DF5A4340172993B2034322C054448734695A4340DCCE18F2B94422C0FAF57953815A4340B3BD950BC24322C03121362EE85A4340645BED2EDD4222C0563EFD8BEA5A4340', 'Disliked', 0, 1, 1.0, 0.0, 0.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000007000000363CBD52964122C0800EF3E5055C43400180031D4B3E22C0823DB9ECE25B4340157CFC45D23D22C022F484A9815B434088146176D23D22C0FA42EBA3815B43400180C4854E3E22C0AAEA694C9E5B4340C98CE169B13F22C058BC5B9B915B4340363CBD52964122C0800EF3E5055C4340', 'Disliked', 0, 1, 1.0, 1.0, 0.0, 1.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000090000007DA15BF1394722C098B1671C2C5C43400080031D184422C076D2954F365C43404E97C5C4E64322C048FE60E0B95B4340BE74CD12024422C0A7C1F547BB5B43406D57E883654422C0588CBAD6DE5B43409E347DE82E4622C0F5A3F6F7DF5B4340EE5589CCFF4622C0DFBD1A87FE5B43400080035D994622C0DA0735D7035C43407DA15BF1394722C098B1671C2C5C4340', 'Disliked', 0, 1, 1.0, 0.0, 1.0, 1.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000C0000005C9733961C4D22C04E9F0FAC605C4340008090CB694D22C0629511E56F5C43400180908B314D22C0EDB51006D75C43400080900B3A4C22C0E59FDA28EF5C43402F27E1D9B24A22C0BCE0FE24965C434041D54EE6364B22C0DFF2B1D7925C434000804657DE4B22C09C1EA1A1A15C4340CB12D06FF14B22C0A95E46C3845C434000805597BB4C22C046D80D12AC5C43402CF72957A04C22C0713DA8268B5C43400080031DB54C22C0250F25158E5C43405C9733961C4D22C04E9F0FAC605C4340', 'Liked', 1, 0, 1.0, 0.0, 1.0, 1.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000006000000AD729FDF905022C0BC3E84ED815B4340F4DB1CB34F4E22C00D27C98D815B4340E429E4B1E44E22C07FB007D7E15A43409339B16F375122C0665916E6EB5A43407410CE08685222C064FE28D61F5B4340AD729FDF905022C0BC3E84ED815B4340', 'Liked', 1, 0, 0.0, 1.0, 0.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000011000000C248BA3C514822C0A3FC3188025B434044EB8A820D4822C08D1FB5A8855B43400180031DC94722C095774150985B434039FB31B8FE4722C04D55774BA25B434053CF8250DE4722C0E0F3C308E15B43406D57E883654422C0588CBAD6DE5B4340A102BACECA4322C00C1DFE84A75B4340D0E2C5AB7B4422C0DC3B0CE6505B434036A6D8076D4522C0CADEB5E65F5B4340CE5725226D4522C0C356EFBD5F5B4340DAACFA5C6D4522C016F6B4C35F5B434010C5DF4D6D4522C0843A237A5F5B4340A3D9BFEB9A4522C0571B7AC0185B4340DE2CACAAB54722C0F3EE91A9215B43408600953D1A4722C0C0BCEF53DF5A43403D9C6F34694722C011C4EC82DE5A4340C248BA3C514822C0A3FC3188025B4340', 'Liked', 1, 0, 1.0, 1.0, 1.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000007000000B5364661614622C0150C219D465C434043051D1F584622C00E81709C515C4340EBEF1976B34322C0B49937A0845C434001069AA8B24322C0C68BA899845C4340D0604BFD074522C0AEAA95A00E5C4340D5DEEE0C984622C04DD6A3F8035C4340B5364661614622C0150C219D465C4340', 'Liked', 1, 0, 1.0, 1.0, 0.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000C0000000080035D424322C01BF27E1C835C43400180031D674022C0E7D248D6525C43408F368E588B3F22C0E4310395F15B43403C13EF088C3F22C0223A777EF15B434001809BE88B3F22C0977BDA8DF15B4340B9911D329C3F22C0CBCCDFE7F05B43406EA3D47FB24022C0C9C9E872FC5B434001800EFA8D4022C09AE9E045115C43408BB7E465D94122C018701E201F5C43400180039D3F4222C024A7D1AB455C43401CC2ABDD2D4322C0945423F74E5C43400080035D424322C01BF27E1C835C4340', 'Disliked', 0, 1, 0.0, 0.0, 1.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000008000000AB63A255F75022C02E21AD986C5B43405A9A824B5F5022C0F4C282D5FF5A43407BC47C8D925022C09A0CB862E25A434080457172835122C0F8BF5F54DD5A43402F077808295222C0F5159DAA055B4340C20853E21D5222C02CD6E824E15A434028DEE052035322C021F1BC81FF5A4340AB63A255F75022C02E21AD986C5B4340', 'Disliked', 0, 1, 0.0, 0.0, 0.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000D000000294E5BBF2E4E22C0AFCBCD225B5A43400080039D144F22C092F16ACE295A4340018003DD685122C0D260B842675A4340EC3D3B791E5122C03AC0AFFF915A4340018097850F5022C0A74575BA825A4340FE16FF75E05022C0243045A0B55A43403DED7080B25022C0D481C607D05A43400080039D225022C011F6ACE1B15A4340743748C1D34E22C008001AFDD05A43400180035DAF4E22C0183DFD7DAD5A434048D02C371B4E22C0A6819298A65A43400080031D854F22C004D6912E885A4340294E5BBF2E4E22C0AFCBCD225B5A4340', 'Disliked', 0, 1, 1.0, 1.0, 0.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000009000000CB12D06FF14B22C0A95E46C3845C4340A556A150254A22C0ECB9784B2B5C43409EE321F5254A22C0D6C09A522B5C43407363AA4E074A22C0E3D215A4195C434001804657494A22C051AE82B2ED5B43401A93B11E134B22C08DA18DF6E25B434086D42A88284C22C05F132B7B305C43405C8FC2F5284C22C0B1A206D3305C4340CB12D06FF14B22C0A95E46C3845C4340', 'Liked', 1, 0, 0.0, 1.0, 0.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E610000001000000090000007619F456AF4222C0C88D3C65A15B4340FEB7921D1B4122C057091687335B43402F03623D1D4222C0884CC08E0C5B43407C5322CB224422C05D5751553F5B434021D9BFEF7B4422C0236DC1C4505B4340016611AE6D4322C070763921D55B434013B383DC534322C07FE4C01CCE5B434001800E7A744322C0D373DEF0A75B43407619F456AF4222C0C88D3C65A15B4340', 'Liked', 1, 0, 0.0, 1.0, 1.0, 1.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000D000000A675F0358B4422C0827B6EB7945A43407742C2D9E34422C091C78BF06F5A43404BBD6216154522C0C8A79CD26E5A43408CEC4E561D4622C0D4B967BB705A4340BEF16BD5664722C0B64F92E9655A43409073FE922A4822C0A246AE2F6E5A43408F225019314822C05AAEAAA4805A43403C78E69E704722C0CBD92DD49F5A4340FAF74BE56E4622C030E22DECB95A4340BF5DC705464522C0AFF0E177BC5A4340FB9F9C73104522C067486175BA5A4340D5CB4FADEA4422C094E1A631AD5A4340A675F0358B4422C0827B6EB7945A4340', 'Liked', 1, 0, 1.0, 0.0, 0.0, 1.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000600000001804657654C22C04635CB94505A43402BF1786AE24B22C07FB5F676AA5A4340EE42739D464A22C0D1967329AE5A434001804657954922C08A2995B2735A434000804617984A22C0195B3C70385A434001804657654C22C04635CB94505A4340', 'Disliked', 0, 1, 0.0, 1.0, 1.0, 0.0, 0.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E6100000010000000500000001809BE88B3F22C0977BDA8DF15B4340FEB7921D1B4122C057091687335B434018096D39974222C01630815B775B434001809B28B34122C00DC32A9CDB5B434001809BE88B3F22C0977BDA8DF15B4340', 'Liked', 1, 0, 1.0, 1.0, 0.0, 0.0, 1.0);
INSERT INTO public.eimglx_result (geom, category, ct_overlap_liked, ct_overlap_disliked, sum_attnat, sum_attopen, sum_attorder, sum_attupkeep, sum_atthist) VALUES ('0103000020E61000000100000010000000543E6DF56C4222C0B0F8DA3FC75A43403E09F8A93E4222C015029009A65A43402028D27A004222C092D9166D795A43403541D47D004222C074EACA67795A4340ADF52575004222C067090569795A43400180E95F004222C0FAE4C859795A43400180E91F4C4522C0875B15AD445A43407742C2D9E34422C091C78BF06F5A4340ED8A86CE884422C007624401725A43401E69038E114422C0878A238E8D5A4340A517E1A79A4322C0CB228AD38A5A43404343A86C1B4322C0D18E8CBDB65A4340DE14817CE14322C0D95775AEBD5A4340D379BC79BE4322C01709DD19C25A4340BBABD570BF4322C09FAF009FC25A4340543E6DF56C4222C0B0F8DA3FC75A4340', 'Disliked', 0, 1, 0.0, 1.0, 1.0, 1.0, 0.0);


--
-- TOC entry 3691 (class 0 OID 26950)
-- Dependencies: 213
-- Data for Name: eimglx_sample; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (87, '0106000020E610000001000000010300000001000000040000009F8EC70C544E22C0B6662B2FF95B4340938B31B08E5322C098F90E7EE25A434088687407B14B22C0C286A757CA5A43409F8EC70C544E22C0B6662B2FF95B4340', 2, 'Disliked', 1, 1, 0, 0, 0, NULL, NULL);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (13, '0106000020E6100000010000000103000000010000000500000001000040BF4822C06E2B7B6E185B434001000000954922C031627F1FF35A434001000080244922C0B615DE65D45A4340010000400B4822C031627F1FF35A434001000040BF4822C06E2B7B6E185B4340', 2, 'Disliked', 1, 1, 0, 0, 1, '2018-11-02 11:24:27.408703', 30111.11);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (14, '0106000020E6100000010000000103000000010000000700000001000080A04522C08430CDE6FB5A434017543611D94422C00D3C998DEF5A43404E9CDCEF504422C0A54929E8F65A434001000000F54322C0BA4506D9115B434001000080B14322C0B66012F6345B4340010000402D4422C0A8CE808B3B5B434001000080A04522C08430CDE6FB5A4340', 2, 'Disliked', 0, 0, 1, 1, 0, '2018-11-02 11:24:27.408703', 41023.82);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (16, '0106000020E610000001000000010300000001000000040000000180031D044922C07107E9F2395B43400080039DC04822C011F6ACE1B15A43400080031D6F4722C0E14E68F1EA5A43400180031D044922C07107E9F2395B4340', 2, 'Disliked', 1, 1, 1, 0, 0, '2018-11-02 11:24:27.408703', 55948.64);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (18, '0106000020E610000001000000010300000001000000050000000180E9BFBC4322C013DDAE60EA5A43400180E91F4C4522C0875B15AD445A43400180E95F004222C0FAE4C859795A43400180E9BFAE4222C07F3EBC72F65A43400180E9BFBC4322C013DDAE60EA5A4340', 2, 'Disliked', 0, 1, 1, 1, 0, '2018-11-02 11:24:27.408703', 173845.34);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (26, '0106000020E610000001000000010300000001000000050000000180FC627D4522C0B19983D6EA5B43400080FC22FC4222C00505375C1A5B43400180FC22754222C0CBE6F672975B43400080FC22FC4222C0EDC44381D05B43400180FC627D4522C0B19983D6EA5B4340', 2, 'Disliked', 1, 0, 0, 0, 0, '2018-11-02 11:24:27.408703', 158912.55);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (27, '0106000020E610000001000000010300000001000000050000000080031D234822C0E9231425295C43400080031D184422C076D2954F365C43404E97C5C4E64322C048FE60E0B95B43400180031DDA4522C04CF65290D35B43400080031D234822C0E9231425295C4340', 2, 'Disliked', 1, 0, 1, 1, 1, '2018-11-02 11:24:27.408703', 176621.21);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (28, '0106000020E6100000010000000103000000010000000400000000802434AB4B22C039CFDE8A3C5B434000802434244B22C0E8292CE8E95B4340008024B44B4922C0DC0C8C7DA15B434000802434AB4B22C039CFDE8A3C5B4340', 2, 'Disliked', 1, 1, 1, 1, 0, '2018-11-02 11:24:27.408703', 103057.08);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (30, '0106000020E610000001000000010300000001000000060000000080039DDC4A22C091ED6B9BD05A43403813C0C4DC4822C005FA7543EB5A43402A6F47382D4822C0E65C8AABCA5A43400180035DA74722C0D3883377B85A43400180039D1A4922C06721AD59955A43400080039DDC4A22C091ED6B9BD05A4340', 2, 'Disliked', 0, 1, 1, 1, 1, '2018-11-02 11:24:27.408703', 79675.99);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (32, '0106000020E6100000010000000103000000010000000500000082FFAD64C74622C0176536C8245B43400180039D774622C01E8B6CC6DD5A43400080031D9F4422C06B3AF6AA095B43400080039D694522C0F9BC6964285B434082FFAD64C74622C0176536C8245B4340', 2, 'Disliked', 0, 1, 0, 0, 1, '2018-11-02 11:24:27.408703', 54549.37);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (33, '0106000020E61000000100000001030000000100000007000000373A34BFFD4B22C0A7A428D6C55A4340018019D7404B22C04A33BA3BE15A434001801997A04922C0AF29E0B3C45A4340018019D7D84922C0FAC5E7A38B5A4340018019D7E64A22C0FCDD12157A5A4340018019D7C74B22C00AA79B07905A4340373A34BFFD4B22C0A7A428D6C55A4340', 2, 'Disliked', 1, 1, 1, 1, 0, '2018-11-02 11:24:27.408703', 98540.06);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (34, '0106000020E61000000100000001030000000100000005000000018019175A4C22C0D091639FE55A4340018019D7E64A22C0F161503D305B4340D4D4B2B5BE4822C0D09B8A54185B434040C4CB8CCC4822C091F774D3CA5A4340018019175A4C22C0D091639FE55A4340', 2, 'Disliked', 0, 1, 1, 1, 0, '2018-11-02 11:24:27.408703', 135938.35);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (39, '0106000020E6100000010000000103000000010000000600000001800EFA034322C03A04F19A2B5C434001800E7A744322C0D373DEF0A75B434000800EBA634122C00B319562965B434001800E3A204122C0B0E6ADE2BD5B434001800EFA8D4022C09AE9E045115C434001800EFA034322C03A04F19A2B5C4340', 2, 'Disliked', 1, 0, 1, 1, 0, '2018-11-02 11:24:27.408703', 173638.91);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (41, '0106000020E610000001000000010300000001000000080000006FA8E997CA4A22C09AE858FAF65A4340F0A2AF20CD4822C0E65C8AABCA5A4340018003DD254922C0F7B74C357D5A43400180039DBD4B22C0C900DC10655A43400080035DA14D22C0DF2C254CAB5A4340D483BD8E264D22C08A1211262D5B4340B476DB85E64A22C0F3AB3940305B43406FA8E997CA4A22C09AE858FAF65A4340', 2, 'Disliked', 0, 1, 0, 0, 0, '2018-11-02 11:24:27.408703', 382390.82);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (42, '0106000020E610000001000000010300000001000000050000000080031DAA4822C0467EFFDE625A43400180031D264522C0290E6C608A5A4340D97745F0BF4522C0164D6727835B4340EF7211DF894922C088BA0F406A5B43400080031DAA4822C0467EFFDE625A4340', 2, 'Disliked', 0, 1, 1, 0, 1, '2018-11-02 11:24:27.408703', 551913.33);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (37, '0106000020E6100000010000000103000000010000000600000001804657654C22C04635CB94505A43402BF1786AE24B22C07FB5F676AA5A4340EE42739D464A22C0D1967329AE5A434001804657954922C08A2995B2735A434000804617984A22C0195B3C70385A434001804657654C22C04635CB94505A4340', 2, 'Disliked', 0, 1, 1, 0, 0, '2018-11-02 11:24:27.408703', 133127.11);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (89, '0106000020E610000001000000010300000001000000050000001E87C1FC155222C0BBEF181EFB5B4340C0046EDDCD5322C0105B7A34D55B434059FAD005F55522C0C26856B60F5B434064027E8D245122C08CBE8234635B43401E87C1FC155222C0BBEF181EFB5B4340', 1, 'Liked', 0, 0, 1, 1, 0, NULL, NULL);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (52, '0106000020E610000001000000010300000001000000060000004985B185204722C01DACFF73985B4340F068D25D934622C0EEBC3983F65A4340C1FF56B2634322C082AD122C0E5B4340E89E1C6CC14322C088954605905B43404C546F0D6C4522C0DD989EB0C45B43404985B185204722C01DACFF73985B4340', 2, 'Disliked', 1, 1, 1, 1, 1, '2018-11-02 11:24:27.408703', 324353.10);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (88, '0106000020E6100000010000000103000000010000000500000053CF8250DE4722C0E0F3C308E15B434049810530654822C001C3F2E7DB5A43405531957EC24122C03FFF3D78ED5A43406D57E883654422C0588CBAD6DE5B434053CF8250DE4722C0E0F3C308E15B4340', 1, 'Liked', 1, 1, 1, 0, 0, NULL, NULL);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (54, '0106000020E610000001000000010300000001000000060000000180C485F14022C05672BC28865B43400180C4854E3E22C0AAEA694C9E5B43400180C405A33C22C07700838B3B5B43403541D47D004222C074EACA67795A4340F715F395C34122C0EF08DFA4E45A43400180C485F14022C05672BC28865B4340', 2, 'Disliked', 1, 0, 0, 0, 1, '2018-11-02 11:24:27.408703', 456548.50);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (55, '0106000020E6100000010000000103000000010000000700000037A6272CF14022C056D4601A865B43400080031D2C3F22C01E8187563E5B43407B2AD1A8D33E22C04A375732EC5A43400180035D913F22C0DF2C254CAB5A43400180035DF94022C05B56162AE25A43405D51682B1B4222C0366C7A95425B434037A6272CF14022C056D4601A865B4340', 2, 'Disliked', 1, 0, 0, 0, 1, '2018-11-02 11:24:27.408703', 228148.65);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (1, '0106000020E6100000010000000103000000010000000C000000FB48FA5E684622C065786C635F5B434091DF59C3094622C09A4E501D425B434091DF59C3094622C09A4E501D425B43409AC56F9DE24522C0DCB40D91155B434081B58A024B4622C0D8437D051A5B434073DC69BB854622C06BB75AEE225B434064B29AFAC64622C0C92A1CD7245B434053371DC00E4722C00BB1B305285B43404A5107E6354722C0BA907891315B43404DF363D9284722C03950BA91465B4340DAA3AD63F14622C0C7B8EF915B5B4340FB48FA5E684622C065786C635F5B4340', 1, 'Liked', 0, 0, 0, 1, 1, '2018-11-02 11:24:27.408703', 36681.78);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (3, '0106000020E6100000010000000103000000010000000C000000BF5DC705464522C0AFF0E177BC5A434010D22FBDF24322C01FD85BBDAF5A43400A8E76D60C4422C0042F1DA58E5A4340ED8A86CE884422C007624401725A43404BBD6216154522C0C8A79CD26E5A43408CEC4E561D4622C0D4B967BB705A4340BEF16BD5664722C0B64F92E9655A43409073FE922A4822C0A246AE2F6E5A43408F225019314822C05AAEAAA4805A43403C78E69E704722C0CBD92DD49F5A4340FAF74BE56E4622C030E22DECB95A4340BF5DC705464522C0AFF0E177BC5A4340', 1, 'Liked', 1, 0, 0, 1, 0, '2018-11-02 11:24:27.408703', 151539.90);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (15, '0106000020E6100000010000000103000000010000000600000000001E404A4522C02891EA607E5B434001001EC08D4522C0B0D74B20435B434001001EC0174322C0D730E983475B434000001E80394322C02891EA607E5B434001001E80474422C0DC0C8C7DA15B434000001E404A4522C02891EA607E5B4340', 1, 'Liked', 0, 1, 0, 1, 0, '2018-11-02 11:24:27.408703', 95096.75);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (17, '0106000020E61000000100000001030000000100000005000000010030D78F4722C0ACD518C2D55B4340010030178A4922C0D19C9A3A6A5B43402D26361FD74622C04F58E201655B434001003017604622C0415B3A09B75B4340010030D78F4722C0ACD518C2D55B4340', 1, 'Liked', 0, 1, 0, 1, 0, '2018-11-02 11:24:27.408703', 118596.68);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (19, '0106000020E6100000010000000103000000010000000500000000801DFA184C22C011359B2D1C5C434001801DBACF4D22C0E62EC7573C5B434000801DFAFC4922C0015FFA8EE45A43400180215DE34722C079659E18EE5B434000801DFA184C22C011359B2D1C5C4340', 1, 'Liked', 1, 0, 1, 1, 0, '2018-11-02 11:24:27.408703', 638992.25);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (29, '0106000020E610000001000000010300000001000000060000001989CFB5634822C018ED5566055B43400180035DF34622C070FABF37CC5A43400180039D774622C041D15FBD995A4340D578E926314822C08351499D805A4340332489332D4822C02D73069ECA5A43401989CFB5634822C018ED5566055B4340', 1, 'Liked', 0, 1, 0, 1, 1, '2018-11-02 11:24:27.408703', 75482.81);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (31, '0106000020E610000001000000010300000001000000060000000080031D644322C0DCA19A0E0E5B434089EFC4AC174322C0D00F2384475B43400180031DA24122C021E76773615B43400180031D1B4122C03D4E7A5D335B43400180031DA24122C025DCD8B1FE5A43400080031D644322C0DCA19A0E0E5B4340', 1, 'Liked', 1, 0, 1, 0, 1, '2018-11-02 11:24:27.408703', 86835.09);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (35, '0106000020E6100000010000000103000000010000000500000001801917E14C22C013CFA6E16F5B434091630B35CC4A22C0E500671FF75A43409308AF35604A22C0C2A8B46D2A5B434026C79DD2C14A22C01D7233DC805B434001801917E14C22C013CFA6E16F5B4340', 1, 'Liked', 1, 1, 0, 0, 0, '2018-11-02 11:24:27.408703', 100028.86);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (40, '0106000020E610000001000000010300000001000000050000001CF743D16E4822C0342D111A685B434066300C16E64822C0C4E70EE6FD5A43409FE57970774622C0F4E0EEACDD5A4340F5D6C056094622C097ADF545425B43401CF743D16E4822C0342D111A685B4340', 1, 'Liked', 0, 1, 0, 0, 0, '2018-11-02 11:24:27.408703', 152697.99);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (43, '0106000020E6100000010000000103000000010000000D0000006D148F7D014822C04C95B36E075B434016C1FF56B24322C03FC6DCB5845C4340E634B75F584622C04DA89197515C43401923C32AA74622C02EF8608BF15B4340008090CB6F4722C00EA78198AC5B43408E62C422954822C0ECBE959CE95B4340008090CB5E4922C0D94A03A6345C43400080900BA54A22C02DC5C500935C43400080900B3A4C22C0E59FDA28EF5C43400180908B314D22C0EDB51006D75C4340008090CB694D22C0629511E56F5C434003951D69294C22C0B2B406BA305C43406D148F7D014822C04C95B36E075B4340', 1, 'Liked', 1, 0, 1, 1, 1, '2018-11-02 11:24:27.408703', 839880.73);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (46, '0106000020E610000001000000010300000001000000060000005C8FC2F5284C22C0B1A206D3305C434001804697BC4B22C0013596F2D95B434001804657494A22C051AE82B2ED5B4340018046178A4922C0D0761BF86C5C434000804657DE4B22C09C1EA1A1A15C43405C8FC2F5284C22C0B1A206D3305C4340', 1, 'Liked', 1, 0, 1, 0, 1, '2018-11-02 11:24:27.408703', 201697.57);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (79, '0106000020E610000001000000010300000001000000040000002F077808295222C0F5159DAA055B4340018097C5095222C019F783429F5A4340018097850F5022C0A74575BA825A43402F077808295222C0F5159DAA055B4340', 1, 'Liked', 1, 0, 0, 1, 0, '2018-11-02 11:24:27.408703', 57274.44);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (66, '0106000020E610000001000000010300000001000000040000008CBE8234634122C048A7AE7C965B43400080031DA53E22C0F9937397C85B4340CA1AF5108D3E22C0D0F23CB83B5B43408CBE8234634122C048A7AE7C965B4340', 1, 'Liked', 1, 0, 0, 0, 1, '2018-11-02 11:24:27.408703', 112519.98);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (83, '0106000020E610000001000000010300000001000000060000000180039D115222C04CF65290D35B43400080039D4F5022C09A096CF96A5C43400180039DD94D22C0F57BF295665C4340755240E15A4C22C0F1F37EB8FA5B4340587380608E4E22C048FE60E0B95B43400180039D115222C04CF65290D35B4340', 1, 'Liked', 0, 0, 1, 0, 0, '2018-11-02 11:24:27.408703', 385402.96);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (36, '0106000020E61000000100000001030000000100000005000000018003DDCE4522C0B6597D6C0A5C43400180035D204722C095774150985B43400080039D1D4622C0E23AFFCF705B43400080039D3C4522C07AAC2F49A35B4340018003DDCE4522C0B6597D6C0A5C4340', 1, 'Liked', 0, 1, 0, 1, 0, '2018-11-02 11:24:27.408703', 82549.94);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (23, '0106000020E610000001000000010300000001000000050000000180129DB44522C0872F0F39BC5B43400180125DE74322C0BCBE4707BA5B43400180121D364422C0D5EFA12A835B4340018012DDBF4522C0D5EFA12A835B43400180129DB44522C0872F0F39BC5B4340', 2, 'Disliked', 1, 1, 0, 1, 0, '2018-11-02 11:24:27.408703', 53887.05);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (4, '0106000020E61000000100000001030000000100000008000000AFC79C14A84722C0B08E05EF5A5B4340AC254021B54722C02009F7D7785B4340440D4EFF4F4722C078640D35785B4340E1E7664AD74622C005D4A61D655B43405C1D339AE74622C07BB0657A415B4340440D4EFF4F4722C0BA907891315B4340A5E1863ACF4722C0BDE33A1D3B5B4340AFC79C14A84722C0B08E05EF5A5B4340', 2, 'Disliked', 0, 1, 0, 0, 1, '2018-11-02 11:24:27.408703', 28828.59);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (5, '0106000020E6100000010000000103000000010000000600000042D74C3C3C4522C0554350D5C95A43404343A86C1B4322C0D18E8CBDB65A4340A517E1A79A4322C0CB228AD38A5A43407055BA7E784422C08FC6F8EA8F5A4340D5CB4FADEA4422C094E1A631AD5A434042D74C3C3C4522C0554350D5C95A4340', 2, 'Disliked', 0, 1, 0, 0, 1, '2018-11-02 11:24:27.408703', 43938.06);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (38, '0106000020E61000000100000001030000000100000006000000018046971C4622C05F658852985C434011E4A084994622C0AB09A2EE035C4340F7B63D5C0B4422C08E97375B155C43406ABC7493184422C00EDB1665365C4340018046D7B14322C0D939FA92845C4340018046971C4622C05F658852985C4340', 1, 'Liked', 1, 1, 0, 0, 1, '2018-11-02 11:24:27.408703', 181001.30);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (50, '0106000020E61000000100000001030000000100000005000000B9AAECBB224822C078D15790665C43400DC347C4944822C08E1EBFB7E95B4340F6622827DA4522C01D3D7E6FD35B4340A1B1AED9334522C0E1B8F9CD325C4340B9AAECBB224822C078D15790665C4340', 1, 'Liked', 0, 1, 0, 0, 0, '2018-11-02 11:24:27.408703', 191040.59);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (51, '0106000020E610000001000000010300000001000000050000009EE321F5254A22C0D6C09A522B5C434065ADCEC0DA4722C0684C8F92D85A434070A8EC246C4522C052EA03CFC45B434011E4A084994622C0AB09A2EE035C43409EE321F5254A22C0D6C09A522B5C4340', 1, 'Liked', 1, 1, 1, 0, 1, '2018-11-02 11:24:27.408703', 444061.78);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (24, '0106000020E61000000100000001030000000100000005000000018007009C4222C0E07BA9F13B5B434001800780C34022C092148915545B434001800700804022C06F3F8AFF255B4340018007801D4122C0AA18E777095B4340018007009C4222C0E07BA9F13B5B4340', 1, 'Liked', 0, 1, 0, 1, 1, '2018-11-02 11:24:27.408703', 47509.39);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (25, '0106000020E610000001000000010300000001000000070000000080035DAA4422C0AEC2FDCE5D5C43400180039D3F4222C024A7D1AB455C4340018003DD964122C04FF0F708065C43400080031D294222C05EEA1849F25B4340008003DD0C4422C0B6597D6C0A5C43400180031D264522C0B6597D6C0A5C43400080035DAA4422C0AEC2FDCE5D5C4340', 1, 'Liked', 1, 0, 1, 0, 1, '2018-11-02 11:24:27.408703', 139002.89);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (6, '0106000020E61000000100000001030000000100000006000000E5DA71B7C34622C05E6ED04B3E5B434002DE61BF474622C0CBEE4A342B5B434081B58A024B4622C0DA737279025B434066034974C04622C0912AAF90005B43405095C0CC1B4722C0FAEE9162195B4340E5DA71B7C34622C05E6ED04B3E5B4340', 1, 'Liked', 1, 1, 1, 0, 1, '2018-11-02 11:24:27.408703', 20148.79);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (85, '0106000020E610000001000000010300000001000000040000004772F90FE94F22C0228D0A9C6C5D434053B29C84D24F22C0A9F57EA31D5D4340D72FD80DDB4E22C046239F573C5D43404772F90FE94F22C0228D0A9C6C5D4340', 1, 'Liked', 0, 0, 0, 0, 1, NULL, NULL);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (47, '0106000020E6100000010000000103000000010000000500000000805597BB4C22C046D80D12AC5C43401EB26384F54B22C0A645BBCABC5B4340E78DA517A84922C060DA8CB8AF5B43406DCC9624344922C047BE7B66FC5B434000805597BB4C22C046D80D12AC5C4340', 1, 'Liked', 0, 1, 0, 1, 0, '2018-11-02 11:24:27.408703', 256359.01);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (20, '0106000020E610000001000000010300000001000000050000000080039D334E22C069989DE59E5B43400080035D994622C0DA0735D7035C43400080031D234822C0F57BF295665C43400180031D0F4D22C0698092C1245C43400080039D334E22C069989DE59E5B4340', 1, 'Liked', 1, 0, 0, 0, 1, '2018-11-02 11:24:27.408703', 428571.87);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (78, '0106000020E610000001000000010300000001000000050000000180031D175422C06691C800245B4340ED507392FB5022C07EABB4A06F5B43409B0D67C3385022C0E3252A45E45A4340018003DDEF5122C0D72FD80DDB5A43400180031D175422C06691C800245B4340', 2, 'Disliked', 0, 0, 0, 0, 1, '2018-11-02 11:24:27.408703', 182890.67);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (80, '0106000020E61000000100000001030000000100000006000000F48DF3DA2B5022C0118410631D5B4340018003DD685122C0D260B842675A43400080039D144F22C092F16ACE295A43400180031DC34D22C0913B043C725A43400AD45E2A894D22C0EE9FF785C45A4340F48DF3DA2B5022C0118410631D5B4340', 2, 'Disliked', 1, 1, 0, 1, 0, '2018-11-02 11:24:27.408703', 327309.03);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (82, '0106000020E610000001000000010300000001000000040000000080031D854F22C004D6912E885A43400080035DA14D22C087DD9E88485A43403FACD2C61A4E22C0EEB003A2A65A43400080031D854F22C004D6912E885A4340', 2, 'Disliked', 1, 1, 0, 0, 1, '2018-11-02 11:24:27.408703', 42482.46);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (2, '0106000020E61000000100000001030000000100000008000000F3B2AD44564522C025A47EECE85A4340305BEA47514422C0E3F0E0ECF65A4340305BEA47514422C0E3F0E0ECF65A4340432716FC024422C046A1B603E75A4340D379BC79BE4322C01709DD19C25A4340B91829652D4422C0C50B6619B45A4340830554C2114522C0948089D3B25A4340F3B2AD44564522C025A47EECE85A4340', 2, 'Disliked', 0, 0, 1, 0, 0, '2018-11-02 11:24:27.408703', 45073.91);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (86, '0106000020E610000001000000010300000001000000040000004772F90FE94F22C0228D0A9C6C5D4340E36F7B82C44E22C0E8305F5E805D4340D72FD80DDB4E22C046239F573C5D43404772F90FE94F22C0228D0A9C6C5D4340', 2, 'Disliked', 1, 0, 0, 0, 0, NULL, NULL);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (44, '0106000020E61000000100000001030000000100000007000000D399D9974C4B22C054ECD8423C5C43409A081B9E5E4922C05CACA8C1345C43409A7860A7C34822C0EA2987285E5C434001805C51944922C0836C384F9D5C434001805C114B4B22C076FC9656925C4340939A8BD4A24C22C0B6F07DB3485C4340D399D9974C4B22C054ECD8423C5C4340', 2, 'Disliked', 1, 1, 1, 0, 0, '2018-11-02 11:24:27.408703', 153853.54);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (57, '0106000020E61000000100000001030000000100000005000000B8979453C34222C07C4398FB4E5B43402604928C443F22C04B4D1841DC5A434001805C918C3E22C0B3DA91BE3B5B434089C5C2DD944022C05BA9387F775B4340B8979453C34222C07C4398FB4E5B4340', 1, 'Liked', 1, 0, 0, 1, 0, '2018-11-02 11:24:27.408703', 180962.07);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (58, '0106000020E61000000100000001030000000100000005000000DAACFA5C6D4522C016F6B4C35F5B4340BC91DE084F4522C056BBAB0CCC5A4340CDF32157CC4222C0D46436CEA15A4340A97DAE27334122C058939E97F55A4340DAACFA5C6D4522C016F6B4C35F5B4340', 1, 'Liked', 0, 1, 1, 0, 0, '2018-11-02 11:24:27.408703', 256030.35);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (71, '0106000020E6100000010000000103000000010000000700000001809B28FE5022C01437ACA6335C434000809B28555422C061B89535A75B434001809B28DC5422C0FB97F9251F5B434001809BA85D5322C00F4B691DDB5A434000809B68DC5022C00F4B691DDB5A434001809B28585122C0CD736ECA5E5B434001809B28FE5022C01437ACA6335C4340', 1, 'Liked', 0, 1, 0, 0, 1, '2018-11-02 11:24:27.408703', 509427.95);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (72, '0106000020E610000001000000010300000001000000060000000180031D825222C02B76AA2B315B43400080039D225022C011F6ACE1B15A43400080031D4A4E22C01E8B6CC6DD5A4340018003DD984E22C0850933AC585B4340C272C665385122C0A08462E7AA5B43400180031D825222C02B76AA2B315B4340', 1, 'Liked', 0, 1, 1, 0, 0, '2018-11-02 11:24:27.408703', 361744.82);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (48, '0106000020E61000000100000001030000000100000006000000DE2CACAAB54722C0F3EE91A9215B43409FE57970774622C034BA83D8995A4340172993B2034322C054448734695A43401386C5C18E4222C07433158FDF5A43406B65C22FF54322C009E1D1C6115B4340DE2CACAAB54722C0F3EE91A9215B4340', 2, 'Disliked', 1, 0, 0, 0, 0, '2018-11-02 11:24:27.408703', 349486.78);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (49, '0106000020E6100000010000000103000000010000000500000036A6D8076D4522C0CADEB5E65F5B4340C062F032D74522C0A346964BBB5A43400180031DA24122C01ECDE905CA5A43403A5F1C401C4222C0A87166242B5B434036A6D8076D4522C0CADEB5E65F5B4340', 2, 'Disliked', 1, 0, 1, 1, 1, '2018-11-02 11:24:27.408703', 282941.23);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (56, '0106000020E61000000100000001030000000100000006000000E4EC3050E94122C0FD390C99A25A434001805C51E93F22C036B31D2C8C5A434001805CD1A53F22C0B0B1B14BFE5A4340C68A1A4CC34022C017D9CEF7535B434018096D39974222C01630815B775B4340E4EC3050E94122C0FD390C99A25A4340', 2, 'Disliked', 1, 1, 1, 0, 1, '2018-11-02 11:24:27.408703', 257595.19);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (73, '0106000020E6100000010000000103000000010000000500000000804D91FF5222C0FCADF7AFA25B434001804DD10D5022C0F71B0CB7E65B4340F3F07CF7144C22C09ECD83F7E05B434067ACE979A54D22C0675887451B5B434000804D91FF5222C0FCADF7AFA25B4340', 1, 'Liked', 0, 1, 1, 0, 0, '2018-11-02 11:24:27.408703', 448005.88);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (74, '0106000020E610000001000000010300000001000000050000000080039DD35322C0F88601D7655B43400080035D445022C06B78C96CBB5B434002BC0512144F22C057B26323105B43400080031D665022C0E14E68F1EA5A43400080039DD35322C0F88601D7655B4340', 1, 'Liked', 1, 0, 1, 1, 0, '2018-11-02 11:24:27.408703', 288093.76);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (76, '0106000020E6100000010000000103000000010000000600000060EE46B4605322C0269F86EA555B43400180039D305122C024E5B80CBF5A434002BC0512144F22C057B26323105B4340796B5554535022C0026BB0C88E5B434057471681745222C08DA87CD5945B434060EE46B4605322C0269F86EA555B4340', 1, 'Liked', 1, 1, 0, 1, 0, '2018-11-02 11:24:27.408703', 314507.54);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (77, '0106000020E610000001000000010300000001000000060000007A7AD1BE495122C03DFF2D0C825B4340F4DB1CB34F4E22C00D27C98D815B4340E429E4B1E44E22C07FB007D7E15A43409339B16F375122C0665916E6EB5A43405BC87894EA5222C0D999A118365B43407A7AD1BE495122C03DFF2D0C825B4340', 1, 'Liked', 0, 1, 0, 0, 1, '2018-11-02 11:24:27.408703', 308963.75);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (21, '0106000020E610000001000000010300000001000000070000000180129DD84E22C08A07FF3BEC5B43400180125DC24A22C0946FC4B4805B4340FD2FDA9E684922C088C36AF32D5B43400180129D464A22C02EDB3406AE5A4340018012DDF44C22C050C37855D35A43400180125D194E22C0AC6BCFC26A5B43400180129DD84E22C08A07FF3BEC5B4340', 2, 'Disliked', 0, 1, 0, 1, 0, '2018-11-02 11:24:27.408703', 509570.95);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (22, '0106000020E610000001000000010300000001000000060000000080039D284A22C09036C1ACA75B43400080039DC04822C0A1E5AC65C65B43400180031DC94722C095774150985B43400CB4E994794822C0309AFB2E685B43400080031D124A22C0A0D3C4FA7D5B43400080039D284A22C09036C1ACA75B4340', 2, 'Disliked', 0, 0, 1, 1, 1, '2018-11-02 11:24:27.408703', 81697.77);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (75, '0106000020E61000000100000001030000000100000004000000008015B4AB5222C0A7A9360DF55A4340B6B755B9F04F22C0297987C3F75A4340018015B4625022C07A4403AB3F5B4340008015B4AB5222C0A7A9360DF55A4340', 2, 'Disliked', 1, 0, 1, 0, 0, '2018-11-02 11:24:27.408703', 56840.92);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (63, '0106000020E610000001000000010300000001000000060000000080035D424322C01BF27E1C835C43400180031D674022C0E7D248D6525C43408F368E588B3F22C0E4310395F15B4340371AC05B204122C0F20703CFBD5B4340DEAB5626FC4222C0DDB5847CD05B43400080035D424322C01BF27E1C835C4340', 2, 'Disliked', 0, 0, 1, 0, 0, '2018-11-02 11:24:27.408703', 283633.53);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (64, '0106000020E61000000100000001030000000100000005000000363CBD52964122C0800EF3E5055C43400180031D4B3E22C0823DB9ECE25B4340157CFC45D23D22C022F484A9815B43400180039DE83E22C021E76773615B4340363CBD52964122C0800EF3E5055C4340', 2, 'Disliked', 1, 1, 0, 1, 1, '2018-11-02 11:24:27.408703', 163697.26);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (67, '0106000020E610000001000000010300000001000000040000000080039D604E22C0DAA18AA4505C43400180039D414F22C0FC821A42AE5B4340FD9A8B728E4D22C0B1EC7C96A75B43400080039D604E22C0DAA18AA4505C4340', 2, 'Disliked', 0, 1, 0, 1, 0, '2018-11-02 11:24:27.408703', 81110.16);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (59, '0106000020E61000000100000001030000000100000005000000016611AE6D4322C070763921D55B434021D9BFEF7B4422C0236DC1C4505B4340184339D1AE4222C082734694F65A4340FEB7921D1B4122C057091687335B4340016611AE6D4322C070763921D55B4340', 1, 'Liked', 0, 1, 1, 1, 1, '2018-11-02 11:24:27.408703', 210060.73);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (60, '0106000020E61000000100000001030000000100000005000000EA5BE674594C22C049F4328AE55A4340B1B61952B34C22C04531A4BB885A434060CDDA4B414A22C05E74AB694C5A4340B0A9CDE2BC4822C03710BB4D795A4340EA5BE674594C22C049F4328AE55A4340', 1, 'Liked', 0, 1, 1, 1, 1, '2018-11-02 11:24:27.408703', 165316.80);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (61, '0106000020E610000001000000010300000001000000050000000180035D884822C04AB6910BE85C434051EDAA62274A22C0423E6ECF6E5C4340B9AAECBB224822C08065A549295C434093E3735AA74522C07CAB9CEA5E5C43400180035D884822C04AB6910BE85C4340', 1, 'Liked', 0, 1, 1, 1, 1, '2018-11-02 11:24:27.408703', 245164.75);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (62, '0106000020E6100000010000000103000000010000000500000001809BE88B3F22C0977BDA8DF15B4340FEB7921D1B4122C057091687335B434018096D39974222C01630815B775B434001809B28B34122C00DC32A9CDB5B434001809BE88B3F22C0977BDA8DF15B4340', 1, 'Liked', 1, 1, 0, 0, 1, '2018-11-02 11:24:27.408703', 168107.28);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (68, '0106000020E610000001000000010300000001000000050000000080035D904F22C042B6BA3A085C434045FE452D594C22C060DFC1E2345C43400A219FA7DD4B22C0506B66FD9D5B4340E7A90EB9194E22C0CF66D5E76A5B43400080035D904F22C042B6BA3A085C4340', 1, 'Liked', 0, 0, 0, 1, 1, '2018-11-02 11:24:27.408703', 268474.19);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (69, '0106000020E61000000100000001030000000100000006000000B8C125A07B4D22C05394008C675B43400080039D144F22C0D9A16C40105B43400180035DAF4E22C0183DFD7DAD5A434016123F81384D22C0A135F40A9C5A4340EA5BE674594C22C049F4328AE55A4340B8C125A07B4D22C05394008C675B4340', 2, 'Disliked', 1, 0, 1, 0, 0, '2018-11-02 11:24:27.408703', 196335.58);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (70, '0106000020E6100000010000000103000000010000000500000029F1EC648E4E22C05107C7D1B95B43400180039DF54F22C0FA03FCE44F5B43400080031D4A4E22C0C691324EFA5A434048BE3886774C22C08D61E60A585B434029F1EC648E4E22C05107C7D1B95B4340', 1, 'Liked', 0, 0, 1, 1, 0, '2018-11-02 11:24:27.408703', 193087.97);
INSERT INTO public.eimglx_sample (id, geom, eval_nr, eval_str, att_nat, att_open, att_order, att_upkeep, att_hist, "timestamp", area_sqm) VALUES (45, '0106000020E610000001000000010300000001000000050000000080031DB54C22C0250F25158E5C434086A86791AC4A22C09F3BBB9E445C4340CC8E31E4154A22C063ECC614065C43400180031DC34D22C0055A0A97175C43400080031DB54C22C0250F25158E5C4340', 2, 'Disliked', 0, 0, 1, 0, 1, '2018-11-02 11:24:27.408703', 154803.84);


--
-- TOC entry 3685 (class 0 OID 24884)
-- Dependencies: 204
-- Data for Name: layer_styles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.layer_styles (id, f_table_catalog, f_table_schema, f_table_name, f_geometry_column, stylename, styleqml, stylesld, useasdefault, description, owner, ui, update_time) VALUES (3, 'eimg_lx', 'public', 'eimglx_areas_demo', 'geom', 'liked-disliked', '<!DOCTYPE qgis PUBLIC ''http://mrcc.com/qgis.dtd'' ''SYSTEM''>
<qgis version="2.18.24" simplifyAlgorithm="0" minimumScale="0" maximumScale="1e+08" simplifyDrawingHints="1" minLabelScale="0" maxLabelScale="1e+08" simplifyDrawingTol="1" readOnly="0" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" simplifyLocal="1" scaleBasedLabelVisibilityFlag="0">
 <edittypes>
  <edittype widgetv2type="TextEdit" name="id">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="eval_nr">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="eval_str">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_nat">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_open">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_order">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_upkeep">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_hist">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="centroid">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
 </edittypes>
 <renderer-v2 attr="eval_nr" forceraster="0" symbollevels="0" type="categorizedSymbol" enableorderby="0">
  <categories>
   <category render="true" symbol="0" value="2" label="Disliked"/>
   <category render="true" symbol="1" value="1" label="Liked"/>
  </categories>
  <symbols>
   <symbol alpha="0.639216" clip_to_extent="1" type="fill" name="0">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="222,97,111,255"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="0,0,0,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
   <symbol alpha="0.639216" clip_to_extent="1" type="fill" name="1">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="63,213,43,255"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="0,0,0,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
  </symbols>
  <source-symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="0">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="192,202,116,255"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="0,0,0,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
  </source-symbol>
  <rotation/>
  <sizescale scalemethod="diameter"/>
 </renderer-v2>
 <labeling type="simple"/>
 <customproperties>
  <property key="embeddedWidgets/count" value="0"/>
  <property key="labeling" value="pal"/>
  <property key="labeling/addDirectionSymbol" value="false"/>
  <property key="labeling/angleOffset" value="0"/>
  <property key="labeling/blendMode" value="0"/>
  <property key="labeling/bufferBlendMode" value="0"/>
  <property key="labeling/bufferColorA" value="255"/>
  <property key="labeling/bufferColorB" value="255"/>
  <property key="labeling/bufferColorG" value="255"/>
  <property key="labeling/bufferColorR" value="255"/>
  <property key="labeling/bufferDraw" value="false"/>
  <property key="labeling/bufferJoinStyle" value="128"/>
  <property key="labeling/bufferNoFill" value="false"/>
  <property key="labeling/bufferSize" value="1"/>
  <property key="labeling/bufferSizeInMapUnits" value="false"/>
  <property key="labeling/bufferSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/bufferTransp" value="0"/>
  <property key="labeling/centroidInside" value="false"/>
  <property key="labeling/centroidWhole" value="false"/>
  <property key="labeling/decimals" value="3"/>
  <property key="labeling/displayAll" value="false"/>
  <property key="labeling/dist" value="0"/>
  <property key="labeling/distInMapUnits" value="false"/>
  <property key="labeling/distMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/drawLabels" value="false"/>
  <property key="labeling/enabled" value="false"/>
  <property key="labeling/fieldName" value=""/>
  <property key="labeling/fitInPolygonOnly" value="false"/>
  <property key="labeling/fontCapitals" value="0"/>
  <property key="labeling/fontFamily" value="MS Shell Dlg 2"/>
  <property key="labeling/fontItalic" value="false"/>
  <property key="labeling/fontLetterSpacing" value="0"/>
  <property key="labeling/fontLimitPixelSize" value="false"/>
  <property key="labeling/fontMaxPixelSize" value="10000"/>
  <property key="labeling/fontMinPixelSize" value="3"/>
  <property key="labeling/fontSize" value="8.25"/>
  <property key="labeling/fontSizeInMapUnits" value="false"/>
  <property key="labeling/fontSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/fontStrikeout" value="false"/>
  <property key="labeling/fontUnderline" value="false"/>
  <property key="labeling/fontWeight" value="50"/>
  <property key="labeling/fontWordSpacing" value="0"/>
  <property key="labeling/formatNumbers" value="false"/>
  <property key="labeling/isExpression" value="true"/>
  <property key="labeling/labelOffsetInMapUnits" value="true"/>
  <property key="labeling/labelOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/labelPerPart" value="false"/>
  <property key="labeling/leftDirectionSymbol" value="&lt;"/>
  <property key="labeling/limitNumLabels" value="false"/>
  <property key="labeling/maxCurvedCharAngleIn" value="25"/>
  <property key="labeling/maxCurvedCharAngleOut" value="-25"/>
  <property key="labeling/maxNumLabels" value="2000"/>
  <property key="labeling/mergeLines" value="false"/>
  <property key="labeling/minFeatureSize" value="0"/>
  <property key="labeling/multilineAlign" value="4294967295"/>
  <property key="labeling/multilineHeight" value="1"/>
  <property key="labeling/namedStyle" value="Normal"/>
  <property key="labeling/obstacle" value="true"/>
  <property key="labeling/obstacleFactor" value="1"/>
  <property key="labeling/obstacleType" value="0"/>
  <property key="labeling/offsetType" value="0"/>
  <property key="labeling/placeDirectionSymbol" value="0"/>
  <property key="labeling/placement" value="1"/>
  <property key="labeling/placementFlags" value="10"/>
  <property key="labeling/plussign" value="false"/>
  <property key="labeling/predefinedPositionOrder" value="TR,TL,BR,BL,R,L,TSR,BSR"/>
  <property key="labeling/preserveRotation" value="true"/>
  <property key="labeling/previewBkgrdColor" value="#ffffff"/>
  <property key="labeling/priority" value="5"/>
  <property key="labeling/quadOffset" value="4"/>
  <property key="labeling/repeatDistance" value="0"/>
  <property key="labeling/repeatDistanceMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/repeatDistanceUnit" value="1"/>
  <property key="labeling/reverseDirectionSymbol" value="false"/>
  <property key="labeling/rightDirectionSymbol" value=">"/>
  <property key="labeling/scaleMax" value="10000000"/>
  <property key="labeling/scaleMin" value="1"/>
  <property key="labeling/scaleVisibility" value="false"/>
  <property key="labeling/shadowBlendMode" value="6"/>
  <property key="labeling/shadowColorB" value="0"/>
  <property key="labeling/shadowColorG" value="0"/>
  <property key="labeling/shadowColorR" value="0"/>
  <property key="labeling/shadowDraw" value="false"/>
  <property key="labeling/shadowOffsetAngle" value="135"/>
  <property key="labeling/shadowOffsetDist" value="1"/>
  <property key="labeling/shadowOffsetGlobal" value="true"/>
  <property key="labeling/shadowOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shadowOffsetUnits" value="1"/>
  <property key="labeling/shadowRadius" value="1.5"/>
  <property key="labeling/shadowRadiusAlphaOnly" value="false"/>
  <property key="labeling/shadowRadiusMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shadowRadiusUnits" value="1"/>
  <property key="labeling/shadowScale" value="100"/>
  <property key="labeling/shadowTransparency" value="30"/>
  <property key="labeling/shadowUnder" value="0"/>
  <property key="labeling/shapeBlendMode" value="0"/>
  <property key="labeling/shapeBorderColorA" value="255"/>
  <property key="labeling/shapeBorderColorB" value="128"/>
  <property key="labeling/shapeBorderColorG" value="128"/>
  <property key="labeling/shapeBorderColorR" value="128"/>
  <property key="labeling/shapeBorderWidth" value="0"/>
  <property key="labeling/shapeBorderWidthMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeBorderWidthUnits" value="1"/>
  <property key="labeling/shapeDraw" value="false"/>
  <property key="labeling/shapeFillColorA" value="255"/>
  <property key="labeling/shapeFillColorB" value="255"/>
  <property key="labeling/shapeFillColorG" value="255"/>
  <property key="labeling/shapeFillColorR" value="255"/>
  <property key="labeling/shapeJoinStyle" value="64"/>
  <property key="labeling/shapeOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeOffsetUnits" value="1"/>
  <property key="labeling/shapeOffsetX" value="0"/>
  <property key="labeling/shapeOffsetY" value="0"/>
  <property key="labeling/shapeRadiiMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeRadiiUnits" value="1"/>
  <property key="labeling/shapeRadiiX" value="0"/>
  <property key="labeling/shapeRadiiY" value="0"/>
  <property key="labeling/shapeRotation" value="0"/>
  <property key="labeling/shapeRotationType" value="0"/>
  <property key="labeling/shapeSVGFile" value=""/>
  <property key="labeling/shapeSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeSizeType" value="0"/>
  <property key="labeling/shapeSizeUnits" value="1"/>
  <property key="labeling/shapeSizeX" value="0"/>
  <property key="labeling/shapeSizeY" value="0"/>
  <property key="labeling/shapeTransparency" value="0"/>
  <property key="labeling/shapeType" value="0"/>
  <property key="labeling/substitutions" value="&lt;substitutions/>"/>
  <property key="labeling/textColorA" value="255"/>
  <property key="labeling/textColorB" value="0"/>
  <property key="labeling/textColorG" value="0"/>
  <property key="labeling/textColorR" value="0"/>
  <property key="labeling/textTransp" value="0"/>
  <property key="labeling/upsidedownLabels" value="0"/>
  <property key="labeling/useSubstitutions" value="false"/>
  <property key="labeling/wrapChar" value=""/>
  <property key="labeling/xOffset" value="0"/>
  <property key="labeling/yOffset" value="0"/>
  <property key="labeling/zIndex" value="0"/>
  <property key="variableNames"/>
  <property key="variableValues"/>
 </customproperties>
 <blendMode>0</blendMode>
 <featureBlendMode>0</featureBlendMode>
 <layerTransparency>0</layerTransparency>
 <displayfield>id</displayfield>
 <label>0</label>
 <labelattributes>
  <label fieldname="" text="Label"/>
  <family fieldname="" name="MS Shell Dlg 2"/>
  <size fieldname="" units="pt" value="12"/>
  <bold fieldname="" on="0"/>
  <italic fieldname="" on="0"/>
  <underline fieldname="" on="0"/>
  <strikeout fieldname="" on="0"/>
  <color fieldname="" red="0" blue="0" green="0"/>
  <x fieldname=""/>
  <y fieldname=""/>
  <offset x="0" y="0" units="pt" yfieldname="" xfieldname=""/>
  <angle fieldname="" value="0" auto="0"/>
  <alignment fieldname="" value="center"/>
  <buffercolor fieldname="" red="255" blue="255" green="255"/>
  <buffersize fieldname="" units="pt" value="1"/>
  <bufferenabled fieldname="" on=""/>
  <multilineenabled fieldname="" on=""/>
  <selectedonly on=""/>
 </labelattributes>
 <SingleCategoryDiagramRenderer diagramType="Histogram" sizeLegend="0" attributeLegend="1">
  <DiagramCategory penColor="#000000" labelPlacementMethod="XHeight" penWidth="0" diagramOrientation="Up" sizeScale="0,0,0,0,0,0" minimumSize="0" barWidth="5" penAlpha="255" maxScaleDenominator="1e+08" backgroundColor="#ffffff" transparency="0" width="15" scaleDependency="Area" backgroundAlpha="255" angleOffset="1440" scaleBasedVisibility="0" enabled="0" height="15" lineSizeScale="0,0,0,0,0,0" sizeType="MM" lineSizeType="MM" minScaleDenominator="inf">
   <fontProperties description="MS Shell Dlg 2,8.25,-1,5,50,0,0,0,0,0" style=""/>
  </DiagramCategory>
  <symbol alpha="1" clip_to_extent="1" type="marker" name="sizeSymbol">
   <layer pass="0" class="SimpleMarker" locked="0">
    <prop k="angle" v="0"/>
    <prop k="color" v="255,0,0,255"/>
    <prop k="horizontal_anchor_point" v="1"/>
    <prop k="joinstyle" v="bevel"/>
    <prop k="name" v="circle"/>
    <prop k="offset" v="0,0"/>
    <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="offset_unit" v="MM"/>
    <prop k="outline_color" v="0,0,0,255"/>
    <prop k="outline_style" v="solid"/>
    <prop k="outline_width" v="0"/>
    <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="outline_width_unit" v="MM"/>
    <prop k="scale_method" v="diameter"/>
    <prop k="size" v="2"/>
    <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="size_unit" v="MM"/>
    <prop k="vertical_anchor_point" v="1"/>
   </layer>
  </symbol>
 </SingleCategoryDiagramRenderer>
 <DiagramLayerSettings yPosColumn="-1" showColumn="-1" linePlacementFlags="10" placement="0" dist="0" xPosColumn="-1" priority="0" obstacle="0" zIndex="0" showAll="1"/>
 <annotationform>.</annotationform>
 <aliases>
  <alias field="id" index="0" name=""/>
  <alias field="eval_nr" index="1" name=""/>
  <alias field="eval_str" index="2" name=""/>
  <alias field="att_nat" index="3" name=""/>
  <alias field="att_open" index="4" name=""/>
  <alias field="att_order" index="5" name=""/>
  <alias field="att_upkeep" index="6" name=""/>
  <alias field="att_hist" index="7" name=""/>
  <alias field="centroid" index="8" name=""/>
 </aliases>
 <excludeAttributesWMS/>
 <excludeAttributesWFS/>
 <attributeactions default="-1"/>
 <attributetableconfig actionWidgetStyle="dropDown" sortExpression="&quot;timestamp_wo_tz&quot;" sortOrder="0">
  <columns>
   <column width="-1" hidden="0" type="field" name="id"/>
   <column width="-1" hidden="0" type="field" name="eval_nr"/>
   <column width="-1" hidden="0" type="field" name="eval_str"/>
   <column width="-1" hidden="0" type="field" name="att_nat"/>
   <column width="-1" hidden="0" type="field" name="att_open"/>
   <column width="-1" hidden="0" type="field" name="att_order"/>
   <column width="-1" hidden="0" type="field" name="att_upkeep"/>
   <column width="-1" hidden="0" type="field" name="att_hist"/>
   <column width="-1" hidden="1" type="actions"/>
   <column width="-1" hidden="0" type="field" name="centroid"/>
  </columns>
 </attributetableconfig>
 <editform>.</editform>
 <editforminit/>
 <editforminitcodesource>0</editforminitcodesource>
 <editforminitfilepath>.</editforminitfilepath>
 <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
 <featformsuppress>0</featformsuppress>
 <editorlayout>generatedlayout</editorlayout>
 <widgets/>
 <conditionalstyles>
  <rowstyles/>
  <fieldstyles/>
 </conditionalstyles>
 <defaults>
  <default field="id" expression=""/>
  <default field="eval_nr" expression=""/>
  <default field="eval_str" expression=""/>
  <default field="att_nat" expression=""/>
  <default field="att_open" expression=""/>
  <default field="att_order" expression=""/>
  <default field="att_upkeep" expression=""/>
  <default field="att_hist" expression=""/>
  <default field="centroid" expression=""/>
 </defaults>
 <previewExpression>COALESCE( "id", ''&lt;NULL>'' )</previewExpression>
 <layerGeometryType>2</layerGeometryType>
</qgis>
', '<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:se="http://www.opengis.net/se">
 <NamedLayer>
  <se:Name>eimglx_areas_demo.geom</se:Name>
  <UserStyle>
   <se:Name>eimglx_areas_demo.geom</se:Name>
   <se:FeatureTypeStyle>
    <se:Rule>
     <se:Name>Disliked</se:Name>
     <se:Description>
      <se:Title>Disliked</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>eval_nr</ogc:PropertyName>
       <ogc:Literal>2</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#de616f</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#000001</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
    <se:Rule>
     <se:Name>Liked</se:Name>
     <se:Description>
      <se:Title>Liked</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>eval_nr</ogc:PropertyName>
       <ogc:Literal>1</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#3fd52b</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#000001</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
   </se:FeatureTypeStyle>
  </UserStyle>
 </NamedLayer>
</StyledLayerDescriptor>
', true, 'Fri Nov 2 09:40:47 2018', 'postgres', NULL, '2018-11-02 09:40:47.756594');
INSERT INTO public.layer_styles (id, f_table_catalog, f_table_schema, f_table_name, f_geometry_column, stylename, styleqml, stylesld, useasdefault, description, owner, ui, update_time) VALUES (4, 'eimg_lx', 'public', 'smp_areas', 'geom', 'like-dislike(sample)', '<!DOCTYPE qgis PUBLIC ''http://mrcc.com/qgis.dtd'' ''SYSTEM''>
<qgis version="2.18.24" simplifyAlgorithm="0" minimumScale="0" maximumScale="1e+08" simplifyDrawingHints="1" minLabelScale="0" maxLabelScale="1e+08" simplifyDrawingTol="1" readOnly="0" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" simplifyLocal="1" scaleBasedLabelVisibilityFlag="0">
 <edittypes>
  <edittype widgetv2type="TextEdit" name="id">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="eval_nr">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="eval_str">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_nat">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_open">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_order">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_upkeep">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="att_hist">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
 </edittypes>
 <renderer-v2 attr="eval_nr" forceraster="0" symbollevels="0" type="categorizedSymbol" enableorderby="0">
  <categories>
   <category render="true" symbol="0" value="1" label="Liked (1)"/>
   <category render="true" symbol="1" value="2" label="Disiked (2)"/>
  </categories>
  <symbols>
   <symbol alpha="0.494118" clip_to_extent="1" type="fill" name="0">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="241,244,199,255"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="0,0,0,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
   <symbol alpha="0.490196" clip_to_extent="1" type="fill" name="1">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="226,48,212,255"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="0,0,0,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
  </symbols>
  <source-symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="0">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="136,115,167,255"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="0,0,0,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
  </source-symbol>
  <rotation/>
  <sizescale scalemethod="diameter"/>
 </renderer-v2>
 <labeling type="simple"/>
 <customproperties>
  <property key="embeddedWidgets/count" value="0"/>
  <property key="labeling" value="pal"/>
  <property key="labeling/addDirectionSymbol" value="false"/>
  <property key="labeling/angleOffset" value="0"/>
  <property key="labeling/blendMode" value="0"/>
  <property key="labeling/bufferBlendMode" value="0"/>
  <property key="labeling/bufferColorA" value="255"/>
  <property key="labeling/bufferColorB" value="255"/>
  <property key="labeling/bufferColorG" value="255"/>
  <property key="labeling/bufferColorR" value="255"/>
  <property key="labeling/bufferDraw" value="false"/>
  <property key="labeling/bufferJoinStyle" value="128"/>
  <property key="labeling/bufferNoFill" value="false"/>
  <property key="labeling/bufferSize" value="1"/>
  <property key="labeling/bufferSizeInMapUnits" value="false"/>
  <property key="labeling/bufferSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/bufferTransp" value="0"/>
  <property key="labeling/centroidInside" value="false"/>
  <property key="labeling/centroidWhole" value="false"/>
  <property key="labeling/decimals" value="3"/>
  <property key="labeling/displayAll" value="false"/>
  <property key="labeling/dist" value="0"/>
  <property key="labeling/distInMapUnits" value="false"/>
  <property key="labeling/distMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/drawLabels" value="false"/>
  <property key="labeling/enabled" value="false"/>
  <property key="labeling/fieldName" value=""/>
  <property key="labeling/fitInPolygonOnly" value="false"/>
  <property key="labeling/fontCapitals" value="0"/>
  <property key="labeling/fontFamily" value="MS Shell Dlg 2"/>
  <property key="labeling/fontItalic" value="false"/>
  <property key="labeling/fontLetterSpacing" value="0"/>
  <property key="labeling/fontLimitPixelSize" value="false"/>
  <property key="labeling/fontMaxPixelSize" value="10000"/>
  <property key="labeling/fontMinPixelSize" value="3"/>
  <property key="labeling/fontSize" value="8.25"/>
  <property key="labeling/fontSizeInMapUnits" value="false"/>
  <property key="labeling/fontSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/fontStrikeout" value="false"/>
  <property key="labeling/fontUnderline" value="false"/>
  <property key="labeling/fontWeight" value="50"/>
  <property key="labeling/fontWordSpacing" value="0"/>
  <property key="labeling/formatNumbers" value="false"/>
  <property key="labeling/isExpression" value="true"/>
  <property key="labeling/labelOffsetInMapUnits" value="true"/>
  <property key="labeling/labelOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/labelPerPart" value="false"/>
  <property key="labeling/leftDirectionSymbol" value="&lt;"/>
  <property key="labeling/limitNumLabels" value="false"/>
  <property key="labeling/maxCurvedCharAngleIn" value="25"/>
  <property key="labeling/maxCurvedCharAngleOut" value="-25"/>
  <property key="labeling/maxNumLabels" value="2000"/>
  <property key="labeling/mergeLines" value="false"/>
  <property key="labeling/minFeatureSize" value="0"/>
  <property key="labeling/multilineAlign" value="4294967295"/>
  <property key="labeling/multilineHeight" value="1"/>
  <property key="labeling/namedStyle" value="Normal"/>
  <property key="labeling/obstacle" value="true"/>
  <property key="labeling/obstacleFactor" value="1"/>
  <property key="labeling/obstacleType" value="0"/>
  <property key="labeling/offsetType" value="0"/>
  <property key="labeling/placeDirectionSymbol" value="0"/>
  <property key="labeling/placement" value="1"/>
  <property key="labeling/placementFlags" value="10"/>
  <property key="labeling/plussign" value="false"/>
  <property key="labeling/predefinedPositionOrder" value="TR,TL,BR,BL,R,L,TSR,BSR"/>
  <property key="labeling/preserveRotation" value="true"/>
  <property key="labeling/previewBkgrdColor" value="#ffffff"/>
  <property key="labeling/priority" value="5"/>
  <property key="labeling/quadOffset" value="4"/>
  <property key="labeling/repeatDistance" value="0"/>
  <property key="labeling/repeatDistanceMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/repeatDistanceUnit" value="1"/>
  <property key="labeling/reverseDirectionSymbol" value="false"/>
  <property key="labeling/rightDirectionSymbol" value=">"/>
  <property key="labeling/scaleMax" value="10000000"/>
  <property key="labeling/scaleMin" value="1"/>
  <property key="labeling/scaleVisibility" value="false"/>
  <property key="labeling/shadowBlendMode" value="6"/>
  <property key="labeling/shadowColorB" value="0"/>
  <property key="labeling/shadowColorG" value="0"/>
  <property key="labeling/shadowColorR" value="0"/>
  <property key="labeling/shadowDraw" value="false"/>
  <property key="labeling/shadowOffsetAngle" value="135"/>
  <property key="labeling/shadowOffsetDist" value="1"/>
  <property key="labeling/shadowOffsetGlobal" value="true"/>
  <property key="labeling/shadowOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shadowOffsetUnits" value="1"/>
  <property key="labeling/shadowRadius" value="1.5"/>
  <property key="labeling/shadowRadiusAlphaOnly" value="false"/>
  <property key="labeling/shadowRadiusMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shadowRadiusUnits" value="1"/>
  <property key="labeling/shadowScale" value="100"/>
  <property key="labeling/shadowTransparency" value="30"/>
  <property key="labeling/shadowUnder" value="0"/>
  <property key="labeling/shapeBlendMode" value="0"/>
  <property key="labeling/shapeBorderColorA" value="255"/>
  <property key="labeling/shapeBorderColorB" value="128"/>
  <property key="labeling/shapeBorderColorG" value="128"/>
  <property key="labeling/shapeBorderColorR" value="128"/>
  <property key="labeling/shapeBorderWidth" value="0"/>
  <property key="labeling/shapeBorderWidthMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeBorderWidthUnits" value="1"/>
  <property key="labeling/shapeDraw" value="false"/>
  <property key="labeling/shapeFillColorA" value="255"/>
  <property key="labeling/shapeFillColorB" value="255"/>
  <property key="labeling/shapeFillColorG" value="255"/>
  <property key="labeling/shapeFillColorR" value="255"/>
  <property key="labeling/shapeJoinStyle" value="64"/>
  <property key="labeling/shapeOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeOffsetUnits" value="1"/>
  <property key="labeling/shapeOffsetX" value="0"/>
  <property key="labeling/shapeOffsetY" value="0"/>
  <property key="labeling/shapeRadiiMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeRadiiUnits" value="1"/>
  <property key="labeling/shapeRadiiX" value="0"/>
  <property key="labeling/shapeRadiiY" value="0"/>
  <property key="labeling/shapeRotation" value="0"/>
  <property key="labeling/shapeRotationType" value="0"/>
  <property key="labeling/shapeSVGFile" value=""/>
  <property key="labeling/shapeSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeSizeType" value="0"/>
  <property key="labeling/shapeSizeUnits" value="1"/>
  <property key="labeling/shapeSizeX" value="0"/>
  <property key="labeling/shapeSizeY" value="0"/>
  <property key="labeling/shapeTransparency" value="0"/>
  <property key="labeling/shapeType" value="0"/>
  <property key="labeling/substitutions" value="&lt;substitutions/>"/>
  <property key="labeling/textColorA" value="255"/>
  <property key="labeling/textColorB" value="0"/>
  <property key="labeling/textColorG" value="0"/>
  <property key="labeling/textColorR" value="0"/>
  <property key="labeling/textTransp" value="0"/>
  <property key="labeling/upsidedownLabels" value="0"/>
  <property key="labeling/useSubstitutions" value="false"/>
  <property key="labeling/wrapChar" value=""/>
  <property key="labeling/xOffset" value="0"/>
  <property key="labeling/yOffset" value="0"/>
  <property key="labeling/zIndex" value="0"/>
  <property key="variableNames"/>
  <property key="variableValues"/>
 </customproperties>
 <blendMode>0</blendMode>
 <featureBlendMode>0</featureBlendMode>
 <layerTransparency>0</layerTransparency>
 <displayfield>id</displayfield>
 <label>0</label>
 <labelattributes>
  <label fieldname="" text="Label"/>
  <family fieldname="" name="MS Shell Dlg 2"/>
  <size fieldname="" units="pt" value="12"/>
  <bold fieldname="" on="0"/>
  <italic fieldname="" on="0"/>
  <underline fieldname="" on="0"/>
  <strikeout fieldname="" on="0"/>
  <color fieldname="" red="0" blue="0" green="0"/>
  <x fieldname=""/>
  <y fieldname=""/>
  <offset x="0" y="0" units="pt" yfieldname="" xfieldname=""/>
  <angle fieldname="" value="0" auto="0"/>
  <alignment fieldname="" value="center"/>
  <buffercolor fieldname="" red="255" blue="255" green="255"/>
  <buffersize fieldname="" units="pt" value="1"/>
  <bufferenabled fieldname="" on=""/>
  <multilineenabled fieldname="" on=""/>
  <selectedonly on=""/>
 </labelattributes>
 <SingleCategoryDiagramRenderer diagramType="Histogram" sizeLegend="0" attributeLegend="1">
  <DiagramCategory penColor="#000000" labelPlacementMethod="XHeight" penWidth="0" diagramOrientation="Up" sizeScale="0,0,0,0,0,0" minimumSize="0" barWidth="5" penAlpha="255" maxScaleDenominator="1e+08" backgroundColor="#ffffff" transparency="0" width="15" scaleDependency="Area" backgroundAlpha="255" angleOffset="1440" scaleBasedVisibility="0" enabled="0" height="15" lineSizeScale="0,0,0,0,0,0" sizeType="MM" lineSizeType="MM" minScaleDenominator="inf">
   <fontProperties description="MS Shell Dlg 2,8.25,-1,5,50,0,0,0,0,0" style=""/>
   <attribute field="" color="#000000" label=""/>
  </DiagramCategory>
  <symbol alpha="1" clip_to_extent="1" type="marker" name="sizeSymbol">
   <layer pass="0" class="SimpleMarker" locked="0">
    <prop k="angle" v="0"/>
    <prop k="color" v="255,0,0,255"/>
    <prop k="horizontal_anchor_point" v="1"/>
    <prop k="joinstyle" v="bevel"/>
    <prop k="name" v="circle"/>
    <prop k="offset" v="0,0"/>
    <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="offset_unit" v="MM"/>
    <prop k="outline_color" v="0,0,0,255"/>
    <prop k="outline_style" v="solid"/>
    <prop k="outline_width" v="0"/>
    <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="outline_width_unit" v="MM"/>
    <prop k="scale_method" v="diameter"/>
    <prop k="size" v="2"/>
    <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="size_unit" v="MM"/>
    <prop k="vertical_anchor_point" v="1"/>
   </layer>
  </symbol>
 </SingleCategoryDiagramRenderer>
 <DiagramLayerSettings yPosColumn="-1" showColumn="-1" linePlacementFlags="10" placement="0" dist="0" xPosColumn="-1" priority="0" obstacle="0" zIndex="0" showAll="1"/>
 <annotationform>.</annotationform>
 <aliases>
  <alias field="id" index="0" name=""/>
  <alias field="eval_nr" index="1" name=""/>
  <alias field="eval_str" index="2" name=""/>
  <alias field="att_nat" index="3" name=""/>
  <alias field="att_open" index="4" name=""/>
  <alias field="att_order" index="5" name=""/>
  <alias field="att_upkeep" index="6" name=""/>
  <alias field="att_hist" index="7" name=""/>
 </aliases>
 <excludeAttributesWMS/>
 <excludeAttributesWFS/>
 <attributeactions default="-1"/>
 <attributetableconfig actionWidgetStyle="dropDown" sortExpression="" sortOrder="0">
  <columns>
   <column width="-1" hidden="0" type="field" name="id"/>
   <column width="-1" hidden="0" type="field" name="eval_nr"/>
   <column width="-1" hidden="0" type="field" name="eval_str"/>
   <column width="-1" hidden="0" type="field" name="att_nat"/>
   <column width="-1" hidden="0" type="field" name="att_open"/>
   <column width="-1" hidden="0" type="field" name="att_order"/>
   <column width="-1" hidden="0" type="field" name="att_upkeep"/>
   <column width="-1" hidden="0" type="field" name="att_hist"/>
   <column width="-1" hidden="1" type="actions"/>
  </columns>
 </attributetableconfig>
 <editform>.</editform>
 <editforminit/>
 <editforminitcodesource>0</editforminitcodesource>
 <editforminitfilepath>.</editforminitfilepath>
 <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
 <featformsuppress>0</featformsuppress>
 <editorlayout>generatedlayout</editorlayout>
 <widgets/>
 <conditionalstyles>
  <rowstyles/>
  <fieldstyles/>
 </conditionalstyles>
 <defaults>
  <default field="id" expression=""/>
  <default field="eval_nr" expression=""/>
  <default field="eval_str" expression=""/>
  <default field="att_nat" expression=""/>
  <default field="att_open" expression=""/>
  <default field="att_order" expression=""/>
  <default field="att_upkeep" expression=""/>
  <default field="att_hist" expression=""/>
 </defaults>
 <previewExpression>COALESCE( "id", ''&lt;NULL>'' )</previewExpression>
 <layerGeometryType>2</layerGeometryType>
</qgis>
', '<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:se="http://www.opengis.net/se">
 <NamedLayer>
  <se:Name>smp_areas</se:Name>
  <UserStyle>
   <se:Name>smp_areas</se:Name>
   <se:FeatureTypeStyle>
    <se:Rule>
     <se:Name>Liked (1)</se:Name>
     <se:Description>
      <se:Title>Liked (1)</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>eval_nr</ogc:PropertyName>
       <ogc:Literal>1</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#f1f4c7</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#000001</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
    <se:Rule>
     <se:Name>Disiked (2)</se:Name>
     <se:Description>
      <se:Title>Disiked (2)</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>eval_nr</ogc:PropertyName>
       <ogc:Literal>2</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#e230d4</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#000001</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
   </se:FeatureTypeStyle>
  </UserStyle>
 </NamedLayer>
</StyledLayerDescriptor>
', false, 'Fri Nov 2 10:59:57 2018', 'postgres', NULL, '2018-11-02 10:59:57.231634');
INSERT INTO public.layer_styles (id, f_table_catalog, f_table_schema, f_table_name, f_geometry_column, stylename, styleqml, stylesld, useasdefault, description, owner, ui, update_time) VALUES (5, 'eimg_lx', 'public', 'tblfoo_result', 'geom', 'foo_result_cat1-2-3', '<!DOCTYPE qgis PUBLIC ''http://mrcc.com/qgis.dtd'' ''SYSTEM''>
<qgis version="2.18.24" simplifyAlgorithm="0" minimumScale="0" maximumScale="1e+08" simplifyDrawingHints="1" minLabelScale="0" maxLabelScale="1e+08" simplifyDrawingTol="1" readOnly="0" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" simplifyLocal="1" scaleBasedLabelVisibilityFlag="0">
 <edittypes>
  <edittype widgetv2type="TextEdit" name="category">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="sum_value">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="ct_overlap_cat1">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="ct_overlap_cat2">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
 </edittypes>
 <renderer-v2 attr="category" forceraster="0" symbollevels="0" type="categorizedSymbol" enableorderby="0">
  <categories>
   <category render="true" symbol="0" value="cat1" label="cat1"/>
   <category render="true" symbol="1" value="cat2" label="cat2"/>
   <category render="true" symbol="2" value="cat3" label="cat3"/>
  </categories>
  <symbols>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="0">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="80,255,0,102"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="128,152,72,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="1">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="255,0,0,102"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="193,68,68,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="2">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="0,255,255,108"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="0,0,0,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
  </symbols>
  <source-symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="0">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="111,44,155,255"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="0,0,0,255"/>
     <prop k="outline_style" v="solid"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
   </symbol>
  </source-symbol>
  <colorramp type="randomcolors" name="[source]"/>
  <invertedcolorramp value="0"/>
  <rotation/>
  <sizescale scalemethod="diameter"/>
 </renderer-v2>
 <labeling type="simple"/>
 <customproperties>
  <property key="embeddedWidgets/count" value="0"/>
  <property key="labeling" value="pal"/>
  <property key="labeling/addDirectionSymbol" value="false"/>
  <property key="labeling/angleOffset" value="0"/>
  <property key="labeling/blendMode" value="0"/>
  <property key="labeling/bufferBlendMode" value="0"/>
  <property key="labeling/bufferColorA" value="255"/>
  <property key="labeling/bufferColorB" value="255"/>
  <property key="labeling/bufferColorG" value="255"/>
  <property key="labeling/bufferColorR" value="255"/>
  <property key="labeling/bufferDraw" value="false"/>
  <property key="labeling/bufferJoinStyle" value="128"/>
  <property key="labeling/bufferNoFill" value="false"/>
  <property key="labeling/bufferSize" value="1"/>
  <property key="labeling/bufferSizeInMapUnits" value="false"/>
  <property key="labeling/bufferSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/bufferTransp" value="0"/>
  <property key="labeling/centroidInside" value="false"/>
  <property key="labeling/centroidWhole" value="false"/>
  <property key="labeling/decimals" value="3"/>
  <property key="labeling/displayAll" value="false"/>
  <property key="labeling/dist" value="0"/>
  <property key="labeling/distInMapUnits" value="false"/>
  <property key="labeling/distMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/drawLabels" value="false"/>
  <property key="labeling/enabled" value="false"/>
  <property key="labeling/fieldName" value=""/>
  <property key="labeling/fitInPolygonOnly" value="false"/>
  <property key="labeling/fontCapitals" value="0"/>
  <property key="labeling/fontFamily" value="MS Shell Dlg 2"/>
  <property key="labeling/fontItalic" value="false"/>
  <property key="labeling/fontLetterSpacing" value="0"/>
  <property key="labeling/fontLimitPixelSize" value="false"/>
  <property key="labeling/fontMaxPixelSize" value="10000"/>
  <property key="labeling/fontMinPixelSize" value="3"/>
  <property key="labeling/fontSize" value="8.25"/>
  <property key="labeling/fontSizeInMapUnits" value="false"/>
  <property key="labeling/fontSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/fontStrikeout" value="false"/>
  <property key="labeling/fontUnderline" value="false"/>
  <property key="labeling/fontWeight" value="50"/>
  <property key="labeling/fontWordSpacing" value="0"/>
  <property key="labeling/formatNumbers" value="false"/>
  <property key="labeling/isExpression" value="true"/>
  <property key="labeling/labelOffsetInMapUnits" value="true"/>
  <property key="labeling/labelOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/labelPerPart" value="false"/>
  <property key="labeling/leftDirectionSymbol" value="&lt;"/>
  <property key="labeling/limitNumLabels" value="false"/>
  <property key="labeling/maxCurvedCharAngleIn" value="25"/>
  <property key="labeling/maxCurvedCharAngleOut" value="-25"/>
  <property key="labeling/maxNumLabels" value="2000"/>
  <property key="labeling/mergeLines" value="false"/>
  <property key="labeling/minFeatureSize" value="0"/>
  <property key="labeling/multilineAlign" value="4294967295"/>
  <property key="labeling/multilineHeight" value="1"/>
  <property key="labeling/namedStyle" value="Normal"/>
  <property key="labeling/obstacle" value="true"/>
  <property key="labeling/obstacleFactor" value="1"/>
  <property key="labeling/obstacleType" value="0"/>
  <property key="labeling/offsetType" value="0"/>
  <property key="labeling/placeDirectionSymbol" value="0"/>
  <property key="labeling/placement" value="1"/>
  <property key="labeling/placementFlags" value="10"/>
  <property key="labeling/plussign" value="false"/>
  <property key="labeling/predefinedPositionOrder" value="TR,TL,BR,BL,R,L,TSR,BSR"/>
  <property key="labeling/preserveRotation" value="true"/>
  <property key="labeling/previewBkgrdColor" value="#ffffff"/>
  <property key="labeling/priority" value="5"/>
  <property key="labeling/quadOffset" value="4"/>
  <property key="labeling/repeatDistance" value="0"/>
  <property key="labeling/repeatDistanceMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/repeatDistanceUnit" value="1"/>
  <property key="labeling/reverseDirectionSymbol" value="false"/>
  <property key="labeling/rightDirectionSymbol" value=">"/>
  <property key="labeling/scaleMax" value="10000000"/>
  <property key="labeling/scaleMin" value="1"/>
  <property key="labeling/scaleVisibility" value="false"/>
  <property key="labeling/shadowBlendMode" value="6"/>
  <property key="labeling/shadowColorB" value="0"/>
  <property key="labeling/shadowColorG" value="0"/>
  <property key="labeling/shadowColorR" value="0"/>
  <property key="labeling/shadowDraw" value="false"/>
  <property key="labeling/shadowOffsetAngle" value="135"/>
  <property key="labeling/shadowOffsetDist" value="1"/>
  <property key="labeling/shadowOffsetGlobal" value="true"/>
  <property key="labeling/shadowOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shadowOffsetUnits" value="1"/>
  <property key="labeling/shadowRadius" value="1.5"/>
  <property key="labeling/shadowRadiusAlphaOnly" value="false"/>
  <property key="labeling/shadowRadiusMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shadowRadiusUnits" value="1"/>
  <property key="labeling/shadowScale" value="100"/>
  <property key="labeling/shadowTransparency" value="30"/>
  <property key="labeling/shadowUnder" value="0"/>
  <property key="labeling/shapeBlendMode" value="0"/>
  <property key="labeling/shapeBorderColorA" value="255"/>
  <property key="labeling/shapeBorderColorB" value="128"/>
  <property key="labeling/shapeBorderColorG" value="128"/>
  <property key="labeling/shapeBorderColorR" value="128"/>
  <property key="labeling/shapeBorderWidth" value="0"/>
  <property key="labeling/shapeBorderWidthMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeBorderWidthUnits" value="1"/>
  <property key="labeling/shapeDraw" value="false"/>
  <property key="labeling/shapeFillColorA" value="255"/>
  <property key="labeling/shapeFillColorB" value="255"/>
  <property key="labeling/shapeFillColorG" value="255"/>
  <property key="labeling/shapeFillColorR" value="255"/>
  <property key="labeling/shapeJoinStyle" value="64"/>
  <property key="labeling/shapeOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeOffsetUnits" value="1"/>
  <property key="labeling/shapeOffsetX" value="0"/>
  <property key="labeling/shapeOffsetY" value="0"/>
  <property key="labeling/shapeRadiiMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeRadiiUnits" value="1"/>
  <property key="labeling/shapeRadiiX" value="0"/>
  <property key="labeling/shapeRadiiY" value="0"/>
  <property key="labeling/shapeRotation" value="0"/>
  <property key="labeling/shapeRotationType" value="0"/>
  <property key="labeling/shapeSVGFile" value=""/>
  <property key="labeling/shapeSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeSizeType" value="0"/>
  <property key="labeling/shapeSizeUnits" value="1"/>
  <property key="labeling/shapeSizeX" value="0"/>
  <property key="labeling/shapeSizeY" value="0"/>
  <property key="labeling/shapeTransparency" value="0"/>
  <property key="labeling/shapeType" value="0"/>
  <property key="labeling/substitutions" value="&lt;substitutions/>"/>
  <property key="labeling/textColorA" value="255"/>
  <property key="labeling/textColorB" value="0"/>
  <property key="labeling/textColorG" value="0"/>
  <property key="labeling/textColorR" value="0"/>
  <property key="labeling/textTransp" value="0"/>
  <property key="labeling/upsidedownLabels" value="0"/>
  <property key="labeling/useSubstitutions" value="false"/>
  <property key="labeling/wrapChar" value=""/>
  <property key="labeling/xOffset" value="0"/>
  <property key="labeling/yOffset" value="0"/>
  <property key="labeling/zIndex" value="0"/>
  <property key="variableNames"/>
  <property key="variableValues"/>
 </customproperties>
 <blendMode>0</blendMode>
 <featureBlendMode>0</featureBlendMode>
 <layerTransparency>0</layerTransparency>
 <displayfield>category</displayfield>
 <label>0</label>
 <labelattributes>
  <label fieldname="" text="Label"/>
  <family fieldname="" name="MS Shell Dlg 2"/>
  <size fieldname="" units="pt" value="12"/>
  <bold fieldname="" on="0"/>
  <italic fieldname="" on="0"/>
  <underline fieldname="" on="0"/>
  <strikeout fieldname="" on="0"/>
  <color fieldname="" red="0" blue="0" green="0"/>
  <x fieldname=""/>
  <y fieldname=""/>
  <offset x="0" y="0" units="pt" yfieldname="" xfieldname=""/>
  <angle fieldname="" value="0" auto="0"/>
  <alignment fieldname="" value="center"/>
  <buffercolor fieldname="" red="255" blue="255" green="255"/>
  <buffersize fieldname="" units="pt" value="1"/>
  <bufferenabled fieldname="" on=""/>
  <multilineenabled fieldname="" on=""/>
  <selectedonly on=""/>
 </labelattributes>
 <SingleCategoryDiagramRenderer diagramType="Histogram" sizeLegend="0" attributeLegend="1">
  <DiagramCategory penColor="#000000" labelPlacementMethod="XHeight" penWidth="0" diagramOrientation="Up" sizeScale="0,0,0,0,0,0" minimumSize="0" barWidth="5" penAlpha="255" maxScaleDenominator="1e+08" backgroundColor="#ffffff" transparency="0" width="15" scaleDependency="Area" backgroundAlpha="255" angleOffset="1440" scaleBasedVisibility="0" enabled="0" height="15" lineSizeScale="0,0,0,0,0,0" sizeType="MM" lineSizeType="MM" minScaleDenominator="inf">
   <fontProperties description="MS Shell Dlg 2,8.25,-1,5,50,0,0,0,0,0" style=""/>
  </DiagramCategory>
  <symbol alpha="1" clip_to_extent="1" type="marker" name="sizeSymbol">
   <layer pass="0" class="SimpleMarker" locked="0">
    <prop k="angle" v="0"/>
    <prop k="color" v="255,0,0,255"/>
    <prop k="horizontal_anchor_point" v="1"/>
    <prop k="joinstyle" v="bevel"/>
    <prop k="name" v="circle"/>
    <prop k="offset" v="0,0"/>
    <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="offset_unit" v="MM"/>
    <prop k="outline_color" v="0,0,0,255"/>
    <prop k="outline_style" v="solid"/>
    <prop k="outline_width" v="0"/>
    <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="outline_width_unit" v="MM"/>
    <prop k="scale_method" v="diameter"/>
    <prop k="size" v="2"/>
    <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="size_unit" v="MM"/>
    <prop k="vertical_anchor_point" v="1"/>
   </layer>
  </symbol>
 </SingleCategoryDiagramRenderer>
 <DiagramLayerSettings yPosColumn="-1" showColumn="-1" linePlacementFlags="10" placement="0" dist="0" xPosColumn="-1" priority="0" obstacle="0" zIndex="0" showAll="1"/>
 <annotationform></annotationform>
 <aliases>
  <alias field="category" index="0" name=""/>
  <alias field="sum_value" index="1" name=""/>
  <alias field="ct_overlap_cat1" index="2" name=""/>
  <alias field="ct_overlap_cat2" index="3" name=""/>
 </aliases>
 <excludeAttributesWMS/>
 <excludeAttributesWFS/>
 <attributeactions default="-1"/>
 <attributetableconfig actionWidgetStyle="dropDown" sortExpression="" sortOrder="594073144">
  <columns>
   <column width="-1" hidden="0" type="field" name="category"/>
   <column width="-1" hidden="0" type="field" name="sum_value"/>
   <column width="-1" hidden="0" type="field" name="ct_overlap_cat1"/>
   <column width="-1" hidden="0" type="field" name="ct_overlap_cat2"/>
   <column width="-1" hidden="1" type="actions"/>
  </columns>
 </attributetableconfig>
 <editform></editform>
 <editforminit/>
 <editforminitcodesource>0</editforminitcodesource>
 <editforminitfilepath></editforminitfilepath>
 <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
 <featformsuppress>0</featformsuppress>
 <editorlayout>generatedlayout</editorlayout>
 <widgets/>
 <conditionalstyles>
  <rowstyles/>
  <fieldstyles/>
 </conditionalstyles>
 <defaults>
  <default field="category" expression=""/>
  <default field="sum_value" expression=""/>
  <default field="ct_overlap_cat1" expression=""/>
  <default field="ct_overlap_cat2" expression=""/>
 </defaults>
 <previewExpression>COALESCE( "category", ''&lt;NULL>'' )</previewExpression>
 <layerGeometryType>2</layerGeometryType>
</qgis>
', '<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:se="http://www.opengis.net/se">
 <NamedLayer>
  <se:Name>tblfoo_result</se:Name>
  <UserStyle>
   <se:Name>tblfoo_result</se:Name>
   <se:FeatureTypeStyle>
    <se:Rule>
     <se:Name>cat1</se:Name>
     <se:Description>
      <se:Title>cat1</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>category</ogc:PropertyName>
       <ogc:Literal>cat1</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#50ff00</se:SvgParameter>
       <se:SvgParameter name="fill-opacity">0.40</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#000001</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
    <se:Rule>
     <se:Name>cat2</se:Name>
     <se:Description>
      <se:Title>cat2</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>category</ogc:PropertyName>
       <ogc:Literal>cat2</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#ff0000</se:SvgParameter>
       <se:SvgParameter name="fill-opacity">0.40</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#000001</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
    <se:Rule>
     <se:Name>cat3</se:Name>
     <se:Description>
      <se:Title>cat3</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>category</ogc:PropertyName>
       <ogc:Literal>cat3</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#00ffff</se:SvgParameter>
       <se:SvgParameter name="fill-opacity">0.42</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#000001</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
   </se:FeatureTypeStyle>
  </UserStyle>
 </NamedLayer>
</StyledLayerDescriptor>
', true, 'Tue Nov 13 14:17:33 2018', 'postgres', NULL, '2018-11-13 14:17:33.794478');


--
-- TOC entry 3695 (class 0 OID 27055)
-- Dependencies: 217
-- Data for Name: parts_singlefeat; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E610000001000000120000004B2B4BD0375122C02C1D8FF6EB5A4340CAD59429695122C0423A9A4DF65A4340B6B755B9F04F22C0297987C3F75A4340018015B4625022C07A4403AB3F5B43405F067D7FDF5122C0A5F30F190F5B43400180031D825222C02B76AA2B315B4340E303EFFA015222C0DCF9697A605B43407A7AD1BE495122C03DFF2D0C825B43406D0753C4325022C0176EE8DD815B4340DCED736ED04F22C061C7C6DB5A5B43400180039DF54F22C0FA03FCE44F5B4340C2F7AABD724F22C006E456B1355B4340E7ED3B72144F22C0B5288E49105B43400080039D144F22C0D9A16C40105B43400BFDAF70144F22C0753D3015105B4340140DD9A0245022C05FA93F40E75A43409339B16F375122C0665916E6EB5A43404B2B4BD0375122C02C1D8FF6EB5A4340', 1, 0, 0, 1, 1, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000C0000005C9733961C4D22C04E9F0FAC605C4340008090CB694D22C0629511E56F5C43400180908B314D22C0EDB51006D75C43400080900B3A4C22C0E59FDA28EF5C43402F27E1D9B24A22C0BCE0FE24965C434041D54EE6364B22C0DFF2B1D7925C434000804657DE4B22C09C1EA1A1A15C4340CB12D06FF14B22C0A95E46C3845C434000805597BB4C22C046D80D12AC5C43402CF72957A04C22C0713DA8268B5C43400080031DB54C22C0250F25158E5C43405C9733961C4D22C04E9F0FAC605C4340', 1, 0, 1, 0, 1, 1, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000010000000F9F137FF374C22C0DC99535A0C5C4340EDC54BA5304C22C07A4F6B1A105C4340CC8E31E4154A22C063ECC614065C4340A1909614164A22C0D706DD28065C43400180215DE34722C079659E18EE5B4340B9DF7C4E5A4822C030551659B35B43400080039DC04822C0A1E5AC65C65B43400080039D284A22C09036C1ACA75B43400080031D124A22C0A0D3C4FA7D5B4340720E13B3E64822C0778A54016E5B4340D7B104086A4922C0E2404A232D5B4340FD2FDA9E684922C088C36AF32D5B43400180125DC24A22C0946FC4B4805B4340DFE53288DE4B22C07B8C58E99D5B43400A219FA7DD4B22C0506B66FD9D5B4340F9F137FF374C22C0DC99535A0C5C4340', 1, 0, 1, 0, 1, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000B000000D7B104086A4922C0E2404A232D5B434000801DFAFC4922C0015FFA8EE45A4340B6BD0E03EE4C22C0B3D93219285B4340006F1E36134D22C0C626E7C3385B434048BE3886774C22C08D61E60A585B4340D3AC7407FA4C22C019DB45E66F5B4340250402D7C64C22C0118CC02A895B4340DFE53288DE4B22C07B8C58E99D5B43400180125DC24A22C0946FC4B4805B4340FD2FDA9E684922C088C36AF32D5B4340D7B104086A4922C0E2404A232D5B4340', 1, 0, 1, 0, 1, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000008000000B12503781F4E22C00483C33D1C5C43400CA65DFEA94D22C0EB36349D225C43400180031DC34D22C0055A0A97175C43403E23653A3B4C22C07B83D04C105C43400A219FA7DD4B22C0506B66FD9D5B4340DFE53288DE4B22C07B8C58E99D5B43401444AAECBF4D22C0B013F662CF5B4340B12503781F4E22C00483C33D1C5C4340', 1, 0, 0, 0, 0, 1, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000200000012000000934DE3D7CD4722C097228B78DD5A4340A3AA0DDEE24722C01A02E540DD5A43403B921FBC464822C097389CDD165B434044EB8A820D4822C08D1FB5A8855B43400180031DC94722C095774150985B434039FB31B8FE4722C04E55774BA25B434053CF8250DE4722C0E0F3C308E15B43408A8D65F97C4722C0303936CBE05B4340F6622827DA4522C01D3D7E6FD35B43403C5AB267CF4522C0337D5D99D95B434070A8EC246C4522C052EA03CFC45B4340BC30B963834522C00B621BFDBB5B43400180129DB44522C0872F0F39BC5B43406337D5A4B84522C04CC84DC8A75B434035147F9E204722C06A9C7D321F5B4340DE2CACAAB54722C0F3EE91A9215B4340D46092766C4722C02BC3756B025B4340934DE3D7CD4722C097228B78DD5A434008000000AFC79C14A84722C0B08E05EF5A5B4340A5E1863ACF4722C0BDE33A1D3B5B4340440D4EFF4F4722C0BA907891315B43405C1D339AE74622C07BB0657A415B4340E1E7664AD74622C005D4A61D655B4340440D4EFF4F4722C078640D35785B4340AC254021B54722C02009F7D7785B4340AFC79C14A84722C0B08E05EF5A5B4340', 1, 0, 1, 1, 1, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000B0000007D21BD4C2C4722C0D11F0F09E75A434066300C16E64822C0C4E70EE6FD5A43401CF743D16E4822C0342D111A685B4340F5D6C056094622C097ADF545425B4340737BE502344622C03F94AC481B5B4340BD01B6FE484622C0434685A11B5B434002DE61BF474622C0CBEE4A342B5B4340E5DA71B7C34622C05E6ED04B3E5B43401A2FB4A30E4722C044045DE61E5B4340DE2CACAAB54722C0F3EE91A9215B43407D21BD4C2C4722C0D11F0F09E75A4340', 1, 0, 0, 1, 0, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000011000000E446815D9D5222C062DE1173EF5B43401E87C1FC155222C0BBEF181EFB5B4340A12EEA80EB5122C09615F062E05B43400180039D115222C04CF65290D35B43409835C057D45122C07F9B43D0D15B43401CDA7160B85122C08D6A9337C05B434000804D91FF5222C0FCADF7AFA25B43406AE38C43735222C0EE8FF6D1945B434057471681745222C08DA87CD5945B4340D87AA7C9C55222C082AB992E7F5B43400080039DD35322C0F88601D7655B4340AFA260645F5322C015390C90555B43404B126525155322C09FB45090415B43409DC6C956D85422C0E59D7AFF225B4340156A4FFB585422C0B2BA305BA35B4340FD78DF5C485422C051A6A74FA95B4340E446815D9D5222C062DE1173EF5B4340', 1, 0, 0, 0, 1, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000008000000C062F032D74522C0A346964BBB5A434036A6D8076D4522C0CADEB5E65F5B4340D0E2C5AB7B4422C0DC3B0CE6505B434021D9BFEF7B4422C0236DC1C4505B4340184339D1AE4222C082734694F65A4340863F7E1D3C4222C08E916FE5075B434099EF7F65084222C0DD4CDF9FC85A4340C062F032D74522C0A346964BBB5A4340', 0, 1, 1, 0, 1, 1, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000D000000C2F7AABD724F22C007E456B1355B4340E7ED3B72144F22C0B5288E49105B43400080039D144F22C0D9A16C40105B4340A8A82C74144F22C0FBF39618105B43404FA066DAF04F22C0C19463D8F75A4340018015B4625022C07A4403AB3F5B4340BF036D18A15122C0C80CAC0E175B4340913FD981775222C0817E1F16355B4340E103EFFA015222C0DDF9697A605B4340D53B70946F5122C0D94A5D277B5B4340858A479FE64F22C0068FA350545B43400180039DF54F22C0FA03FCE44F5B4340C2F7AABD724F22C007E456B1355B4340', 1, 0, 1, 1, 0, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000A000000E247DBD5E64B22C04BC2ACF8705C4340939A8BD4A24C22C0B6F07DB3485C4340D399D9974C4B22C054ECD8423C5C4340075C5C95914A22C069A5856B395C4340CC8E31E4154A22C063ECC614065C43403E23653A3B4C22C07B83D04C105C434045FE452D594C22C060DFC1E2345C43400CA65DFEA94D22C0EB36349D225C43400080031DB54C22C0250F25158E5C4340E247DBD5E64B22C04BC2ACF8705C4340', 0, 1, 0, 0, 1, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000C000000524C8C9A604622C03CCC2D89475C43408837B795594622C0FD477BDF4F5C434093E3735AA74522C07CAB9CEA5E5C4340A521667F364622C05CABCD8C795C4340018046971C4622C05F658852985C4340018046D7B14322C0D939FA92845C4340DDD7D16AEE4322C0BC620F7A565C43400080035DAA4422C0AEC2FDCE5D5C4340B852A9DB204522C0048E02F70D5C4340D2DA1725784522C08712D1A30B5C4340A1B1AED9334522C0E1B8F9CD325C4340524C8C9A604622C03CCC2D89475C4340', 1, 0, 1, 1, 0, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000A0000000080039DD35322C0F88601D7655B43400080035D445022C06B78C96CBB5B43401D399CEEAB4F22C0FF610C9F655B43400180039DF54F22C0FA03FCE44F5B4340E613FB5A474F22C0177FB0012D5B434019A0A25D144F22C04FB4F34D105B43400080039D144F22C0D9A16C40105B4340A8A82C74144F22C0FBF39618105B43400080031D665022C0E14E68F1EA5A43400080039DD35322C0F88601D7655B4340', 1, 0, 1, 0, 1, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000014000000295C5AB9944822C0A48DA886E95B4340008090CB6F4722C00EA78198AC5B4340AAF544EDE54622C044F9E4F9DB5B434078EF2374644622C03F93BBD8D75B43400180035D204722C095774150985B4340D96C87C2994622C04CC5CAC3835B4340A07404EAE94622C0681DB70F685B4340440D4EFF4F4722C078640D35785B4340AC254021B54722C02009F7D7785B4340C1DE777DA84722C034885BDF5B5B43401CF743D16E4822C0342D111A685B43402790FC6B964822C05D1303D6445B434072C2C5E0DC4822C09CD42F7B6D5B43400CB4E994794822C0309AFB2E685B43400180031DC94722C095774150985B43400080039DC04822C0A1E5AC65C65B43405EAEFE805F4922C0F6A964D6B85B4340AAB405E97E4922C0663093F4CA5B4340DF5DDDAD604922C08B079EF2DE5B4340295C5AB9944822C0A48DA886E95B4340', 1, 0, 1, 1, 1, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000800000014E9DE641D4922C02772FB99845A4340018003DD254922C0F7B74C357D5A43406266F142634B22C0EF4A295A685A4340A46E8B37B34C22C0EE2515B9885A4340C6E9FF50B34C22C09B38C7BC885A434011ECC7F9714C22C04970C437CC5A4340AE837754B04A22C0D4AB92C5B35A434014E9DE641D4922C02772FB99845A4340', 0, 1, 0, 1, 0, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000D00000023AD5FD6FF5022C0BCE239AE2F5C43400080039D4F5022C09A096CF96A5C43400180039DD94D22C0F57BF295665C43403B46FC4C5E4D22C08D8030D5435C43400CA65DFEA94D22C0EB36349D225C4340B12503781F4E22C00483C33D1C5C43400080039D604E22C0DAA18AA4505C4340DE50AB6AB44E22C05AD33E29145C43400080035D904F22C042B6BA3A085C4340918AE9C03D4F22C072B7F289E55B434001804DD10D5022C0F71B0CB7E65B43406A199183295122C027875C1CCD5B434023AD5FD6FF5022C0BCE239AE2F5C4340', 1, 0, 0, 0, 1, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E610000001000000070000007DA15BF1394722C098B1671C2C5C43400080031D184422C076D2954F365C43404E97C5C4E64322C048FE60E0B95B43400180031DDA4522C04CF65290D35B4340EE5589CCFF4622C0DFBD1A87FE5B43400080035D994622C0DA0735D7035C43407DA15BF1394722C098B1671C2C5C4340', 0, 1, 1, 0, 1, 1, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000006000000B0A9CDE2BC4822C03710BB4D795A434060CDDA4B414A22C05E74AB694C5A4340B1B61952B34C22C04531A4BB885A434011ECC7F9714C22C04970C437CC5A4340B5837754B04A22C0D4AB92C5B35A4340B0A9CDE2BC4822C03710BB4D795A4340', 1, 0, 0, 1, 1, 1, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000F0000000080031DAA4822C0467EFFDE625A4340C2855025BD4822C0572B0B46795A4340B0A9CDE2BC4822C03710BB4D795A4340CC74E933BD4822C08CCE3957795A4340EF7211DF894922C088BA0F406A5B43402EDD4E63664922C0CB094B296B5B4340BADDEC55A74822C0DFA867C6355B434066300C16E64822C0C4E70EE6FD5A434007469F7C074822C00976F460F25A434065ADCEC0DA4722C0684C8F92D85A4340D958AD45A44722C0CBF7823EED5A43407D21BD4C2C4722C0D11F0F09E75A43409FE57970774622C034BA83D8995A43405762F76A454522C0142AA600895A43400080031DAA4822C0467EFFDE625A4340', 0, 1, 0, 1, 1, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000D0000007A7AD1BE495122C03DFF2D0C825B43406E0753C4325022C0176EE8DD815B4340DCED736ED04F22C061C7C6DB5A5B43400180039DF54F22C0FA03FCE44F5B4340C2F7AABD724F22C007E456B1355B4340E7ED3B72144F22C0B5288E49105B43400080039D144F22C0D9A16C40105B4340A8A82C74144F22C0FBF39618105B43404FA066DAF04F22C0C19463D8F75A4340018015B4625022C07A4403AB3F5B4340BD036D18A15122C0C80CAC0E175B434067A01EB4BB5222C0A3A436A33E5B43407A7AD1BE495122C03DFF2D0C825B4340', 1, 0, 0, 1, 0, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000D00000043288ACC594622C08AACDADA4F5C4340963A5AE9884622C03D1CDFE04B5C434081CDA91C934622C0FC4E77044B5C4340B9AAECBB224822C078D15790665C4340F2ADDAC9224822C038A61781665C43400080031D234822C0F57BF295665C4340D4B622C4C34822C0894F3B315E5C4340230C685E8E4922C0A6374E829B5C43400180035D884822C04AB6910BE85C4340A521667F364622C05CABCD8C795C434043051D1F584622C00E81709C515C4340E634B75F584622C04DA89197515C434043288ACC594622C08AACDADA4F5C4340', 1, 0, 0, 1, 1, 1, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E610000001000000080000009C587F7B8E4022C069356E78765B43400080031D2C3F22C01E8187563E5B43407B2AD1A8D33E22C04A375732EC5A43400180035D913F22C0DF2C254CAB5A43400180035DF94022C05B56162AE25A4340E174E31DAC4122C079F3E1A21D5B4340FEB7921D1B4122C057091687335B43409C587F7B8E4022C069356E78765B4340', 0, 1, 1, 0, 0, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000D0000004B8619ADB13F22C0AB261F3FEA5A434001805C51E93F22C036B31D2C8C5A4340E4EC3050E94122C0FD390C99A25A434099EF7F65084222C0DD4CDF9FC85A43400180031DA24122C01ECDE905CA5A4340B890AFF6B64122C081AA3D9ADA5A4340A97DAE27334122C058939E97F55A4340B20D093CF04122C0D2176D24085B43406A142715FC4122C073E24090115B4340745F6CE1B04122C0C9B8C3EA1C5B4340018007801D4122C0AA18E777095B4340ECE566A1EB4022C089F97880125B43404B8619ADB13F22C0AB261F3FEA5A4340', 0, 1, 1, 1, 1, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000800000000804D91FF5222C0FCADF7AFA25B434001804DD10D5022C0F71B0CB7E65B4340918AE9C03D4F22C072B7F289E55B434037F682C50F4F22C0813FC03AD25B43400180039D414F22C0FC821A42AE5B4340B9C41685BC4E22C00E5AD637AC5B4340868A479FE64F22C0068FA350545B434000804D91FF5222C0FCADF7AFA25B4340', 1, 0, 0, 1, 1, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000500000001809BE88B3F22C0977BDA8DF15B4340FEB7921D1B4122C057091687335B4340D1612458654222C0A8BD98488D5B434001809B28B34122C00DC32A9CDB5B434001809BE88B3F22C0977BDA8DF15B4340', 1, 0, 1, 1, 0, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000A000000D0E2C5AB7B4422C0DC3B0CE6505B4340016611AE6D4322C070763921D55B4340D1612458654222C0A8BD98488D5B434018096D39974222C01630815B775B43409032C4897A4222C0A3396843545B4340B8979453C34222C07C4398FB4E5B434000304E2DBB4222C01F9C17F04D5B434089EFC4AC174322C0D00F2384475B4340D830F155274322C051B16CBE3B5B4340D0E2C5AB7B4422C0DC3B0CE6505B4340', 1, 0, 0, 1, 1, 1, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000B000000B4CEE25ECC4A22C08D5CE228F75A434040A16EB8774C22C0610DD000585B434048BE3886774C22C08D61E60A585B4340D6CF3370794C22C0EA877864585B434001801917E14C22C013CFA6E16F5B43405BA80163C34A22C0DC05B0CF805B43400180125DC24A22C0946FC4B4805B434034394A62C14A22C0D4C9BD78805B43409308AF35604A22C0C2A8B46D2A5B4340D86DE62ACC4A22C0AABA3824F75A4340B4CEE25ECC4A22C08D5CE228F75A4340', 1, 0, 1, 1, 0, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E610000001000000080000003363244F094222C0DDBFB4BDC95A4340CDF32157CC4222C0D46436CEA15A4340BC91DE084F4522C056BBAB0CCC5A4340DAACFA5C6D4522C016F6B4C35F5B43407E5322CB224422C05D5751553F5B4340184339D1AE4222C082734694F65A4340863F7E1D3C4222C08E916FE5075B43403363244F094222C0DDBFB4BDC95A4340', 1, 0, 0, 1, 1, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000B000000E0E53288DE4B22C07B8C58E99D5B43400180125DC24A22C0946FC4B4805B4340FD2FDA9E684922C088C36AF32D5B43400180129D464A22C02EDB3406AE5A4340AE837754B04A22C0D4AB92C5B35A4340EA5BE674594C22C049F4328AE55A4340FF6E1E36134D22C0C626E7C3385B434048BE3886774C22C08D61E60A585B4340D3AC7407FA4C22C019DB45E66F5B4340260402D7C64C22C0118CC02A895B4340E0E53288DE4B22C07B8C58E99D5B4340', 0, 1, 0, 1, 0, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E610000001000000120000009DC6C956D85422C0E59D7AFF225B434099B05C21865422C055854DDA755B4340156A4FFB585422C0B2BA305BA35B4340FE78DF5C485422C051A6A74FA95B4340E146815D9D5222C062DE1173EF5B43401E87C1FC155222C0BBEF181EFB5B4340A12EEA80EB5122C09615F062E05B43400180039D115222C04CF65290D35B43409835C057D45122C07F9B43D0D15B43401CDA7160B85122C08D6A9337C05B434000804D91FF5222C0FCADF7AFA25B43406AE38C43735222C0EE8FF6D1945B434057471681745222C08DA87CD5945B4340D87AA7C9C55222C082AB992E7F5B43400080039DD35322C0F88601D7655B4340ACA260645F5322C015390C90555B434048126525155322C09FB45090415B43409DC6C956D85422C0E59D7AFF225B4340', 1, 0, 0, 1, 0, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000D00000046D02C371B4E22C0A6819298A65A43400080031D854F22C004D6912E885A4340294E5BBF2E4E22C0AFCBCD225B5A43400080039D144F22C092F16ACE295A4340018003DD685122C0D260B842675A4340EC3D3B791E5122C03AC0AFFF915A4340018097850F5022C0A74575BA825A4340FE16FF75E05022C0243045A0B55A43403DED7080B25022C0D481C607D05A43400080039D225022C011F6ACE1B15A4340733748C1D34E22C007001AFDD05A43400180035DAF4E22C0183DFD7DAD5A434046D02C371B4E22C0A6819298A65A4340', 0, 1, 1, 1, 0, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000014000000737BE502344622C03F94AC481B5B4340A3D9BFEB9A4522C0571B7AC0185B4340C062F032D74522C0A346964BBB5A4340C6ED92A91F4522C07E050ECEBD5A4340830554C2114522C0948089D3B25A4340E455A913FB4422C08B43E7F3B25A4340D5CB4FADEA4422C094E1A631AD5A43407055BA7E784422C08FC6F8EA8F5A4340A517E1A79A4322C0CB228AD38A5A434018C775B9414322C04CD96785A95A4340CDF32157CC4222C0D46436CEA15A43407F7C0DA1CB4222C01EFC7EF3A15A4340172993B2034322C054448734695A43409FE57970774622C034BA83D8995A43407C21BD4C2C4722C0D11F0F09E75A43409FE57970774622C0F4E0EEACDD5A43401380573D4F4622C01E36D867025B434081B58A024B4622C0DA737279025B4340D4EF8FAE4A4622C0C580EB91065B4340737BE502344622C03F94AC481B5B4340', 0, 1, 1, 0, 0, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000A000000D31F5300404222C043FFE0B29D5B43407619F456AF4222C0C88D3C65A15B434013B383DC534322C07FE4C01CCE5B434001800EFA034322C03A04F19A2B5C434001800EFA8D4022C09AE9E045115C43406EA3D47FB24022C0C9C9E872FC5B4340363CBD52964122C0800EF3E5055C4340B41AC232034122C0F7A5589DE25B434001809B28B34122C00DC32A9CDB5B4340D31F5300404222C043FFE0B29D5B4340', 0, 1, 1, 0, 1, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000C0000000080035D424322C01BF27E1C835C43400180031D674022C0E7D248D6525C43408F368E588B3F22C0E4310395F15B43403D13EF088C3F22C0223A777EF15B434001809BE88B3F22C0977BDA8DF15B4340B8911D329C3F22C0CBCCDFE7F05B43406EA3D47FB24022C0C9C9E872FC5B434001800EFA8D4022C09AE9E045115C43408BB7E465D94122C018701E201F5C43400180039D3F4222C024A7D1AB455C43401DC2ABDD2D4322C0945423F74E5C43400080035D424322C01BF27E1C835C4340', 0, 1, 0, 0, 1, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000006000000016861FC8D4022C0817EF0B4765B434001805C918C3E22C0B3DA91BE3B5B43402604928C443F22C04B4D1841DC5A4340216C09997B4122C0BACD1BF6245B4340FEB7921D1B4122C057091687335B4340016861FC8D4022C0817EF0B4765B4340', 1, 0, 1, 0, 0, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E610000001000000060000009526C7C7594C22C056E854AFE55A4340018019D7E64A22C0F161503D305B4340D4D4B2B5BE4822C0D09B8A54185B434040C4CB8CCC4822C091F774D3CA5A434091621B9C594C22C052EFC39BE55A43409526C7C7594C22C056E854AFE55A4340', 0, 1, 0, 1, 1, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000008000000807C9C148D3E22C06492A4CD3B5B434058D2DB27953E22C01911ED1B6B5B434088146176D23D22C0FA42EBA3815B43400180C405A33C22C07700838B3B5B43400FA652C1D33E22C081FD1849EC5A43405DE1E41EF13E22C03EFD2C8E075B434001805C918C3E22C0B3DA91BE3B5B4340807C9C148D3E22C06492A4CD3B5B4340', 0, 1, 1, 0, 0, 0, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E610000001000000060000003B1E89778E3F22C08FE41956F05B43400180031D4B3E22C0823DB9ECE25B4340157CFC45D23D22C022F484A9815B43400180039DE83E22C021E76773615B434017D88B821E4022C0E9243BC5AB5B43403B1E89778E3F22C08FE41956F05B4340', 0, 1, 1, 1, 0, 1, 1);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000200000009000000061357A8E74E22C09C40DCD8195B43400080039D144F22C0D9A16C40105B4340F3C05FD9D64E22C0C1C8B501D45A4340938B31B08E5322C098F90E7EE25A4340A61AE004104F22C0C54D050DD25B43400180039D414F22C0FC821A42AE5B4340B9C41685BC4E22C00E5AD637AC5B43400180039DF54F22C0FA03FCE44F5B4340061357A8E74E22C09C40DCD8195B434004000000008015B4AB5222C0A7A9360DF55A4340B6B755B9F04F22C0297987C3F75A4340018015B4625022C07A4403AB3F5B4340008015B4AB5222C0A7A9360DF55A4340', 0, 1, 1, 1, 0, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E61000000100000008000000359F822EA34C22C0868D1E3FCD5A4340F3C05FD9D64E22C0C1C8B501D45A43400080039D144F22C0D9A16C40105B4340061357A8E74E22C09C40DCD8195B43400080031D4A4E22C0C691324EFA5A4340FF6E1E36134D22C0C726E7C3385B4340EA5BE674594C22C049F4328AE55A4340359F822EA34C22C0868D1E3FCD5A4340', 0, 1, 1, 1, 0, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E6100000010000000B000000376870913D4D22C0019AF73E7C5B43409C81CC93C84C22C0A05B56C2475B4340FF6E1E36134D22C0C726E7C3385B4340B8C125A07B4D22C05394008C675B4340061357A8E74E22C09C40DCD8195B43400180039DF54F22C0FA03FCE44F5B4340B9C41685BC4E22C00E5AD637AC5B434097AA7DFAB44E22C068933E1AAC5B4340E7A90EB9194E22C0CF66D5E76A5B4340C8D01C17464D22C03AB2C9CD7D5B4340376870913D4D22C0019AF73E7C5B4340', 0, 1, 1, 1, 0, 0, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E610000001000000050000000180039DF54F22C0FA03FCE44F5B434029F1EC648E4E22C05107C7D1B95B434048BE3886774C22C08D61E60A585B43400080031D4A4E22C0C691324EFA5A43400180039DF54F22C0FA03FCE44F5B4340', 1, 0, 0, 0, 1, 1, 0);
INSERT INTO public.parts_singlefeat (geom, cat1, cat2, a_nat, a_ope, a_ord, a_upk, a_his) VALUES ('0103000020E610000001000000070000007DCDA91C934622C0FC4E77044B5C4340A1B1AED9334522C0E1B8F9CD325C4340F6622827DA4522C01D3D7E6FD35B4340E0297673924822C072B1D6A4E95B43400080035D994622C0DA0735D7035C43402993C5236C4722C018F00BB3385C43407DCDA91C934622C0FC4E77044B5C4340', 1, 0, 0, 1, 0, 0, 0);


--
-- TOC entry 3548 (class 0 OID 21536)
-- Dependencies: 187
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3689 (class 0 OID 26828)
-- Dependencies: 211
-- Data for Name: tbl_foo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tbl_foo (id, geom, att_category, att_value) VALUES (1, '0106000020E6100000010000000103000000010000000400000000000000000000000000000000001840000000000000000000000000000028400000000000002040000000000000224000000000000000000000000000001840', 'cat1', 2);
INSERT INTO public.tbl_foo (id, geom, att_category, att_value) VALUES (2, '0106000020E610000001000000010300000001000000050000000000000000001440000000000000000000000000000014400000000000002840000000000000224000000000000028400000000000002240000000000000000000000000000014400000000000000000', 'cat1', 1);
INSERT INTO public.tbl_foo (id, geom, att_category, att_value) VALUES (3, '0106000020E610000001000000010300000001000000080000000000000000001040000000000000104000000000000008400000000000002040000000000000104000000000000028400000000000001C400000000000002C4000000000000024400000000000002840000000000000264000000000000020400000000000002440000000000000104000000000000010400000000000001040', 'cat2', 5);


--
-- TOC entry 3688 (class 0 OID 26819)
-- Dependencies: 210
-- Data for Name: tbl_foo_1; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tbl_foo_1 (id, geom, att_category, att_value) VALUES (1, '0106000020E6100000010000000103000000010000000400000000000000000000000000000000001840000000000000000000000000000028400000000000002040000000000000224000000000000000000000000000001840', 'cat1', 2);
INSERT INTO public.tbl_foo_1 (id, geom, att_category, att_value) VALUES (2, '0106000020E610000001000000010300000001000000050000000000000000001440000000000000000000000000000014400000000000002840000000000000224000000000000028400000000000002240000000000000000000000000000014400000000000000000', 'cat1', 1);
INSERT INTO public.tbl_foo_1 (id, geom, att_category, att_value) VALUES (3, '0106000020E610000001000000010300000001000000080000000000000000001040000000000000104000000000000008400000000000002040000000000000104000000000000028400000000000001C400000000000002C4000000000000024400000000000002840000000000000264000000000000020400000000000002440000000000000104000000000000010400000000000001040', 'cat2', 5);
INSERT INTO public.tbl_foo_1 (id, geom, att_category, att_value) VALUES (4, '0106000020E61000000100000001030000000100000005000000203324553E35FE3F1F14BAB3AC262940EC68E58187B01A4090115F55F7681340B0BF092E40F514409D182562196F2B40B0BF092E40F514409D182562196F2B40203324553E35FE3F1F14BAB3AC262940', 'cat1', 3);
INSERT INTO public.tbl_foo_1 (id, geom, att_category, att_value) VALUES (5, '0106000020E61000000100000001030000000100000004000000D4F41F0E09A92B40611E7388F04525406493743FA7812040E87DBBDDDCB2144086B0330153D723409025FC5AB770FD3FD4F41F0E09A92B40611E7388F0452540', 'cat2', 2);
INSERT INTO public.tbl_foo_1 (id, geom, att_category, att_value) VALUES (6, '0106000020E610000001000000010300000001000000040000002CFC326588550EC05917A68EE1772440EB92A3E15D2F21C01C5DACD9B03A0740E068C0BF59BCD7BF6801709FFC4CF93F2CFC326588550EC05917A68EE1772440', 'cat1', 2);


--
-- TOC entry 3690 (class 0 OID 26834)
-- Dependencies: 212
-- Data for Name: tbl_foo_2; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tbl_foo_2 (id, geom, att_category, att_value) VALUES (1, '0106000020E6100000010000000103000000010000000400000000000000000000000000000000001840000000000000000000000000000028400000000000002040000000000000224000000000000000000000000000001840', 'cat1', 2);
INSERT INTO public.tbl_foo_2 (id, geom, att_category, att_value) VALUES (2, '0106000020E610000001000000010300000001000000050000000000000000001440000000000000000000000000000014400000000000002840000000000000224000000000000028400000000000002240000000000000000000000000000014400000000000000000', 'cat1', 1);
INSERT INTO public.tbl_foo_2 (id, geom, att_category, att_value) VALUES (3, '0106000020E610000001000000010300000001000000080000000000000000001040000000000000104000000000000008400000000000002040000000000000104000000000000028400000000000001C400000000000002C4000000000000024400000000000002840000000000000264000000000000020400000000000002440000000000000104000000000000010400000000000001040', 'cat2', 5);
INSERT INTO public.tbl_foo_2 (id, geom, att_category, att_value) VALUES (6, '0106000020E610000001000000010300000001000000040000002CFC326588550EC05917A68EE1772440EB92A3E15D2F21C01C5DACD9B03A0740E068C0BF59BCD7BF6801709FFC4CF93F2CFC326588550EC05917A68EE1772440', 'cat1', 2);


--
-- TOC entry 3694 (class 0 OID 27049)
-- Dependencies: 216
-- Data for Name: tblfoo_allsingle_feat; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3693 (class 0 OID 27043)
-- Dependencies: 215
-- Data for Name: tblfoo_result; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (2, 1, 0, '0103000020E6100000010000000600000000000000000000000000000000001840000000000000000000000000000028401DD4411DD4410D401DD4411DD4412540000000000000084000000000000020409A99999999990940CDCCCCCCCCCC1C4000000000000000000000000000001840');
INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (2, 1, 0, '0103000020E610000001000000060000001DD4411DD4410D401DD4411DD44125400000000000001440000000000040244000000000000014400000000000801F409A99999999990940CDCCCCCCCCCC1C40000000000000084000000000000020401DD4411DD4410D401DD4411DD4412540');
INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (2, 1, 0, '0103000020E61000000100000004000000000000000000144000000000004024400000000000002040000000000000224000000000000014400000000000801F4000000000000014400000000000402440');
INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (1, 1, 0, '0103000020E610000001000000050000000000000000001440000000000000000000000000000014400000000000001040000000000000224000000000000010400000000000002240000000000000000000000000000014400000000000000000');
INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (1, 1, 0, '0103000020E610000001000000080000000000000000001440000000000000104000000000000014400000000000801F40000000000000204000000000000022400000000000001440000000000040244000000000000014400000000000002840000000000000224000000000000028400000000000002240000000000000104000000000000014400000000000001040');
INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (1, 1, 0, '0103000020E6100000010000000400000000000000000014400000000000801F40000000000000144000000000004024400000000000002040000000000000224000000000000014400000000000801F40');
INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (5, 0, 1, '0106000020E61000000200000001030000000100000005000000000000000000104000000000000010409A99999999990940CDCCCCCCCCCC1C4000000000000014400000000000801F4000000000000014400000000000001040000000000000104000000000000010400103000000010000000B000000000000000000144000000000004024401DD4411DD4410D401DD4411DD4412540000000000000104000000000000028400000000000001C400000000000002C4000000000000024400000000000002840000000000000264000000000000020400000000000002440000000000000104000000000000022400000000000001040000000000000224000000000000028400000000000001440000000000000284000000000000014400000000000402440');
INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (5, 0, 1, '0103000020E610000001000000060000009A99999999990940CDCCCCCCCCCC1C40000000000000084000000000000020401DD4411DD4410D401DD4411DD44125400000000000001440000000000040244000000000000014400000000000801F409A99999999990940CDCCCCCCCCCC1C40');
INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (5, 0, 1, '0103000020E6100000010000000800000000000000000014400000000000801F4000000000000020400000000000002240000000000000144000000000004024400000000000001440000000000000284000000000000022400000000000002840000000000000224000000000000010400000000000001440000000000000104000000000000014400000000000801F40');
INSERT INTO public.tblfoo_result (val, cat1, cat2, geom) VALUES (5, 0, 1, '0103000020E61000000100000004000000000000000000144000000000004024400000000000002040000000000000224000000000000014400000000000801F4000000000000014400000000000402440');


--
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 202
-- Name: eimglx_areas_demo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.eimglx_areas_demo_id_seq', 89, true);


--
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 203
-- Name: layer_styles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.layer_styles_id_seq', 5, true);


--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 208
-- Name: public_test_adduniqueid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.public_test_adduniqueid_seq', 3, true);


--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 209
-- Name: public_test_geotablesummary_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.public_test_geotablesummary_seq', 12, true);


--
-- TOC entry 3554 (class 2606 OID 22765)
-- Name: eimglx_areas_demo eimglx_areas_demo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eimglx_areas_demo
    ADD CONSTRAINT eimglx_areas_demo_pkey PRIMARY KEY (id);


--
-- TOC entry 3557 (class 2606 OID 24893)
-- Name: layer_styles layer_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.layer_styles
    ADD CONSTRAINT layer_styles_pkey PRIMARY KEY (id);


--
-- TOC entry 3555 (class 1259 OID 22769)
-- Name: sidx_eimglx_areas_demo_geom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sidx_eimglx_areas_demo_geom ON public.eimglx_areas_demo USING gist (geom);


-- Completed on 2018-11-13 19:45:45

--
-- PostgreSQL database dump complete
--

