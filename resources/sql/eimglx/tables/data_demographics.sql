--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 10.5

-- Started on 2018-12-17 13:41:23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

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
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 213
-- Name: data_demographics_seq_id; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_demographics_seq_id OWNED BY public.data_demographics.table_id;


--
-- TOC entry 3512 (class 2604 OID 34913)
-- Name: data_demographics table_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_demographics ALTER COLUMN table_id SET DEFAULT nextval('public.data_demographics_seq_id'::regclass);


--
-- TOC entry 3639 (class 0 OID 34899)
-- Dependencies: 212
-- Data for Name: data_demographics; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 213
-- Name: data_demographics_seq_id; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.data_demographics_seq_id', 31, true);


--
-- TOC entry 3514 (class 2606 OID 34906)
-- Name: data_demographics data_demographics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_demographics
    ADD CONSTRAINT data_demographics_pkey PRIMARY KEY (table_id);


-- Completed on 2018-12-17 13:41:24

--
-- PostgreSQL database dump complete
--

