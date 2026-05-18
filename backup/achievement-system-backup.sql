--
-- PostgreSQL database dump
--

-- Dumped from database version 14.22
-- Dumped by pg_dump version 14.18 (Homebrew)

-- Started on 2026-05-18 00:16:01 PDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 9 (class 2615 OID 148515)
-- Name: achievement_system; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA {{SCHEMA}};


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 767 (class 1259 OID 148516)
-- Name: as_achievement_change_logs; Type: TABLE; Schema: achievement_system; Owner: -
--

CREATE TABLE {{SCHEMA}}.as_achievement_change_logs (
    id bigint NOT NULL,
    event_log_id bigint NOT NULL,
    achievement_id bigint NOT NULL,
    user_achievement_id bigint NOT NULL,
    event_name character varying(255) NOT NULL,
    userid character varying(255) NOT NULL,
    username character varying(255),
    points_added integer NOT NULL,
    progress_before integer NOT NULL,
    progress_after integer NOT NULL,
    achieved_before boolean NOT NULL,
    achieved_after boolean NOT NULL,
    achieved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 768 (class 1259 OID 148522)
-- Name: as_achievement_change_logs_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_achievement_change_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 768
-- Name: as_achievement_change_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_achievement_change_logs_id_seq OWNED BY {{SCHEMA}}.as_achievement_change_logs.id;


--
-- TOC entry 769 (class 1259 OID 148523)
-- Name: as_achievement_translations; Type: TABLE; Schema: achievement_system; Owner: -
--

CREATE TABLE {{SCHEMA}}.as_achievement_translations (
    id bigint NOT NULL,
    achievement_id bigint NOT NULL,
    locale character varying(50) DEFAULT 'en'::character varying NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 770 (class 1259 OID 148531)
-- Name: as_achievement_translations_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_achievement_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 770
-- Name: as_achievement_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_achievement_translations_id_seq OWNED BY {{SCHEMA}}.as_achievement_translations.id;


--
-- TOC entry 771 (class 1259 OID 148532)
-- Name: as_achievements; Type: TABLE; Schema: achievement_system; Owner: -
--

CREATE TABLE {{SCHEMA}}.as_achievements (
    id bigint NOT NULL,
    code character varying(255) NOT NULL,
    event_name character varying(255) NOT NULL,
    icon_name character varying(255),
    points integer DEFAULT 1 NOT NULL,
    goal integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 772 (class 1259 OID 148540)
-- Name: as_achievements_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 772
-- Name: as_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_achievements_id_seq OWNED BY {{SCHEMA}}.as_achievements.id;


--
-- TOC entry 773 (class 1259 OID 148541)
-- Name: as_event_lists; Type: TABLE; Schema: achievement_system; Owner: -
--

CREATE TABLE {{SCHEMA}}.as_event_lists (
    id bigint NOT NULL,
    event_name character varying(255) NOT NULL,
    points integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 774 (class 1259 OID 148547)
-- Name: as_event_lists_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_event_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 774
-- Name: as_event_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_event_lists_id_seq OWNED BY {{SCHEMA}}.as_event_lists.id;


--
-- TOC entry 775 (class 1259 OID 148548)
-- Name: as_event_logs; Type: TABLE; Schema: achievement_system; Owner: -
--

CREATE TABLE {{SCHEMA}}.as_event_logs (
    id bigint NOT NULL,
    event_name character varying(255) NOT NULL,
    userid character varying(255),
    username character varying(255),
    payload_json jsonb NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    status text DEFAULT 'handled'::text NOT NULL,
    handle_result jsonb,
    handled_at timestamp with time zone,
    CONSTRAINT as_event_logs_status_check CHECK ((status = ANY (ARRAY['processing'::text, 'handled'::text, 'failed'::text, 'ignored'::text])))
);


--
-- TOC entry 776 (class 1259 OID 148554)
-- Name: as_event_logs_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_event_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5131 (class 0 OID 0)
-- Dependencies: 776
-- Name: as_event_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_event_logs_id_seq OWNED BY {{SCHEMA}}.as_event_logs.id;


--
-- TOC entry 777 (class 1259 OID 148555)
-- Name: as_user_achievements; Type: TABLE; Schema: achievement_system; Owner: -
--

CREATE TABLE {{SCHEMA}}.as_user_achievements (
    id bigint NOT NULL,
    userid character varying(255) NOT NULL,
    username character varying(255),
    achievement_id bigint NOT NULL,
    progress integer DEFAULT 0 NOT NULL,
    achieved boolean DEFAULT false NOT NULL,
    achieved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 778 (class 1259 OID 148564)
-- Name: as_user_achievements_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_user_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 778
-- Name: as_user_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_user_achievements_id_seq OWNED BY {{SCHEMA}}.as_user_achievements.id;


--
-- TOC entry 4914 (class 2604 OID 148565)
-- Name: as_achievement_change_logs id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_achievement_change_logs_id_seq'::regclass);


--
-- TOC entry 4918 (class 2604 OID 148566)
-- Name: as_achievement_translations id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_translations ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_achievement_translations_id_seq'::regclass);


--
-- TOC entry 4922 (class 2604 OID 148567)
-- Name: as_achievements id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievements ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_achievements_id_seq'::regclass);


--
-- TOC entry 4926 (class 2604 OID 148568)
-- Name: as_event_lists id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_event_lists ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_event_lists_id_seq'::regclass);


--
-- TOC entry 4929 (class 2604 OID 148569)
-- Name: as_event_logs id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_event_logs ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_event_logs_id_seq'::regclass);


--
-- TOC entry 4935 (class 2604 OID 148570)
-- Name: as_user_achievements id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_user_achievements ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_user_achievements_id_seq'::regclass);


--
-- TOC entry 5110 (class 0 OID 148516)
-- Dependencies: 767
-- Data for Name: as_achievement_change_logs; Type: TABLE DATA; Schema: achievement_system; Owner: -
--

COPY {{SCHEMA}}.as_achievement_change_logs (id, event_log_id, achievement_id, user_achievement_id, event_name, userid, username, points_added, progress_before, progress_after, achieved_before, achieved_after, achieved_at, created_at) FROM stdin;
1	1	13	39	flashcard.reviewed	8	vivian	1	844	845	f	f	\N	2026-05-11 06:24:03.117857+00
2	1	14	40	flashcard.reviewed	8	vivian	1	844	845	f	f	\N	2026-05-11 06:24:03.117857+00
3	1	15	41	flashcard.reviewed	8	vivian	1	844	845	f	f	\N	2026-05-11 06:24:03.117857+00
4	1	16	42	flashcard.reviewed	8	vivian	1	844	845	f	f	\N	2026-05-11 06:24:03.117857+00
5	2	13	39	flashcard.reviewed	8	vivian	1	845	846	f	f	\N	2026-05-11 06:25:01.327114+00
6	2	14	40	flashcard.reviewed	8	vivian	1	845	846	f	f	\N	2026-05-11 06:25:01.327114+00
7	2	15	41	flashcard.reviewed	8	vivian	1	845	846	f	f	\N	2026-05-11 06:25:01.327114+00
8	2	16	42	flashcard.reviewed	8	vivian	1	845	846	f	f	\N	2026-05-11 06:25:01.327114+00
9	3	13	39	flashcard.reviewed	8	vivian	1	846	847	f	f	\N	2026-05-11 06:34:00.414913+00
10	3	14	40	flashcard.reviewed	8	vivian	1	846	847	f	f	\N	2026-05-11 06:34:00.414913+00
11	3	15	41	flashcard.reviewed	8	vivian	1	846	847	f	f	\N	2026-05-11 06:34:00.414913+00
12	3	16	42	flashcard.reviewed	8	vivian	1	846	847	f	f	\N	2026-05-11 06:34:00.414913+00
13	7	3	29	flashcard.created	8	vivian	1	93	94	f	f	\N	2026-05-17 17:16:20.383732+00
14	7	4	30	flashcard.created	8	vivian	1	93	94	f	f	\N	2026-05-17 17:16:20.383732+00
15	7	5	31	flashcard.created	8	vivian	1	93	94	f	f	\N	2026-05-17 17:16:20.383732+00
16	7	6	32	flashcard.created	8	vivian	1	93	94	f	f	\N	2026-05-17 17:16:20.383732+00
17	7	7	33	flashcard.created	8	vivian	1	93	94	f	f	\N	2026-05-17 17:16:20.383732+00
18	7	8	34	flashcard.created	8	vivian	1	93	94	f	f	\N	2026-05-17 17:16:20.383732+00
19	7	9	35	flashcard.created	8	vivian	1	93	94	f	f	\N	2026-05-17 17:16:20.383732+00
20	8	3	29	flashcard.created	8	vivian	1	94	95	f	f	\N	2026-05-17 17:26:46.693062+00
21	8	4	30	flashcard.created	8	vivian	1	94	95	f	f	\N	2026-05-17 17:26:46.693062+00
22	8	5	31	flashcard.created	8	vivian	1	94	95	f	f	\N	2026-05-17 17:26:46.693062+00
23	8	6	32	flashcard.created	8	vivian	1	94	95	f	f	\N	2026-05-17 17:26:46.693062+00
24	8	7	33	flashcard.created	8	vivian	1	94	95	f	f	\N	2026-05-17 17:26:46.693062+00
25	8	8	34	flashcard.created	8	vivian	1	94	95	f	f	\N	2026-05-17 17:26:46.693062+00
26	8	9	35	flashcard.created	8	vivian	1	94	95	f	f	\N	2026-05-17 17:26:46.693062+00
27	9	3	29	flashcard.created	8	vivian	1	95	96	f	f	\N	2026-05-17 17:27:30.09534+00
28	9	4	30	flashcard.created	8	vivian	1	95	96	f	f	\N	2026-05-17 17:27:30.09534+00
29	9	5	31	flashcard.created	8	vivian	1	95	96	f	f	\N	2026-05-17 17:27:30.09534+00
30	9	6	32	flashcard.created	8	vivian	1	95	96	f	f	\N	2026-05-17 17:27:30.09534+00
31	9	7	33	flashcard.created	8	vivian	1	95	96	f	f	\N	2026-05-17 17:27:30.09534+00
32	9	8	34	flashcard.created	8	vivian	1	95	96	f	f	\N	2026-05-17 17:27:30.09534+00
33	9	9	35	flashcard.created	8	vivian	1	95	96	f	f	\N	2026-05-17 17:27:30.09534+00
34	10	3	29	flashcard.created	8	vivian	1	96	97	f	f	\N	2026-05-17 17:29:00.937576+00
35	10	4	30	flashcard.created	8	vivian	1	96	97	f	f	\N	2026-05-17 17:29:00.937576+00
36	10	5	31	flashcard.created	8	vivian	1	96	97	f	f	\N	2026-05-17 17:29:00.937576+00
37	10	6	32	flashcard.created	8	vivian	1	96	97	f	f	\N	2026-05-17 17:29:00.937576+00
38	10	7	33	flashcard.created	8	vivian	1	96	97	f	f	\N	2026-05-17 17:29:00.937576+00
39	10	8	34	flashcard.created	8	vivian	1	96	97	f	f	\N	2026-05-17 17:29:00.937576+00
40	10	9	35	flashcard.created	8	vivian	1	96	97	f	f	\N	2026-05-17 17:29:00.937576+00
41	12	2	2	flashcard.created	60	chinese2	1	11	12	f	f	\N	2026-05-17 17:33:06.603957+00
42	12	3	3	flashcard.created	60	chinese2	1	11	12	f	f	\N	2026-05-17 17:33:06.603957+00
43	12	4	4	flashcard.created	60	chinese2	1	11	12	f	f	\N	2026-05-17 17:33:06.603957+00
44	12	5	5	flashcard.created	60	chinese2	1	11	12	f	f	\N	2026-05-17 17:33:06.603957+00
45	12	6	6	flashcard.created	60	chinese2	1	11	12	f	f	\N	2026-05-17 17:33:06.603957+00
46	12	7	7	flashcard.created	60	chinese2	1	11	12	f	f	\N	2026-05-17 17:33:06.603957+00
47	12	8	8	flashcard.created	60	chinese2	1	11	12	f	f	\N	2026-05-17 17:33:06.603957+00
48	12	9	9	flashcard.created	60	chinese2	1	11	12	f	f	\N	2026-05-17 17:33:06.603957+00
49	13	11	11	flashcard.reviewed	60	chinese2	1	184	185	f	f	\N	2026-05-17 17:33:34.34884+00
50	13	12	12	flashcard.reviewed	60	chinese2	1	184	185	f	f	\N	2026-05-17 17:33:34.34884+00
51	13	13	13	flashcard.reviewed	60	chinese2	1	184	185	f	f	\N	2026-05-17 17:33:34.34884+00
52	13	14	14	flashcard.reviewed	60	chinese2	1	184	185	f	f	\N	2026-05-17 17:33:34.34884+00
53	13	15	15	flashcard.reviewed	60	chinese2	1	184	185	f	f	\N	2026-05-17 17:33:34.34884+00
54	13	16	16	flashcard.reviewed	60	chinese2	1	184	185	f	f	\N	2026-05-17 17:33:34.34884+00
55	14	3	29	flashcard.created	8	vivian	1	97	98	f	f	\N	2026-05-17 17:52:53.168298+00
56	14	4	30	flashcard.created	8	vivian	1	97	98	f	f	\N	2026-05-17 17:52:53.168298+00
57	14	5	31	flashcard.created	8	vivian	1	97	98	f	f	\N	2026-05-17 17:52:53.168298+00
58	14	6	32	flashcard.created	8	vivian	1	97	98	f	f	\N	2026-05-17 17:52:53.168298+00
59	14	7	33	flashcard.created	8	vivian	1	97	98	f	f	\N	2026-05-17 17:52:53.168298+00
60	14	8	34	flashcard.created	8	vivian	1	97	98	f	f	\N	2026-05-17 17:52:53.168298+00
61	14	9	35	flashcard.created	8	vivian	1	97	98	f	f	\N	2026-05-17 17:52:53.168298+00
62	15	13	39	flashcard.reviewed	8	vivian	1	847	848	f	f	\N	2026-05-17 17:52:58.174726+00
63	15	14	40	flashcard.reviewed	8	vivian	1	847	848	f	f	\N	2026-05-17 17:52:58.174726+00
64	15	15	41	flashcard.reviewed	8	vivian	1	847	848	f	f	\N	2026-05-17 17:52:58.174726+00
65	15	16	42	flashcard.reviewed	8	vivian	1	847	848	f	f	\N	2026-05-17 17:52:58.174726+00
66	16	13	39	flashcard.reviewed	8	vivian	1	848	849	f	f	\N	2026-05-17 17:52:58.83259+00
67	16	14	40	flashcard.reviewed	8	vivian	1	848	849	f	f	\N	2026-05-17 17:52:58.83259+00
68	16	15	41	flashcard.reviewed	8	vivian	1	848	849	f	f	\N	2026-05-17 17:52:58.83259+00
69	16	16	42	flashcard.reviewed	8	vivian	1	848	849	f	f	\N	2026-05-17 17:52:58.83259+00
70	17	13	39	flashcard.reviewed	8	vivian	1	849	850	f	f	\N	2026-05-17 17:52:59.628696+00
71	17	14	40	flashcard.reviewed	8	vivian	1	849	850	f	f	\N	2026-05-17 17:52:59.628696+00
72	17	15	41	flashcard.reviewed	8	vivian	1	849	850	f	f	\N	2026-05-17 17:52:59.628696+00
73	17	16	42	flashcard.reviewed	8	vivian	1	849	850	f	f	\N	2026-05-17 17:52:59.628696+00
1393	220	11	63	flashcard.reviewed	58	manual	1	170	171	f	f	\N	2026-05-18 06:08:32.512339+00
1394	220	12	64	flashcard.reviewed	58	manual	1	170	171	f	f	\N	2026-05-18 06:08:32.512339+00
1395	220	13	65	flashcard.reviewed	58	manual	1	170	171	f	f	\N	2026-05-18 06:08:32.512339+00
1396	220	14	66	flashcard.reviewed	58	manual	1	170	171	f	f	\N	2026-05-18 06:08:32.512339+00
1397	220	15	67	flashcard.reviewed	58	manual	1	170	171	f	f	\N	2026-05-18 06:08:32.512339+00
1398	220	16	68	flashcard.reviewed	58	manual	1	170	171	f	f	\N	2026-05-18 06:08:32.512339+00
1405	222	11	63	flashcard.reviewed	58	module-test	1	172	173	f	f	\N	2026-05-18 06:09:05.220753+00
81	21	3	29	flashcard.created	8	vivian	1	98	99	f	f	\N	2026-05-17 18:23:51.614984+00
82	21	4	30	flashcard.created	8	vivian	1	98	99	f	f	\N	2026-05-17 18:23:51.614984+00
83	21	5	31	flashcard.created	8	vivian	1	98	99	f	f	\N	2026-05-17 18:23:51.614984+00
84	21	6	32	flashcard.created	8	vivian	1	98	99	f	f	\N	2026-05-17 18:23:51.614984+00
85	21	7	33	flashcard.created	8	vivian	1	98	99	f	f	\N	2026-05-17 18:23:51.614984+00
86	21	8	34	flashcard.created	8	vivian	1	98	99	f	f	\N	2026-05-17 18:23:51.614984+00
87	21	9	35	flashcard.created	8	vivian	1	98	99	f	f	\N	2026-05-17 18:23:51.614984+00
88	22	3	29	flashcard.created	8	vivian	1	99	100	f	t	2026-05-17 18:24:33.398+00	2026-05-17 18:24:33.38469+00
89	22	4	30	flashcard.created	8	vivian	1	99	100	f	f	\N	2026-05-17 18:24:33.38469+00
90	22	5	31	flashcard.created	8	vivian	1	99	100	f	f	\N	2026-05-17 18:24:33.38469+00
91	22	6	32	flashcard.created	8	vivian	1	99	100	f	f	\N	2026-05-17 18:24:33.38469+00
92	22	7	33	flashcard.created	8	vivian	1	99	100	f	f	\N	2026-05-17 18:24:33.38469+00
93	22	8	34	flashcard.created	8	vivian	1	99	100	f	f	\N	2026-05-17 18:24:33.38469+00
94	22	9	35	flashcard.created	8	vivian	1	99	100	f	f	\N	2026-05-17 18:24:33.38469+00
95	23	11	11	flashcard.reviewed	60	chinese2	1	185	186	f	f	\N	2026-05-17 18:31:24.549668+00
96	23	12	12	flashcard.reviewed	60	chinese2	1	185	186	f	f	\N	2026-05-17 18:31:24.549668+00
97	23	13	13	flashcard.reviewed	60	chinese2	1	185	186	f	f	\N	2026-05-17 18:31:24.549668+00
98	23	14	14	flashcard.reviewed	60	chinese2	1	185	186	f	f	\N	2026-05-17 18:31:24.549668+00
99	23	15	15	flashcard.reviewed	60	chinese2	1	185	186	f	f	\N	2026-05-17 18:31:24.549668+00
100	23	16	16	flashcard.reviewed	60	chinese2	1	185	186	f	f	\N	2026-05-17 18:31:24.549668+00
101	24	4	30	flashcard.created	8	vivian	1	100	101	f	f	\N	2026-05-17 18:35:56.757532+00
102	24	5	31	flashcard.created	8	vivian	1	100	101	f	f	\N	2026-05-17 18:35:56.757532+00
103	24	6	32	flashcard.created	8	vivian	1	100	101	f	f	\N	2026-05-17 18:35:56.757532+00
104	24	7	33	flashcard.created	8	vivian	1	100	101	f	f	\N	2026-05-17 18:35:56.757532+00
105	24	8	34	flashcard.created	8	vivian	1	100	101	f	f	\N	2026-05-17 18:35:56.757532+00
106	24	9	35	flashcard.created	8	vivian	1	100	101	f	f	\N	2026-05-17 18:35:56.757532+00
107	25	4	30	flashcard.created	8	vivian	1	101	102	f	f	\N	2026-05-17 18:37:39.336719+00
108	25	5	31	flashcard.created	8	vivian	1	101	102	f	f	\N	2026-05-17 18:37:39.336719+00
109	25	6	32	flashcard.created	8	vivian	1	101	102	f	f	\N	2026-05-17 18:37:39.336719+00
110	25	7	33	flashcard.created	8	vivian	1	101	102	f	f	\N	2026-05-17 18:37:39.336719+00
111	25	8	34	flashcard.created	8	vivian	1	101	102	f	f	\N	2026-05-17 18:37:39.336719+00
112	25	9	35	flashcard.created	8	vivian	1	101	102	f	f	\N	2026-05-17 18:37:39.336719+00
113	26	4	30	flashcard.created	8	vivian	1	102	103	f	f	\N	2026-05-17 18:40:33.97577+00
114	26	5	31	flashcard.created	8	vivian	1	102	103	f	f	\N	2026-05-17 18:40:33.97577+00
115	26	6	32	flashcard.created	8	vivian	1	102	103	f	f	\N	2026-05-17 18:40:33.97577+00
116	26	7	33	flashcard.created	8	vivian	1	102	103	f	f	\N	2026-05-17 18:40:33.97577+00
117	26	8	34	flashcard.created	8	vivian	1	102	103	f	f	\N	2026-05-17 18:40:33.97577+00
118	26	9	35	flashcard.created	8	vivian	1	102	103	f	f	\N	2026-05-17 18:40:33.97577+00
119	27	4	30	flashcard.created	8	vivian	1	103	104	f	f	\N	2026-05-17 18:41:05.239256+00
120	27	5	31	flashcard.created	8	vivian	1	103	104	f	f	\N	2026-05-17 18:41:05.239256+00
121	27	6	32	flashcard.created	8	vivian	1	103	104	f	f	\N	2026-05-17 18:41:05.239256+00
122	27	7	33	flashcard.created	8	vivian	1	103	104	f	f	\N	2026-05-17 18:41:05.239256+00
123	27	8	34	flashcard.created	8	vivian	1	103	104	f	f	\N	2026-05-17 18:41:05.239256+00
124	27	9	35	flashcard.created	8	vivian	1	103	104	f	f	\N	2026-05-17 18:41:05.239256+00
125	28	4	30	flashcard.created	8	vivian	1	104	105	f	f	\N	2026-05-17 18:43:18.633084+00
126	28	5	31	flashcard.created	8	vivian	1	104	105	f	f	\N	2026-05-17 18:43:18.633084+00
127	28	6	32	flashcard.created	8	vivian	1	104	105	f	f	\N	2026-05-17 18:43:18.633084+00
128	28	7	33	flashcard.created	8	vivian	1	104	105	f	f	\N	2026-05-17 18:43:18.633084+00
129	28	8	34	flashcard.created	8	vivian	1	104	105	f	f	\N	2026-05-17 18:43:18.633084+00
1406	222	12	64	flashcard.reviewed	58	module-test	1	172	173	f	f	\N	2026-05-18 06:09:05.220753+00
130	28	9	35	flashcard.created	8	vivian	1	104	105	f	f	\N	2026-05-17 18:43:18.633084+00
131	29	4	30	flashcard.created	8	vivian	1	105	106	f	f	\N	2026-05-17 18:46:46.28073+00
132	29	5	31	flashcard.created	8	vivian	1	105	106	f	f	\N	2026-05-17 18:46:46.28073+00
133	29	6	32	flashcard.created	8	vivian	1	105	106	f	f	\N	2026-05-17 18:46:46.28073+00
134	29	7	33	flashcard.created	8	vivian	1	105	106	f	f	\N	2026-05-17 18:46:46.28073+00
135	29	8	34	flashcard.created	8	vivian	1	105	106	f	f	\N	2026-05-17 18:46:46.28073+00
136	29	9	35	flashcard.created	8	vivian	1	105	106	f	f	\N	2026-05-17 18:46:46.28073+00
137	30	4	30	flashcard.created	8	vivian	1	106	107	f	f	\N	2026-05-17 18:50:22.293639+00
138	30	5	31	flashcard.created	8	vivian	1	106	107	f	f	\N	2026-05-17 18:50:22.293639+00
139	30	6	32	flashcard.created	8	vivian	1	106	107	f	f	\N	2026-05-17 18:50:22.293639+00
140	30	7	33	flashcard.created	8	vivian	1	106	107	f	f	\N	2026-05-17 18:50:22.293639+00
141	30	8	34	flashcard.created	8	vivian	1	106	107	f	f	\N	2026-05-17 18:50:22.293639+00
142	30	9	35	flashcard.created	8	vivian	1	106	107	f	f	\N	2026-05-17 18:50:22.293639+00
143	31	4	30	flashcard.created	8	vivian	1	107	108	f	f	\N	2026-05-17 18:55:30.330829+00
144	31	5	31	flashcard.created	8	vivian	1	107	108	f	f	\N	2026-05-17 18:55:30.330829+00
145	31	6	32	flashcard.created	8	vivian	1	107	108	f	f	\N	2026-05-17 18:55:30.330829+00
146	31	7	33	flashcard.created	8	vivian	1	107	108	f	f	\N	2026-05-17 18:55:30.330829+00
147	31	8	34	flashcard.created	8	vivian	1	107	108	f	f	\N	2026-05-17 18:55:30.330829+00
148	31	9	35	flashcard.created	8	vivian	1	107	108	f	f	\N	2026-05-17 18:55:30.330829+00
149	32	4	30	flashcard.created	8	vivian	1	108	109	f	f	\N	2026-05-17 18:57:27.244278+00
150	32	5	31	flashcard.created	8	vivian	1	108	109	f	f	\N	2026-05-17 18:57:27.244278+00
151	32	6	32	flashcard.created	8	vivian	1	108	109	f	f	\N	2026-05-17 18:57:27.244278+00
152	32	7	33	flashcard.created	8	vivian	1	108	109	f	f	\N	2026-05-17 18:57:27.244278+00
153	32	8	34	flashcard.created	8	vivian	1	108	109	f	f	\N	2026-05-17 18:57:27.244278+00
154	32	9	35	flashcard.created	8	vivian	1	108	109	f	f	\N	2026-05-17 18:57:27.244278+00
155	33	4	30	flashcard.created	8	vivian	1	109	110	f	f	\N	2026-05-17 18:58:11.208562+00
156	33	5	31	flashcard.created	8	vivian	1	109	110	f	f	\N	2026-05-17 18:58:11.208562+00
157	33	6	32	flashcard.created	8	vivian	1	109	110	f	f	\N	2026-05-17 18:58:11.208562+00
158	33	7	33	flashcard.created	8	vivian	1	109	110	f	f	\N	2026-05-17 18:58:11.208562+00
159	33	8	34	flashcard.created	8	vivian	1	109	110	f	f	\N	2026-05-17 18:58:11.208562+00
160	33	9	35	flashcard.created	8	vivian	1	109	110	f	f	\N	2026-05-17 18:58:11.208562+00
161	34	4	30	flashcard.created	8	vivian	1	110	111	f	f	\N	2026-05-17 18:59:40.273674+00
162	34	5	31	flashcard.created	8	vivian	1	110	111	f	f	\N	2026-05-17 18:59:40.273674+00
163	34	6	32	flashcard.created	8	vivian	1	110	111	f	f	\N	2026-05-17 18:59:40.273674+00
164	34	7	33	flashcard.created	8	vivian	1	110	111	f	f	\N	2026-05-17 18:59:40.273674+00
165	34	8	34	flashcard.created	8	vivian	1	110	111	f	f	\N	2026-05-17 18:59:40.273674+00
166	34	9	35	flashcard.created	8	vivian	1	110	111	f	f	\N	2026-05-17 18:59:40.273674+00
167	35	4	30	flashcard.created	8	vivian	1	111	112	f	f	\N	2026-05-17 19:00:41.03164+00
168	35	5	31	flashcard.created	8	vivian	1	111	112	f	f	\N	2026-05-17 19:00:41.03164+00
169	35	6	32	flashcard.created	8	vivian	1	111	112	f	f	\N	2026-05-17 19:00:41.03164+00
170	35	7	33	flashcard.created	8	vivian	1	111	112	f	f	\N	2026-05-17 19:00:41.03164+00
171	35	8	34	flashcard.created	8	vivian	1	111	112	f	f	\N	2026-05-17 19:00:41.03164+00
172	35	9	35	flashcard.created	8	vivian	1	111	112	f	f	\N	2026-05-17 19:00:41.03164+00
173	36	4	30	flashcard.created	8	vivian	1	112	113	f	f	\N	2026-05-17 19:01:14.97465+00
174	36	5	31	flashcard.created	8	vivian	1	112	113	f	f	\N	2026-05-17 19:01:14.97465+00
175	36	6	32	flashcard.created	8	vivian	1	112	113	f	f	\N	2026-05-17 19:01:14.97465+00
176	36	7	33	flashcard.created	8	vivian	1	112	113	f	f	\N	2026-05-17 19:01:14.97465+00
177	36	8	34	flashcard.created	8	vivian	1	112	113	f	f	\N	2026-05-17 19:01:14.97465+00
178	36	9	35	flashcard.created	8	vivian	1	112	113	f	f	\N	2026-05-17 19:01:14.97465+00
179	37	4	30	flashcard.created	8	vivian	1	113	114	f	f	\N	2026-05-17 19:04:15.790256+00
180	37	5	31	flashcard.created	8	vivian	1	113	114	f	f	\N	2026-05-17 19:04:15.790256+00
181	37	6	32	flashcard.created	8	vivian	1	113	114	f	f	\N	2026-05-17 19:04:15.790256+00
182	37	7	33	flashcard.created	8	vivian	1	113	114	f	f	\N	2026-05-17 19:04:15.790256+00
183	37	8	34	flashcard.created	8	vivian	1	113	114	f	f	\N	2026-05-17 19:04:15.790256+00
184	37	9	35	flashcard.created	8	vivian	1	113	114	f	f	\N	2026-05-17 19:04:15.790256+00
185	38	4	30	flashcard.created	8	vivian	1	114	115	f	f	\N	2026-05-17 19:04:29.189246+00
186	38	5	31	flashcard.created	8	vivian	1	114	115	f	f	\N	2026-05-17 19:04:29.189246+00
187	38	6	32	flashcard.created	8	vivian	1	114	115	f	f	\N	2026-05-17 19:04:29.189246+00
188	38	7	33	flashcard.created	8	vivian	1	114	115	f	f	\N	2026-05-17 19:04:29.189246+00
189	38	8	34	flashcard.created	8	vivian	1	114	115	f	f	\N	2026-05-17 19:04:29.189246+00
190	38	9	35	flashcard.created	8	vivian	1	114	115	f	f	\N	2026-05-17 19:04:29.189246+00
191	39	4	30	flashcard.created	8	vivian	1	115	116	f	f	\N	2026-05-17 19:05:27.616279+00
192	39	5	31	flashcard.created	8	vivian	1	115	116	f	f	\N	2026-05-17 19:05:27.616279+00
193	39	6	32	flashcard.created	8	vivian	1	115	116	f	f	\N	2026-05-17 19:05:27.616279+00
194	39	7	33	flashcard.created	8	vivian	1	115	116	f	f	\N	2026-05-17 19:05:27.616279+00
195	39	8	34	flashcard.created	8	vivian	1	115	116	f	f	\N	2026-05-17 19:05:27.616279+00
196	39	9	35	flashcard.created	8	vivian	1	115	116	f	f	\N	2026-05-17 19:05:27.616279+00
197	40	2	54	flashcard.created	58	aug13	1	14	15	f	f	\N	2026-05-17 19:21:49.635602+00
198	40	3	55	flashcard.created	58	aug13	1	14	15	f	f	\N	2026-05-17 19:21:49.635602+00
199	40	4	56	flashcard.created	58	aug13	1	14	15	f	f	\N	2026-05-17 19:21:49.635602+00
200	40	5	57	flashcard.created	58	aug13	1	14	15	f	f	\N	2026-05-17 19:21:49.635602+00
201	40	6	58	flashcard.created	58	aug13	1	14	15	f	f	\N	2026-05-17 19:21:49.635602+00
202	40	7	59	flashcard.created	58	aug13	1	14	15	f	f	\N	2026-05-17 19:21:49.635602+00
203	40	8	60	flashcard.created	58	aug13	1	14	15	f	f	\N	2026-05-17 19:21:49.635602+00
204	40	9	61	flashcard.created	58	aug13	1	14	15	f	f	\N	2026-05-17 19:21:49.635602+00
205	41	2	54	flashcard.created	58	aug13	1	15	16	f	f	\N	2026-05-17 19:23:20.904091+00
206	41	3	55	flashcard.created	58	aug13	1	15	16	f	f	\N	2026-05-17 19:23:20.904091+00
207	41	4	56	flashcard.created	58	aug13	1	15	16	f	f	\N	2026-05-17 19:23:20.904091+00
208	41	5	57	flashcard.created	58	aug13	1	15	16	f	f	\N	2026-05-17 19:23:20.904091+00
209	41	6	58	flashcard.created	58	aug13	1	15	16	f	f	\N	2026-05-17 19:23:20.904091+00
210	41	7	59	flashcard.created	58	aug13	1	15	16	f	f	\N	2026-05-17 19:23:20.904091+00
211	41	8	60	flashcard.created	58	aug13	1	15	16	f	f	\N	2026-05-17 19:23:20.904091+00
212	41	9	61	flashcard.created	58	aug13	1	15	16	f	f	\N	2026-05-17 19:23:20.904091+00
213	42	2	54	flashcard.created	58	aug13	1	16	17	f	f	\N	2026-05-17 19:24:29.524098+00
214	42	3	55	flashcard.created	58	aug13	1	16	17	f	f	\N	2026-05-17 19:24:29.524098+00
215	42	4	56	flashcard.created	58	aug13	1	16	17	f	f	\N	2026-05-17 19:24:29.524098+00
216	42	5	57	flashcard.created	58	aug13	1	16	17	f	f	\N	2026-05-17 19:24:29.524098+00
217	42	6	58	flashcard.created	58	aug13	1	16	17	f	f	\N	2026-05-17 19:24:29.524098+00
218	42	7	59	flashcard.created	58	aug13	1	16	17	f	f	\N	2026-05-17 19:24:29.524098+00
219	42	8	60	flashcard.created	58	aug13	1	16	17	f	f	\N	2026-05-17 19:24:29.524098+00
220	42	9	61	flashcard.created	58	aug13	1	16	17	f	f	\N	2026-05-17 19:24:29.524098+00
221	43	2	54	flashcard.created	58	aug13	1	17	18	f	f	\N	2026-05-17 21:11:06.803568+00
222	43	3	55	flashcard.created	58	aug13	1	17	18	f	f	\N	2026-05-17 21:11:06.803568+00
223	43	4	56	flashcard.created	58	aug13	1	17	18	f	f	\N	2026-05-17 21:11:06.803568+00
224	43	5	57	flashcard.created	58	aug13	1	17	18	f	f	\N	2026-05-17 21:11:06.803568+00
225	43	6	58	flashcard.created	58	aug13	1	17	18	f	f	\N	2026-05-17 21:11:06.803568+00
226	43	7	59	flashcard.created	58	aug13	1	17	18	f	f	\N	2026-05-17 21:11:06.803568+00
227	43	8	60	flashcard.created	58	aug13	1	17	18	f	f	\N	2026-05-17 21:11:06.803568+00
228	43	9	61	flashcard.created	58	aug13	1	17	18	f	f	\N	2026-05-17 21:11:06.803568+00
229	44	2	54	flashcard.created	58	aug13	1	18	19	f	f	\N	2026-05-17 22:12:28.951659+00
230	44	3	55	flashcard.created	58	aug13	1	18	19	f	f	\N	2026-05-17 22:12:28.951659+00
231	44	4	56	flashcard.created	58	aug13	1	18	19	f	f	\N	2026-05-17 22:12:28.951659+00
232	44	5	57	flashcard.created	58	aug13	1	18	19	f	f	\N	2026-05-17 22:12:28.951659+00
233	44	6	58	flashcard.created	58	aug13	1	18	19	f	f	\N	2026-05-17 22:12:28.951659+00
234	44	7	59	flashcard.created	58	aug13	1	18	19	f	f	\N	2026-05-17 22:12:28.951659+00
235	44	8	60	flashcard.created	58	aug13	1	18	19	f	f	\N	2026-05-17 22:12:28.951659+00
236	44	9	61	flashcard.created	58	aug13	1	18	19	f	f	\N	2026-05-17 22:12:28.951659+00
237	45	2	54	flashcard.created	58	aug13	1	19	20	f	f	\N	2026-05-17 22:12:29.041141+00
238	45	3	55	flashcard.created	58	aug13	1	19	20	f	f	\N	2026-05-17 22:12:29.041141+00
239	45	4	56	flashcard.created	58	aug13	1	19	20	f	f	\N	2026-05-17 22:12:29.041141+00
240	45	5	57	flashcard.created	58	aug13	1	19	20	f	f	\N	2026-05-17 22:12:29.041141+00
241	45	6	58	flashcard.created	58	aug13	1	19	20	f	f	\N	2026-05-17 22:12:29.041141+00
242	45	7	59	flashcard.created	58	aug13	1	19	20	f	f	\N	2026-05-17 22:12:29.041141+00
243	45	8	60	flashcard.created	58	aug13	1	19	20	f	f	\N	2026-05-17 22:12:29.041141+00
244	45	9	61	flashcard.created	58	aug13	1	19	20	f	f	\N	2026-05-17 22:12:29.041141+00
245	46	2	54	flashcard.created	58	aug13	1	20	21	f	f	\N	2026-05-17 22:13:37.480562+00
246	46	3	55	flashcard.created	58	aug13	1	20	21	f	f	\N	2026-05-17 22:13:37.480562+00
247	46	4	56	flashcard.created	58	aug13	1	20	21	f	f	\N	2026-05-17 22:13:37.480562+00
248	46	5	57	flashcard.created	58	aug13	1	20	21	f	f	\N	2026-05-17 22:13:37.480562+00
249	46	6	58	flashcard.created	58	aug13	1	20	21	f	f	\N	2026-05-17 22:13:37.480562+00
250	46	7	59	flashcard.created	58	aug13	1	20	21	f	f	\N	2026-05-17 22:13:37.480562+00
251	46	8	60	flashcard.created	58	aug13	1	20	21	f	f	\N	2026-05-17 22:13:37.480562+00
252	46	9	61	flashcard.created	58	aug13	1	20	21	f	f	\N	2026-05-17 22:13:37.480562+00
253	47	2	54	flashcard.created	58	aug13	1	21	22	f	f	\N	2026-05-17 22:13:37.505688+00
254	47	3	55	flashcard.created	58	aug13	1	21	22	f	f	\N	2026-05-17 22:13:37.505688+00
255	47	4	56	flashcard.created	58	aug13	1	21	22	f	f	\N	2026-05-17 22:13:37.505688+00
256	47	5	57	flashcard.created	58	aug13	1	21	22	f	f	\N	2026-05-17 22:13:37.505688+00
257	47	6	58	flashcard.created	58	aug13	1	21	22	f	f	\N	2026-05-17 22:13:37.505688+00
258	47	7	59	flashcard.created	58	aug13	1	21	22	f	f	\N	2026-05-17 22:13:37.505688+00
259	47	8	60	flashcard.created	58	aug13	1	21	22	f	f	\N	2026-05-17 22:13:37.505688+00
260	47	9	61	flashcard.created	58	aug13	1	21	22	f	f	\N	2026-05-17 22:13:37.505688+00
261	48	10	62	flashcard.reviewed	58	aug13	1	0	1	f	f	\N	2026-05-18 04:11:25.835466+00
262	48	11	63	flashcard.reviewed	58	aug13	1	0	1	f	f	\N	2026-05-18 04:11:25.835466+00
263	48	12	64	flashcard.reviewed	58	aug13	1	0	1	f	f	\N	2026-05-18 04:11:25.835466+00
264	48	13	65	flashcard.reviewed	58	aug13	1	0	1	f	f	\N	2026-05-18 04:11:25.835466+00
265	48	14	66	flashcard.reviewed	58	aug13	1	0	1	f	f	\N	2026-05-18 04:11:25.835466+00
266	48	15	67	flashcard.reviewed	58	aug13	1	0	1	f	f	\N	2026-05-18 04:11:25.835466+00
267	48	16	68	flashcard.reviewed	58	aug13	1	0	1	f	f	\N	2026-05-18 04:11:25.835466+00
268	49	10	62	flashcard.reviewed	58	aug13	1	1	2	f	f	\N	2026-05-18 04:11:25.900289+00
269	49	11	63	flashcard.reviewed	58	aug13	1	1	2	f	f	\N	2026-05-18 04:11:25.900289+00
270	49	12	64	flashcard.reviewed	58	aug13	1	1	2	f	f	\N	2026-05-18 04:11:25.900289+00
271	49	13	65	flashcard.reviewed	58	aug13	1	1	2	f	f	\N	2026-05-18 04:11:25.900289+00
272	49	14	66	flashcard.reviewed	58	aug13	1	1	2	f	f	\N	2026-05-18 04:11:25.900289+00
273	49	15	67	flashcard.reviewed	58	aug13	1	1	2	f	f	\N	2026-05-18 04:11:25.900289+00
274	49	16	68	flashcard.reviewed	58	aug13	1	1	2	f	f	\N	2026-05-18 04:11:25.900289+00
275	50	10	62	flashcard.reviewed	58	aug13	1	2	3	f	f	\N	2026-05-18 04:26:23.338844+00
276	50	11	63	flashcard.reviewed	58	aug13	1	2	3	f	f	\N	2026-05-18 04:26:23.338844+00
277	50	12	64	flashcard.reviewed	58	aug13	1	2	3	f	f	\N	2026-05-18 04:26:23.338844+00
278	50	13	65	flashcard.reviewed	58	aug13	1	2	3	f	f	\N	2026-05-18 04:26:23.338844+00
279	50	14	66	flashcard.reviewed	58	aug13	1	2	3	f	f	\N	2026-05-18 04:26:23.338844+00
280	50	15	67	flashcard.reviewed	58	aug13	1	2	3	f	f	\N	2026-05-18 04:26:23.338844+00
281	50	16	68	flashcard.reviewed	58	aug13	1	2	3	f	f	\N	2026-05-18 04:26:23.338844+00
282	51	10	62	flashcard.reviewed	58	aug13	1	3	4	f	f	\N	2026-05-18 04:26:23.509546+00
283	51	11	63	flashcard.reviewed	58	aug13	1	3	4	f	f	\N	2026-05-18 04:26:23.509546+00
284	51	12	64	flashcard.reviewed	58	aug13	1	3	4	f	f	\N	2026-05-18 04:26:23.509546+00
285	51	13	65	flashcard.reviewed	58	aug13	1	3	4	f	f	\N	2026-05-18 04:26:23.509546+00
286	51	14	66	flashcard.reviewed	58	aug13	1	3	4	f	f	\N	2026-05-18 04:26:23.509546+00
287	51	15	67	flashcard.reviewed	58	aug13	1	3	4	f	f	\N	2026-05-18 04:26:23.509546+00
288	51	16	68	flashcard.reviewed	58	aug13	1	3	4	f	f	\N	2026-05-18 04:26:23.509546+00
289	52	11	11	flashcard.reviewed	60	chinese2	1	186	187	f	f	\N	2026-05-18 04:42:04.71423+00
290	52	12	12	flashcard.reviewed	60	chinese2	1	186	187	f	f	\N	2026-05-18 04:42:04.71423+00
291	52	13	13	flashcard.reviewed	60	chinese2	1	186	187	f	f	\N	2026-05-18 04:42:04.71423+00
292	52	14	14	flashcard.reviewed	60	chinese2	1	186	187	f	f	\N	2026-05-18 04:42:04.71423+00
293	52	15	15	flashcard.reviewed	60	chinese2	1	186	187	f	f	\N	2026-05-18 04:42:04.71423+00
294	52	16	16	flashcard.reviewed	60	chinese2	1	186	187	f	f	\N	2026-05-18 04:42:04.71423+00
295	53	11	11	flashcard.reviewed	60	chinese2	1	187	188	f	f	\N	2026-05-18 04:42:04.971784+00
296	53	12	12	flashcard.reviewed	60	chinese2	1	187	188	f	f	\N	2026-05-18 04:42:04.971784+00
297	53	13	13	flashcard.reviewed	60	chinese2	1	187	188	f	f	\N	2026-05-18 04:42:04.971784+00
298	53	14	14	flashcard.reviewed	60	chinese2	1	187	188	f	f	\N	2026-05-18 04:42:04.971784+00
299	53	15	15	flashcard.reviewed	60	chinese2	1	187	188	f	f	\N	2026-05-18 04:42:04.971784+00
300	53	16	16	flashcard.reviewed	60	chinese2	1	187	188	f	f	\N	2026-05-18 04:42:04.971784+00
301	54	10	62	flashcard.reviewed	58	aug13	1	4	5	f	f	\N	2026-05-18 04:49:05.379891+00
302	54	11	63	flashcard.reviewed	58	aug13	1	4	5	f	f	\N	2026-05-18 04:49:05.379891+00
303	54	12	64	flashcard.reviewed	58	aug13	1	4	5	f	f	\N	2026-05-18 04:49:05.379891+00
304	54	13	65	flashcard.reviewed	58	aug13	1	4	5	f	f	\N	2026-05-18 04:49:05.379891+00
305	54	14	66	flashcard.reviewed	58	aug13	1	4	5	f	f	\N	2026-05-18 04:49:05.379891+00
306	54	15	67	flashcard.reviewed	58	aug13	1	4	5	f	f	\N	2026-05-18 04:49:05.379891+00
307	54	16	68	flashcard.reviewed	58	aug13	1	4	5	f	f	\N	2026-05-18 04:49:05.379891+00
308	55	10	62	flashcard.reviewed	58	aug13	1	5	6	f	f	\N	2026-05-18 04:49:05.407513+00
309	55	11	63	flashcard.reviewed	58	aug13	1	5	6	f	f	\N	2026-05-18 04:49:05.407513+00
310	55	12	64	flashcard.reviewed	58	aug13	1	5	6	f	f	\N	2026-05-18 04:49:05.407513+00
311	55	13	65	flashcard.reviewed	58	aug13	1	5	6	f	f	\N	2026-05-18 04:49:05.407513+00
312	55	14	66	flashcard.reviewed	58	aug13	1	5	6	f	f	\N	2026-05-18 04:49:05.407513+00
313	55	15	67	flashcard.reviewed	58	aug13	1	5	6	f	f	\N	2026-05-18 04:49:05.407513+00
314	55	16	68	flashcard.reviewed	58	aug13	1	5	6	f	f	\N	2026-05-18 04:49:05.407513+00
315	56	10	62	flashcard.reviewed	58	aug13	1	6	7	f	f	\N	2026-05-18 04:49:21.582636+00
316	56	11	63	flashcard.reviewed	58	aug13	1	6	7	f	f	\N	2026-05-18 04:49:21.582636+00
317	56	12	64	flashcard.reviewed	58	aug13	1	6	7	f	f	\N	2026-05-18 04:49:21.582636+00
318	56	13	65	flashcard.reviewed	58	aug13	1	6	7	f	f	\N	2026-05-18 04:49:21.582636+00
319	56	14	66	flashcard.reviewed	58	aug13	1	6	7	f	f	\N	2026-05-18 04:49:21.582636+00
320	56	15	67	flashcard.reviewed	58	aug13	1	6	7	f	f	\N	2026-05-18 04:49:21.582636+00
321	56	16	68	flashcard.reviewed	58	aug13	1	6	7	f	f	\N	2026-05-18 04:49:21.582636+00
322	57	10	62	flashcard.reviewed	58	aug13	1	7	8	f	f	\N	2026-05-18 04:49:21.610623+00
323	57	11	63	flashcard.reviewed	58	aug13	1	7	8	f	f	\N	2026-05-18 04:49:21.610623+00
324	57	12	64	flashcard.reviewed	58	aug13	1	7	8	f	f	\N	2026-05-18 04:49:21.610623+00
325	57	13	65	flashcard.reviewed	58	aug13	1	7	8	f	f	\N	2026-05-18 04:49:21.610623+00
326	57	14	66	flashcard.reviewed	58	aug13	1	7	8	f	f	\N	2026-05-18 04:49:21.610623+00
327	57	15	67	flashcard.reviewed	58	aug13	1	7	8	f	f	\N	2026-05-18 04:49:21.610623+00
328	57	16	68	flashcard.reviewed	58	aug13	1	7	8	f	f	\N	2026-05-18 04:49:21.610623+00
329	58	10	62	flashcard.reviewed	58	aug13	1	8	9	f	f	\N	2026-05-18 04:58:29.27952+00
330	58	11	63	flashcard.reviewed	58	aug13	1	8	9	f	f	\N	2026-05-18 04:58:29.27952+00
331	58	12	64	flashcard.reviewed	58	aug13	1	8	9	f	f	\N	2026-05-18 04:58:29.27952+00
332	58	13	65	flashcard.reviewed	58	aug13	1	8	9	f	f	\N	2026-05-18 04:58:29.27952+00
333	58	14	66	flashcard.reviewed	58	aug13	1	8	9	f	f	\N	2026-05-18 04:58:29.27952+00
334	58	15	67	flashcard.reviewed	58	aug13	1	8	9	f	f	\N	2026-05-18 04:58:29.27952+00
335	58	16	68	flashcard.reviewed	58	aug13	1	8	9	f	f	\N	2026-05-18 04:58:29.27952+00
336	59	10	62	flashcard.reviewed	58	aug13	1	9	10	f	f	\N	2026-05-18 04:58:29.302234+00
337	59	11	63	flashcard.reviewed	58	aug13	1	9	10	f	f	\N	2026-05-18 04:58:29.302234+00
338	59	12	64	flashcard.reviewed	58	aug13	1	9	10	f	f	\N	2026-05-18 04:58:29.302234+00
339	59	13	65	flashcard.reviewed	58	aug13	1	9	10	f	f	\N	2026-05-18 04:58:29.302234+00
340	59	14	66	flashcard.reviewed	58	aug13	1	9	10	f	f	\N	2026-05-18 04:58:29.302234+00
341	59	15	67	flashcard.reviewed	58	aug13	1	9	10	f	f	\N	2026-05-18 04:58:29.302234+00
342	59	16	68	flashcard.reviewed	58	aug13	1	9	10	f	f	\N	2026-05-18 04:58:29.302234+00
343	60	10	62	flashcard.reviewed	58	aug13	1	10	11	f	f	\N	2026-05-18 05:11:35.279318+00
344	60	11	63	flashcard.reviewed	58	aug13	1	10	11	f	f	\N	2026-05-18 05:11:35.279318+00
345	60	12	64	flashcard.reviewed	58	aug13	1	10	11	f	f	\N	2026-05-18 05:11:35.279318+00
346	60	13	65	flashcard.reviewed	58	aug13	1	10	11	f	f	\N	2026-05-18 05:11:35.279318+00
347	60	14	66	flashcard.reviewed	58	aug13	1	10	11	f	f	\N	2026-05-18 05:11:35.279318+00
348	60	15	67	flashcard.reviewed	58	aug13	1	10	11	f	f	\N	2026-05-18 05:11:35.279318+00
349	60	16	68	flashcard.reviewed	58	aug13	1	10	11	f	f	\N	2026-05-18 05:11:35.279318+00
350	61	10	62	flashcard.reviewed	58	aug13	1	11	12	f	f	\N	2026-05-18 05:11:35.333651+00
351	61	11	63	flashcard.reviewed	58	aug13	1	11	12	f	f	\N	2026-05-18 05:11:35.333651+00
352	61	12	64	flashcard.reviewed	58	aug13	1	11	12	f	f	\N	2026-05-18 05:11:35.333651+00
353	61	13	65	flashcard.reviewed	58	aug13	1	11	12	f	f	\N	2026-05-18 05:11:35.333651+00
354	61	14	66	flashcard.reviewed	58	aug13	1	11	12	f	f	\N	2026-05-18 05:11:35.333651+00
355	61	15	67	flashcard.reviewed	58	aug13	1	11	12	f	f	\N	2026-05-18 05:11:35.333651+00
356	61	16	68	flashcard.reviewed	58	aug13	1	11	12	f	f	\N	2026-05-18 05:11:35.333651+00
357	62	10	62	flashcard.reviewed	58	aug13	1	12	13	f	f	\N	2026-05-18 05:11:41.090097+00
358	62	11	63	flashcard.reviewed	58	aug13	1	12	13	f	f	\N	2026-05-18 05:11:41.090097+00
359	62	12	64	flashcard.reviewed	58	aug13	1	12	13	f	f	\N	2026-05-18 05:11:41.090097+00
360	62	13	65	flashcard.reviewed	58	aug13	1	12	13	f	f	\N	2026-05-18 05:11:41.090097+00
361	62	14	66	flashcard.reviewed	58	aug13	1	12	13	f	f	\N	2026-05-18 05:11:41.090097+00
362	62	15	67	flashcard.reviewed	58	aug13	1	12	13	f	f	\N	2026-05-18 05:11:41.090097+00
363	62	16	68	flashcard.reviewed	58	aug13	1	12	13	f	f	\N	2026-05-18 05:11:41.090097+00
364	63	10	62	flashcard.reviewed	58	aug13	1	13	14	f	f	\N	2026-05-18 05:11:41.114318+00
365	63	11	63	flashcard.reviewed	58	aug13	1	13	14	f	f	\N	2026-05-18 05:11:41.114318+00
366	63	12	64	flashcard.reviewed	58	aug13	1	13	14	f	f	\N	2026-05-18 05:11:41.114318+00
367	63	13	65	flashcard.reviewed	58	aug13	1	13	14	f	f	\N	2026-05-18 05:11:41.114318+00
368	63	14	66	flashcard.reviewed	58	aug13	1	13	14	f	f	\N	2026-05-18 05:11:41.114318+00
369	63	15	67	flashcard.reviewed	58	aug13	1	13	14	f	f	\N	2026-05-18 05:11:41.114318+00
370	63	16	68	flashcard.reviewed	58	aug13	1	13	14	f	f	\N	2026-05-18 05:11:41.114318+00
371	64	10	62	flashcard.reviewed	58	aug13	1	14	15	f	f	\N	2026-05-18 05:11:49.485535+00
372	64	11	63	flashcard.reviewed	58	aug13	1	14	15	f	f	\N	2026-05-18 05:11:49.485535+00
373	64	12	64	flashcard.reviewed	58	aug13	1	14	15	f	f	\N	2026-05-18 05:11:49.485535+00
374	64	13	65	flashcard.reviewed	58	aug13	1	14	15	f	f	\N	2026-05-18 05:11:49.485535+00
375	64	14	66	flashcard.reviewed	58	aug13	1	14	15	f	f	\N	2026-05-18 05:11:49.485535+00
376	64	15	67	flashcard.reviewed	58	aug13	1	14	15	f	f	\N	2026-05-18 05:11:49.485535+00
377	64	16	68	flashcard.reviewed	58	aug13	1	14	15	f	f	\N	2026-05-18 05:11:49.485535+00
378	65	10	62	flashcard.reviewed	58	aug13	1	15	16	f	f	\N	2026-05-18 05:11:49.510678+00
379	65	11	63	flashcard.reviewed	58	aug13	1	15	16	f	f	\N	2026-05-18 05:11:49.510678+00
380	65	12	64	flashcard.reviewed	58	aug13	1	15	16	f	f	\N	2026-05-18 05:11:49.510678+00
381	65	13	65	flashcard.reviewed	58	aug13	1	15	16	f	f	\N	2026-05-18 05:11:49.510678+00
382	65	14	66	flashcard.reviewed	58	aug13	1	15	16	f	f	\N	2026-05-18 05:11:49.510678+00
383	65	15	67	flashcard.reviewed	58	aug13	1	15	16	f	f	\N	2026-05-18 05:11:49.510678+00
384	65	16	68	flashcard.reviewed	58	aug13	1	15	16	f	f	\N	2026-05-18 05:11:49.510678+00
385	66	10	62	flashcard.reviewed	58	aug13	1	16	17	f	f	\N	2026-05-18 05:11:52.730452+00
386	66	11	63	flashcard.reviewed	58	aug13	1	16	17	f	f	\N	2026-05-18 05:11:52.730452+00
387	66	12	64	flashcard.reviewed	58	aug13	1	16	17	f	f	\N	2026-05-18 05:11:52.730452+00
388	66	13	65	flashcard.reviewed	58	aug13	1	16	17	f	f	\N	2026-05-18 05:11:52.730452+00
389	66	14	66	flashcard.reviewed	58	aug13	1	16	17	f	f	\N	2026-05-18 05:11:52.730452+00
390	66	15	67	flashcard.reviewed	58	aug13	1	16	17	f	f	\N	2026-05-18 05:11:52.730452+00
391	66	16	68	flashcard.reviewed	58	aug13	1	16	17	f	f	\N	2026-05-18 05:11:52.730452+00
399	68	10	62	flashcard.reviewed	58	aug13	1	18	19	f	f	\N	2026-05-18 05:11:54.857657+00
400	68	11	63	flashcard.reviewed	58	aug13	1	18	19	f	f	\N	2026-05-18 05:11:54.857657+00
401	68	12	64	flashcard.reviewed	58	aug13	1	18	19	f	f	\N	2026-05-18 05:11:54.857657+00
402	68	13	65	flashcard.reviewed	58	aug13	1	18	19	f	f	\N	2026-05-18 05:11:54.857657+00
403	68	14	66	flashcard.reviewed	58	aug13	1	18	19	f	f	\N	2026-05-18 05:11:54.857657+00
404	68	15	67	flashcard.reviewed	58	aug13	1	18	19	f	f	\N	2026-05-18 05:11:54.857657+00
405	68	16	68	flashcard.reviewed	58	aug13	1	18	19	f	f	\N	2026-05-18 05:11:54.857657+00
413	70	10	62	flashcard.reviewed	58	aug13	1	20	21	f	f	\N	2026-05-18 05:12:02.355281+00
414	70	11	63	flashcard.reviewed	58	aug13	1	20	21	f	f	\N	2026-05-18 05:12:02.355281+00
415	70	12	64	flashcard.reviewed	58	aug13	1	20	21	f	f	\N	2026-05-18 05:12:02.355281+00
416	70	13	65	flashcard.reviewed	58	aug13	1	20	21	f	f	\N	2026-05-18 05:12:02.355281+00
417	70	14	66	flashcard.reviewed	58	aug13	1	20	21	f	f	\N	2026-05-18 05:12:02.355281+00
418	70	15	67	flashcard.reviewed	58	aug13	1	20	21	f	f	\N	2026-05-18 05:12:02.355281+00
419	70	16	68	flashcard.reviewed	58	aug13	1	20	21	f	f	\N	2026-05-18 05:12:02.355281+00
1399	221	11	63	flashcard.reviewed	58	manual	1	171	172	f	f	\N	2026-05-18 06:08:32.542862+00
1400	221	12	64	flashcard.reviewed	58	manual	1	171	172	f	f	\N	2026-05-18 06:08:32.542862+00
1401	221	13	65	flashcard.reviewed	58	manual	1	171	172	f	f	\N	2026-05-18 06:08:32.542862+00
1402	221	14	66	flashcard.reviewed	58	manual	1	171	172	f	f	\N	2026-05-18 06:08:32.542862+00
1403	221	15	67	flashcard.reviewed	58	manual	1	171	172	f	f	\N	2026-05-18 06:08:32.542862+00
1404	221	16	68	flashcard.reviewed	58	manual	1	171	172	f	f	\N	2026-05-18 06:08:32.542862+00
1411	223	11	63	flashcard.reviewed	58	module-test	1	173	174	f	f	\N	2026-05-18 06:09:05.24814+00
1412	223	12	64	flashcard.reviewed	58	module-test	1	173	174	f	f	\N	2026-05-18 06:09:05.24814+00
1413	223	13	65	flashcard.reviewed	58	module-test	1	173	174	f	f	\N	2026-05-18 06:09:05.24814+00
1414	223	14	66	flashcard.reviewed	58	module-test	1	173	174	f	f	\N	2026-05-18 06:09:05.24814+00
1415	223	15	67	flashcard.reviewed	58	module-test	1	173	174	f	f	\N	2026-05-18 06:09:05.24814+00
1416	223	16	68	flashcard.reviewed	58	module-test	1	173	174	f	f	\N	2026-05-18 06:09:05.24814+00
392	67	10	62	flashcard.reviewed	58	aug13	1	17	18	f	f	\N	2026-05-18 05:11:52.757081+00
393	67	11	63	flashcard.reviewed	58	aug13	1	17	18	f	f	\N	2026-05-18 05:11:52.757081+00
394	67	12	64	flashcard.reviewed	58	aug13	1	17	18	f	f	\N	2026-05-18 05:11:52.757081+00
395	67	13	65	flashcard.reviewed	58	aug13	1	17	18	f	f	\N	2026-05-18 05:11:52.757081+00
396	67	14	66	flashcard.reviewed	58	aug13	1	17	18	f	f	\N	2026-05-18 05:11:52.757081+00
397	67	15	67	flashcard.reviewed	58	aug13	1	17	18	f	f	\N	2026-05-18 05:11:52.757081+00
398	67	16	68	flashcard.reviewed	58	aug13	1	17	18	f	f	\N	2026-05-18 05:11:52.757081+00
406	69	10	62	flashcard.reviewed	58	aug13	1	19	20	f	f	\N	2026-05-18 05:11:54.884346+00
407	69	11	63	flashcard.reviewed	58	aug13	1	19	20	f	f	\N	2026-05-18 05:11:54.884346+00
408	69	12	64	flashcard.reviewed	58	aug13	1	19	20	f	f	\N	2026-05-18 05:11:54.884346+00
409	69	13	65	flashcard.reviewed	58	aug13	1	19	20	f	f	\N	2026-05-18 05:11:54.884346+00
410	69	14	66	flashcard.reviewed	58	aug13	1	19	20	f	f	\N	2026-05-18 05:11:54.884346+00
411	69	15	67	flashcard.reviewed	58	aug13	1	19	20	f	f	\N	2026-05-18 05:11:54.884346+00
412	69	16	68	flashcard.reviewed	58	aug13	1	19	20	f	f	\N	2026-05-18 05:11:54.884346+00
420	71	10	62	flashcard.reviewed	58	aug13	1	21	22	f	f	\N	2026-05-18 05:12:02.381977+00
421	71	11	63	flashcard.reviewed	58	aug13	1	21	22	f	f	\N	2026-05-18 05:12:02.381977+00
422	71	12	64	flashcard.reviewed	58	aug13	1	21	22	f	f	\N	2026-05-18 05:12:02.381977+00
423	71	13	65	flashcard.reviewed	58	aug13	1	21	22	f	f	\N	2026-05-18 05:12:02.381977+00
424	71	14	66	flashcard.reviewed	58	aug13	1	21	22	f	f	\N	2026-05-18 05:12:02.381977+00
425	71	15	67	flashcard.reviewed	58	aug13	1	21	22	f	f	\N	2026-05-18 05:12:02.381977+00
426	71	16	68	flashcard.reviewed	58	aug13	1	21	22	f	f	\N	2026-05-18 05:12:02.381977+00
427	72	10	62	flashcard.reviewed	58	aug13	1	22	23	f	f	\N	2026-05-18 06:02:01.764167+00
428	72	11	63	flashcard.reviewed	58	aug13	1	22	23	f	f	\N	2026-05-18 06:02:01.764167+00
429	72	12	64	flashcard.reviewed	58	aug13	1	22	23	f	f	\N	2026-05-18 06:02:01.764167+00
430	72	13	65	flashcard.reviewed	58	aug13	1	22	23	f	f	\N	2026-05-18 06:02:01.764167+00
431	72	14	66	flashcard.reviewed	58	aug13	1	22	23	f	f	\N	2026-05-18 06:02:01.764167+00
432	72	15	67	flashcard.reviewed	58	aug13	1	22	23	f	f	\N	2026-05-18 06:02:01.764167+00
433	72	16	68	flashcard.reviewed	58	aug13	1	22	23	f	f	\N	2026-05-18 06:02:01.764167+00
434	73	10	62	flashcard.reviewed	58	aug13	1	23	24	f	f	\N	2026-05-18 06:02:01.769294+00
435	73	11	63	flashcard.reviewed	58	aug13	1	23	24	f	f	\N	2026-05-18 06:02:01.769294+00
436	73	12	64	flashcard.reviewed	58	aug13	1	23	24	f	f	\N	2026-05-18 06:02:01.769294+00
437	73	13	65	flashcard.reviewed	58	aug13	1	23	24	f	f	\N	2026-05-18 06:02:01.769294+00
438	73	14	66	flashcard.reviewed	58	aug13	1	23	24	f	f	\N	2026-05-18 06:02:01.769294+00
439	73	15	67	flashcard.reviewed	58	aug13	1	23	24	f	f	\N	2026-05-18 06:02:01.769294+00
440	73	16	68	flashcard.reviewed	58	aug13	1	23	24	f	f	\N	2026-05-18 06:02:01.769294+00
441	74	10	62	flashcard.reviewed	58	aug13	1	24	25	f	f	\N	2026-05-18 06:02:01.830197+00
442	74	11	63	flashcard.reviewed	58	aug13	1	24	25	f	f	\N	2026-05-18 06:02:01.830197+00
443	74	12	64	flashcard.reviewed	58	aug13	1	24	25	f	f	\N	2026-05-18 06:02:01.830197+00
444	74	13	65	flashcard.reviewed	58	aug13	1	24	25	f	f	\N	2026-05-18 06:02:01.830197+00
445	74	14	66	flashcard.reviewed	58	aug13	1	24	25	f	f	\N	2026-05-18 06:02:01.830197+00
446	74	15	67	flashcard.reviewed	58	aug13	1	24	25	f	f	\N	2026-05-18 06:02:01.830197+00
447	74	16	68	flashcard.reviewed	58	aug13	1	24	25	f	f	\N	2026-05-18 06:02:01.830197+00
448	75	10	62	flashcard.reviewed	58	aug13	1	25	26	f	f	\N	2026-05-18 06:02:01.873618+00
449	75	11	63	flashcard.reviewed	58	aug13	1	25	26	f	f	\N	2026-05-18 06:02:01.873618+00
450	75	12	64	flashcard.reviewed	58	aug13	1	25	26	f	f	\N	2026-05-18 06:02:01.873618+00
451	75	13	65	flashcard.reviewed	58	aug13	1	25	26	f	f	\N	2026-05-18 06:02:01.873618+00
452	75	14	66	flashcard.reviewed	58	aug13	1	25	26	f	f	\N	2026-05-18 06:02:01.873618+00
453	75	15	67	flashcard.reviewed	58	aug13	1	25	26	f	f	\N	2026-05-18 06:02:01.873618+00
454	75	16	68	flashcard.reviewed	58	aug13	1	25	26	f	f	\N	2026-05-18 06:02:01.873618+00
455	76	10	62	flashcard.reviewed	58	aug13	1	26	27	f	f	\N	2026-05-18 06:02:01.882102+00
456	76	11	63	flashcard.reviewed	58	aug13	1	26	27	f	f	\N	2026-05-18 06:02:01.882102+00
457	76	12	64	flashcard.reviewed	58	aug13	1	26	27	f	f	\N	2026-05-18 06:02:01.882102+00
458	76	13	65	flashcard.reviewed	58	aug13	1	26	27	f	f	\N	2026-05-18 06:02:01.882102+00
459	76	14	66	flashcard.reviewed	58	aug13	1	26	27	f	f	\N	2026-05-18 06:02:01.882102+00
460	76	15	67	flashcard.reviewed	58	aug13	1	26	27	f	f	\N	2026-05-18 06:02:01.882102+00
461	76	16	68	flashcard.reviewed	58	aug13	1	26	27	f	f	\N	2026-05-18 06:02:01.882102+00
462	78	10	62	flashcard.reviewed	58	aug13	1	27	28	f	f	\N	2026-05-18 06:02:01.973601+00
463	78	11	63	flashcard.reviewed	58	aug13	1	27	28	f	f	\N	2026-05-18 06:02:01.973601+00
464	78	12	64	flashcard.reviewed	58	aug13	1	27	28	f	f	\N	2026-05-18 06:02:01.973601+00
465	78	13	65	flashcard.reviewed	58	aug13	1	27	28	f	f	\N	2026-05-18 06:02:01.973601+00
466	78	14	66	flashcard.reviewed	58	aug13	1	27	28	f	f	\N	2026-05-18 06:02:01.973601+00
467	78	15	67	flashcard.reviewed	58	aug13	1	27	28	f	f	\N	2026-05-18 06:02:01.973601+00
468	78	16	68	flashcard.reviewed	58	aug13	1	27	28	f	f	\N	2026-05-18 06:02:01.973601+00
469	77	10	62	flashcard.reviewed	58	aug13	1	28	29	f	f	\N	2026-05-18 06:02:01.903086+00
470	77	11	63	flashcard.reviewed	58	aug13	1	28	29	f	f	\N	2026-05-18 06:02:01.903086+00
471	77	12	64	flashcard.reviewed	58	aug13	1	28	29	f	f	\N	2026-05-18 06:02:01.903086+00
472	77	13	65	flashcard.reviewed	58	aug13	1	28	29	f	f	\N	2026-05-18 06:02:01.903086+00
473	77	14	66	flashcard.reviewed	58	aug13	1	28	29	f	f	\N	2026-05-18 06:02:01.903086+00
474	77	15	67	flashcard.reviewed	58	aug13	1	28	29	f	f	\N	2026-05-18 06:02:01.903086+00
475	77	16	68	flashcard.reviewed	58	aug13	1	28	29	f	f	\N	2026-05-18 06:02:01.903086+00
476	85	10	62	flashcard.reviewed	58	aug13	1	29	30	f	f	\N	2026-05-18 06:02:02.130505+00
477	85	11	63	flashcard.reviewed	58	aug13	1	29	30	f	f	\N	2026-05-18 06:02:02.130505+00
478	85	12	64	flashcard.reviewed	58	aug13	1	29	30	f	f	\N	2026-05-18 06:02:02.130505+00
479	85	13	65	flashcard.reviewed	58	aug13	1	29	30	f	f	\N	2026-05-18 06:02:02.130505+00
480	85	14	66	flashcard.reviewed	58	aug13	1	29	30	f	f	\N	2026-05-18 06:02:02.130505+00
481	85	15	67	flashcard.reviewed	58	aug13	1	29	30	f	f	\N	2026-05-18 06:02:02.130505+00
482	85	16	68	flashcard.reviewed	58	aug13	1	29	30	f	f	\N	2026-05-18 06:02:02.130505+00
483	84	10	62	flashcard.reviewed	58	aug13	1	30	31	f	f	\N	2026-05-18 06:02:02.055595+00
484	84	11	63	flashcard.reviewed	58	aug13	1	30	31	f	f	\N	2026-05-18 06:02:02.055595+00
485	84	12	64	flashcard.reviewed	58	aug13	1	30	31	f	f	\N	2026-05-18 06:02:02.055595+00
486	84	13	65	flashcard.reviewed	58	aug13	1	30	31	f	f	\N	2026-05-18 06:02:02.055595+00
487	84	14	66	flashcard.reviewed	58	aug13	1	30	31	f	f	\N	2026-05-18 06:02:02.055595+00
488	84	15	67	flashcard.reviewed	58	aug13	1	30	31	f	f	\N	2026-05-18 06:02:02.055595+00
489	84	16	68	flashcard.reviewed	58	aug13	1	30	31	f	f	\N	2026-05-18 06:02:02.055595+00
490	79	10	62	flashcard.reviewed	58	aug13	1	31	32	f	f	\N	2026-05-18 06:02:01.992264+00
491	79	11	63	flashcard.reviewed	58	aug13	1	31	32	f	f	\N	2026-05-18 06:02:01.992264+00
492	79	12	64	flashcard.reviewed	58	aug13	1	31	32	f	f	\N	2026-05-18 06:02:01.992264+00
493	79	13	65	flashcard.reviewed	58	aug13	1	31	32	f	f	\N	2026-05-18 06:02:01.992264+00
494	79	14	66	flashcard.reviewed	58	aug13	1	31	32	f	f	\N	2026-05-18 06:02:01.992264+00
495	79	15	67	flashcard.reviewed	58	aug13	1	31	32	f	f	\N	2026-05-18 06:02:01.992264+00
496	79	16	68	flashcard.reviewed	58	aug13	1	31	32	f	f	\N	2026-05-18 06:02:01.992264+00
497	97	10	62	flashcard.reviewed	58	aug13	1	32	33	f	f	\N	2026-05-18 06:02:02.432619+00
498	97	11	63	flashcard.reviewed	58	aug13	1	32	33	f	f	\N	2026-05-18 06:02:02.432619+00
499	97	12	64	flashcard.reviewed	58	aug13	1	32	33	f	f	\N	2026-05-18 06:02:02.432619+00
500	97	13	65	flashcard.reviewed	58	aug13	1	32	33	f	f	\N	2026-05-18 06:02:02.432619+00
501	97	14	66	flashcard.reviewed	58	aug13	1	32	33	f	f	\N	2026-05-18 06:02:02.432619+00
502	97	15	67	flashcard.reviewed	58	aug13	1	32	33	f	f	\N	2026-05-18 06:02:02.432619+00
503	97	16	68	flashcard.reviewed	58	aug13	1	32	33	f	f	\N	2026-05-18 06:02:02.432619+00
511	100	10	62	flashcard.reviewed	58	aug13	1	34	35	f	f	\N	2026-05-18 06:02:02.989711+00
512	100	11	63	flashcard.reviewed	58	aug13	1	34	35	f	f	\N	2026-05-18 06:02:02.989711+00
513	100	12	64	flashcard.reviewed	58	aug13	1	34	35	f	f	\N	2026-05-18 06:02:02.989711+00
514	100	13	65	flashcard.reviewed	58	aug13	1	34	35	f	f	\N	2026-05-18 06:02:02.989711+00
515	100	14	66	flashcard.reviewed	58	aug13	1	34	35	f	f	\N	2026-05-18 06:02:02.989711+00
516	100	15	67	flashcard.reviewed	58	aug13	1	34	35	f	f	\N	2026-05-18 06:02:02.989711+00
517	100	16	68	flashcard.reviewed	58	aug13	1	34	35	f	f	\N	2026-05-18 06:02:02.989711+00
518	102	10	62	flashcard.reviewed	58	aug13	1	35	36	f	f	\N	2026-05-18 06:02:03.016979+00
519	102	11	63	flashcard.reviewed	58	aug13	1	35	36	f	f	\N	2026-05-18 06:02:03.016979+00
520	102	12	64	flashcard.reviewed	58	aug13	1	35	36	f	f	\N	2026-05-18 06:02:03.016979+00
521	102	13	65	flashcard.reviewed	58	aug13	1	35	36	f	f	\N	2026-05-18 06:02:03.016979+00
522	102	14	66	flashcard.reviewed	58	aug13	1	35	36	f	f	\N	2026-05-18 06:02:03.016979+00
523	102	15	67	flashcard.reviewed	58	aug13	1	35	36	f	f	\N	2026-05-18 06:02:03.016979+00
524	102	16	68	flashcard.reviewed	58	aug13	1	35	36	f	f	\N	2026-05-18 06:02:03.016979+00
567	105	10	62	flashcard.reviewed	58	aug13	1	42	43	f	f	\N	2026-05-18 06:02:03.120085+00
568	105	11	63	flashcard.reviewed	58	aug13	1	42	43	f	f	\N	2026-05-18 06:02:03.120085+00
569	105	12	64	flashcard.reviewed	58	aug13	1	42	43	f	f	\N	2026-05-18 06:02:03.120085+00
570	105	13	65	flashcard.reviewed	58	aug13	1	42	43	f	f	\N	2026-05-18 06:02:03.120085+00
571	105	14	66	flashcard.reviewed	58	aug13	1	42	43	f	f	\N	2026-05-18 06:02:03.120085+00
572	105	15	67	flashcard.reviewed	58	aug13	1	42	43	f	f	\N	2026-05-18 06:02:03.120085+00
573	105	16	68	flashcard.reviewed	58	aug13	1	42	43	f	f	\N	2026-05-18 06:02:03.120085+00
574	104	10	62	flashcard.reviewed	58	aug13	1	43	44	f	f	\N	2026-05-18 06:02:03.084273+00
575	104	11	63	flashcard.reviewed	58	aug13	1	43	44	f	f	\N	2026-05-18 06:02:03.084273+00
576	104	12	64	flashcard.reviewed	58	aug13	1	43	44	f	f	\N	2026-05-18 06:02:03.084273+00
577	104	13	65	flashcard.reviewed	58	aug13	1	43	44	f	f	\N	2026-05-18 06:02:03.084273+00
578	104	14	66	flashcard.reviewed	58	aug13	1	43	44	f	f	\N	2026-05-18 06:02:03.084273+00
579	104	15	67	flashcard.reviewed	58	aug13	1	43	44	f	f	\N	2026-05-18 06:02:03.084273+00
580	104	16	68	flashcard.reviewed	58	aug13	1	43	44	f	f	\N	2026-05-18 06:02:03.084273+00
595	113	10	62	flashcard.reviewed	58	aug13	1	46	47	f	f	\N	2026-05-18 06:02:03.333911+00
596	113	11	63	flashcard.reviewed	58	aug13	1	46	47	f	f	\N	2026-05-18 06:02:03.333911+00
597	113	12	64	flashcard.reviewed	58	aug13	1	46	47	f	f	\N	2026-05-18 06:02:03.333911+00
598	113	13	65	flashcard.reviewed	58	aug13	1	46	47	f	f	\N	2026-05-18 06:02:03.333911+00
504	83	10	62	flashcard.reviewed	58	aug13	1	33	34	f	f	\N	2026-05-18 06:02:02.094108+00
505	83	11	63	flashcard.reviewed	58	aug13	1	33	34	f	f	\N	2026-05-18 06:02:02.094108+00
506	83	12	64	flashcard.reviewed	58	aug13	1	33	34	f	f	\N	2026-05-18 06:02:02.094108+00
507	83	13	65	flashcard.reviewed	58	aug13	1	33	34	f	f	\N	2026-05-18 06:02:02.094108+00
508	83	14	66	flashcard.reviewed	58	aug13	1	33	34	f	f	\N	2026-05-18 06:02:02.094108+00
509	83	15	67	flashcard.reviewed	58	aug13	1	33	34	f	f	\N	2026-05-18 06:02:02.094108+00
510	83	16	68	flashcard.reviewed	58	aug13	1	33	34	f	f	\N	2026-05-18 06:02:02.094108+00
525	103	10	62	flashcard.reviewed	58	aug13	1	36	37	f	f	\N	2026-05-18 06:02:03.053598+00
526	103	11	63	flashcard.reviewed	58	aug13	1	36	37	f	f	\N	2026-05-18 06:02:03.053598+00
527	103	12	64	flashcard.reviewed	58	aug13	1	36	37	f	f	\N	2026-05-18 06:02:03.053598+00
528	103	13	65	flashcard.reviewed	58	aug13	1	36	37	f	f	\N	2026-05-18 06:02:03.053598+00
529	103	14	66	flashcard.reviewed	58	aug13	1	36	37	f	f	\N	2026-05-18 06:02:03.053598+00
530	103	15	67	flashcard.reviewed	58	aug13	1	36	37	f	f	\N	2026-05-18 06:02:03.053598+00
531	103	16	68	flashcard.reviewed	58	aug13	1	36	37	f	f	\N	2026-05-18 06:02:03.053598+00
546	106	10	62	flashcard.reviewed	58	aug13	1	39	40	f	f	\N	2026-05-18 06:02:03.147767+00
547	106	11	63	flashcard.reviewed	58	aug13	1	39	40	f	f	\N	2026-05-18 06:02:03.147767+00
548	106	12	64	flashcard.reviewed	58	aug13	1	39	40	f	f	\N	2026-05-18 06:02:03.147767+00
549	106	13	65	flashcard.reviewed	58	aug13	1	39	40	f	f	\N	2026-05-18 06:02:03.147767+00
550	106	14	66	flashcard.reviewed	58	aug13	1	39	40	f	f	\N	2026-05-18 06:02:03.147767+00
551	106	15	67	flashcard.reviewed	58	aug13	1	39	40	f	f	\N	2026-05-18 06:02:03.147767+00
552	106	16	68	flashcard.reviewed	58	aug13	1	39	40	f	f	\N	2026-05-18 06:02:03.147767+00
588	109	10	62	flashcard.reviewed	58	aug13	1	45	46	f	f	\N	2026-05-18 06:02:03.231407+00
589	109	11	63	flashcard.reviewed	58	aug13	1	45	46	f	f	\N	2026-05-18 06:02:03.231407+00
590	109	12	64	flashcard.reviewed	58	aug13	1	45	46	f	f	\N	2026-05-18 06:02:03.231407+00
591	109	13	65	flashcard.reviewed	58	aug13	1	45	46	f	f	\N	2026-05-18 06:02:03.231407+00
592	109	14	66	flashcard.reviewed	58	aug13	1	45	46	f	f	\N	2026-05-18 06:02:03.231407+00
593	109	15	67	flashcard.reviewed	58	aug13	1	45	46	f	f	\N	2026-05-18 06:02:03.231407+00
594	109	16	68	flashcard.reviewed	58	aug13	1	45	46	f	f	\N	2026-05-18 06:02:03.231407+00
630	115	10	62	flashcard.reviewed	58	aug13	1	51	52	f	f	\N	2026-05-18 06:02:03.394526+00
631	115	11	63	flashcard.reviewed	58	aug13	1	51	52	f	f	\N	2026-05-18 06:02:03.394526+00
632	115	12	64	flashcard.reviewed	58	aug13	1	51	52	f	f	\N	2026-05-18 06:02:03.394526+00
633	115	13	65	flashcard.reviewed	58	aug13	1	51	52	f	f	\N	2026-05-18 06:02:03.394526+00
634	115	14	66	flashcard.reviewed	58	aug13	1	51	52	f	f	\N	2026-05-18 06:02:03.394526+00
635	115	15	67	flashcard.reviewed	58	aug13	1	51	52	f	f	\N	2026-05-18 06:02:03.394526+00
636	115	16	68	flashcard.reviewed	58	aug13	1	51	52	f	f	\N	2026-05-18 06:02:03.394526+00
665	121	10	62	flashcard.reviewed	58	aug13	1	56	57	f	f	\N	2026-05-18 06:02:03.99047+00
666	121	11	63	flashcard.reviewed	58	aug13	1	56	57	f	f	\N	2026-05-18 06:02:03.99047+00
667	121	12	64	flashcard.reviewed	58	aug13	1	56	57	f	f	\N	2026-05-18 06:02:03.99047+00
668	121	13	65	flashcard.reviewed	58	aug13	1	56	57	f	f	\N	2026-05-18 06:02:03.99047+00
669	121	14	66	flashcard.reviewed	58	aug13	1	56	57	f	f	\N	2026-05-18 06:02:03.99047+00
670	121	15	67	flashcard.reviewed	58	aug13	1	56	57	f	f	\N	2026-05-18 06:02:03.99047+00
671	121	16	68	flashcard.reviewed	58	aug13	1	56	57	f	f	\N	2026-05-18 06:02:03.99047+00
854	125	10	62	flashcard.reviewed	58	aug13	1	83	84	f	f	\N	2026-05-18 06:02:05.005173+00
855	125	11	63	flashcard.reviewed	58	aug13	1	83	84	f	f	\N	2026-05-18 06:02:05.005173+00
856	125	12	64	flashcard.reviewed	58	aug13	1	83	84	f	f	\N	2026-05-18 06:02:05.005173+00
857	125	13	65	flashcard.reviewed	58	aug13	1	83	84	f	f	\N	2026-05-18 06:02:05.005173+00
858	125	14	66	flashcard.reviewed	58	aug13	1	83	84	f	f	\N	2026-05-18 06:02:05.005173+00
859	125	15	67	flashcard.reviewed	58	aug13	1	83	84	f	f	\N	2026-05-18 06:02:05.005173+00
860	125	16	68	flashcard.reviewed	58	aug13	1	83	84	f	f	\N	2026-05-18 06:02:05.005173+00
1407	222	13	65	flashcard.reviewed	58	module-test	1	172	173	f	f	\N	2026-05-18 06:09:05.220753+00
1408	222	14	66	flashcard.reviewed	58	module-test	1	172	173	f	f	\N	2026-05-18 06:09:05.220753+00
1409	222	15	67	flashcard.reviewed	58	module-test	1	172	173	f	f	\N	2026-05-18 06:09:05.220753+00
1410	222	16	68	flashcard.reviewed	58	module-test	1	172	173	f	f	\N	2026-05-18 06:09:05.220753+00
1417	224	11	63	flashcard.reviewed	58	aug13	1	174	175	f	f	\N	2026-05-18 06:15:50.411987+00
1418	224	12	64	flashcard.reviewed	58	aug13	1	174	175	f	f	\N	2026-05-18 06:15:50.411987+00
1419	224	13	65	flashcard.reviewed	58	aug13	1	174	175	f	f	\N	2026-05-18 06:15:50.411987+00
1420	224	14	66	flashcard.reviewed	58	aug13	1	174	175	f	f	\N	2026-05-18 06:15:50.411987+00
1421	224	15	67	flashcard.reviewed	58	aug13	1	174	175	f	f	\N	2026-05-18 06:15:50.411987+00
1422	224	16	68	flashcard.reviewed	58	aug13	1	174	175	f	f	\N	2026-05-18 06:15:50.411987+00
1429	231	11	63	flashcard.reviewed	58	aug13	1	176	177	f	f	\N	2026-05-18 06:15:50.706737+00
1430	231	12	64	flashcard.reviewed	58	aug13	1	176	177	f	f	\N	2026-05-18 06:15:50.706737+00
1431	231	13	65	flashcard.reviewed	58	aug13	1	176	177	f	f	\N	2026-05-18 06:15:50.706737+00
1432	231	14	66	flashcard.reviewed	58	aug13	1	176	177	f	f	\N	2026-05-18 06:15:50.706737+00
1433	231	15	67	flashcard.reviewed	58	aug13	1	176	177	f	f	\N	2026-05-18 06:15:50.706737+00
1434	231	16	68	flashcard.reviewed	58	aug13	1	176	177	f	f	\N	2026-05-18 06:15:50.706737+00
532	90	10	62	flashcard.reviewed	58	aug13	1	37	38	f	f	\N	2026-05-18 06:02:02.284283+00
533	90	11	63	flashcard.reviewed	58	aug13	1	37	38	f	f	\N	2026-05-18 06:02:02.284283+00
534	90	12	64	flashcard.reviewed	58	aug13	1	37	38	f	f	\N	2026-05-18 06:02:02.284283+00
535	90	13	65	flashcard.reviewed	58	aug13	1	37	38	f	f	\N	2026-05-18 06:02:02.284283+00
536	90	14	66	flashcard.reviewed	58	aug13	1	37	38	f	f	\N	2026-05-18 06:02:02.284283+00
537	90	15	67	flashcard.reviewed	58	aug13	1	37	38	f	f	\N	2026-05-18 06:02:02.284283+00
538	90	16	68	flashcard.reviewed	58	aug13	1	37	38	f	f	\N	2026-05-18 06:02:02.284283+00
553	107	10	62	flashcard.reviewed	58	aug13	1	40	41	f	f	\N	2026-05-18 06:02:03.176621+00
554	107	11	63	flashcard.reviewed	58	aug13	1	40	41	f	f	\N	2026-05-18 06:02:03.176621+00
555	107	12	64	flashcard.reviewed	58	aug13	1	40	41	f	f	\N	2026-05-18 06:02:03.176621+00
556	107	13	65	flashcard.reviewed	58	aug13	1	40	41	f	f	\N	2026-05-18 06:02:03.176621+00
557	107	14	66	flashcard.reviewed	58	aug13	1	40	41	f	f	\N	2026-05-18 06:02:03.176621+00
558	107	15	67	flashcard.reviewed	58	aug13	1	40	41	f	f	\N	2026-05-18 06:02:03.176621+00
559	107	16	68	flashcard.reviewed	58	aug13	1	40	41	f	f	\N	2026-05-18 06:02:03.176621+00
581	110	10	62	flashcard.reviewed	58	aug13	1	44	45	f	f	\N	2026-05-18 06:02:03.256159+00
582	110	11	63	flashcard.reviewed	58	aug13	1	44	45	f	f	\N	2026-05-18 06:02:03.256159+00
583	110	12	64	flashcard.reviewed	58	aug13	1	44	45	f	f	\N	2026-05-18 06:02:03.256159+00
584	110	13	65	flashcard.reviewed	58	aug13	1	44	45	f	f	\N	2026-05-18 06:02:03.256159+00
585	110	14	66	flashcard.reviewed	58	aug13	1	44	45	f	f	\N	2026-05-18 06:02:03.256159+00
586	110	15	67	flashcard.reviewed	58	aug13	1	44	45	f	f	\N	2026-05-18 06:02:03.256159+00
587	110	16	68	flashcard.reviewed	58	aug13	1	44	45	f	f	\N	2026-05-18 06:02:03.256159+00
602	114	10	62	flashcard.reviewed	58	aug13	1	47	48	f	f	\N	2026-05-18 06:02:03.365208+00
603	114	11	63	flashcard.reviewed	58	aug13	1	47	48	f	f	\N	2026-05-18 06:02:03.365208+00
604	114	12	64	flashcard.reviewed	58	aug13	1	47	48	f	f	\N	2026-05-18 06:02:03.365208+00
605	114	13	65	flashcard.reviewed	58	aug13	1	47	48	f	f	\N	2026-05-18 06:02:03.365208+00
606	114	14	66	flashcard.reviewed	58	aug13	1	47	48	f	f	\N	2026-05-18 06:02:03.365208+00
607	114	15	67	flashcard.reviewed	58	aug13	1	47	48	f	f	\N	2026-05-18 06:02:03.365208+00
608	114	16	68	flashcard.reviewed	58	aug13	1	47	48	f	f	\N	2026-05-18 06:02:03.365208+00
637	117	10	62	flashcard.reviewed	58	aug13	1	52	53	f	f	\N	2026-05-18 06:02:03.447337+00
638	117	11	63	flashcard.reviewed	58	aug13	1	52	53	f	f	\N	2026-05-18 06:02:03.447337+00
639	117	12	64	flashcard.reviewed	58	aug13	1	52	53	f	f	\N	2026-05-18 06:02:03.447337+00
640	117	13	65	flashcard.reviewed	58	aug13	1	52	53	f	f	\N	2026-05-18 06:02:03.447337+00
641	117	14	66	flashcard.reviewed	58	aug13	1	52	53	f	f	\N	2026-05-18 06:02:03.447337+00
642	117	15	67	flashcard.reviewed	58	aug13	1	52	53	f	f	\N	2026-05-18 06:02:03.447337+00
643	117	16	68	flashcard.reviewed	58	aug13	1	52	53	f	f	\N	2026-05-18 06:02:03.447337+00
833	122	10	62	flashcard.reviewed	58	aug13	1	80	81	f	f	\N	2026-05-18 06:02:04.019569+00
834	122	11	63	flashcard.reviewed	58	aug13	1	80	81	f	f	\N	2026-05-18 06:02:04.019569+00
835	122	12	64	flashcard.reviewed	58	aug13	1	80	81	f	f	\N	2026-05-18 06:02:04.019569+00
836	122	13	65	flashcard.reviewed	58	aug13	1	80	81	f	f	\N	2026-05-18 06:02:04.019569+00
837	122	14	66	flashcard.reviewed	58	aug13	1	80	81	f	f	\N	2026-05-18 06:02:04.019569+00
838	122	15	67	flashcard.reviewed	58	aug13	1	80	81	f	f	\N	2026-05-18 06:02:04.019569+00
839	122	16	68	flashcard.reviewed	58	aug13	1	80	81	f	f	\N	2026-05-18 06:02:04.019569+00
1423	225	11	63	flashcard.reviewed	58	aug13	1	175	176	f	f	\N	2026-05-18 06:15:50.425746+00
1424	225	12	64	flashcard.reviewed	58	aug13	1	175	176	f	f	\N	2026-05-18 06:15:50.425746+00
1425	225	13	65	flashcard.reviewed	58	aug13	1	175	176	f	f	\N	2026-05-18 06:15:50.425746+00
1426	225	14	66	flashcard.reviewed	58	aug13	1	175	176	f	f	\N	2026-05-18 06:15:50.425746+00
1427	225	15	67	flashcard.reviewed	58	aug13	1	175	176	f	f	\N	2026-05-18 06:15:50.425746+00
1428	225	16	68	flashcard.reviewed	58	aug13	1	175	176	f	f	\N	2026-05-18 06:15:50.425746+00
1543	245	11	63	flashcard.reviewed	58	aug13	1	195	196	f	f	\N	2026-05-18 06:15:51.674788+00
1544	245	12	64	flashcard.reviewed	58	aug13	1	195	196	f	f	\N	2026-05-18 06:15:51.674788+00
1545	245	13	65	flashcard.reviewed	58	aug13	1	195	196	f	f	\N	2026-05-18 06:15:51.674788+00
1546	245	14	66	flashcard.reviewed	58	aug13	1	195	196	f	f	\N	2026-05-18 06:15:51.674788+00
1547	245	15	67	flashcard.reviewed	58	aug13	1	195	196	f	f	\N	2026-05-18 06:15:51.674788+00
1548	245	16	68	flashcard.reviewed	58	aug13	1	195	196	f	f	\N	2026-05-18 06:15:51.674788+00
1668	267	12	64	flashcard.reviewed	58	aug13	1	219	220	f	f	\N	2026-05-18 06:15:55.747318+00
1669	267	13	65	flashcard.reviewed	58	aug13	1	219	220	f	f	\N	2026-05-18 06:15:55.747318+00
1670	267	14	66	flashcard.reviewed	58	aug13	1	219	220	f	f	\N	2026-05-18 06:15:55.747318+00
1671	267	15	67	flashcard.reviewed	58	aug13	1	219	220	f	f	\N	2026-05-18 06:15:55.747318+00
1672	267	16	68	flashcard.reviewed	58	aug13	1	219	220	f	f	\N	2026-05-18 06:15:55.747318+00
1793	291	12	64	flashcard.reviewed	58	aug13	1	244	245	f	f	\N	2026-05-18 06:15:59.36077+00
1794	291	13	65	flashcard.reviewed	58	aug13	1	244	245	f	f	\N	2026-05-18 06:15:59.36077+00
1795	291	14	66	flashcard.reviewed	58	aug13	1	244	245	f	f	\N	2026-05-18 06:15:59.36077+00
1796	291	15	67	flashcard.reviewed	58	aug13	1	244	245	f	f	\N	2026-05-18 06:15:59.36077+00
1797	291	16	68	flashcard.reviewed	58	aug13	1	244	245	f	f	\N	2026-05-18 06:15:59.36077+00
539	95	10	62	flashcard.reviewed	58	aug13	1	38	39	f	f	\N	2026-05-18 06:02:02.366479+00
540	95	11	63	flashcard.reviewed	58	aug13	1	38	39	f	f	\N	2026-05-18 06:02:02.366479+00
541	95	12	64	flashcard.reviewed	58	aug13	1	38	39	f	f	\N	2026-05-18 06:02:02.366479+00
542	95	13	65	flashcard.reviewed	58	aug13	1	38	39	f	f	\N	2026-05-18 06:02:02.366479+00
543	95	14	66	flashcard.reviewed	58	aug13	1	38	39	f	f	\N	2026-05-18 06:02:02.366479+00
544	95	15	67	flashcard.reviewed	58	aug13	1	38	39	f	f	\N	2026-05-18 06:02:02.366479+00
545	95	16	68	flashcard.reviewed	58	aug13	1	38	39	f	f	\N	2026-05-18 06:02:02.366479+00
560	108	10	62	flashcard.reviewed	58	aug13	1	41	42	f	f	\N	2026-05-18 06:02:03.203763+00
561	108	11	63	flashcard.reviewed	58	aug13	1	41	42	f	f	\N	2026-05-18 06:02:03.203763+00
562	108	12	64	flashcard.reviewed	58	aug13	1	41	42	f	f	\N	2026-05-18 06:02:03.203763+00
563	108	13	65	flashcard.reviewed	58	aug13	1	41	42	f	f	\N	2026-05-18 06:02:03.203763+00
564	108	14	66	flashcard.reviewed	58	aug13	1	41	42	f	f	\N	2026-05-18 06:02:03.203763+00
565	108	15	67	flashcard.reviewed	58	aug13	1	41	42	f	f	\N	2026-05-18 06:02:03.203763+00
566	108	16	68	flashcard.reviewed	58	aug13	1	41	42	f	f	\N	2026-05-18 06:02:03.203763+00
798	111	10	62	flashcard.reviewed	58	aug13	1	75	76	f	f	\N	2026-05-18 06:02:03.282329+00
799	111	11	63	flashcard.reviewed	58	aug13	1	75	76	f	f	\N	2026-05-18 06:02:03.282329+00
800	111	12	64	flashcard.reviewed	58	aug13	1	75	76	f	f	\N	2026-05-18 06:02:03.282329+00
801	111	13	65	flashcard.reviewed	58	aug13	1	75	76	f	f	\N	2026-05-18 06:02:03.282329+00
802	111	14	66	flashcard.reviewed	58	aug13	1	75	76	f	f	\N	2026-05-18 06:02:03.282329+00
803	111	15	67	flashcard.reviewed	58	aug13	1	75	76	f	f	\N	2026-05-18 06:02:03.282329+00
804	111	16	68	flashcard.reviewed	58	aug13	1	75	76	f	f	\N	2026-05-18 06:02:03.282329+00
1435	227	11	63	flashcard.reviewed	58	aug13	1	177	178	f	f	\N	2026-05-18 06:15:50.654086+00
1436	227	12	64	flashcard.reviewed	58	aug13	1	177	178	f	f	\N	2026-05-18 06:15:50.654086+00
1437	227	13	65	flashcard.reviewed	58	aug13	1	177	178	f	f	\N	2026-05-18 06:15:50.654086+00
1438	227	14	66	flashcard.reviewed	58	aug13	1	177	178	f	f	\N	2026-05-18 06:15:50.654086+00
1439	227	15	67	flashcard.reviewed	58	aug13	1	177	178	f	f	\N	2026-05-18 06:15:50.654086+00
1440	227	16	68	flashcard.reviewed	58	aug13	1	177	178	f	f	\N	2026-05-18 06:15:50.654086+00
1588	253	12	64	flashcard.reviewed	58	aug13	1	203	204	f	f	\N	2026-05-18 06:15:52.054016+00
1589	253	13	65	flashcard.reviewed	58	aug13	1	203	204	f	f	\N	2026-05-18 06:15:52.054016+00
1590	253	14	66	flashcard.reviewed	58	aug13	1	203	204	f	f	\N	2026-05-18 06:15:52.054016+00
1591	253	15	67	flashcard.reviewed	58	aug13	1	203	204	f	f	\N	2026-05-18 06:15:52.054016+00
1592	253	16	68	flashcard.reviewed	58	aug13	1	203	204	f	f	\N	2026-05-18 06:15:52.054016+00
1683	272	12	64	flashcard.reviewed	58	aug13	1	222	223	f	f	\N	2026-05-18 06:15:56.226993+00
1684	272	13	65	flashcard.reviewed	58	aug13	1	222	223	f	f	\N	2026-05-18 06:15:56.226993+00
1685	272	14	66	flashcard.reviewed	58	aug13	1	222	223	f	f	\N	2026-05-18 06:15:56.226993+00
1686	272	15	67	flashcard.reviewed	58	aug13	1	222	223	f	f	\N	2026-05-18 06:15:56.226993+00
1687	272	16	68	flashcard.reviewed	58	aug13	1	222	223	f	f	\N	2026-05-18 06:15:56.226993+00
1778	292	12	64	flashcard.reviewed	58	aug13	1	241	242	f	f	\N	2026-05-18 06:15:59.391507+00
1779	292	13	65	flashcard.reviewed	58	aug13	1	241	242	f	f	\N	2026-05-18 06:15:59.391507+00
1780	292	14	66	flashcard.reviewed	58	aug13	1	241	242	f	f	\N	2026-05-18 06:15:59.391507+00
1781	292	15	67	flashcard.reviewed	58	aug13	1	241	242	f	f	\N	2026-05-18 06:15:59.391507+00
1782	292	16	68	flashcard.reviewed	58	aug13	1	241	242	f	f	\N	2026-05-18 06:15:59.391507+00
599	113	14	66	flashcard.reviewed	58	aug13	1	46	47	f	f	\N	2026-05-18 06:02:03.333911+00
600	113	15	67	flashcard.reviewed	58	aug13	1	46	47	f	f	\N	2026-05-18 06:02:03.333911+00
601	113	16	68	flashcard.reviewed	58	aug13	1	46	47	f	f	\N	2026-05-18 06:02:03.333911+00
623	116	10	62	flashcard.reviewed	58	aug13	1	50	51	f	f	\N	2026-05-18 06:02:03.419627+00
624	116	11	63	flashcard.reviewed	58	aug13	1	50	51	f	f	\N	2026-05-18 06:02:03.419627+00
625	116	12	64	flashcard.reviewed	58	aug13	1	50	51	f	f	\N	2026-05-18 06:02:03.419627+00
626	116	13	65	flashcard.reviewed	58	aug13	1	50	51	f	f	\N	2026-05-18 06:02:03.419627+00
627	116	14	66	flashcard.reviewed	58	aug13	1	50	51	f	f	\N	2026-05-18 06:02:03.419627+00
628	116	15	67	flashcard.reviewed	58	aug13	1	50	51	f	f	\N	2026-05-18 06:02:03.419627+00
629	116	16	68	flashcard.reviewed	58	aug13	1	50	51	f	f	\N	2026-05-18 06:02:03.419627+00
651	119	10	62	flashcard.reviewed	58	aug13	1	54	55	f	f	\N	2026-05-18 06:02:03.962845+00
652	119	11	63	flashcard.reviewed	58	aug13	1	54	55	f	f	\N	2026-05-18 06:02:03.962845+00
653	119	12	64	flashcard.reviewed	58	aug13	1	54	55	f	f	\N	2026-05-18 06:02:03.962845+00
654	119	13	65	flashcard.reviewed	58	aug13	1	54	55	f	f	\N	2026-05-18 06:02:03.962845+00
655	119	14	66	flashcard.reviewed	58	aug13	1	54	55	f	f	\N	2026-05-18 06:02:03.962845+00
656	119	15	67	flashcard.reviewed	58	aug13	1	54	55	f	f	\N	2026-05-18 06:02:03.962845+00
657	119	16	68	flashcard.reviewed	58	aug13	1	54	55	f	f	\N	2026-05-18 06:02:03.962845+00
847	123	10	62	flashcard.reviewed	58	aug13	1	82	83	f	f	\N	2026-05-18 06:02:04.498875+00
848	123	11	63	flashcard.reviewed	58	aug13	1	82	83	f	f	\N	2026-05-18 06:02:04.498875+00
849	123	12	64	flashcard.reviewed	58	aug13	1	82	83	f	f	\N	2026-05-18 06:02:04.498875+00
850	123	13	65	flashcard.reviewed	58	aug13	1	82	83	f	f	\N	2026-05-18 06:02:04.498875+00
851	123	14	66	flashcard.reviewed	58	aug13	1	82	83	f	f	\N	2026-05-18 06:02:04.498875+00
852	123	15	67	flashcard.reviewed	58	aug13	1	82	83	f	f	\N	2026-05-18 06:02:04.498875+00
853	123	16	68	flashcard.reviewed	58	aug13	1	82	83	f	f	\N	2026-05-18 06:02:04.498875+00
1441	226	11	63	flashcard.reviewed	58	aug13	1	178	179	f	f	\N	2026-05-18 06:15:50.610665+00
1442	226	12	64	flashcard.reviewed	58	aug13	1	178	179	f	f	\N	2026-05-18 06:15:50.610665+00
1443	226	13	65	flashcard.reviewed	58	aug13	1	178	179	f	f	\N	2026-05-18 06:15:50.610665+00
1444	226	14	66	flashcard.reviewed	58	aug13	1	178	179	f	f	\N	2026-05-18 06:15:50.610665+00
1445	226	15	67	flashcard.reviewed	58	aug13	1	178	179	f	f	\N	2026-05-18 06:15:50.610665+00
1446	226	16	68	flashcard.reviewed	58	aug13	1	178	179	f	f	\N	2026-05-18 06:15:50.610665+00
1583	252	12	64	flashcard.reviewed	58	aug13	1	202	203	f	f	\N	2026-05-18 06:15:52.019203+00
1584	252	13	65	flashcard.reviewed	58	aug13	1	202	203	f	f	\N	2026-05-18 06:15:52.019203+00
1585	252	14	66	flashcard.reviewed	58	aug13	1	202	203	f	f	\N	2026-05-18 06:15:52.019203+00
1586	252	15	67	flashcard.reviewed	58	aug13	1	202	203	f	f	\N	2026-05-18 06:15:52.019203+00
1587	252	16	68	flashcard.reviewed	58	aug13	1	202	203	f	f	\N	2026-05-18 06:15:52.019203+00
1678	271	12	64	flashcard.reviewed	58	aug13	1	221	222	f	f	\N	2026-05-18 06:15:56.20657+00
1679	271	13	65	flashcard.reviewed	58	aug13	1	221	222	f	f	\N	2026-05-18 06:15:56.20657+00
1680	271	14	66	flashcard.reviewed	58	aug13	1	221	222	f	f	\N	2026-05-18 06:15:56.20657+00
1681	271	15	67	flashcard.reviewed	58	aug13	1	221	222	f	f	\N	2026-05-18 06:15:56.20657+00
1682	271	16	68	flashcard.reviewed	58	aug13	1	221	222	f	f	\N	2026-05-18 06:15:56.20657+00
1773	290	12	64	flashcard.reviewed	58	aug13	1	240	241	f	f	\N	2026-05-18 06:15:59.372908+00
1774	290	13	65	flashcard.reviewed	58	aug13	1	240	241	f	f	\N	2026-05-18 06:15:59.372908+00
1775	290	14	66	flashcard.reviewed	58	aug13	1	240	241	f	f	\N	2026-05-18 06:15:59.372908+00
1776	290	15	67	flashcard.reviewed	58	aug13	1	240	241	f	f	\N	2026-05-18 06:15:59.372908+00
1777	290	16	68	flashcard.reviewed	58	aug13	1	240	241	f	f	\N	2026-05-18 06:15:59.372908+00
609	99	10	62	flashcard.reviewed	58	aug13	1	48	49	f	f	\N	2026-05-18 06:02:02.494039+00
610	99	11	63	flashcard.reviewed	58	aug13	1	48	49	f	f	\N	2026-05-18 06:02:02.494039+00
611	99	12	64	flashcard.reviewed	58	aug13	1	48	49	f	f	\N	2026-05-18 06:02:02.494039+00
612	99	13	65	flashcard.reviewed	58	aug13	1	48	49	f	f	\N	2026-05-18 06:02:02.494039+00
613	99	14	66	flashcard.reviewed	58	aug13	1	48	49	f	f	\N	2026-05-18 06:02:02.494039+00
614	99	15	67	flashcard.reviewed	58	aug13	1	48	49	f	f	\N	2026-05-18 06:02:02.494039+00
615	99	16	68	flashcard.reviewed	58	aug13	1	48	49	f	f	\N	2026-05-18 06:02:02.494039+00
616	81	10	62	flashcard.reviewed	58	aug13	1	49	50	f	f	\N	2026-05-18 06:02:01.979257+00
617	81	11	63	flashcard.reviewed	58	aug13	1	49	50	f	f	\N	2026-05-18 06:02:01.979257+00
618	81	12	64	flashcard.reviewed	58	aug13	1	49	50	f	f	\N	2026-05-18 06:02:01.979257+00
619	81	13	65	flashcard.reviewed	58	aug13	1	49	50	f	f	\N	2026-05-18 06:02:01.979257+00
620	81	14	66	flashcard.reviewed	58	aug13	1	49	50	f	f	\N	2026-05-18 06:02:01.979257+00
621	81	15	67	flashcard.reviewed	58	aug13	1	49	50	f	f	\N	2026-05-18 06:02:01.979257+00
622	81	16	68	flashcard.reviewed	58	aug13	1	49	50	f	f	\N	2026-05-18 06:02:01.979257+00
644	91	10	62	flashcard.reviewed	58	aug13	1	53	54	f	f	\N	2026-05-18 06:02:02.266592+00
645	91	11	63	flashcard.reviewed	58	aug13	1	53	54	f	f	\N	2026-05-18 06:02:02.266592+00
646	91	12	64	flashcard.reviewed	58	aug13	1	53	54	f	f	\N	2026-05-18 06:02:02.266592+00
647	91	13	65	flashcard.reviewed	58	aug13	1	53	54	f	f	\N	2026-05-18 06:02:02.266592+00
648	91	14	66	flashcard.reviewed	58	aug13	1	53	54	f	f	\N	2026-05-18 06:02:02.266592+00
649	91	15	67	flashcard.reviewed	58	aug13	1	53	54	f	f	\N	2026-05-18 06:02:02.266592+00
650	91	16	68	flashcard.reviewed	58	aug13	1	53	54	f	f	\N	2026-05-18 06:02:02.266592+00
658	120	10	62	flashcard.reviewed	58	aug13	1	55	56	f	f	\N	2026-05-18 06:02:03.960564+00
659	120	11	63	flashcard.reviewed	58	aug13	1	55	56	f	f	\N	2026-05-18 06:02:03.960564+00
660	120	12	64	flashcard.reviewed	58	aug13	1	55	56	f	f	\N	2026-05-18 06:02:03.960564+00
661	120	13	65	flashcard.reviewed	58	aug13	1	55	56	f	f	\N	2026-05-18 06:02:03.960564+00
662	120	14	66	flashcard.reviewed	58	aug13	1	55	56	f	f	\N	2026-05-18 06:02:03.960564+00
663	120	15	67	flashcard.reviewed	58	aug13	1	55	56	f	f	\N	2026-05-18 06:02:03.960564+00
664	120	16	68	flashcard.reviewed	58	aug13	1	55	56	f	f	\N	2026-05-18 06:02:03.960564+00
672	86	10	62	flashcard.reviewed	58	aug13	1	57	58	f	f	\N	2026-05-18 06:02:02.113925+00
673	86	11	63	flashcard.reviewed	58	aug13	1	57	58	f	f	\N	2026-05-18 06:02:02.113925+00
674	86	12	64	flashcard.reviewed	58	aug13	1	57	58	f	f	\N	2026-05-18 06:02:02.113925+00
675	86	13	65	flashcard.reviewed	58	aug13	1	57	58	f	f	\N	2026-05-18 06:02:02.113925+00
676	86	14	66	flashcard.reviewed	58	aug13	1	57	58	f	f	\N	2026-05-18 06:02:02.113925+00
677	86	15	67	flashcard.reviewed	58	aug13	1	57	58	f	f	\N	2026-05-18 06:02:02.113925+00
678	86	16	68	flashcard.reviewed	58	aug13	1	57	58	f	f	\N	2026-05-18 06:02:02.113925+00
679	124	10	62	flashcard.reviewed	58	aug13	1	58	59	f	f	\N	2026-05-18 06:02:04.499417+00
680	124	11	63	flashcard.reviewed	58	aug13	1	58	59	f	f	\N	2026-05-18 06:02:04.499417+00
681	124	12	64	flashcard.reviewed	58	aug13	1	58	59	f	f	\N	2026-05-18 06:02:04.499417+00
682	124	13	65	flashcard.reviewed	58	aug13	1	58	59	f	f	\N	2026-05-18 06:02:04.499417+00
683	124	14	66	flashcard.reviewed	58	aug13	1	58	59	f	f	\N	2026-05-18 06:02:04.499417+00
684	124	15	67	flashcard.reviewed	58	aug13	1	58	59	f	f	\N	2026-05-18 06:02:04.499417+00
685	124	16	68	flashcard.reviewed	58	aug13	1	58	59	f	f	\N	2026-05-18 06:02:04.499417+00
686	87	10	62	flashcard.reviewed	58	aug13	1	59	60	f	f	\N	2026-05-18 06:02:02.204617+00
687	87	11	63	flashcard.reviewed	58	aug13	1	59	60	f	f	\N	2026-05-18 06:02:02.204617+00
688	87	12	64	flashcard.reviewed	58	aug13	1	59	60	f	f	\N	2026-05-18 06:02:02.204617+00
689	87	13	65	flashcard.reviewed	58	aug13	1	59	60	f	f	\N	2026-05-18 06:02:02.204617+00
690	87	14	66	flashcard.reviewed	58	aug13	1	59	60	f	f	\N	2026-05-18 06:02:02.204617+00
691	87	15	67	flashcard.reviewed	58	aug13	1	59	60	f	f	\N	2026-05-18 06:02:02.204617+00
692	87	16	68	flashcard.reviewed	58	aug13	1	59	60	f	f	\N	2026-05-18 06:02:02.204617+00
693	93	10	62	flashcard.reviewed	58	aug13	1	60	61	f	f	\N	2026-05-18 06:02:02.358434+00
694	93	11	63	flashcard.reviewed	58	aug13	1	60	61	f	f	\N	2026-05-18 06:02:02.358434+00
695	93	12	64	flashcard.reviewed	58	aug13	1	60	61	f	f	\N	2026-05-18 06:02:02.358434+00
696	93	13	65	flashcard.reviewed	58	aug13	1	60	61	f	f	\N	2026-05-18 06:02:02.358434+00
697	93	14	66	flashcard.reviewed	58	aug13	1	60	61	f	f	\N	2026-05-18 06:02:02.358434+00
698	93	15	67	flashcard.reviewed	58	aug13	1	60	61	f	f	\N	2026-05-18 06:02:02.358434+00
699	93	16	68	flashcard.reviewed	58	aug13	1	60	61	f	f	\N	2026-05-18 06:02:02.358434+00
700	127	10	62	flashcard.reviewed	58	aug13	1	61	62	f	f	\N	2026-05-18 06:02:05.500981+00
701	127	11	63	flashcard.reviewed	58	aug13	1	61	62	f	f	\N	2026-05-18 06:02:05.500981+00
702	127	12	64	flashcard.reviewed	58	aug13	1	61	62	f	f	\N	2026-05-18 06:02:05.500981+00
703	127	13	65	flashcard.reviewed	58	aug13	1	61	62	f	f	\N	2026-05-18 06:02:05.500981+00
704	127	14	66	flashcard.reviewed	58	aug13	1	61	62	f	f	\N	2026-05-18 06:02:05.500981+00
705	127	15	67	flashcard.reviewed	58	aug13	1	61	62	f	f	\N	2026-05-18 06:02:05.500981+00
706	127	16	68	flashcard.reviewed	58	aug13	1	61	62	f	f	\N	2026-05-18 06:02:05.500981+00
707	96	10	62	flashcard.reviewed	58	aug13	1	62	63	f	f	\N	2026-05-18 06:02:02.385985+00
708	96	11	63	flashcard.reviewed	58	aug13	1	62	63	f	f	\N	2026-05-18 06:02:02.385985+00
709	96	12	64	flashcard.reviewed	58	aug13	1	62	63	f	f	\N	2026-05-18 06:02:02.385985+00
710	96	13	65	flashcard.reviewed	58	aug13	1	62	63	f	f	\N	2026-05-18 06:02:02.385985+00
711	96	14	66	flashcard.reviewed	58	aug13	1	62	63	f	f	\N	2026-05-18 06:02:02.385985+00
712	96	15	67	flashcard.reviewed	58	aug13	1	62	63	f	f	\N	2026-05-18 06:02:02.385985+00
713	96	16	68	flashcard.reviewed	58	aug13	1	62	63	f	f	\N	2026-05-18 06:02:02.385985+00
868	131	10	62	flashcard.reviewed	58	aug13	1	85	86	f	f	\N	2026-05-18 06:02:06.490461+00
869	131	11	63	flashcard.reviewed	58	aug13	1	85	86	f	f	\N	2026-05-18 06:02:06.490461+00
870	131	12	64	flashcard.reviewed	58	aug13	1	85	86	f	f	\N	2026-05-18 06:02:06.490461+00
871	131	13	65	flashcard.reviewed	58	aug13	1	85	86	f	f	\N	2026-05-18 06:02:06.490461+00
872	131	14	66	flashcard.reviewed	58	aug13	1	85	86	f	f	\N	2026-05-18 06:02:06.490461+00
873	131	15	67	flashcard.reviewed	58	aug13	1	85	86	f	f	\N	2026-05-18 06:02:06.490461+00
874	131	16	68	flashcard.reviewed	58	aug13	1	85	86	f	f	\N	2026-05-18 06:02:06.490461+00
1447	230	11	63	flashcard.reviewed	58	aug13	1	179	180	f	f	\N	2026-05-18 06:15:50.611789+00
1448	230	12	64	flashcard.reviewed	58	aug13	1	179	180	f	f	\N	2026-05-18 06:15:50.611789+00
1449	230	13	65	flashcard.reviewed	58	aug13	1	179	180	f	f	\N	2026-05-18 06:15:50.611789+00
1450	230	14	66	flashcard.reviewed	58	aug13	1	179	180	f	f	\N	2026-05-18 06:15:50.611789+00
1451	230	15	67	flashcard.reviewed	58	aug13	1	179	180	f	f	\N	2026-05-18 06:15:50.611789+00
1452	230	16	68	flashcard.reviewed	58	aug13	1	179	180	f	f	\N	2026-05-18 06:15:50.611789+00
1573	251	12	64	flashcard.reviewed	58	aug13	1	200	201	f	f	\N	2026-05-18 06:15:51.988117+00
1574	251	13	65	flashcard.reviewed	58	aug13	1	200	201	f	f	\N	2026-05-18 06:15:51.988117+00
1575	251	14	66	flashcard.reviewed	58	aug13	1	200	201	f	f	\N	2026-05-18 06:15:51.988117+00
1576	251	15	67	flashcard.reviewed	58	aug13	1	200	201	f	f	\N	2026-05-18 06:15:51.988117+00
1577	251	16	68	flashcard.reviewed	58	aug13	1	200	201	f	f	\N	2026-05-18 06:15:51.988117+00
1673	270	12	64	flashcard.reviewed	58	aug13	1	220	221	f	f	\N	2026-05-18 06:15:55.840122+00
1674	270	13	65	flashcard.reviewed	58	aug13	1	220	221	f	f	\N	2026-05-18 06:15:55.840122+00
1675	270	14	66	flashcard.reviewed	58	aug13	1	220	221	f	f	\N	2026-05-18 06:15:55.840122+00
1676	270	15	67	flashcard.reviewed	58	aug13	1	220	221	f	f	\N	2026-05-18 06:15:55.840122+00
1677	270	16	68	flashcard.reviewed	58	aug13	1	220	221	f	f	\N	2026-05-18 06:15:55.840122+00
1768	289	12	64	flashcard.reviewed	58	aug13	1	239	240	f	f	\N	2026-05-18 06:15:59.355027+00
1769	289	13	65	flashcard.reviewed	58	aug13	1	239	240	f	f	\N	2026-05-18 06:15:59.355027+00
1770	289	14	66	flashcard.reviewed	58	aug13	1	239	240	f	f	\N	2026-05-18 06:15:59.355027+00
1771	289	15	67	flashcard.reviewed	58	aug13	1	239	240	f	f	\N	2026-05-18 06:15:59.355027+00
1772	289	16	68	flashcard.reviewed	58	aug13	1	239	240	f	f	\N	2026-05-18 06:15:59.355027+00
714	129	10	62	flashcard.reviewed	58	aug13	1	63	64	f	f	\N	2026-05-18 06:02:05.963395+00
715	129	11	63	flashcard.reviewed	58	aug13	1	63	64	f	f	\N	2026-05-18 06:02:05.963395+00
716	129	12	64	flashcard.reviewed	58	aug13	1	63	64	f	f	\N	2026-05-18 06:02:05.963395+00
717	129	13	65	flashcard.reviewed	58	aug13	1	63	64	f	f	\N	2026-05-18 06:02:05.963395+00
718	129	14	66	flashcard.reviewed	58	aug13	1	63	64	f	f	\N	2026-05-18 06:02:05.963395+00
719	129	15	67	flashcard.reviewed	58	aug13	1	63	64	f	f	\N	2026-05-18 06:02:05.963395+00
720	129	16	68	flashcard.reviewed	58	aug13	1	63	64	f	f	\N	2026-05-18 06:02:05.963395+00
735	133	10	62	flashcard.reviewed	58	aug13	1	66	67	f	f	\N	2026-05-18 06:02:06.982335+00
736	133	11	63	flashcard.reviewed	58	aug13	1	66	67	f	f	\N	2026-05-18 06:02:06.982335+00
737	133	12	64	flashcard.reviewed	58	aug13	1	66	67	f	f	\N	2026-05-18 06:02:06.982335+00
738	133	13	65	flashcard.reviewed	58	aug13	1	66	67	f	f	\N	2026-05-18 06:02:06.982335+00
739	133	14	66	flashcard.reviewed	58	aug13	1	66	67	f	f	\N	2026-05-18 06:02:06.982335+00
740	133	15	67	flashcard.reviewed	58	aug13	1	66	67	f	f	\N	2026-05-18 06:02:06.982335+00
741	133	16	68	flashcard.reviewed	58	aug13	1	66	67	f	f	\N	2026-05-18 06:02:06.982335+00
1453	229	11	63	flashcard.reviewed	58	aug13	1	180	181	f	f	\N	2026-05-18 06:15:50.614123+00
1454	229	12	64	flashcard.reviewed	58	aug13	1	180	181	f	f	\N	2026-05-18 06:15:50.614123+00
1455	229	13	65	flashcard.reviewed	58	aug13	1	180	181	f	f	\N	2026-05-18 06:15:50.614123+00
1456	229	14	66	flashcard.reviewed	58	aug13	1	180	181	f	f	\N	2026-05-18 06:15:50.614123+00
1457	229	15	67	flashcard.reviewed	58	aug13	1	180	181	f	f	\N	2026-05-18 06:15:50.614123+00
1458	229	16	68	flashcard.reviewed	58	aug13	1	180	181	f	f	\N	2026-05-18 06:15:50.614123+00
1567	250	11	63	flashcard.reviewed	58	aug13	1	199	200	f	t	2026-05-18 06:15:55.795+00	2026-05-18 06:15:51.956741+00
1568	250	12	64	flashcard.reviewed	58	aug13	1	199	200	f	f	\N	2026-05-18 06:15:51.956741+00
1569	250	13	65	flashcard.reviewed	58	aug13	1	199	200	f	f	\N	2026-05-18 06:15:51.956741+00
1570	250	14	66	flashcard.reviewed	58	aug13	1	199	200	f	f	\N	2026-05-18 06:15:51.956741+00
1571	250	15	67	flashcard.reviewed	58	aug13	1	199	200	f	f	\N	2026-05-18 06:15:51.956741+00
1572	250	16	68	flashcard.reviewed	58	aug13	1	199	200	f	f	\N	2026-05-18 06:15:51.956741+00
1663	269	12	64	flashcard.reviewed	58	aug13	1	218	219	f	f	\N	2026-05-18 06:15:55.819475+00
1664	269	13	65	flashcard.reviewed	58	aug13	1	218	219	f	f	\N	2026-05-18 06:15:55.819475+00
1665	269	14	66	flashcard.reviewed	58	aug13	1	218	219	f	f	\N	2026-05-18 06:15:55.819475+00
1666	269	15	67	flashcard.reviewed	58	aug13	1	218	219	f	f	\N	2026-05-18 06:15:55.819475+00
1667	269	16	68	flashcard.reviewed	58	aug13	1	218	219	f	f	\N	2026-05-18 06:15:55.819475+00
1758	288	12	64	flashcard.reviewed	58	aug13	1	237	238	f	f	\N	2026-05-18 06:15:59.019466+00
1759	288	13	65	flashcard.reviewed	58	aug13	1	237	238	f	f	\N	2026-05-18 06:15:59.019466+00
1760	288	14	66	flashcard.reviewed	58	aug13	1	237	238	f	f	\N	2026-05-18 06:15:59.019466+00
1761	288	15	67	flashcard.reviewed	58	aug13	1	237	238	f	f	\N	2026-05-18 06:15:59.019466+00
1762	288	16	68	flashcard.reviewed	58	aug13	1	237	238	f	f	\N	2026-05-18 06:15:59.019466+00
721	126	10	62	flashcard.reviewed	58	aug13	1	64	65	f	f	\N	2026-05-18 06:02:05.000656+00
722	126	11	63	flashcard.reviewed	58	aug13	1	64	65	f	f	\N	2026-05-18 06:02:05.000656+00
723	126	12	64	flashcard.reviewed	58	aug13	1	64	65	f	f	\N	2026-05-18 06:02:05.000656+00
724	126	13	65	flashcard.reviewed	58	aug13	1	64	65	f	f	\N	2026-05-18 06:02:05.000656+00
725	126	14	66	flashcard.reviewed	58	aug13	1	64	65	f	f	\N	2026-05-18 06:02:05.000656+00
726	126	15	67	flashcard.reviewed	58	aug13	1	64	65	f	f	\N	2026-05-18 06:02:05.000656+00
727	126	16	68	flashcard.reviewed	58	aug13	1	64	65	f	f	\N	2026-05-18 06:02:05.000656+00
742	134	10	62	flashcard.reviewed	58	aug13	1	67	68	f	f	\N	2026-05-18 06:02:07.476717+00
743	134	11	63	flashcard.reviewed	58	aug13	1	67	68	f	f	\N	2026-05-18 06:02:07.476717+00
744	134	12	64	flashcard.reviewed	58	aug13	1	67	68	f	f	\N	2026-05-18 06:02:07.476717+00
745	134	13	65	flashcard.reviewed	58	aug13	1	67	68	f	f	\N	2026-05-18 06:02:07.476717+00
746	134	14	66	flashcard.reviewed	58	aug13	1	67	68	f	f	\N	2026-05-18 06:02:07.476717+00
747	134	15	67	flashcard.reviewed	58	aug13	1	67	68	f	f	\N	2026-05-18 06:02:07.476717+00
748	134	16	68	flashcard.reviewed	58	aug13	1	67	68	f	f	\N	2026-05-18 06:02:07.476717+00
1459	232	11	63	flashcard.reviewed	58	aug13	1	181	182	f	f	\N	2026-05-18 06:15:50.706648+00
1460	232	12	64	flashcard.reviewed	58	aug13	1	181	182	f	f	\N	2026-05-18 06:15:50.706648+00
1461	232	13	65	flashcard.reviewed	58	aug13	1	181	182	f	f	\N	2026-05-18 06:15:50.706648+00
1462	232	14	66	flashcard.reviewed	58	aug13	1	181	182	f	f	\N	2026-05-18 06:15:50.706648+00
1463	232	15	67	flashcard.reviewed	58	aug13	1	181	182	f	f	\N	2026-05-18 06:15:50.706648+00
1464	232	16	68	flashcard.reviewed	58	aug13	1	181	182	f	f	\N	2026-05-18 06:15:50.706648+00
1555	247	11	63	flashcard.reviewed	58	aug13	1	197	198	f	f	\N	2026-05-18 06:15:51.901136+00
1556	247	12	64	flashcard.reviewed	58	aug13	1	197	198	f	f	\N	2026-05-18 06:15:51.901136+00
1557	247	13	65	flashcard.reviewed	58	aug13	1	197	198	f	f	\N	2026-05-18 06:15:51.901136+00
1558	247	14	66	flashcard.reviewed	58	aug13	1	197	198	f	f	\N	2026-05-18 06:15:51.901136+00
1559	247	15	67	flashcard.reviewed	58	aug13	1	197	198	f	f	\N	2026-05-18 06:15:51.901136+00
1560	247	16	68	flashcard.reviewed	58	aug13	1	197	198	f	f	\N	2026-05-18 06:15:51.901136+00
1653	266	12	64	flashcard.reviewed	58	aug13	1	216	217	f	f	\N	2026-05-18 06:15:55.772529+00
1654	266	13	65	flashcard.reviewed	58	aug13	1	216	217	f	f	\N	2026-05-18 06:15:55.772529+00
1655	266	14	66	flashcard.reviewed	58	aug13	1	216	217	f	f	\N	2026-05-18 06:15:55.772529+00
1656	266	15	67	flashcard.reviewed	58	aug13	1	216	217	f	f	\N	2026-05-18 06:15:55.772529+00
1657	266	16	68	flashcard.reviewed	58	aug13	1	216	217	f	f	\N	2026-05-18 06:15:55.772529+00
1748	285	12	64	flashcard.reviewed	58	aug13	1	235	236	f	f	\N	2026-05-18 06:15:58.977461+00
1749	285	13	65	flashcard.reviewed	58	aug13	1	235	236	f	f	\N	2026-05-18 06:15:58.977461+00
1750	285	14	66	flashcard.reviewed	58	aug13	1	235	236	f	f	\N	2026-05-18 06:15:58.977461+00
1751	285	15	67	flashcard.reviewed	58	aug13	1	235	236	f	f	\N	2026-05-18 06:15:58.977461+00
1752	285	16	68	flashcard.reviewed	58	aug13	1	235	236	f	f	\N	2026-05-18 06:15:58.977461+00
728	132	10	62	flashcard.reviewed	58	aug13	1	65	66	f	f	\N	2026-05-18 06:02:06.488736+00
729	132	11	63	flashcard.reviewed	58	aug13	1	65	66	f	f	\N	2026-05-18 06:02:06.488736+00
730	132	12	64	flashcard.reviewed	58	aug13	1	65	66	f	f	\N	2026-05-18 06:02:06.488736+00
731	132	13	65	flashcard.reviewed	58	aug13	1	65	66	f	f	\N	2026-05-18 06:02:06.488736+00
732	132	14	66	flashcard.reviewed	58	aug13	1	65	66	f	f	\N	2026-05-18 06:02:06.488736+00
733	132	15	67	flashcard.reviewed	58	aug13	1	65	66	f	f	\N	2026-05-18 06:02:06.488736+00
734	132	16	68	flashcard.reviewed	58	aug13	1	65	66	f	f	\N	2026-05-18 06:02:06.488736+00
749	135	10	62	flashcard.reviewed	58	aug13	1	68	69	f	f	\N	2026-05-18 06:02:07.944813+00
750	135	11	63	flashcard.reviewed	58	aug13	1	68	69	f	f	\N	2026-05-18 06:02:07.944813+00
751	135	12	64	flashcard.reviewed	58	aug13	1	68	69	f	f	\N	2026-05-18 06:02:07.944813+00
752	135	13	65	flashcard.reviewed	58	aug13	1	68	69	f	f	\N	2026-05-18 06:02:07.944813+00
753	135	14	66	flashcard.reviewed	58	aug13	1	68	69	f	f	\N	2026-05-18 06:02:07.944813+00
754	135	15	67	flashcard.reviewed	58	aug13	1	68	69	f	f	\N	2026-05-18 06:02:07.944813+00
755	135	16	68	flashcard.reviewed	58	aug13	1	68	69	f	f	\N	2026-05-18 06:02:07.944813+00
1465	233	11	63	flashcard.reviewed	58	aug13	1	182	183	f	f	\N	2026-05-18 06:15:50.705966+00
1466	233	12	64	flashcard.reviewed	58	aug13	1	182	183	f	f	\N	2026-05-18 06:15:50.705966+00
1467	233	13	65	flashcard.reviewed	58	aug13	1	182	183	f	f	\N	2026-05-18 06:15:50.705966+00
1468	233	14	66	flashcard.reviewed	58	aug13	1	182	183	f	f	\N	2026-05-18 06:15:50.705966+00
1469	233	15	67	flashcard.reviewed	58	aug13	1	182	183	f	f	\N	2026-05-18 06:15:50.705966+00
1470	233	16	68	flashcard.reviewed	58	aug13	1	182	183	f	f	\N	2026-05-18 06:15:50.705966+00
1549	246	11	63	flashcard.reviewed	58	aug13	1	196	197	f	f	\N	2026-05-18 06:15:51.870303+00
1550	246	12	64	flashcard.reviewed	58	aug13	1	196	197	f	f	\N	2026-05-18 06:15:51.870303+00
1551	246	13	65	flashcard.reviewed	58	aug13	1	196	197	f	f	\N	2026-05-18 06:15:51.870303+00
1552	246	14	66	flashcard.reviewed	58	aug13	1	196	197	f	f	\N	2026-05-18 06:15:51.870303+00
1553	246	15	67	flashcard.reviewed	58	aug13	1	196	197	f	f	\N	2026-05-18 06:15:51.870303+00
1554	246	16	68	flashcard.reviewed	58	aug13	1	196	197	f	f	\N	2026-05-18 06:15:51.870303+00
1648	265	12	64	flashcard.reviewed	58	aug13	1	215	216	f	f	\N	2026-05-18 06:15:55.74313+00
1649	265	13	65	flashcard.reviewed	58	aug13	1	215	216	f	f	\N	2026-05-18 06:15:55.74313+00
1650	265	14	66	flashcard.reviewed	58	aug13	1	215	216	f	f	\N	2026-05-18 06:15:55.74313+00
1651	265	15	67	flashcard.reviewed	58	aug13	1	215	216	f	f	\N	2026-05-18 06:15:55.74313+00
1652	265	16	68	flashcard.reviewed	58	aug13	1	215	216	f	f	\N	2026-05-18 06:15:55.74313+00
1743	284	12	64	flashcard.reviewed	58	aug13	1	234	235	f	f	\N	2026-05-18 06:15:58.958403+00
1744	284	13	65	flashcard.reviewed	58	aug13	1	234	235	f	f	\N	2026-05-18 06:15:58.958403+00
1745	284	14	66	flashcard.reviewed	58	aug13	1	234	235	f	f	\N	2026-05-18 06:15:58.958403+00
1746	284	15	67	flashcard.reviewed	58	aug13	1	234	235	f	f	\N	2026-05-18 06:15:58.958403+00
1747	284	16	68	flashcard.reviewed	58	aug13	1	234	235	f	f	\N	2026-05-18 06:15:58.958403+00
756	128	10	62	flashcard.reviewed	58	aug13	1	69	70	f	f	\N	2026-05-18 06:02:05.968454+00
757	128	11	63	flashcard.reviewed	58	aug13	1	69	70	f	f	\N	2026-05-18 06:02:05.968454+00
758	128	12	64	flashcard.reviewed	58	aug13	1	69	70	f	f	\N	2026-05-18 06:02:05.968454+00
759	128	13	65	flashcard.reviewed	58	aug13	1	69	70	f	f	\N	2026-05-18 06:02:05.968454+00
760	128	14	66	flashcard.reviewed	58	aug13	1	69	70	f	f	\N	2026-05-18 06:02:05.968454+00
761	128	15	67	flashcard.reviewed	58	aug13	1	69	70	f	f	\N	2026-05-18 06:02:05.968454+00
762	128	16	68	flashcard.reviewed	58	aug13	1	69	70	f	f	\N	2026-05-18 06:02:05.968454+00
763	98	10	62	flashcard.reviewed	58	aug13	1	70	71	f	f	\N	2026-05-18 06:02:02.398016+00
764	98	11	63	flashcard.reviewed	58	aug13	1	70	71	f	f	\N	2026-05-18 06:02:02.398016+00
765	98	12	64	flashcard.reviewed	58	aug13	1	70	71	f	f	\N	2026-05-18 06:02:02.398016+00
766	98	13	65	flashcard.reviewed	58	aug13	1	70	71	f	f	\N	2026-05-18 06:02:02.398016+00
767	98	14	66	flashcard.reviewed	58	aug13	1	70	71	f	f	\N	2026-05-18 06:02:02.398016+00
768	98	15	67	flashcard.reviewed	58	aug13	1	70	71	f	f	\N	2026-05-18 06:02:02.398016+00
769	98	16	68	flashcard.reviewed	58	aug13	1	70	71	f	f	\N	2026-05-18 06:02:02.398016+00
770	88	10	62	flashcard.reviewed	58	aug13	1	71	72	f	f	\N	2026-05-18 06:02:02.207003+00
771	88	11	63	flashcard.reviewed	58	aug13	1	71	72	f	f	\N	2026-05-18 06:02:02.207003+00
772	88	12	64	flashcard.reviewed	58	aug13	1	71	72	f	f	\N	2026-05-18 06:02:02.207003+00
773	88	13	65	flashcard.reviewed	58	aug13	1	71	72	f	f	\N	2026-05-18 06:02:02.207003+00
774	88	14	66	flashcard.reviewed	58	aug13	1	71	72	f	f	\N	2026-05-18 06:02:02.207003+00
775	88	15	67	flashcard.reviewed	58	aug13	1	71	72	f	f	\N	2026-05-18 06:02:02.207003+00
776	88	16	68	flashcard.reviewed	58	aug13	1	71	72	f	f	\N	2026-05-18 06:02:02.207003+00
777	82	10	62	flashcard.reviewed	58	aug13	1	72	73	f	f	\N	2026-05-18 06:02:02.02471+00
778	82	11	63	flashcard.reviewed	58	aug13	1	72	73	f	f	\N	2026-05-18 06:02:02.02471+00
779	82	12	64	flashcard.reviewed	58	aug13	1	72	73	f	f	\N	2026-05-18 06:02:02.02471+00
780	82	13	65	flashcard.reviewed	58	aug13	1	72	73	f	f	\N	2026-05-18 06:02:02.02471+00
781	82	14	66	flashcard.reviewed	58	aug13	1	72	73	f	f	\N	2026-05-18 06:02:02.02471+00
782	82	15	67	flashcard.reviewed	58	aug13	1	72	73	f	f	\N	2026-05-18 06:02:02.02471+00
783	82	16	68	flashcard.reviewed	58	aug13	1	72	73	f	f	\N	2026-05-18 06:02:02.02471+00
1471	234	11	63	flashcard.reviewed	58	aug13	1	183	184	f	f	\N	2026-05-18 06:15:50.747531+00
1472	234	12	64	flashcard.reviewed	58	aug13	1	183	184	f	f	\N	2026-05-18 06:15:50.747531+00
1473	234	13	65	flashcard.reviewed	58	aug13	1	183	184	f	f	\N	2026-05-18 06:15:50.747531+00
1474	234	14	66	flashcard.reviewed	58	aug13	1	183	184	f	f	\N	2026-05-18 06:15:50.747531+00
1475	234	15	67	flashcard.reviewed	58	aug13	1	183	184	f	f	\N	2026-05-18 06:15:50.747531+00
1476	234	16	68	flashcard.reviewed	58	aug13	1	183	184	f	f	\N	2026-05-18 06:15:50.747531+00
1537	244	11	63	flashcard.reviewed	58	aug13	1	194	195	f	f	\N	2026-05-18 06:15:51.652236+00
1538	244	12	64	flashcard.reviewed	58	aug13	1	194	195	f	f	\N	2026-05-18 06:15:51.652236+00
1539	244	13	65	flashcard.reviewed	58	aug13	1	194	195	f	f	\N	2026-05-18 06:15:51.652236+00
1540	244	14	66	flashcard.reviewed	58	aug13	1	194	195	f	f	\N	2026-05-18 06:15:51.652236+00
1541	244	15	67	flashcard.reviewed	58	aug13	1	194	195	f	f	\N	2026-05-18 06:15:51.652236+00
1542	244	16	68	flashcard.reviewed	58	aug13	1	194	195	f	f	\N	2026-05-18 06:15:51.652236+00
1638	263	12	64	flashcard.reviewed	58	aug13	1	213	214	f	f	\N	2026-05-18 06:15:55.346659+00
1639	263	13	65	flashcard.reviewed	58	aug13	1	213	214	f	f	\N	2026-05-18 06:15:55.346659+00
1640	263	14	66	flashcard.reviewed	58	aug13	1	213	214	f	f	\N	2026-05-18 06:15:55.346659+00
1641	263	15	67	flashcard.reviewed	58	aug13	1	213	214	f	f	\N	2026-05-18 06:15:55.346659+00
1642	263	16	68	flashcard.reviewed	58	aug13	1	213	214	f	f	\N	2026-05-18 06:15:55.346659+00
1733	282	12	64	flashcard.reviewed	58	aug13	1	232	233	f	f	\N	2026-05-18 06:15:58.613973+00
1734	282	13	65	flashcard.reviewed	58	aug13	1	232	233	f	f	\N	2026-05-18 06:15:58.613973+00
1735	282	14	66	flashcard.reviewed	58	aug13	1	232	233	f	f	\N	2026-05-18 06:15:58.613973+00
1736	282	15	67	flashcard.reviewed	58	aug13	1	232	233	f	f	\N	2026-05-18 06:15:58.613973+00
1737	282	16	68	flashcard.reviewed	58	aug13	1	232	233	f	f	\N	2026-05-18 06:15:58.613973+00
784	112	10	62	flashcard.reviewed	58	aug13	1	73	74	f	f	\N	2026-05-18 06:02:03.308334+00
785	112	11	63	flashcard.reviewed	58	aug13	1	73	74	f	f	\N	2026-05-18 06:02:03.308334+00
786	112	12	64	flashcard.reviewed	58	aug13	1	73	74	f	f	\N	2026-05-18 06:02:03.308334+00
787	112	13	65	flashcard.reviewed	58	aug13	1	73	74	f	f	\N	2026-05-18 06:02:03.308334+00
788	112	14	66	flashcard.reviewed	58	aug13	1	73	74	f	f	\N	2026-05-18 06:02:03.308334+00
789	112	15	67	flashcard.reviewed	58	aug13	1	73	74	f	f	\N	2026-05-18 06:02:03.308334+00
790	112	16	68	flashcard.reviewed	58	aug13	1	73	74	f	f	\N	2026-05-18 06:02:03.308334+00
791	89	10	62	flashcard.reviewed	58	aug13	1	74	75	f	f	\N	2026-05-18 06:02:02.21539+00
792	89	11	63	flashcard.reviewed	58	aug13	1	74	75	f	f	\N	2026-05-18 06:02:02.21539+00
793	89	12	64	flashcard.reviewed	58	aug13	1	74	75	f	f	\N	2026-05-18 06:02:02.21539+00
794	89	13	65	flashcard.reviewed	58	aug13	1	74	75	f	f	\N	2026-05-18 06:02:02.21539+00
795	89	14	66	flashcard.reviewed	58	aug13	1	74	75	f	f	\N	2026-05-18 06:02:02.21539+00
796	89	15	67	flashcard.reviewed	58	aug13	1	74	75	f	f	\N	2026-05-18 06:02:02.21539+00
797	89	16	68	flashcard.reviewed	58	aug13	1	74	75	f	f	\N	2026-05-18 06:02:02.21539+00
805	92	10	62	flashcard.reviewed	58	aug13	1	76	77	f	f	\N	2026-05-18 06:02:02.328072+00
806	92	11	63	flashcard.reviewed	58	aug13	1	76	77	f	f	\N	2026-05-18 06:02:02.328072+00
807	92	12	64	flashcard.reviewed	58	aug13	1	76	77	f	f	\N	2026-05-18 06:02:02.328072+00
808	92	13	65	flashcard.reviewed	58	aug13	1	76	77	f	f	\N	2026-05-18 06:02:02.328072+00
809	92	14	66	flashcard.reviewed	58	aug13	1	76	77	f	f	\N	2026-05-18 06:02:02.328072+00
810	92	15	67	flashcard.reviewed	58	aug13	1	76	77	f	f	\N	2026-05-18 06:02:02.328072+00
811	92	16	68	flashcard.reviewed	58	aug13	1	76	77	f	f	\N	2026-05-18 06:02:02.328072+00
812	94	10	62	flashcard.reviewed	58	aug13	1	77	78	f	f	\N	2026-05-18 06:02:02.358337+00
813	94	11	63	flashcard.reviewed	58	aug13	1	77	78	f	f	\N	2026-05-18 06:02:02.358337+00
814	94	12	64	flashcard.reviewed	58	aug13	1	77	78	f	f	\N	2026-05-18 06:02:02.358337+00
815	94	13	65	flashcard.reviewed	58	aug13	1	77	78	f	f	\N	2026-05-18 06:02:02.358337+00
816	94	14	66	flashcard.reviewed	58	aug13	1	77	78	f	f	\N	2026-05-18 06:02:02.358337+00
817	94	15	67	flashcard.reviewed	58	aug13	1	77	78	f	f	\N	2026-05-18 06:02:02.358337+00
818	94	16	68	flashcard.reviewed	58	aug13	1	77	78	f	f	\N	2026-05-18 06:02:02.358337+00
819	80	10	62	flashcard.reviewed	58	aug13	1	78	79	f	f	\N	2026-05-18 06:02:01.979519+00
820	80	11	63	flashcard.reviewed	58	aug13	1	78	79	f	f	\N	2026-05-18 06:02:01.979519+00
821	80	12	64	flashcard.reviewed	58	aug13	1	78	79	f	f	\N	2026-05-18 06:02:01.979519+00
822	80	13	65	flashcard.reviewed	58	aug13	1	78	79	f	f	\N	2026-05-18 06:02:01.979519+00
823	80	14	66	flashcard.reviewed	58	aug13	1	78	79	f	f	\N	2026-05-18 06:02:01.979519+00
824	80	15	67	flashcard.reviewed	58	aug13	1	78	79	f	f	\N	2026-05-18 06:02:01.979519+00
825	80	16	68	flashcard.reviewed	58	aug13	1	78	79	f	f	\N	2026-05-18 06:02:01.979519+00
1477	228	11	63	flashcard.reviewed	58	aug13	1	184	185	f	f	\N	2026-05-18 06:15:50.65764+00
1478	228	12	64	flashcard.reviewed	58	aug13	1	184	185	f	f	\N	2026-05-18 06:15:50.65764+00
1479	228	13	65	flashcard.reviewed	58	aug13	1	184	185	f	f	\N	2026-05-18 06:15:50.65764+00
1480	228	14	66	flashcard.reviewed	58	aug13	1	184	185	f	f	\N	2026-05-18 06:15:50.65764+00
1481	228	15	67	flashcard.reviewed	58	aug13	1	184	185	f	f	\N	2026-05-18 06:15:50.65764+00
1482	228	16	68	flashcard.reviewed	58	aug13	1	184	185	f	f	\N	2026-05-18 06:15:50.65764+00
1578	249	12	64	flashcard.reviewed	58	aug13	1	201	202	f	f	\N	2026-05-18 06:15:51.921848+00
1579	249	13	65	flashcard.reviewed	58	aug13	1	201	202	f	f	\N	2026-05-18 06:15:51.921848+00
1580	249	14	66	flashcard.reviewed	58	aug13	1	201	202	f	f	\N	2026-05-18 06:15:51.921848+00
1581	249	15	67	flashcard.reviewed	58	aug13	1	201	202	f	f	\N	2026-05-18 06:15:51.921848+00
1582	249	16	68	flashcard.reviewed	58	aug13	1	201	202	f	f	\N	2026-05-18 06:15:51.921848+00
1698	273	12	64	flashcard.reviewed	58	aug13	1	225	226	f	f	\N	2026-05-18 06:15:56.214088+00
1699	273	13	65	flashcard.reviewed	58	aug13	1	225	226	f	f	\N	2026-05-18 06:15:56.214088+00
1700	273	14	66	flashcard.reviewed	58	aug13	1	225	226	f	f	\N	2026-05-18 06:15:56.214088+00
1701	273	15	67	flashcard.reviewed	58	aug13	1	225	226	f	f	\N	2026-05-18 06:15:56.214088+00
1702	273	16	68	flashcard.reviewed	58	aug13	1	225	226	f	f	\N	2026-05-18 06:15:56.214088+00
1798	295	12	64	flashcard.reviewed	58	aug13	1	245	246	f	f	\N	2026-05-18 06:15:59.786296+00
1799	295	13	65	flashcard.reviewed	58	aug13	1	245	246	f	f	\N	2026-05-18 06:15:59.786296+00
1800	295	14	66	flashcard.reviewed	58	aug13	1	245	246	f	f	\N	2026-05-18 06:15:59.786296+00
1801	295	15	67	flashcard.reviewed	58	aug13	1	245	246	f	f	\N	2026-05-18 06:15:59.786296+00
1802	295	16	68	flashcard.reviewed	58	aug13	1	245	246	f	f	\N	2026-05-18 06:15:59.786296+00
826	118	10	62	flashcard.reviewed	58	aug13	1	79	80	f	f	\N	2026-05-18 06:02:03.47463+00
827	118	11	63	flashcard.reviewed	58	aug13	1	79	80	f	f	\N	2026-05-18 06:02:03.47463+00
828	118	12	64	flashcard.reviewed	58	aug13	1	79	80	f	f	\N	2026-05-18 06:02:03.47463+00
829	118	13	65	flashcard.reviewed	58	aug13	1	79	80	f	f	\N	2026-05-18 06:02:03.47463+00
830	118	14	66	flashcard.reviewed	58	aug13	1	79	80	f	f	\N	2026-05-18 06:02:03.47463+00
831	118	15	67	flashcard.reviewed	58	aug13	1	79	80	f	f	\N	2026-05-18 06:02:03.47463+00
832	118	16	68	flashcard.reviewed	58	aug13	1	79	80	f	f	\N	2026-05-18 06:02:03.47463+00
1483	236	11	63	flashcard.reviewed	58	aug13	1	185	186	f	f	\N	2026-05-18 06:15:50.879467+00
1484	236	12	64	flashcard.reviewed	58	aug13	1	185	186	f	f	\N	2026-05-18 06:15:50.879467+00
1485	236	13	65	flashcard.reviewed	58	aug13	1	185	186	f	f	\N	2026-05-18 06:15:50.879467+00
1486	236	14	66	flashcard.reviewed	58	aug13	1	185	186	f	f	\N	2026-05-18 06:15:50.879467+00
1487	236	15	67	flashcard.reviewed	58	aug13	1	185	186	f	f	\N	2026-05-18 06:15:50.879467+00
1488	236	16	68	flashcard.reviewed	58	aug13	1	185	186	f	f	\N	2026-05-18 06:15:50.879467+00
1561	248	11	63	flashcard.reviewed	58	aug13	1	198	199	f	f	\N	2026-05-18 06:15:51.928636+00
1562	248	12	64	flashcard.reviewed	58	aug13	1	198	199	f	f	\N	2026-05-18 06:15:51.928636+00
1563	248	13	65	flashcard.reviewed	58	aug13	1	198	199	f	f	\N	2026-05-18 06:15:51.928636+00
1564	248	14	66	flashcard.reviewed	58	aug13	1	198	199	f	f	\N	2026-05-18 06:15:51.928636+00
1565	248	15	67	flashcard.reviewed	58	aug13	1	198	199	f	f	\N	2026-05-18 06:15:51.928636+00
1566	248	16	68	flashcard.reviewed	58	aug13	1	198	199	f	f	\N	2026-05-18 06:15:51.928636+00
1658	268	12	64	flashcard.reviewed	58	aug13	1	217	218	f	f	\N	2026-05-18 06:15:55.79461+00
1659	268	13	65	flashcard.reviewed	58	aug13	1	217	218	f	f	\N	2026-05-18 06:15:55.79461+00
1660	268	14	66	flashcard.reviewed	58	aug13	1	217	218	f	f	\N	2026-05-18 06:15:55.79461+00
1661	268	15	67	flashcard.reviewed	58	aug13	1	217	218	f	f	\N	2026-05-18 06:15:55.79461+00
1662	268	16	68	flashcard.reviewed	58	aug13	1	217	218	f	f	\N	2026-05-18 06:15:55.79461+00
1753	286	12	64	flashcard.reviewed	58	aug13	1	236	237	f	f	\N	2026-05-18 06:15:58.995154+00
1754	286	13	65	flashcard.reviewed	58	aug13	1	236	237	f	f	\N	2026-05-18 06:15:58.995154+00
1755	286	14	66	flashcard.reviewed	58	aug13	1	236	237	f	f	\N	2026-05-18 06:15:58.995154+00
1756	286	15	67	flashcard.reviewed	58	aug13	1	236	237	f	f	\N	2026-05-18 06:15:58.995154+00
1757	286	16	68	flashcard.reviewed	58	aug13	1	236	237	f	f	\N	2026-05-18 06:15:58.995154+00
840	101	10	62	flashcard.reviewed	58	aug13	1	81	82	f	f	\N	2026-05-18 06:02:02.986672+00
841	101	11	63	flashcard.reviewed	58	aug13	1	81	82	f	f	\N	2026-05-18 06:02:02.986672+00
842	101	12	64	flashcard.reviewed	58	aug13	1	81	82	f	f	\N	2026-05-18 06:02:02.986672+00
843	101	13	65	flashcard.reviewed	58	aug13	1	81	82	f	f	\N	2026-05-18 06:02:02.986672+00
844	101	14	66	flashcard.reviewed	58	aug13	1	81	82	f	f	\N	2026-05-18 06:02:02.986672+00
845	101	15	67	flashcard.reviewed	58	aug13	1	81	82	f	f	\N	2026-05-18 06:02:02.986672+00
846	101	16	68	flashcard.reviewed	58	aug13	1	81	82	f	f	\N	2026-05-18 06:02:02.986672+00
1489	235	11	63	flashcard.reviewed	58	aug13	1	186	187	f	f	\N	2026-05-18 06:15:50.750717+00
1490	235	12	64	flashcard.reviewed	58	aug13	1	186	187	f	f	\N	2026-05-18 06:15:50.750717+00
1491	235	13	65	flashcard.reviewed	58	aug13	1	186	187	f	f	\N	2026-05-18 06:15:50.750717+00
1492	235	14	66	flashcard.reviewed	58	aug13	1	186	187	f	f	\N	2026-05-18 06:15:50.750717+00
1493	235	15	67	flashcard.reviewed	58	aug13	1	186	187	f	f	\N	2026-05-18 06:15:50.750717+00
1494	235	16	68	flashcard.reviewed	58	aug13	1	186	187	f	f	\N	2026-05-18 06:15:50.750717+00
1603	256	12	64	flashcard.reviewed	58	aug13	1	206	207	f	f	\N	2026-05-18 06:15:52.330211+00
1604	256	13	65	flashcard.reviewed	58	aug13	1	206	207	f	f	\N	2026-05-18 06:15:52.330211+00
1605	256	14	66	flashcard.reviewed	58	aug13	1	206	207	f	f	\N	2026-05-18 06:15:52.330211+00
1606	256	15	67	flashcard.reviewed	58	aug13	1	206	207	f	f	\N	2026-05-18 06:15:52.330211+00
1607	256	16	68	flashcard.reviewed	58	aug13	1	206	207	f	f	\N	2026-05-18 06:15:52.330211+00
1703	276	12	64	flashcard.reviewed	58	aug13	1	226	227	f	f	\N	2026-05-18 06:15:56.606602+00
1704	276	13	65	flashcard.reviewed	58	aug13	1	226	227	f	f	\N	2026-05-18 06:15:56.606602+00
1705	276	14	66	flashcard.reviewed	58	aug13	1	226	227	f	f	\N	2026-05-18 06:15:56.606602+00
1706	276	15	67	flashcard.reviewed	58	aug13	1	226	227	f	f	\N	2026-05-18 06:15:56.606602+00
1707	276	16	68	flashcard.reviewed	58	aug13	1	226	227	f	f	\N	2026-05-18 06:15:56.606602+00
1803	296	12	64	flashcard.reviewed	58	aug13	1	246	247	f	f	\N	2026-05-18 06:16:00.131585+00
1804	296	13	65	flashcard.reviewed	58	aug13	1	246	247	f	f	\N	2026-05-18 06:16:00.131585+00
1805	296	14	66	flashcard.reviewed	58	aug13	1	246	247	f	f	\N	2026-05-18 06:16:00.131585+00
1806	296	15	67	flashcard.reviewed	58	aug13	1	246	247	f	f	\N	2026-05-18 06:16:00.131585+00
1807	296	16	68	flashcard.reviewed	58	aug13	1	246	247	f	f	\N	2026-05-18 06:16:00.131585+00
861	130	10	62	flashcard.reviewed	58	aug13	1	84	85	f	f	\N	2026-05-18 06:02:06.000912+00
862	130	11	63	flashcard.reviewed	58	aug13	1	84	85	f	f	\N	2026-05-18 06:02:06.000912+00
863	130	12	64	flashcard.reviewed	58	aug13	1	84	85	f	f	\N	2026-05-18 06:02:06.000912+00
864	130	13	65	flashcard.reviewed	58	aug13	1	84	85	f	f	\N	2026-05-18 06:02:06.000912+00
865	130	14	66	flashcard.reviewed	58	aug13	1	84	85	f	f	\N	2026-05-18 06:02:06.000912+00
866	130	15	67	flashcard.reviewed	58	aug13	1	84	85	f	f	\N	2026-05-18 06:02:06.000912+00
867	130	16	68	flashcard.reviewed	58	aug13	1	84	85	f	f	\N	2026-05-18 06:02:06.000912+00
875	136	10	62	flashcard.reviewed	58	aug13	1	86	87	f	f	\N	2026-05-18 06:02:50.248314+00
876	136	11	63	flashcard.reviewed	58	aug13	1	86	87	f	f	\N	2026-05-18 06:02:50.248314+00
877	136	12	64	flashcard.reviewed	58	aug13	1	86	87	f	f	\N	2026-05-18 06:02:50.248314+00
878	136	13	65	flashcard.reviewed	58	aug13	1	86	87	f	f	\N	2026-05-18 06:02:50.248314+00
879	136	14	66	flashcard.reviewed	58	aug13	1	86	87	f	f	\N	2026-05-18 06:02:50.248314+00
880	136	15	67	flashcard.reviewed	58	aug13	1	86	87	f	f	\N	2026-05-18 06:02:50.248314+00
881	136	16	68	flashcard.reviewed	58	aug13	1	86	87	f	f	\N	2026-05-18 06:02:50.248314+00
882	137	10	62	flashcard.reviewed	58	aug13	1	87	88	f	f	\N	2026-05-18 06:02:50.275602+00
883	137	11	63	flashcard.reviewed	58	aug13	1	87	88	f	f	\N	2026-05-18 06:02:50.275602+00
884	137	12	64	flashcard.reviewed	58	aug13	1	87	88	f	f	\N	2026-05-18 06:02:50.275602+00
885	137	13	65	flashcard.reviewed	58	aug13	1	87	88	f	f	\N	2026-05-18 06:02:50.275602+00
886	137	14	66	flashcard.reviewed	58	aug13	1	87	88	f	f	\N	2026-05-18 06:02:50.275602+00
887	137	15	67	flashcard.reviewed	58	aug13	1	87	88	f	f	\N	2026-05-18 06:02:50.275602+00
888	137	16	68	flashcard.reviewed	58	aug13	1	87	88	f	f	\N	2026-05-18 06:02:50.275602+00
889	138	10	62	flashcard.reviewed	58	aug13	1	88	89	f	f	\N	2026-05-18 06:02:50.791352+00
890	138	11	63	flashcard.reviewed	58	aug13	1	88	89	f	f	\N	2026-05-18 06:02:50.791352+00
891	138	12	64	flashcard.reviewed	58	aug13	1	88	89	f	f	\N	2026-05-18 06:02:50.791352+00
892	138	13	65	flashcard.reviewed	58	aug13	1	88	89	f	f	\N	2026-05-18 06:02:50.791352+00
893	138	14	66	flashcard.reviewed	58	aug13	1	88	89	f	f	\N	2026-05-18 06:02:50.791352+00
894	138	15	67	flashcard.reviewed	58	aug13	1	88	89	f	f	\N	2026-05-18 06:02:50.791352+00
895	138	16	68	flashcard.reviewed	58	aug13	1	88	89	f	f	\N	2026-05-18 06:02:50.791352+00
896	139	10	62	flashcard.reviewed	58	aug13	1	89	90	f	f	\N	2026-05-18 06:02:50.815064+00
897	139	11	63	flashcard.reviewed	58	aug13	1	89	90	f	f	\N	2026-05-18 06:02:50.815064+00
898	139	12	64	flashcard.reviewed	58	aug13	1	89	90	f	f	\N	2026-05-18 06:02:50.815064+00
899	139	13	65	flashcard.reviewed	58	aug13	1	89	90	f	f	\N	2026-05-18 06:02:50.815064+00
900	139	14	66	flashcard.reviewed	58	aug13	1	89	90	f	f	\N	2026-05-18 06:02:50.815064+00
901	139	15	67	flashcard.reviewed	58	aug13	1	89	90	f	f	\N	2026-05-18 06:02:50.815064+00
902	139	16	68	flashcard.reviewed	58	aug13	1	89	90	f	f	\N	2026-05-18 06:02:50.815064+00
903	140	10	62	flashcard.reviewed	58	aug13	1	90	91	f	f	\N	2026-05-18 06:02:51.366149+00
904	140	11	63	flashcard.reviewed	58	aug13	1	90	91	f	f	\N	2026-05-18 06:02:51.366149+00
905	140	12	64	flashcard.reviewed	58	aug13	1	90	91	f	f	\N	2026-05-18 06:02:51.366149+00
906	140	13	65	flashcard.reviewed	58	aug13	1	90	91	f	f	\N	2026-05-18 06:02:51.366149+00
907	140	14	66	flashcard.reviewed	58	aug13	1	90	91	f	f	\N	2026-05-18 06:02:51.366149+00
908	140	15	67	flashcard.reviewed	58	aug13	1	90	91	f	f	\N	2026-05-18 06:02:51.366149+00
909	140	16	68	flashcard.reviewed	58	aug13	1	90	91	f	f	\N	2026-05-18 06:02:51.366149+00
910	141	10	62	flashcard.reviewed	58	aug13	1	91	92	f	f	\N	2026-05-18 06:02:51.388969+00
911	141	11	63	flashcard.reviewed	58	aug13	1	91	92	f	f	\N	2026-05-18 06:02:51.388969+00
912	141	12	64	flashcard.reviewed	58	aug13	1	91	92	f	f	\N	2026-05-18 06:02:51.388969+00
913	141	13	65	flashcard.reviewed	58	aug13	1	91	92	f	f	\N	2026-05-18 06:02:51.388969+00
914	141	14	66	flashcard.reviewed	58	aug13	1	91	92	f	f	\N	2026-05-18 06:02:51.388969+00
915	141	15	67	flashcard.reviewed	58	aug13	1	91	92	f	f	\N	2026-05-18 06:02:51.388969+00
916	141	16	68	flashcard.reviewed	58	aug13	1	91	92	f	f	\N	2026-05-18 06:02:51.388969+00
917	142	10	62	flashcard.reviewed	58	aug13	1	92	93	f	f	\N	2026-05-18 06:02:51.726708+00
918	142	11	63	flashcard.reviewed	58	aug13	1	92	93	f	f	\N	2026-05-18 06:02:51.726708+00
919	142	12	64	flashcard.reviewed	58	aug13	1	92	93	f	f	\N	2026-05-18 06:02:51.726708+00
920	142	13	65	flashcard.reviewed	58	aug13	1	92	93	f	f	\N	2026-05-18 06:02:51.726708+00
921	142	14	66	flashcard.reviewed	58	aug13	1	92	93	f	f	\N	2026-05-18 06:02:51.726708+00
922	142	15	67	flashcard.reviewed	58	aug13	1	92	93	f	f	\N	2026-05-18 06:02:51.726708+00
923	142	16	68	flashcard.reviewed	58	aug13	1	92	93	f	f	\N	2026-05-18 06:02:51.726708+00
924	143	10	62	flashcard.reviewed	58	aug13	1	93	94	f	f	\N	2026-05-18 06:02:51.756712+00
925	143	11	63	flashcard.reviewed	58	aug13	1	93	94	f	f	\N	2026-05-18 06:02:51.756712+00
926	143	12	64	flashcard.reviewed	58	aug13	1	93	94	f	f	\N	2026-05-18 06:02:51.756712+00
927	143	13	65	flashcard.reviewed	58	aug13	1	93	94	f	f	\N	2026-05-18 06:02:51.756712+00
928	143	14	66	flashcard.reviewed	58	aug13	1	93	94	f	f	\N	2026-05-18 06:02:51.756712+00
929	143	15	67	flashcard.reviewed	58	aug13	1	93	94	f	f	\N	2026-05-18 06:02:51.756712+00
930	143	16	68	flashcard.reviewed	58	aug13	1	93	94	f	f	\N	2026-05-18 06:02:51.756712+00
931	144	10	62	flashcard.reviewed	58	aug13	1	94	95	f	f	\N	2026-05-18 06:02:51.749967+00
932	144	11	63	flashcard.reviewed	58	aug13	1	94	95	f	f	\N	2026-05-18 06:02:51.749967+00
933	144	12	64	flashcard.reviewed	58	aug13	1	94	95	f	f	\N	2026-05-18 06:02:51.749967+00
934	144	13	65	flashcard.reviewed	58	aug13	1	94	95	f	f	\N	2026-05-18 06:02:51.749967+00
935	144	14	66	flashcard.reviewed	58	aug13	1	94	95	f	f	\N	2026-05-18 06:02:51.749967+00
936	144	15	67	flashcard.reviewed	58	aug13	1	94	95	f	f	\N	2026-05-18 06:02:51.749967+00
937	144	16	68	flashcard.reviewed	58	aug13	1	94	95	f	f	\N	2026-05-18 06:02:51.749967+00
938	145	10	62	flashcard.reviewed	58	aug13	1	95	96	f	f	\N	2026-05-18 06:02:51.781122+00
939	145	11	63	flashcard.reviewed	58	aug13	1	95	96	f	f	\N	2026-05-18 06:02:51.781122+00
940	145	12	64	flashcard.reviewed	58	aug13	1	95	96	f	f	\N	2026-05-18 06:02:51.781122+00
941	145	13	65	flashcard.reviewed	58	aug13	1	95	96	f	f	\N	2026-05-18 06:02:51.781122+00
942	145	14	66	flashcard.reviewed	58	aug13	1	95	96	f	f	\N	2026-05-18 06:02:51.781122+00
943	145	15	67	flashcard.reviewed	58	aug13	1	95	96	f	f	\N	2026-05-18 06:02:51.781122+00
944	145	16	68	flashcard.reviewed	58	aug13	1	95	96	f	f	\N	2026-05-18 06:02:51.781122+00
973	150	11	63	flashcard.reviewed	58	aug13	1	100	101	f	f	\N	2026-05-18 06:02:53.02787+00
974	150	12	64	flashcard.reviewed	58	aug13	1	100	101	f	f	\N	2026-05-18 06:02:53.02787+00
975	150	13	65	flashcard.reviewed	58	aug13	1	100	101	f	f	\N	2026-05-18 06:02:53.02787+00
976	150	14	66	flashcard.reviewed	58	aug13	1	100	101	f	f	\N	2026-05-18 06:02:53.02787+00
977	150	15	67	flashcard.reviewed	58	aug13	1	100	101	f	f	\N	2026-05-18 06:02:53.02787+00
978	150	16	68	flashcard.reviewed	58	aug13	1	100	101	f	f	\N	2026-05-18 06:02:53.02787+00
979	151	11	63	flashcard.reviewed	58	aug13	1	101	102	f	f	\N	2026-05-18 06:02:53.059383+00
980	151	12	64	flashcard.reviewed	58	aug13	1	101	102	f	f	\N	2026-05-18 06:02:53.059383+00
981	151	13	65	flashcard.reviewed	58	aug13	1	101	102	f	f	\N	2026-05-18 06:02:53.059383+00
982	151	14	66	flashcard.reviewed	58	aug13	1	101	102	f	f	\N	2026-05-18 06:02:53.059383+00
983	151	15	67	flashcard.reviewed	58	aug13	1	101	102	f	f	\N	2026-05-18 06:02:53.059383+00
984	151	16	68	flashcard.reviewed	58	aug13	1	101	102	f	f	\N	2026-05-18 06:02:53.059383+00
991	153	11	63	flashcard.reviewed	58	aug13	1	103	104	f	f	\N	2026-05-18 06:03:03.310411+00
992	153	12	64	flashcard.reviewed	58	aug13	1	103	104	f	f	\N	2026-05-18 06:03:03.310411+00
993	153	13	65	flashcard.reviewed	58	aug13	1	103	104	f	f	\N	2026-05-18 06:03:03.310411+00
994	153	14	66	flashcard.reviewed	58	aug13	1	103	104	f	f	\N	2026-05-18 06:03:03.310411+00
995	153	15	67	flashcard.reviewed	58	aug13	1	103	104	f	f	\N	2026-05-18 06:03:03.310411+00
996	153	16	68	flashcard.reviewed	58	aug13	1	103	104	f	f	\N	2026-05-18 06:03:03.310411+00
1009	156	11	63	flashcard.reviewed	58	aug13	1	106	107	f	f	\N	2026-05-18 06:03:03.699668+00
1010	156	12	64	flashcard.reviewed	58	aug13	1	106	107	f	f	\N	2026-05-18 06:03:03.699668+00
1011	156	13	65	flashcard.reviewed	58	aug13	1	106	107	f	f	\N	2026-05-18 06:03:03.699668+00
1012	156	14	66	flashcard.reviewed	58	aug13	1	106	107	f	f	\N	2026-05-18 06:03:03.699668+00
1013	156	15	67	flashcard.reviewed	58	aug13	1	106	107	f	f	\N	2026-05-18 06:03:03.699668+00
1014	156	16	68	flashcard.reviewed	58	aug13	1	106	107	f	f	\N	2026-05-18 06:03:03.699668+00
1027	159	11	63	flashcard.reviewed	58	aug13	1	109	110	f	f	\N	2026-05-18 06:03:04.12053+00
1028	159	12	64	flashcard.reviewed	58	aug13	1	109	110	f	f	\N	2026-05-18 06:03:04.12053+00
1029	159	13	65	flashcard.reviewed	58	aug13	1	109	110	f	f	\N	2026-05-18 06:03:04.12053+00
1030	159	14	66	flashcard.reviewed	58	aug13	1	109	110	f	f	\N	2026-05-18 06:03:04.12053+00
1031	159	15	67	flashcard.reviewed	58	aug13	1	109	110	f	f	\N	2026-05-18 06:03:04.12053+00
1032	159	16	68	flashcard.reviewed	58	aug13	1	109	110	f	f	\N	2026-05-18 06:03:04.12053+00
1057	163	11	63	flashcard.reviewed	58	aug13	1	114	115	f	f	\N	2026-05-18 06:03:05.020477+00
1058	163	12	64	flashcard.reviewed	58	aug13	1	114	115	f	f	\N	2026-05-18 06:03:05.020477+00
1059	163	13	65	flashcard.reviewed	58	aug13	1	114	115	f	f	\N	2026-05-18 06:03:05.020477+00
1060	163	14	66	flashcard.reviewed	58	aug13	1	114	115	f	f	\N	2026-05-18 06:03:05.020477+00
1061	163	15	67	flashcard.reviewed	58	aug13	1	114	115	f	f	\N	2026-05-18 06:03:05.020477+00
1062	163	16	68	flashcard.reviewed	58	aug13	1	114	115	f	f	\N	2026-05-18 06:03:05.020477+00
1075	167	11	63	flashcard.reviewed	58	aug13	1	117	118	f	f	\N	2026-05-18 06:03:05.504972+00
1076	167	12	64	flashcard.reviewed	58	aug13	1	117	118	f	f	\N	2026-05-18 06:03:05.504972+00
1077	167	13	65	flashcard.reviewed	58	aug13	1	117	118	f	f	\N	2026-05-18 06:03:05.504972+00
1078	167	14	66	flashcard.reviewed	58	aug13	1	117	118	f	f	\N	2026-05-18 06:03:05.504972+00
1079	167	15	67	flashcard.reviewed	58	aug13	1	117	118	f	f	\N	2026-05-18 06:03:05.504972+00
1080	167	16	68	flashcard.reviewed	58	aug13	1	117	118	f	f	\N	2026-05-18 06:03:05.504972+00
1087	169	11	63	flashcard.reviewed	58	aug13	1	119	120	f	f	\N	2026-05-18 06:03:06.313499+00
1088	169	12	64	flashcard.reviewed	58	aug13	1	119	120	f	f	\N	2026-05-18 06:03:06.313499+00
1089	169	13	65	flashcard.reviewed	58	aug13	1	119	120	f	f	\N	2026-05-18 06:03:06.313499+00
1090	169	14	66	flashcard.reviewed	58	aug13	1	119	120	f	f	\N	2026-05-18 06:03:06.313499+00
1091	169	15	67	flashcard.reviewed	58	aug13	1	119	120	f	f	\N	2026-05-18 06:03:06.313499+00
1092	169	16	68	flashcard.reviewed	58	aug13	1	119	120	f	f	\N	2026-05-18 06:03:06.313499+00
1099	171	11	63	flashcard.reviewed	58	aug13	1	121	122	f	f	\N	2026-05-18 06:03:07.173934+00
1100	171	12	64	flashcard.reviewed	58	aug13	1	121	122	f	f	\N	2026-05-18 06:03:07.173934+00
1101	171	13	65	flashcard.reviewed	58	aug13	1	121	122	f	f	\N	2026-05-18 06:03:07.173934+00
1102	171	14	66	flashcard.reviewed	58	aug13	1	121	122	f	f	\N	2026-05-18 06:03:07.173934+00
1103	171	15	67	flashcard.reviewed	58	aug13	1	121	122	f	f	\N	2026-05-18 06:03:07.173934+00
945	146	10	62	flashcard.reviewed	58	aug13	1	96	97	f	f	\N	2026-05-18 06:02:52.083882+00
946	146	11	63	flashcard.reviewed	58	aug13	1	96	97	f	f	\N	2026-05-18 06:02:52.083882+00
947	146	12	64	flashcard.reviewed	58	aug13	1	96	97	f	f	\N	2026-05-18 06:02:52.083882+00
948	146	13	65	flashcard.reviewed	58	aug13	1	96	97	f	f	\N	2026-05-18 06:02:52.083882+00
949	146	14	66	flashcard.reviewed	58	aug13	1	96	97	f	f	\N	2026-05-18 06:02:52.083882+00
950	146	15	67	flashcard.reviewed	58	aug13	1	96	97	f	f	\N	2026-05-18 06:02:52.083882+00
951	146	16	68	flashcard.reviewed	58	aug13	1	96	97	f	f	\N	2026-05-18 06:02:52.083882+00
959	148	10	62	flashcard.reviewed	58	aug13	1	98	99	f	f	\N	2026-05-18 06:02:53.004953+00
960	148	11	63	flashcard.reviewed	58	aug13	1	98	99	f	f	\N	2026-05-18 06:02:53.004953+00
961	148	12	64	flashcard.reviewed	58	aug13	1	98	99	f	f	\N	2026-05-18 06:02:53.004953+00
962	148	13	65	flashcard.reviewed	58	aug13	1	98	99	f	f	\N	2026-05-18 06:02:53.004953+00
963	148	14	66	flashcard.reviewed	58	aug13	1	98	99	f	f	\N	2026-05-18 06:02:53.004953+00
964	148	15	67	flashcard.reviewed	58	aug13	1	98	99	f	f	\N	2026-05-18 06:02:53.004953+00
965	148	16	68	flashcard.reviewed	58	aug13	1	98	99	f	f	\N	2026-05-18 06:02:53.004953+00
1003	155	11	63	flashcard.reviewed	58	aug13	1	105	106	f	f	\N	2026-05-18 06:03:03.703447+00
1004	155	12	64	flashcard.reviewed	58	aug13	1	105	106	f	f	\N	2026-05-18 06:03:03.703447+00
1005	155	13	65	flashcard.reviewed	58	aug13	1	105	106	f	f	\N	2026-05-18 06:03:03.703447+00
1006	155	14	66	flashcard.reviewed	58	aug13	1	105	106	f	f	\N	2026-05-18 06:03:03.703447+00
1007	155	15	67	flashcard.reviewed	58	aug13	1	105	106	f	f	\N	2026-05-18 06:03:03.703447+00
1008	155	16	68	flashcard.reviewed	58	aug13	1	105	106	f	f	\N	2026-05-18 06:03:03.703447+00
1021	158	11	63	flashcard.reviewed	58	aug13	1	108	109	f	f	\N	2026-05-18 06:03:04.101222+00
1022	158	12	64	flashcard.reviewed	58	aug13	1	108	109	f	f	\N	2026-05-18 06:03:04.101222+00
1023	158	13	65	flashcard.reviewed	58	aug13	1	108	109	f	f	\N	2026-05-18 06:03:04.101222+00
1024	158	14	66	flashcard.reviewed	58	aug13	1	108	109	f	f	\N	2026-05-18 06:03:04.101222+00
1025	158	15	67	flashcard.reviewed	58	aug13	1	108	109	f	f	\N	2026-05-18 06:03:04.101222+00
1026	158	16	68	flashcard.reviewed	58	aug13	1	108	109	f	f	\N	2026-05-18 06:03:04.101222+00
1033	160	11	63	flashcard.reviewed	58	aug13	1	110	111	f	f	\N	2026-05-18 06:03:04.749289+00
1034	160	12	64	flashcard.reviewed	58	aug13	1	110	111	f	f	\N	2026-05-18 06:03:04.749289+00
1035	160	13	65	flashcard.reviewed	58	aug13	1	110	111	f	f	\N	2026-05-18 06:03:04.749289+00
1036	160	14	66	flashcard.reviewed	58	aug13	1	110	111	f	f	\N	2026-05-18 06:03:04.749289+00
1037	160	15	67	flashcard.reviewed	58	aug13	1	110	111	f	f	\N	2026-05-18 06:03:04.749289+00
1038	160	16	68	flashcard.reviewed	58	aug13	1	110	111	f	f	\N	2026-05-18 06:03:04.749289+00
1069	166	11	63	flashcard.reviewed	58	aug13	1	116	117	f	f	\N	2026-05-18 06:03:05.481438+00
1070	166	12	64	flashcard.reviewed	58	aug13	1	116	117	f	f	\N	2026-05-18 06:03:05.481438+00
1071	166	13	65	flashcard.reviewed	58	aug13	1	116	117	f	f	\N	2026-05-18 06:03:05.481438+00
1072	166	14	66	flashcard.reviewed	58	aug13	1	116	117	f	f	\N	2026-05-18 06:03:05.481438+00
1073	166	15	67	flashcard.reviewed	58	aug13	1	116	117	f	f	\N	2026-05-18 06:03:05.481438+00
1074	166	16	68	flashcard.reviewed	58	aug13	1	116	117	f	f	\N	2026-05-18 06:03:05.481438+00
1111	174	11	63	flashcard.reviewed	58	aug13	1	123	124	f	f	\N	2026-05-18 06:03:07.602484+00
1112	174	12	64	flashcard.reviewed	58	aug13	1	123	124	f	f	\N	2026-05-18 06:03:07.602484+00
1113	174	13	65	flashcard.reviewed	58	aug13	1	123	124	f	f	\N	2026-05-18 06:03:07.602484+00
1114	174	14	66	flashcard.reviewed	58	aug13	1	123	124	f	f	\N	2026-05-18 06:03:07.602484+00
1115	174	15	67	flashcard.reviewed	58	aug13	1	123	124	f	f	\N	2026-05-18 06:03:07.602484+00
1116	174	16	68	flashcard.reviewed	58	aug13	1	123	124	f	f	\N	2026-05-18 06:03:07.602484+00
1201	188	11	63	flashcard.reviewed	58	aug13	1	138	139	f	f	\N	2026-05-18 06:03:08.820445+00
1202	188	12	64	flashcard.reviewed	58	aug13	1	138	139	f	f	\N	2026-05-18 06:03:08.820445+00
1203	188	13	65	flashcard.reviewed	58	aug13	1	138	139	f	f	\N	2026-05-18 06:03:08.820445+00
1204	188	14	66	flashcard.reviewed	58	aug13	1	138	139	f	f	\N	2026-05-18 06:03:08.820445+00
1205	188	15	67	flashcard.reviewed	58	aug13	1	138	139	f	f	\N	2026-05-18 06:03:08.820445+00
1206	188	16	68	flashcard.reviewed	58	aug13	1	138	139	f	f	\N	2026-05-18 06:03:08.820445+00
1315	207	11	63	flashcard.reviewed	58	aug13	1	157	158	f	f	\N	2026-05-18 06:03:11.333696+00
1316	207	12	64	flashcard.reviewed	58	aug13	1	157	158	f	f	\N	2026-05-18 06:03:11.333696+00
1317	207	13	65	flashcard.reviewed	58	aug13	1	157	158	f	f	\N	2026-05-18 06:03:11.333696+00
1318	207	14	66	flashcard.reviewed	58	aug13	1	157	158	f	f	\N	2026-05-18 06:03:11.333696+00
1319	207	15	67	flashcard.reviewed	58	aug13	1	157	158	f	f	\N	2026-05-18 06:03:11.333696+00
1320	207	16	68	flashcard.reviewed	58	aug13	1	157	158	f	f	\N	2026-05-18 06:03:11.333696+00
1495	238	11	63	flashcard.reviewed	58	aug13	1	187	188	f	f	\N	2026-05-18 06:15:50.872597+00
1496	238	12	64	flashcard.reviewed	58	aug13	1	187	188	f	f	\N	2026-05-18 06:15:50.872597+00
1497	238	13	65	flashcard.reviewed	58	aug13	1	187	188	f	f	\N	2026-05-18 06:15:50.872597+00
1498	238	14	66	flashcard.reviewed	58	aug13	1	187	188	f	f	\N	2026-05-18 06:15:50.872597+00
1499	238	15	67	flashcard.reviewed	58	aug13	1	187	188	f	f	\N	2026-05-18 06:15:50.872597+00
1500	238	16	68	flashcard.reviewed	58	aug13	1	187	188	f	f	\N	2026-05-18 06:15:50.872597+00
1608	257	12	64	flashcard.reviewed	58	aug13	1	207	208	f	f	\N	2026-05-18 06:15:52.718226+00
1609	257	13	65	flashcard.reviewed	58	aug13	1	207	208	f	f	\N	2026-05-18 06:15:52.718226+00
1610	257	14	66	flashcard.reviewed	58	aug13	1	207	208	f	f	\N	2026-05-18 06:15:52.718226+00
952	147	10	62	flashcard.reviewed	58	aug13	1	97	98	f	f	\N	2026-05-18 06:02:52.108165+00
953	147	11	63	flashcard.reviewed	58	aug13	1	97	98	f	f	\N	2026-05-18 06:02:52.108165+00
954	147	12	64	flashcard.reviewed	58	aug13	1	97	98	f	f	\N	2026-05-18 06:02:52.108165+00
955	147	13	65	flashcard.reviewed	58	aug13	1	97	98	f	f	\N	2026-05-18 06:02:52.108165+00
956	147	14	66	flashcard.reviewed	58	aug13	1	97	98	f	f	\N	2026-05-18 06:02:52.108165+00
957	147	15	67	flashcard.reviewed	58	aug13	1	97	98	f	f	\N	2026-05-18 06:02:52.108165+00
958	147	16	68	flashcard.reviewed	58	aug13	1	97	98	f	f	\N	2026-05-18 06:02:52.108165+00
1015	157	11	63	flashcard.reviewed	58	aug13	1	107	108	f	f	\N	2026-05-18 06:03:03.731368+00
1016	157	12	64	flashcard.reviewed	58	aug13	1	107	108	f	f	\N	2026-05-18 06:03:03.731368+00
1017	157	13	65	flashcard.reviewed	58	aug13	1	107	108	f	f	\N	2026-05-18 06:03:03.731368+00
1018	157	14	66	flashcard.reviewed	58	aug13	1	107	108	f	f	\N	2026-05-18 06:03:03.731368+00
1019	157	15	67	flashcard.reviewed	58	aug13	1	107	108	f	f	\N	2026-05-18 06:03:03.731368+00
1020	157	16	68	flashcard.reviewed	58	aug13	1	107	108	f	f	\N	2026-05-18 06:03:03.731368+00
1039	161	11	63	flashcard.reviewed	58	aug13	1	111	112	f	f	\N	2026-05-18 06:03:04.77535+00
1040	161	12	64	flashcard.reviewed	58	aug13	1	111	112	f	f	\N	2026-05-18 06:03:04.77535+00
1041	161	13	65	flashcard.reviewed	58	aug13	1	111	112	f	f	\N	2026-05-18 06:03:04.77535+00
1042	161	14	66	flashcard.reviewed	58	aug13	1	111	112	f	f	\N	2026-05-18 06:03:04.77535+00
1043	161	15	67	flashcard.reviewed	58	aug13	1	111	112	f	f	\N	2026-05-18 06:03:04.77535+00
1044	161	16	68	flashcard.reviewed	58	aug13	1	111	112	f	f	\N	2026-05-18 06:03:04.77535+00
1147	178	11	63	flashcard.reviewed	58	aug13	1	129	130	f	f	\N	2026-05-18 06:03:07.663191+00
1148	178	12	64	flashcard.reviewed	58	aug13	1	129	130	f	f	\N	2026-05-18 06:03:07.663191+00
1149	178	13	65	flashcard.reviewed	58	aug13	1	129	130	f	f	\N	2026-05-18 06:03:07.663191+00
1150	178	14	66	flashcard.reviewed	58	aug13	1	129	130	f	f	\N	2026-05-18 06:03:07.663191+00
1151	178	15	67	flashcard.reviewed	58	aug13	1	129	130	f	f	\N	2026-05-18 06:03:07.663191+00
1152	178	16	68	flashcard.reviewed	58	aug13	1	129	130	f	f	\N	2026-05-18 06:03:07.663191+00
1267	199	11	63	flashcard.reviewed	58	aug13	1	149	150	f	f	\N	2026-05-18 06:03:09.175872+00
1268	199	12	64	flashcard.reviewed	58	aug13	1	149	150	f	f	\N	2026-05-18 06:03:09.175872+00
1269	199	13	65	flashcard.reviewed	58	aug13	1	149	150	f	f	\N	2026-05-18 06:03:09.175872+00
1270	199	14	66	flashcard.reviewed	58	aug13	1	149	150	f	f	\N	2026-05-18 06:03:09.175872+00
1271	199	15	67	flashcard.reviewed	58	aug13	1	149	150	f	f	\N	2026-05-18 06:03:09.175872+00
1272	199	16	68	flashcard.reviewed	58	aug13	1	149	150	f	f	\N	2026-05-18 06:03:09.175872+00
1381	218	11	63	flashcard.reviewed	58	aug13	1	168	169	f	f	\N	2026-05-18 06:03:13.447292+00
1382	218	12	64	flashcard.reviewed	58	aug13	1	168	169	f	f	\N	2026-05-18 06:03:13.447292+00
1383	218	13	65	flashcard.reviewed	58	aug13	1	168	169	f	f	\N	2026-05-18 06:03:13.447292+00
1384	218	14	66	flashcard.reviewed	58	aug13	1	168	169	f	f	\N	2026-05-18 06:03:13.447292+00
1385	218	15	67	flashcard.reviewed	58	aug13	1	168	169	f	f	\N	2026-05-18 06:03:13.447292+00
1386	218	16	68	flashcard.reviewed	58	aug13	1	168	169	f	f	\N	2026-05-18 06:03:13.447292+00
1501	237	11	63	flashcard.reviewed	58	aug13	1	188	189	f	f	\N	2026-05-18 06:15:50.789295+00
1502	237	12	64	flashcard.reviewed	58	aug13	1	188	189	f	f	\N	2026-05-18 06:15:50.789295+00
1503	237	13	65	flashcard.reviewed	58	aug13	1	188	189	f	f	\N	2026-05-18 06:15:50.789295+00
1504	237	14	66	flashcard.reviewed	58	aug13	1	188	189	f	f	\N	2026-05-18 06:15:50.789295+00
1505	237	15	67	flashcard.reviewed	58	aug13	1	188	189	f	f	\N	2026-05-18 06:15:50.789295+00
1506	237	16	68	flashcard.reviewed	58	aug13	1	188	189	f	f	\N	2026-05-18 06:15:50.789295+00
1613	258	12	64	flashcard.reviewed	58	aug13	1	208	209	f	f	\N	2026-05-18 06:15:53.368838+00
1614	258	13	65	flashcard.reviewed	58	aug13	1	208	209	f	f	\N	2026-05-18 06:15:53.368838+00
1615	258	14	66	flashcard.reviewed	58	aug13	1	208	209	f	f	\N	2026-05-18 06:15:53.368838+00
1616	258	15	67	flashcard.reviewed	58	aug13	1	208	209	f	f	\N	2026-05-18 06:15:53.368838+00
1617	258	16	68	flashcard.reviewed	58	aug13	1	208	209	f	f	\N	2026-05-18 06:15:53.368838+00
1713	278	12	64	flashcard.reviewed	58	aug13	1	228	229	f	f	\N	2026-05-18 06:15:57.290229+00
1714	278	13	65	flashcard.reviewed	58	aug13	1	228	229	f	f	\N	2026-05-18 06:15:57.290229+00
1715	278	14	66	flashcard.reviewed	58	aug13	1	228	229	f	f	\N	2026-05-18 06:15:57.290229+00
1716	278	15	67	flashcard.reviewed	58	aug13	1	228	229	f	f	\N	2026-05-18 06:15:57.290229+00
1717	278	16	68	flashcard.reviewed	58	aug13	1	228	229	f	f	\N	2026-05-18 06:15:57.290229+00
1813	298	12	64	flashcard.reviewed	58	aug13	1	248	249	f	f	\N	2026-05-18 06:16:00.770954+00
1814	298	13	65	flashcard.reviewed	58	aug13	1	248	249	f	f	\N	2026-05-18 06:16:00.770954+00
1815	298	14	66	flashcard.reviewed	58	aug13	1	248	249	f	f	\N	2026-05-18 06:16:00.770954+00
1816	298	15	67	flashcard.reviewed	58	aug13	1	248	249	f	f	\N	2026-05-18 06:16:00.770954+00
1817	298	16	68	flashcard.reviewed	58	aug13	1	248	249	f	f	\N	2026-05-18 06:16:00.770954+00
966	149	10	62	flashcard.reviewed	58	aug13	1	99	100	f	t	2026-05-18 06:02:53.386+00	2026-05-18 06:02:53.033706+00
967	149	11	63	flashcard.reviewed	58	aug13	1	99	100	f	f	\N	2026-05-18 06:02:53.033706+00
968	149	12	64	flashcard.reviewed	58	aug13	1	99	100	f	f	\N	2026-05-18 06:02:53.033706+00
969	149	13	65	flashcard.reviewed	58	aug13	1	99	100	f	f	\N	2026-05-18 06:02:53.033706+00
970	149	14	66	flashcard.reviewed	58	aug13	1	99	100	f	f	\N	2026-05-18 06:02:53.033706+00
971	149	15	67	flashcard.reviewed	58	aug13	1	99	100	f	f	\N	2026-05-18 06:02:53.033706+00
972	149	16	68	flashcard.reviewed	58	aug13	1	99	100	f	f	\N	2026-05-18 06:02:53.033706+00
985	152	11	63	flashcard.reviewed	58	aug13	1	102	103	f	f	\N	2026-05-18 06:03:03.287372+00
986	152	12	64	flashcard.reviewed	58	aug13	1	102	103	f	f	\N	2026-05-18 06:03:03.287372+00
987	152	13	65	flashcard.reviewed	58	aug13	1	102	103	f	f	\N	2026-05-18 06:03:03.287372+00
988	152	14	66	flashcard.reviewed	58	aug13	1	102	103	f	f	\N	2026-05-18 06:03:03.287372+00
989	152	15	67	flashcard.reviewed	58	aug13	1	102	103	f	f	\N	2026-05-18 06:03:03.287372+00
990	152	16	68	flashcard.reviewed	58	aug13	1	102	103	f	f	\N	2026-05-18 06:03:03.287372+00
997	154	11	63	flashcard.reviewed	58	aug13	1	104	105	f	f	\N	2026-05-18 06:03:03.668456+00
998	154	12	64	flashcard.reviewed	58	aug13	1	104	105	f	f	\N	2026-05-18 06:03:03.668456+00
999	154	13	65	flashcard.reviewed	58	aug13	1	104	105	f	f	\N	2026-05-18 06:03:03.668456+00
1000	154	14	66	flashcard.reviewed	58	aug13	1	104	105	f	f	\N	2026-05-18 06:03:03.668456+00
1001	154	15	67	flashcard.reviewed	58	aug13	1	104	105	f	f	\N	2026-05-18 06:03:03.668456+00
1002	154	16	68	flashcard.reviewed	58	aug13	1	104	105	f	f	\N	2026-05-18 06:03:03.668456+00
1045	162	11	63	flashcard.reviewed	58	aug13	1	112	113	f	f	\N	2026-05-18 06:03:04.997395+00
1046	162	12	64	flashcard.reviewed	58	aug13	1	112	113	f	f	\N	2026-05-18 06:03:04.997395+00
1047	162	13	65	flashcard.reviewed	58	aug13	1	112	113	f	f	\N	2026-05-18 06:03:04.997395+00
1048	162	14	66	flashcard.reviewed	58	aug13	1	112	113	f	f	\N	2026-05-18 06:03:04.997395+00
1049	162	15	67	flashcard.reviewed	58	aug13	1	112	113	f	f	\N	2026-05-18 06:03:04.997395+00
1050	162	16	68	flashcard.reviewed	58	aug13	1	112	113	f	f	\N	2026-05-18 06:03:04.997395+00
1051	165	11	63	flashcard.reviewed	58	aug13	1	113	114	f	f	\N	2026-05-18 06:03:05.031524+00
1052	165	12	64	flashcard.reviewed	58	aug13	1	113	114	f	f	\N	2026-05-18 06:03:05.031524+00
1053	165	13	65	flashcard.reviewed	58	aug13	1	113	114	f	f	\N	2026-05-18 06:03:05.031524+00
1054	165	14	66	flashcard.reviewed	58	aug13	1	113	114	f	f	\N	2026-05-18 06:03:05.031524+00
1055	165	15	67	flashcard.reviewed	58	aug13	1	113	114	f	f	\N	2026-05-18 06:03:05.031524+00
1056	165	16	68	flashcard.reviewed	58	aug13	1	113	114	f	f	\N	2026-05-18 06:03:05.031524+00
1063	164	11	63	flashcard.reviewed	58	aug13	1	115	116	f	f	\N	2026-05-18 06:03:05.04571+00
1064	164	12	64	flashcard.reviewed	58	aug13	1	115	116	f	f	\N	2026-05-18 06:03:05.04571+00
1065	164	13	65	flashcard.reviewed	58	aug13	1	115	116	f	f	\N	2026-05-18 06:03:05.04571+00
1066	164	14	66	flashcard.reviewed	58	aug13	1	115	116	f	f	\N	2026-05-18 06:03:05.04571+00
1067	164	15	67	flashcard.reviewed	58	aug13	1	115	116	f	f	\N	2026-05-18 06:03:05.04571+00
1068	164	16	68	flashcard.reviewed	58	aug13	1	115	116	f	f	\N	2026-05-18 06:03:05.04571+00
1081	168	11	63	flashcard.reviewed	58	aug13	1	118	119	f	f	\N	2026-05-18 06:03:06.28478+00
1082	168	12	64	flashcard.reviewed	58	aug13	1	118	119	f	f	\N	2026-05-18 06:03:06.28478+00
1083	168	13	65	flashcard.reviewed	58	aug13	1	118	119	f	f	\N	2026-05-18 06:03:06.28478+00
1084	168	14	66	flashcard.reviewed	58	aug13	1	118	119	f	f	\N	2026-05-18 06:03:06.28478+00
1085	168	15	67	flashcard.reviewed	58	aug13	1	118	119	f	f	\N	2026-05-18 06:03:06.28478+00
1086	168	16	68	flashcard.reviewed	58	aug13	1	118	119	f	f	\N	2026-05-18 06:03:06.28478+00
1093	170	11	63	flashcard.reviewed	58	aug13	1	120	121	f	f	\N	2026-05-18 06:03:07.14759+00
1094	170	12	64	flashcard.reviewed	58	aug13	1	120	121	f	f	\N	2026-05-18 06:03:07.14759+00
1095	170	13	65	flashcard.reviewed	58	aug13	1	120	121	f	f	\N	2026-05-18 06:03:07.14759+00
1096	170	14	66	flashcard.reviewed	58	aug13	1	120	121	f	f	\N	2026-05-18 06:03:07.14759+00
1097	170	15	67	flashcard.reviewed	58	aug13	1	120	121	f	f	\N	2026-05-18 06:03:07.14759+00
1098	170	16	68	flashcard.reviewed	58	aug13	1	120	121	f	f	\N	2026-05-18 06:03:07.14759+00
1105	172	11	63	flashcard.reviewed	58	aug13	1	122	123	f	f	\N	2026-05-18 06:03:07.536054+00
1106	172	12	64	flashcard.reviewed	58	aug13	1	122	123	f	f	\N	2026-05-18 06:03:07.536054+00
1107	172	13	65	flashcard.reviewed	58	aug13	1	122	123	f	f	\N	2026-05-18 06:03:07.536054+00
1108	172	14	66	flashcard.reviewed	58	aug13	1	122	123	f	f	\N	2026-05-18 06:03:07.536054+00
1109	172	15	67	flashcard.reviewed	58	aug13	1	122	123	f	f	\N	2026-05-18 06:03:07.536054+00
1110	172	16	68	flashcard.reviewed	58	aug13	1	122	123	f	f	\N	2026-05-18 06:03:07.536054+00
1117	175	11	63	flashcard.reviewed	58	aug13	1	124	125	f	f	\N	2026-05-18 06:03:07.635293+00
1118	175	12	64	flashcard.reviewed	58	aug13	1	124	125	f	f	\N	2026-05-18 06:03:07.635293+00
1119	175	13	65	flashcard.reviewed	58	aug13	1	124	125	f	f	\N	2026-05-18 06:03:07.635293+00
1120	175	14	66	flashcard.reviewed	58	aug13	1	124	125	f	f	\N	2026-05-18 06:03:07.635293+00
1121	175	15	67	flashcard.reviewed	58	aug13	1	124	125	f	f	\N	2026-05-18 06:03:07.635293+00
1122	175	16	68	flashcard.reviewed	58	aug13	1	124	125	f	f	\N	2026-05-18 06:03:07.635293+00
1141	176	11	63	flashcard.reviewed	58	aug13	1	128	129	f	f	\N	2026-05-18 06:03:07.631941+00
1142	176	12	64	flashcard.reviewed	58	aug13	1	128	129	f	f	\N	2026-05-18 06:03:07.631941+00
1143	176	13	65	flashcard.reviewed	58	aug13	1	128	129	f	f	\N	2026-05-18 06:03:07.631941+00
1144	176	14	66	flashcard.reviewed	58	aug13	1	128	129	f	f	\N	2026-05-18 06:03:07.631941+00
1104	171	16	68	flashcard.reviewed	58	aug13	1	121	122	f	f	\N	2026-05-18 06:03:07.173934+00
1171	183	11	63	flashcard.reviewed	58	aug13	1	133	134	f	f	\N	2026-05-18 06:03:08.076482+00
1172	183	12	64	flashcard.reviewed	58	aug13	1	133	134	f	f	\N	2026-05-18 06:03:08.076482+00
1173	183	13	65	flashcard.reviewed	58	aug13	1	133	134	f	f	\N	2026-05-18 06:03:08.076482+00
1174	183	14	66	flashcard.reviewed	58	aug13	1	133	134	f	f	\N	2026-05-18 06:03:08.076482+00
1175	183	15	67	flashcard.reviewed	58	aug13	1	133	134	f	f	\N	2026-05-18 06:03:08.076482+00
1176	183	16	68	flashcard.reviewed	58	aug13	1	133	134	f	f	\N	2026-05-18 06:03:08.076482+00
1303	205	11	63	flashcard.reviewed	58	aug13	1	155	156	f	f	\N	2026-05-18 06:03:10.493241+00
1304	205	12	64	flashcard.reviewed	58	aug13	1	155	156	f	f	\N	2026-05-18 06:03:10.493241+00
1305	205	13	65	flashcard.reviewed	58	aug13	1	155	156	f	f	\N	2026-05-18 06:03:10.493241+00
1306	205	14	66	flashcard.reviewed	58	aug13	1	155	156	f	f	\N	2026-05-18 06:03:10.493241+00
1307	205	15	67	flashcard.reviewed	58	aug13	1	155	156	f	f	\N	2026-05-18 06:03:10.493241+00
1308	205	16	68	flashcard.reviewed	58	aug13	1	155	156	f	f	\N	2026-05-18 06:03:10.493241+00
1507	239	11	63	flashcard.reviewed	58	aug13	1	189	190	f	f	\N	2026-05-18 06:15:50.913633+00
1508	239	12	64	flashcard.reviewed	58	aug13	1	189	190	f	f	\N	2026-05-18 06:15:50.913633+00
1509	239	13	65	flashcard.reviewed	58	aug13	1	189	190	f	f	\N	2026-05-18 06:15:50.913633+00
1510	239	14	66	flashcard.reviewed	58	aug13	1	189	190	f	f	\N	2026-05-18 06:15:50.913633+00
1511	239	15	67	flashcard.reviewed	58	aug13	1	189	190	f	f	\N	2026-05-18 06:15:50.913633+00
1512	239	16	68	flashcard.reviewed	58	aug13	1	189	190	f	f	\N	2026-05-18 06:15:50.913633+00
1618	259	12	64	flashcard.reviewed	58	aug13	1	209	210	f	f	\N	2026-05-18 06:15:53.769364+00
1619	259	13	65	flashcard.reviewed	58	aug13	1	209	210	f	f	\N	2026-05-18 06:15:53.769364+00
1620	259	14	66	flashcard.reviewed	58	aug13	1	209	210	f	f	\N	2026-05-18 06:15:53.769364+00
1621	259	15	67	flashcard.reviewed	58	aug13	1	209	210	f	f	\N	2026-05-18 06:15:53.769364+00
1622	259	16	68	flashcard.reviewed	58	aug13	1	209	210	f	f	\N	2026-05-18 06:15:53.769364+00
1718	279	12	64	flashcard.reviewed	58	aug13	1	229	230	f	f	\N	2026-05-18 06:15:57.635788+00
1719	279	13	65	flashcard.reviewed	58	aug13	1	229	230	f	f	\N	2026-05-18 06:15:57.635788+00
1720	279	14	66	flashcard.reviewed	58	aug13	1	229	230	f	f	\N	2026-05-18 06:15:57.635788+00
1721	279	15	67	flashcard.reviewed	58	aug13	1	229	230	f	f	\N	2026-05-18 06:15:57.635788+00
1722	279	16	68	flashcard.reviewed	58	aug13	1	229	230	f	f	\N	2026-05-18 06:15:57.635788+00
1818	299	12	64	flashcard.reviewed	58	aug13	1	249	250	f	f	\N	2026-05-18 06:16:01.10575+00
1819	299	13	65	flashcard.reviewed	58	aug13	1	249	250	f	f	\N	2026-05-18 06:16:01.10575+00
1820	299	14	66	flashcard.reviewed	58	aug13	1	249	250	f	f	\N	2026-05-18 06:16:01.10575+00
1821	299	15	67	flashcard.reviewed	58	aug13	1	249	250	f	f	\N	2026-05-18 06:16:01.10575+00
1822	299	16	68	flashcard.reviewed	58	aug13	1	249	250	f	f	\N	2026-05-18 06:16:01.10575+00
1123	173	11	63	flashcard.reviewed	58	aug13	1	125	126	f	f	\N	2026-05-18 06:03:07.570078+00
1124	173	12	64	flashcard.reviewed	58	aug13	1	125	126	f	f	\N	2026-05-18 06:03:07.570078+00
1125	173	13	65	flashcard.reviewed	58	aug13	1	125	126	f	f	\N	2026-05-18 06:03:07.570078+00
1126	173	14	66	flashcard.reviewed	58	aug13	1	125	126	f	f	\N	2026-05-18 06:03:07.570078+00
1127	173	15	67	flashcard.reviewed	58	aug13	1	125	126	f	f	\N	2026-05-18 06:03:07.570078+00
1128	173	16	68	flashcard.reviewed	58	aug13	1	125	126	f	f	\N	2026-05-18 06:03:07.570078+00
1129	177	11	63	flashcard.reviewed	58	aug13	1	126	127	f	f	\N	2026-05-18 06:03:07.668504+00
1130	177	12	64	flashcard.reviewed	58	aug13	1	126	127	f	f	\N	2026-05-18 06:03:07.668504+00
1131	177	13	65	flashcard.reviewed	58	aug13	1	126	127	f	f	\N	2026-05-18 06:03:07.668504+00
1132	177	14	66	flashcard.reviewed	58	aug13	1	126	127	f	f	\N	2026-05-18 06:03:07.668504+00
1133	177	15	67	flashcard.reviewed	58	aug13	1	126	127	f	f	\N	2026-05-18 06:03:07.668504+00
1134	177	16	68	flashcard.reviewed	58	aug13	1	126	127	f	f	\N	2026-05-18 06:03:07.668504+00
1135	179	11	63	flashcard.reviewed	58	aug13	1	127	128	f	f	\N	2026-05-18 06:03:07.704652+00
1136	179	12	64	flashcard.reviewed	58	aug13	1	127	128	f	f	\N	2026-05-18 06:03:07.704652+00
1137	179	13	65	flashcard.reviewed	58	aug13	1	127	128	f	f	\N	2026-05-18 06:03:07.704652+00
1138	179	14	66	flashcard.reviewed	58	aug13	1	127	128	f	f	\N	2026-05-18 06:03:07.704652+00
1139	179	15	67	flashcard.reviewed	58	aug13	1	127	128	f	f	\N	2026-05-18 06:03:07.704652+00
1140	179	16	68	flashcard.reviewed	58	aug13	1	127	128	f	f	\N	2026-05-18 06:03:07.704652+00
1177	184	11	63	flashcard.reviewed	58	aug13	1	134	135	f	f	\N	2026-05-18 06:03:08.377987+00
1178	184	12	64	flashcard.reviewed	58	aug13	1	134	135	f	f	\N	2026-05-18 06:03:08.377987+00
1179	184	13	65	flashcard.reviewed	58	aug13	1	134	135	f	f	\N	2026-05-18 06:03:08.377987+00
1180	184	14	66	flashcard.reviewed	58	aug13	1	134	135	f	f	\N	2026-05-18 06:03:08.377987+00
1181	184	15	67	flashcard.reviewed	58	aug13	1	134	135	f	f	\N	2026-05-18 06:03:08.377987+00
1182	184	16	68	flashcard.reviewed	58	aug13	1	134	135	f	f	\N	2026-05-18 06:03:08.377987+00
1183	185	11	63	flashcard.reviewed	58	aug13	1	135	136	f	f	\N	2026-05-18 06:03:08.404098+00
1184	185	12	64	flashcard.reviewed	58	aug13	1	135	136	f	f	\N	2026-05-18 06:03:08.404098+00
1185	185	13	65	flashcard.reviewed	58	aug13	1	135	136	f	f	\N	2026-05-18 06:03:08.404098+00
1186	185	14	66	flashcard.reviewed	58	aug13	1	135	136	f	f	\N	2026-05-18 06:03:08.404098+00
1187	185	15	67	flashcard.reviewed	58	aug13	1	135	136	f	f	\N	2026-05-18 06:03:08.404098+00
1188	185	16	68	flashcard.reviewed	58	aug13	1	135	136	f	f	\N	2026-05-18 06:03:08.404098+00
1189	186	11	63	flashcard.reviewed	58	aug13	1	136	137	f	f	\N	2026-05-18 06:03:08.400687+00
1190	186	12	64	flashcard.reviewed	58	aug13	1	136	137	f	f	\N	2026-05-18 06:03:08.400687+00
1191	186	13	65	flashcard.reviewed	58	aug13	1	136	137	f	f	\N	2026-05-18 06:03:08.400687+00
1192	186	14	66	flashcard.reviewed	58	aug13	1	136	137	f	f	\N	2026-05-18 06:03:08.400687+00
1193	186	15	67	flashcard.reviewed	58	aug13	1	136	137	f	f	\N	2026-05-18 06:03:08.400687+00
1194	186	16	68	flashcard.reviewed	58	aug13	1	136	137	f	f	\N	2026-05-18 06:03:08.400687+00
1291	203	11	63	flashcard.reviewed	58	aug13	1	153	154	f	f	\N	2026-05-18 06:03:10.489869+00
1292	203	12	64	flashcard.reviewed	58	aug13	1	153	154	f	f	\N	2026-05-18 06:03:10.489869+00
1293	203	13	65	flashcard.reviewed	58	aug13	1	153	154	f	f	\N	2026-05-18 06:03:10.489869+00
1294	203	14	66	flashcard.reviewed	58	aug13	1	153	154	f	f	\N	2026-05-18 06:03:10.489869+00
1295	203	15	67	flashcard.reviewed	58	aug13	1	153	154	f	f	\N	2026-05-18 06:03:10.489869+00
1296	203	16	68	flashcard.reviewed	58	aug13	1	153	154	f	f	\N	2026-05-18 06:03:10.489869+00
1297	204	11	63	flashcard.reviewed	58	aug13	1	154	155	f	f	\N	2026-05-18 06:03:10.516234+00
1298	204	12	64	flashcard.reviewed	58	aug13	1	154	155	f	f	\N	2026-05-18 06:03:10.516234+00
1299	204	13	65	flashcard.reviewed	58	aug13	1	154	155	f	f	\N	2026-05-18 06:03:10.516234+00
1300	204	14	66	flashcard.reviewed	58	aug13	1	154	155	f	f	\N	2026-05-18 06:03:10.516234+00
1301	204	15	67	flashcard.reviewed	58	aug13	1	154	155	f	f	\N	2026-05-18 06:03:10.516234+00
1302	204	16	68	flashcard.reviewed	58	aug13	1	154	155	f	f	\N	2026-05-18 06:03:10.516234+00
1309	206	11	63	flashcard.reviewed	58	aug13	1	156	157	f	f	\N	2026-05-18 06:03:10.952214+00
1310	206	12	64	flashcard.reviewed	58	aug13	1	156	157	f	f	\N	2026-05-18 06:03:10.952214+00
1311	206	13	65	flashcard.reviewed	58	aug13	1	156	157	f	f	\N	2026-05-18 06:03:10.952214+00
1312	206	14	66	flashcard.reviewed	58	aug13	1	156	157	f	f	\N	2026-05-18 06:03:10.952214+00
1313	206	15	67	flashcard.reviewed	58	aug13	1	156	157	f	f	\N	2026-05-18 06:03:10.952214+00
1314	206	16	68	flashcard.reviewed	58	aug13	1	156	157	f	f	\N	2026-05-18 06:03:10.952214+00
1513	240	11	63	flashcard.reviewed	58	aug13	1	190	191	f	f	\N	2026-05-18 06:15:50.93131+00
1514	240	12	64	flashcard.reviewed	58	aug13	1	190	191	f	f	\N	2026-05-18 06:15:50.93131+00
1515	240	13	65	flashcard.reviewed	58	aug13	1	190	191	f	f	\N	2026-05-18 06:15:50.93131+00
1516	240	14	66	flashcard.reviewed	58	aug13	1	190	191	f	f	\N	2026-05-18 06:15:50.93131+00
1517	240	15	67	flashcard.reviewed	58	aug13	1	190	191	f	f	\N	2026-05-18 06:15:50.93131+00
1518	240	16	68	flashcard.reviewed	58	aug13	1	190	191	f	f	\N	2026-05-18 06:15:50.93131+00
1623	260	12	64	flashcard.reviewed	58	aug13	1	210	211	f	f	\N	2026-05-18 06:15:54.155408+00
1624	260	13	65	flashcard.reviewed	58	aug13	1	210	211	f	f	\N	2026-05-18 06:15:54.155408+00
1625	260	14	66	flashcard.reviewed	58	aug13	1	210	211	f	f	\N	2026-05-18 06:15:54.155408+00
1626	260	15	67	flashcard.reviewed	58	aug13	1	210	211	f	f	\N	2026-05-18 06:15:54.155408+00
1627	260	16	68	flashcard.reviewed	58	aug13	1	210	211	f	f	\N	2026-05-18 06:15:54.155408+00
1145	176	15	67	flashcard.reviewed	58	aug13	1	128	129	f	f	\N	2026-05-18 06:03:07.631941+00
1146	176	16	68	flashcard.reviewed	58	aug13	1	128	129	f	f	\N	2026-05-18 06:03:07.631941+00
1153	180	11	63	flashcard.reviewed	58	aug13	1	130	131	f	f	\N	2026-05-18 06:03:07.699856+00
1154	180	12	64	flashcard.reviewed	58	aug13	1	130	131	f	f	\N	2026-05-18 06:03:07.699856+00
1155	180	13	65	flashcard.reviewed	58	aug13	1	130	131	f	f	\N	2026-05-18 06:03:07.699856+00
1156	180	14	66	flashcard.reviewed	58	aug13	1	130	131	f	f	\N	2026-05-18 06:03:07.699856+00
1157	180	15	67	flashcard.reviewed	58	aug13	1	130	131	f	f	\N	2026-05-18 06:03:07.699856+00
1158	180	16	68	flashcard.reviewed	58	aug13	1	130	131	f	f	\N	2026-05-18 06:03:07.699856+00
1159	181	11	63	flashcard.reviewed	58	aug13	1	131	132	f	f	\N	2026-05-18 06:03:07.73538+00
1160	181	12	64	flashcard.reviewed	58	aug13	1	131	132	f	f	\N	2026-05-18 06:03:07.73538+00
1161	181	13	65	flashcard.reviewed	58	aug13	1	131	132	f	f	\N	2026-05-18 06:03:07.73538+00
1162	181	14	66	flashcard.reviewed	58	aug13	1	131	132	f	f	\N	2026-05-18 06:03:07.73538+00
1163	181	15	67	flashcard.reviewed	58	aug13	1	131	132	f	f	\N	2026-05-18 06:03:07.73538+00
1164	181	16	68	flashcard.reviewed	58	aug13	1	131	132	f	f	\N	2026-05-18 06:03:07.73538+00
1207	189	11	63	flashcard.reviewed	58	aug13	1	139	140	f	f	\N	2026-05-18 06:03:08.842975+00
1208	189	12	64	flashcard.reviewed	58	aug13	1	139	140	f	f	\N	2026-05-18 06:03:08.842975+00
1209	189	13	65	flashcard.reviewed	58	aug13	1	139	140	f	f	\N	2026-05-18 06:03:08.842975+00
1210	189	14	66	flashcard.reviewed	58	aug13	1	139	140	f	f	\N	2026-05-18 06:03:08.842975+00
1211	189	15	67	flashcard.reviewed	58	aug13	1	139	140	f	f	\N	2026-05-18 06:03:08.842975+00
1212	189	16	68	flashcard.reviewed	58	aug13	1	139	140	f	f	\N	2026-05-18 06:03:08.842975+00
1273	200	11	63	flashcard.reviewed	58	aug13	1	150	151	f	f	\N	2026-05-18 06:03:09.648487+00
1274	200	12	64	flashcard.reviewed	58	aug13	1	150	151	f	f	\N	2026-05-18 06:03:09.648487+00
1275	200	13	65	flashcard.reviewed	58	aug13	1	150	151	f	f	\N	2026-05-18 06:03:09.648487+00
1276	200	14	66	flashcard.reviewed	58	aug13	1	150	151	f	f	\N	2026-05-18 06:03:09.648487+00
1277	200	15	67	flashcard.reviewed	58	aug13	1	150	151	f	f	\N	2026-05-18 06:03:09.648487+00
1278	200	16	68	flashcard.reviewed	58	aug13	1	150	151	f	f	\N	2026-05-18 06:03:09.648487+00
1285	202	11	63	flashcard.reviewed	58	aug13	1	152	153	f	f	\N	2026-05-18 06:03:10.047332+00
1286	202	12	64	flashcard.reviewed	58	aug13	1	152	153	f	f	\N	2026-05-18 06:03:10.047332+00
1287	202	13	65	flashcard.reviewed	58	aug13	1	152	153	f	f	\N	2026-05-18 06:03:10.047332+00
1288	202	14	66	flashcard.reviewed	58	aug13	1	152	153	f	f	\N	2026-05-18 06:03:10.047332+00
1289	202	15	67	flashcard.reviewed	58	aug13	1	152	153	f	f	\N	2026-05-18 06:03:10.047332+00
1290	202	16	68	flashcard.reviewed	58	aug13	1	152	153	f	f	\N	2026-05-18 06:03:10.047332+00
1351	211	11	63	flashcard.reviewed	58	aug13	1	163	164	f	f	\N	2026-05-18 06:03:11.777648+00
1352	211	12	64	flashcard.reviewed	58	aug13	1	163	164	f	f	\N	2026-05-18 06:03:11.777648+00
1353	211	13	65	flashcard.reviewed	58	aug13	1	163	164	f	f	\N	2026-05-18 06:03:11.777648+00
1354	211	14	66	flashcard.reviewed	58	aug13	1	163	164	f	f	\N	2026-05-18 06:03:11.777648+00
1355	211	15	67	flashcard.reviewed	58	aug13	1	163	164	f	f	\N	2026-05-18 06:03:11.777648+00
1356	211	16	68	flashcard.reviewed	58	aug13	1	163	164	f	f	\N	2026-05-18 06:03:11.777648+00
1387	219	11	63	flashcard.reviewed	58	aug13	1	169	170	f	f	\N	2026-05-18 06:03:13.84529+00
1388	219	12	64	flashcard.reviewed	58	aug13	1	169	170	f	f	\N	2026-05-18 06:03:13.84529+00
1389	219	13	65	flashcard.reviewed	58	aug13	1	169	170	f	f	\N	2026-05-18 06:03:13.84529+00
1390	219	14	66	flashcard.reviewed	58	aug13	1	169	170	f	f	\N	2026-05-18 06:03:13.84529+00
1391	219	15	67	flashcard.reviewed	58	aug13	1	169	170	f	f	\N	2026-05-18 06:03:13.84529+00
1392	219	16	68	flashcard.reviewed	58	aug13	1	169	170	f	f	\N	2026-05-18 06:03:13.84529+00
1519	241	11	63	flashcard.reviewed	58	aug13	1	191	192	f	f	\N	2026-05-18 06:15:50.983575+00
1520	241	12	64	flashcard.reviewed	58	aug13	1	191	192	f	f	\N	2026-05-18 06:15:50.983575+00
1521	241	13	65	flashcard.reviewed	58	aug13	1	191	192	f	f	\N	2026-05-18 06:15:50.983575+00
1522	241	14	66	flashcard.reviewed	58	aug13	1	191	192	f	f	\N	2026-05-18 06:15:50.983575+00
1523	241	15	67	flashcard.reviewed	58	aug13	1	191	192	f	f	\N	2026-05-18 06:15:50.983575+00
1524	241	16	68	flashcard.reviewed	58	aug13	1	191	192	f	f	\N	2026-05-18 06:15:50.983575+00
1628	261	12	64	flashcard.reviewed	58	aug13	1	211	212	f	f	\N	2026-05-18 06:15:54.568789+00
1629	261	13	65	flashcard.reviewed	58	aug13	1	211	212	f	f	\N	2026-05-18 06:15:54.568789+00
1630	261	14	66	flashcard.reviewed	58	aug13	1	211	212	f	f	\N	2026-05-18 06:15:54.568789+00
1631	261	15	67	flashcard.reviewed	58	aug13	1	211	212	f	f	\N	2026-05-18 06:15:54.568789+00
1632	261	16	68	flashcard.reviewed	58	aug13	1	211	212	f	f	\N	2026-05-18 06:15:54.568789+00
1728	281	12	64	flashcard.reviewed	58	aug13	1	231	232	f	f	\N	2026-05-18 06:15:58.290258+00
1729	281	13	65	flashcard.reviewed	58	aug13	1	231	232	f	f	\N	2026-05-18 06:15:58.290258+00
1730	281	14	66	flashcard.reviewed	58	aug13	1	231	232	f	f	\N	2026-05-18 06:15:58.290258+00
1731	281	15	67	flashcard.reviewed	58	aug13	1	231	232	f	f	\N	2026-05-18 06:15:58.290258+00
1732	281	16	68	flashcard.reviewed	58	aug13	1	231	232	f	f	\N	2026-05-18 06:15:58.290258+00
1165	182	11	63	flashcard.reviewed	58	aug13	1	132	133	f	f	\N	2026-05-18 06:03:08.049934+00
1166	182	12	64	flashcard.reviewed	58	aug13	1	132	133	f	f	\N	2026-05-18 06:03:08.049934+00
1167	182	13	65	flashcard.reviewed	58	aug13	1	132	133	f	f	\N	2026-05-18 06:03:08.049934+00
1168	182	14	66	flashcard.reviewed	58	aug13	1	132	133	f	f	\N	2026-05-18 06:03:08.049934+00
1169	182	15	67	flashcard.reviewed	58	aug13	1	132	133	f	f	\N	2026-05-18 06:03:08.049934+00
1170	182	16	68	flashcard.reviewed	58	aug13	1	132	133	f	f	\N	2026-05-18 06:03:08.049934+00
1195	187	11	63	flashcard.reviewed	58	aug13	1	137	138	f	f	\N	2026-05-18 06:03:08.431269+00
1196	187	12	64	flashcard.reviewed	58	aug13	1	137	138	f	f	\N	2026-05-18 06:03:08.431269+00
1197	187	13	65	flashcard.reviewed	58	aug13	1	137	138	f	f	\N	2026-05-18 06:03:08.431269+00
1198	187	14	66	flashcard.reviewed	58	aug13	1	137	138	f	f	\N	2026-05-18 06:03:08.431269+00
1199	187	15	67	flashcard.reviewed	58	aug13	1	137	138	f	f	\N	2026-05-18 06:03:08.431269+00
1200	187	16	68	flashcard.reviewed	58	aug13	1	137	138	f	f	\N	2026-05-18 06:03:08.431269+00
1279	201	11	63	flashcard.reviewed	58	aug13	1	151	152	f	f	\N	2026-05-18 06:03:10.060107+00
1280	201	12	64	flashcard.reviewed	58	aug13	1	151	152	f	f	\N	2026-05-18 06:03:10.060107+00
1281	201	13	65	flashcard.reviewed	58	aug13	1	151	152	f	f	\N	2026-05-18 06:03:10.060107+00
1282	201	14	66	flashcard.reviewed	58	aug13	1	151	152	f	f	\N	2026-05-18 06:03:10.060107+00
1283	201	15	67	flashcard.reviewed	58	aug13	1	151	152	f	f	\N	2026-05-18 06:03:10.060107+00
1284	201	16	68	flashcard.reviewed	58	aug13	1	151	152	f	f	\N	2026-05-18 06:03:10.060107+00
1321	208	11	63	flashcard.reviewed	58	aug13	1	158	159	f	f	\N	2026-05-18 06:03:11.335542+00
1322	208	12	64	flashcard.reviewed	58	aug13	1	158	159	f	f	\N	2026-05-18 06:03:11.335542+00
1323	208	13	65	flashcard.reviewed	58	aug13	1	158	159	f	f	\N	2026-05-18 06:03:11.335542+00
1324	208	14	66	flashcard.reviewed	58	aug13	1	158	159	f	f	\N	2026-05-18 06:03:11.335542+00
1325	208	15	67	flashcard.reviewed	58	aug13	1	158	159	f	f	\N	2026-05-18 06:03:11.335542+00
1326	208	16	68	flashcard.reviewed	58	aug13	1	158	159	f	f	\N	2026-05-18 06:03:11.335542+00
1525	242	11	63	flashcard.reviewed	58	aug13	1	192	193	f	f	\N	2026-05-18 06:15:51.002624+00
1526	242	12	64	flashcard.reviewed	58	aug13	1	192	193	f	f	\N	2026-05-18 06:15:51.002624+00
1527	242	13	65	flashcard.reviewed	58	aug13	1	192	193	f	f	\N	2026-05-18 06:15:51.002624+00
1528	242	14	66	flashcard.reviewed	58	aug13	1	192	193	f	f	\N	2026-05-18 06:15:51.002624+00
1529	242	15	67	flashcard.reviewed	58	aug13	1	192	193	f	f	\N	2026-05-18 06:15:51.002624+00
1530	242	16	68	flashcard.reviewed	58	aug13	1	192	193	f	f	\N	2026-05-18 06:15:51.002624+00
1633	262	12	64	flashcard.reviewed	58	aug13	1	212	213	f	f	\N	2026-05-18 06:15:54.951526+00
1634	262	13	65	flashcard.reviewed	58	aug13	1	212	213	f	f	\N	2026-05-18 06:15:54.951526+00
1635	262	14	66	flashcard.reviewed	58	aug13	1	212	213	f	f	\N	2026-05-18 06:15:54.951526+00
1636	262	15	67	flashcard.reviewed	58	aug13	1	212	213	f	f	\N	2026-05-18 06:15:54.951526+00
1637	262	16	68	flashcard.reviewed	58	aug13	1	212	213	f	f	\N	2026-05-18 06:15:54.951526+00
1738	283	12	64	flashcard.reviewed	58	aug13	1	233	234	f	f	\N	2026-05-18 06:15:58.610439+00
1739	283	13	65	flashcard.reviewed	58	aug13	1	233	234	f	f	\N	2026-05-18 06:15:58.610439+00
1740	283	14	66	flashcard.reviewed	58	aug13	1	233	234	f	f	\N	2026-05-18 06:15:58.610439+00
1741	283	15	67	flashcard.reviewed	58	aug13	1	233	234	f	f	\N	2026-05-18 06:15:58.610439+00
1742	283	16	68	flashcard.reviewed	58	aug13	1	233	234	f	f	\N	2026-05-18 06:15:58.610439+00
1213	190	11	63	flashcard.reviewed	58	aug13	1	140	141	f	f	\N	2026-05-18 06:03:08.975817+00
1214	190	12	64	flashcard.reviewed	58	aug13	1	140	141	f	f	\N	2026-05-18 06:03:08.975817+00
1215	190	13	65	flashcard.reviewed	58	aug13	1	140	141	f	f	\N	2026-05-18 06:03:08.975817+00
1216	190	14	66	flashcard.reviewed	58	aug13	1	140	141	f	f	\N	2026-05-18 06:03:08.975817+00
1217	190	15	67	flashcard.reviewed	58	aug13	1	140	141	f	f	\N	2026-05-18 06:03:08.975817+00
1218	190	16	68	flashcard.reviewed	58	aug13	1	140	141	f	f	\N	2026-05-18 06:03:08.975817+00
1219	191	11	63	flashcard.reviewed	58	aug13	1	141	142	f	f	\N	2026-05-18 06:03:09.00916+00
1220	191	12	64	flashcard.reviewed	58	aug13	1	141	142	f	f	\N	2026-05-18 06:03:09.00916+00
1221	191	13	65	flashcard.reviewed	58	aug13	1	141	142	f	f	\N	2026-05-18 06:03:09.00916+00
1222	191	14	66	flashcard.reviewed	58	aug13	1	141	142	f	f	\N	2026-05-18 06:03:09.00916+00
1223	191	15	67	flashcard.reviewed	58	aug13	1	141	142	f	f	\N	2026-05-18 06:03:09.00916+00
1224	191	16	68	flashcard.reviewed	58	aug13	1	141	142	f	f	\N	2026-05-18 06:03:09.00916+00
1225	193	11	63	flashcard.reviewed	58	aug13	1	142	143	f	f	\N	2026-05-18 06:03:09.056952+00
1226	193	12	64	flashcard.reviewed	58	aug13	1	142	143	f	f	\N	2026-05-18 06:03:09.056952+00
1227	193	13	65	flashcard.reviewed	58	aug13	1	142	143	f	f	\N	2026-05-18 06:03:09.056952+00
1228	193	14	66	flashcard.reviewed	58	aug13	1	142	143	f	f	\N	2026-05-18 06:03:09.056952+00
1229	193	15	67	flashcard.reviewed	58	aug13	1	142	143	f	f	\N	2026-05-18 06:03:09.056952+00
1230	193	16	68	flashcard.reviewed	58	aug13	1	142	143	f	f	\N	2026-05-18 06:03:09.056952+00
1231	194	11	63	flashcard.reviewed	58	aug13	1	143	144	f	f	\N	2026-05-18 06:03:09.083537+00
1232	194	12	64	flashcard.reviewed	58	aug13	1	143	144	f	f	\N	2026-05-18 06:03:09.083537+00
1233	194	13	65	flashcard.reviewed	58	aug13	1	143	144	f	f	\N	2026-05-18 06:03:09.083537+00
1234	194	14	66	flashcard.reviewed	58	aug13	1	143	144	f	f	\N	2026-05-18 06:03:09.083537+00
1235	194	15	67	flashcard.reviewed	58	aug13	1	143	144	f	f	\N	2026-05-18 06:03:09.083537+00
1236	194	16	68	flashcard.reviewed	58	aug13	1	143	144	f	f	\N	2026-05-18 06:03:09.083537+00
1237	192	11	63	flashcard.reviewed	58	aug13	1	144	145	f	f	\N	2026-05-18 06:03:08.998869+00
1238	192	12	64	flashcard.reviewed	58	aug13	1	144	145	f	f	\N	2026-05-18 06:03:08.998869+00
1239	192	13	65	flashcard.reviewed	58	aug13	1	144	145	f	f	\N	2026-05-18 06:03:08.998869+00
1240	192	14	66	flashcard.reviewed	58	aug13	1	144	145	f	f	\N	2026-05-18 06:03:08.998869+00
1241	192	15	67	flashcard.reviewed	58	aug13	1	144	145	f	f	\N	2026-05-18 06:03:08.998869+00
1242	192	16	68	flashcard.reviewed	58	aug13	1	144	145	f	f	\N	2026-05-18 06:03:08.998869+00
1243	197	11	63	flashcard.reviewed	58	aug13	1	145	146	f	f	\N	2026-05-18 06:03:09.121661+00
1244	197	12	64	flashcard.reviewed	58	aug13	1	145	146	f	f	\N	2026-05-18 06:03:09.121661+00
1245	197	13	65	flashcard.reviewed	58	aug13	1	145	146	f	f	\N	2026-05-18 06:03:09.121661+00
1246	197	14	66	flashcard.reviewed	58	aug13	1	145	146	f	f	\N	2026-05-18 06:03:09.121661+00
1247	197	15	67	flashcard.reviewed	58	aug13	1	145	146	f	f	\N	2026-05-18 06:03:09.121661+00
1248	197	16	68	flashcard.reviewed	58	aug13	1	145	146	f	f	\N	2026-05-18 06:03:09.121661+00
1249	198	11	63	flashcard.reviewed	58	aug13	1	146	147	f	f	\N	2026-05-18 06:03:09.183138+00
1250	198	12	64	flashcard.reviewed	58	aug13	1	146	147	f	f	\N	2026-05-18 06:03:09.183138+00
1251	198	13	65	flashcard.reviewed	58	aug13	1	146	147	f	f	\N	2026-05-18 06:03:09.183138+00
1252	198	14	66	flashcard.reviewed	58	aug13	1	146	147	f	f	\N	2026-05-18 06:03:09.183138+00
1253	198	15	67	flashcard.reviewed	58	aug13	1	146	147	f	f	\N	2026-05-18 06:03:09.183138+00
1254	198	16	68	flashcard.reviewed	58	aug13	1	146	147	f	f	\N	2026-05-18 06:03:09.183138+00
1255	196	11	63	flashcard.reviewed	58	aug13	1	147	148	f	f	\N	2026-05-18 06:03:09.076155+00
1256	196	12	64	flashcard.reviewed	58	aug13	1	147	148	f	f	\N	2026-05-18 06:03:09.076155+00
1257	196	13	65	flashcard.reviewed	58	aug13	1	147	148	f	f	\N	2026-05-18 06:03:09.076155+00
1258	196	14	66	flashcard.reviewed	58	aug13	1	147	148	f	f	\N	2026-05-18 06:03:09.076155+00
1259	196	15	67	flashcard.reviewed	58	aug13	1	147	148	f	f	\N	2026-05-18 06:03:09.076155+00
1260	196	16	68	flashcard.reviewed	58	aug13	1	147	148	f	f	\N	2026-05-18 06:03:09.076155+00
1261	195	11	63	flashcard.reviewed	58	aug13	1	148	149	f	f	\N	2026-05-18 06:03:09.077295+00
1262	195	12	64	flashcard.reviewed	58	aug13	1	148	149	f	f	\N	2026-05-18 06:03:09.077295+00
1263	195	13	65	flashcard.reviewed	58	aug13	1	148	149	f	f	\N	2026-05-18 06:03:09.077295+00
1264	195	14	66	flashcard.reviewed	58	aug13	1	148	149	f	f	\N	2026-05-18 06:03:09.077295+00
1265	195	15	67	flashcard.reviewed	58	aug13	1	148	149	f	f	\N	2026-05-18 06:03:09.077295+00
1266	195	16	68	flashcard.reviewed	58	aug13	1	148	149	f	f	\N	2026-05-18 06:03:09.077295+00
1327	209	11	63	flashcard.reviewed	58	aug13	1	159	160	f	f	\N	2026-05-18 06:03:11.772735+00
1328	209	12	64	flashcard.reviewed	58	aug13	1	159	160	f	f	\N	2026-05-18 06:03:11.772735+00
1329	209	13	65	flashcard.reviewed	58	aug13	1	159	160	f	f	\N	2026-05-18 06:03:11.772735+00
1330	209	14	66	flashcard.reviewed	58	aug13	1	159	160	f	f	\N	2026-05-18 06:03:11.772735+00
1331	209	15	67	flashcard.reviewed	58	aug13	1	159	160	f	f	\N	2026-05-18 06:03:11.772735+00
1332	209	16	68	flashcard.reviewed	58	aug13	1	159	160	f	f	\N	2026-05-18 06:03:11.772735+00
1333	210	11	63	flashcard.reviewed	58	aug13	1	160	161	f	f	\N	2026-05-18 06:03:11.793947+00
1334	210	12	64	flashcard.reviewed	58	aug13	1	160	161	f	f	\N	2026-05-18 06:03:11.793947+00
1335	210	13	65	flashcard.reviewed	58	aug13	1	160	161	f	f	\N	2026-05-18 06:03:11.793947+00
1336	210	14	66	flashcard.reviewed	58	aug13	1	160	161	f	f	\N	2026-05-18 06:03:11.793947+00
1337	210	15	67	flashcard.reviewed	58	aug13	1	160	161	f	f	\N	2026-05-18 06:03:11.793947+00
1338	210	16	68	flashcard.reviewed	58	aug13	1	160	161	f	f	\N	2026-05-18 06:03:11.793947+00
1531	243	11	63	flashcard.reviewed	58	aug13	1	193	194	f	f	\N	2026-05-18 06:15:51.041235+00
1532	243	12	64	flashcard.reviewed	58	aug13	1	193	194	f	f	\N	2026-05-18 06:15:51.041235+00
1533	243	13	65	flashcard.reviewed	58	aug13	1	193	194	f	f	\N	2026-05-18 06:15:51.041235+00
1534	243	14	66	flashcard.reviewed	58	aug13	1	193	194	f	f	\N	2026-05-18 06:15:51.041235+00
1535	243	15	67	flashcard.reviewed	58	aug13	1	193	194	f	f	\N	2026-05-18 06:15:51.041235+00
1536	243	16	68	flashcard.reviewed	58	aug13	1	193	194	f	f	\N	2026-05-18 06:15:51.041235+00
1643	264	12	64	flashcard.reviewed	58	aug13	1	214	215	f	f	\N	2026-05-18 06:15:55.344088+00
1644	264	13	65	flashcard.reviewed	58	aug13	1	214	215	f	f	\N	2026-05-18 06:15:55.344088+00
1645	264	14	66	flashcard.reviewed	58	aug13	1	214	215	f	f	\N	2026-05-18 06:15:55.344088+00
1646	264	15	67	flashcard.reviewed	58	aug13	1	214	215	f	f	\N	2026-05-18 06:15:55.344088+00
1647	264	16	68	flashcard.reviewed	58	aug13	1	214	215	f	f	\N	2026-05-18 06:15:55.344088+00
1763	287	12	64	flashcard.reviewed	58	aug13	1	238	239	f	f	\N	2026-05-18 06:15:58.967137+00
1764	287	13	65	flashcard.reviewed	58	aug13	1	238	239	f	f	\N	2026-05-18 06:15:58.967137+00
1765	287	14	66	flashcard.reviewed	58	aug13	1	238	239	f	f	\N	2026-05-18 06:15:58.967137+00
1766	287	15	67	flashcard.reviewed	58	aug13	1	238	239	f	f	\N	2026-05-18 06:15:58.967137+00
1767	287	16	68	flashcard.reviewed	58	aug13	1	238	239	f	f	\N	2026-05-18 06:15:58.967137+00
1339	212	11	63	flashcard.reviewed	58	aug13	1	161	162	f	f	\N	2026-05-18 06:03:11.817678+00
1340	212	12	64	flashcard.reviewed	58	aug13	1	161	162	f	f	\N	2026-05-18 06:03:11.817678+00
1341	212	13	65	flashcard.reviewed	58	aug13	1	161	162	f	f	\N	2026-05-18 06:03:11.817678+00
1342	212	14	66	flashcard.reviewed	58	aug13	1	161	162	f	f	\N	2026-05-18 06:03:11.817678+00
1343	212	15	67	flashcard.reviewed	58	aug13	1	161	162	f	f	\N	2026-05-18 06:03:11.817678+00
1344	212	16	68	flashcard.reviewed	58	aug13	1	161	162	f	f	\N	2026-05-18 06:03:11.817678+00
1593	254	12	64	flashcard.reviewed	58	aug13	1	204	205	f	f	\N	2026-05-18 06:15:52.080113+00
1594	254	13	65	flashcard.reviewed	58	aug13	1	204	205	f	f	\N	2026-05-18 06:15:52.080113+00
1595	254	14	66	flashcard.reviewed	58	aug13	1	204	205	f	f	\N	2026-05-18 06:15:52.080113+00
1596	254	15	67	flashcard.reviewed	58	aug13	1	204	205	f	f	\N	2026-05-18 06:15:52.080113+00
1597	254	16	68	flashcard.reviewed	58	aug13	1	204	205	f	f	\N	2026-05-18 06:15:52.080113+00
1688	274	12	64	flashcard.reviewed	58	aug13	1	223	224	f	f	\N	2026-05-18 06:15:56.24819+00
1689	274	13	65	flashcard.reviewed	58	aug13	1	223	224	f	f	\N	2026-05-18 06:15:56.24819+00
1690	274	14	66	flashcard.reviewed	58	aug13	1	223	224	f	f	\N	2026-05-18 06:15:56.24819+00
1691	274	15	67	flashcard.reviewed	58	aug13	1	223	224	f	f	\N	2026-05-18 06:15:56.24819+00
1692	274	16	68	flashcard.reviewed	58	aug13	1	223	224	f	f	\N	2026-05-18 06:15:56.24819+00
1783	293	12	64	flashcard.reviewed	58	aug13	1	242	243	f	f	\N	2026-05-18 06:15:59.409706+00
1784	293	13	65	flashcard.reviewed	58	aug13	1	242	243	f	f	\N	2026-05-18 06:15:59.409706+00
1785	293	14	66	flashcard.reviewed	58	aug13	1	242	243	f	f	\N	2026-05-18 06:15:59.409706+00
1786	293	15	67	flashcard.reviewed	58	aug13	1	242	243	f	f	\N	2026-05-18 06:15:59.409706+00
1787	293	16	68	flashcard.reviewed	58	aug13	1	242	243	f	f	\N	2026-05-18 06:15:59.409706+00
1345	213	11	63	flashcard.reviewed	58	aug13	1	162	163	f	f	\N	2026-05-18 06:03:11.840202+00
1346	213	12	64	flashcard.reviewed	58	aug13	1	162	163	f	f	\N	2026-05-18 06:03:11.840202+00
1347	213	13	65	flashcard.reviewed	58	aug13	1	162	163	f	f	\N	2026-05-18 06:03:11.840202+00
1348	213	14	66	flashcard.reviewed	58	aug13	1	162	163	f	f	\N	2026-05-18 06:03:11.840202+00
1349	213	15	67	flashcard.reviewed	58	aug13	1	162	163	f	f	\N	2026-05-18 06:03:11.840202+00
1350	213	16	68	flashcard.reviewed	58	aug13	1	162	163	f	f	\N	2026-05-18 06:03:11.840202+00
1598	255	12	64	flashcard.reviewed	58	aug13	1	205	206	f	f	\N	2026-05-18 06:15:52.142504+00
1599	255	13	65	flashcard.reviewed	58	aug13	1	205	206	f	f	\N	2026-05-18 06:15:52.142504+00
1600	255	14	66	flashcard.reviewed	58	aug13	1	205	206	f	f	\N	2026-05-18 06:15:52.142504+00
1601	255	15	67	flashcard.reviewed	58	aug13	1	205	206	f	f	\N	2026-05-18 06:15:52.142504+00
1602	255	16	68	flashcard.reviewed	58	aug13	1	205	206	f	f	\N	2026-05-18 06:15:52.142504+00
1693	275	12	64	flashcard.reviewed	58	aug13	1	224	225	f	f	\N	2026-05-18 06:15:56.269795+00
1694	275	13	65	flashcard.reviewed	58	aug13	1	224	225	f	f	\N	2026-05-18 06:15:56.269795+00
1695	275	14	66	flashcard.reviewed	58	aug13	1	224	225	f	f	\N	2026-05-18 06:15:56.269795+00
1696	275	15	67	flashcard.reviewed	58	aug13	1	224	225	f	f	\N	2026-05-18 06:15:56.269795+00
1697	275	16	68	flashcard.reviewed	58	aug13	1	224	225	f	f	\N	2026-05-18 06:15:56.269795+00
1788	294	12	64	flashcard.reviewed	58	aug13	1	243	244	f	f	\N	2026-05-18 06:15:59.428927+00
1789	294	13	65	flashcard.reviewed	58	aug13	1	243	244	f	f	\N	2026-05-18 06:15:59.428927+00
1790	294	14	66	flashcard.reviewed	58	aug13	1	243	244	f	f	\N	2026-05-18 06:15:59.428927+00
1791	294	15	67	flashcard.reviewed	58	aug13	1	243	244	f	f	\N	2026-05-18 06:15:59.428927+00
1792	294	16	68	flashcard.reviewed	58	aug13	1	243	244	f	f	\N	2026-05-18 06:15:59.428927+00
1357	214	11	63	flashcard.reviewed	58	aug13	1	164	165	f	f	\N	2026-05-18 06:03:12.291292+00
1358	214	12	64	flashcard.reviewed	58	aug13	1	164	165	f	f	\N	2026-05-18 06:03:12.291292+00
1359	214	13	65	flashcard.reviewed	58	aug13	1	164	165	f	f	\N	2026-05-18 06:03:12.291292+00
1360	214	14	66	flashcard.reviewed	58	aug13	1	164	165	f	f	\N	2026-05-18 06:03:12.291292+00
1361	214	15	67	flashcard.reviewed	58	aug13	1	164	165	f	f	\N	2026-05-18 06:03:12.291292+00
1362	214	16	68	flashcard.reviewed	58	aug13	1	164	165	f	f	\N	2026-05-18 06:03:12.291292+00
1611	257	15	67	flashcard.reviewed	58	aug13	1	207	208	f	f	\N	2026-05-18 06:15:52.718226+00
1612	257	16	68	flashcard.reviewed	58	aug13	1	207	208	f	f	\N	2026-05-18 06:15:52.718226+00
1708	277	12	64	flashcard.reviewed	58	aug13	1	227	228	f	f	\N	2026-05-18 06:15:56.943617+00
1709	277	13	65	flashcard.reviewed	58	aug13	1	227	228	f	f	\N	2026-05-18 06:15:56.943617+00
1710	277	14	66	flashcard.reviewed	58	aug13	1	227	228	f	f	\N	2026-05-18 06:15:56.943617+00
1711	277	15	67	flashcard.reviewed	58	aug13	1	227	228	f	f	\N	2026-05-18 06:15:56.943617+00
1712	277	16	68	flashcard.reviewed	58	aug13	1	227	228	f	f	\N	2026-05-18 06:15:56.943617+00
1808	297	12	64	flashcard.reviewed	58	aug13	1	247	248	f	f	\N	2026-05-18 06:16:00.449843+00
1809	297	13	65	flashcard.reviewed	58	aug13	1	247	248	f	f	\N	2026-05-18 06:16:00.449843+00
1810	297	14	66	flashcard.reviewed	58	aug13	1	247	248	f	f	\N	2026-05-18 06:16:00.449843+00
1811	297	15	67	flashcard.reviewed	58	aug13	1	247	248	f	f	\N	2026-05-18 06:16:00.449843+00
1812	297	16	68	flashcard.reviewed	58	aug13	1	247	248	f	f	\N	2026-05-18 06:16:00.449843+00
1363	215	11	63	flashcard.reviewed	58	aug13	1	165	166	f	f	\N	2026-05-18 06:03:12.284302+00
1364	215	12	64	flashcard.reviewed	58	aug13	1	165	166	f	f	\N	2026-05-18 06:03:12.284302+00
1365	215	13	65	flashcard.reviewed	58	aug13	1	165	166	f	f	\N	2026-05-18 06:03:12.284302+00
1366	215	14	66	flashcard.reviewed	58	aug13	1	165	166	f	f	\N	2026-05-18 06:03:12.284302+00
1367	215	15	67	flashcard.reviewed	58	aug13	1	165	166	f	f	\N	2026-05-18 06:03:12.284302+00
1368	215	16	68	flashcard.reviewed	58	aug13	1	165	166	f	f	\N	2026-05-18 06:03:12.284302+00
1723	280	12	64	flashcard.reviewed	58	aug13	1	230	231	f	f	\N	2026-05-18 06:15:57.953577+00
1724	280	13	65	flashcard.reviewed	58	aug13	1	230	231	f	f	\N	2026-05-18 06:15:57.953577+00
1725	280	14	66	flashcard.reviewed	58	aug13	1	230	231	f	f	\N	2026-05-18 06:15:57.953577+00
1726	280	15	67	flashcard.reviewed	58	aug13	1	230	231	f	f	\N	2026-05-18 06:15:57.953577+00
1727	280	16	68	flashcard.reviewed	58	aug13	1	230	231	f	f	\N	2026-05-18 06:15:57.953577+00
1823	300	12	64	flashcard.reviewed	58	aug13	1	250	251	f	f	\N	2026-05-18 06:16:01.42237+00
1824	300	13	65	flashcard.reviewed	58	aug13	1	250	251	f	f	\N	2026-05-18 06:16:01.42237+00
1825	300	14	66	flashcard.reviewed	58	aug13	1	250	251	f	f	\N	2026-05-18 06:16:01.42237+00
1826	300	15	67	flashcard.reviewed	58	aug13	1	250	251	f	f	\N	2026-05-18 06:16:01.42237+00
1827	300	16	68	flashcard.reviewed	58	aug13	1	250	251	f	f	\N	2026-05-18 06:16:01.42237+00
1369	216	11	63	flashcard.reviewed	58	aug13	1	166	167	f	f	\N	2026-05-18 06:03:12.730689+00
1370	216	12	64	flashcard.reviewed	58	aug13	1	166	167	f	f	\N	2026-05-18 06:03:12.730689+00
1371	216	13	65	flashcard.reviewed	58	aug13	1	166	167	f	f	\N	2026-05-18 06:03:12.730689+00
1372	216	14	66	flashcard.reviewed	58	aug13	1	166	167	f	f	\N	2026-05-18 06:03:12.730689+00
1373	216	15	67	flashcard.reviewed	58	aug13	1	166	167	f	f	\N	2026-05-18 06:03:12.730689+00
1374	216	16	68	flashcard.reviewed	58	aug13	1	166	167	f	f	\N	2026-05-18 06:03:12.730689+00
1375	217	11	63	flashcard.reviewed	58	aug13	1	167	168	f	f	\N	2026-05-18 06:03:13.088263+00
1376	217	12	64	flashcard.reviewed	58	aug13	1	167	168	f	f	\N	2026-05-18 06:03:13.088263+00
1377	217	13	65	flashcard.reviewed	58	aug13	1	167	168	f	f	\N	2026-05-18 06:03:13.088263+00
1378	217	14	66	flashcard.reviewed	58	aug13	1	167	168	f	f	\N	2026-05-18 06:03:13.088263+00
1379	217	15	67	flashcard.reviewed	58	aug13	1	167	168	f	f	\N	2026-05-18 06:03:13.088263+00
1380	217	16	68	flashcard.reviewed	58	aug13	1	167	168	f	f	\N	2026-05-18 06:03:13.088263+00
\.


--
-- TOC entry 5112 (class 0 OID 148523)
-- Dependencies: 769
-- Data for Name: as_achievement_translations; Type: TABLE DATA; Schema: achievement_system; Owner: -
--

COPY {{SCHEMA}}.as_achievement_translations (id, achievement_id, locale, title, description, created_at, updated_at) FROM stdin;
1	1	en	Create 10 Flashcards	Create 10 flashcards in LangGo.	2026-05-04 21:05:25.127+00	2026-05-06 16:18:30.087242+00
3	2	en	Create 50 Flashcards	Create 50 flashcards in LangGo.	2026-05-04 21:06:05.884+00	2026-05-06 16:18:30.087242+00
5	3	en	Create 100 Flashcards	Create 100 flashcards in LangGo.	2026-05-04 21:06:27.41+00	2026-05-06 16:18:30.087242+00
7	4	en	Create 200 Flashcards	Create 200 flashcards in LangGo.	2026-05-04 21:06:49.498+00	2026-05-06 16:18:30.087242+00
9	5	en	Create 500 Flashcards	Create 500 flashcards in LangGo.	2026-05-04 21:07:12.125+00	2026-05-06 16:18:30.087242+00
11	6	en	Create 1000 Flashcards	Create 1000 flashcards in LangGo.	2026-05-04 21:07:24.168+00	2026-05-06 16:18:30.087242+00
13	7	en	Create 2000 Flashcards	Create 2000 flashcards in LangGo.	2026-05-04 21:07:42.908+00	2026-05-06 16:18:30.087242+00
15	8	en	Create 3000 Flashcards	Create 3000 flashcards in LangGo.	2026-05-04 21:08:00.024+00	2026-05-06 16:18:30.087242+00
17	9	en	Create 5000 Flashcards	Create 5000 flashcards in LangGo.	2026-05-04 21:08:17.555+00	2026-05-06 16:18:30.087242+00
19	10	en	Complete 100 Reviews	Complete 100 flashcard reviews in LangGo.	2026-05-04 21:09:14.216+00	2026-05-06 16:18:30.087242+00
21	11	en	Complete 200 Reviews	Complete 200 flashcard reviews in LangGo.	2026-05-04 21:09:51.515+00	2026-05-06 16:18:30.087242+00
23	12	en	Complete 500 Reviews	Complete 500 flashcard reviews in LangGo.	2026-05-04 21:10:14.686+00	2026-05-06 16:18:30.087242+00
25	13	en	Complete 1000 Reviews	Complete 1000 flashcard reviews in LangGo.	2026-05-04 21:11:00.936+00	2026-05-06 16:18:30.087242+00
57	1	es	Crear 10 tarjetas	Crea 10 tarjetas en LangGo.	2026-05-04 21:05:25.127+00	2026-05-06 16:18:30.087242+00
56	1	fr	Créer 10 fiches	Créez 10 fiches dans LangGo.	2026-05-04 21:05:25.127+00	2026-05-06 16:18:30.087242+00
54	1	ja	10枚の単語カードを作成	LangGoで10枚の単語カードを作成する。	2026-05-04 21:05:25.127+00	2026-05-06 16:18:30.087242+00
55	1	ko	플래시카드 10개 만들기	LangGo에서 플래시카드 10개를 만드세요.	2026-05-04 21:05:25.127+00	2026-05-06 16:18:30.087242+00
58	1	vi	Tạo 10 thẻ ghi nhớ	Tạo 10 thẻ ghi nhớ trong LangGo.	2026-05-04 21:05:25.127+00	2026-05-06 16:18:30.087242+00
52	1	zh	建立 10 張單字卡	在 LangGo 中建立 10 張單字卡。	2026-05-04 21:05:25.127+00	2026-05-06 16:18:30.087242+00
53	1	zh-Hans	创建 10 张单词卡	在 LangGo 中创建 10 张单词卡。	2026-05-04 21:05:25.127+00	2026-05-06 16:18:30.087242+00
64	2	es	Crear 50 tarjetas	Crea 50 tarjetas en LangGo.	2026-05-04 21:06:05.884+00	2026-05-06 16:18:30.087242+00
63	2	fr	Créer 50 fiches	Créez 50 fiches dans LangGo.	2026-05-04 21:06:05.884+00	2026-05-06 16:18:30.087242+00
61	2	ja	50枚の単語カードを作成	LangGoで50枚の単語カードを作成する。	2026-05-04 21:06:05.884+00	2026-05-06 16:18:30.087242+00
62	2	ko	플래시카드 50개 만들기	LangGo에서 플래시카드 50개를 만드세요.	2026-05-04 21:06:05.884+00	2026-05-06 16:18:30.087242+00
65	2	vi	Tạo 50 thẻ ghi nhớ	Tạo 50 thẻ ghi nhớ trong LangGo.	2026-05-04 21:06:05.884+00	2026-05-06 16:18:30.087242+00
59	2	zh	建立 50 張單字卡	在 LangGo 中建立 50 張單字卡。	2026-05-04 21:06:05.884+00	2026-05-06 16:18:30.087242+00
60	2	zh-Hans	创建 50 张单词卡	在 LangGo 中创建 50 张单词卡。	2026-05-04 21:06:05.884+00	2026-05-06 16:18:30.087242+00
71	3	es	Crear 100 tarjetas	Crea 100 tarjetas en LangGo.	2026-05-04 21:06:27.41+00	2026-05-06 16:18:30.087242+00
70	3	fr	Créer 100 fiches	Créez 100 fiches dans LangGo.	2026-05-04 21:06:27.41+00	2026-05-06 16:18:30.087242+00
68	3	ja	100枚の単語カードを作成	LangGoで100枚の単語カードを作成する。	2026-05-04 21:06:27.41+00	2026-05-06 16:18:30.087242+00
69	3	ko	플래시카드 100개 만들기	LangGo에서 플래시카드 100개를 만드세요.	2026-05-04 21:06:27.41+00	2026-05-06 16:18:30.087242+00
72	3	vi	Tạo 100 thẻ ghi nhớ	Tạo 100 thẻ ghi nhớ trong LangGo.	2026-05-04 21:06:27.41+00	2026-05-06 16:18:30.087242+00
66	3	zh	建立 100 張單字卡	在 LangGo 中建立 100 張單字卡。	2026-05-04 21:06:27.41+00	2026-05-06 16:18:30.087242+00
67	3	zh-Hans	创建 100 张单词卡	在 LangGo 中创建 100 张单词卡。	2026-05-04 21:06:27.41+00	2026-05-06 16:18:30.087242+00
78	4	es	Crear 200 tarjetas	Crea 200 tarjetas en LangGo.	2026-05-04 21:06:49.498+00	2026-05-06 16:18:30.087242+00
77	4	fr	Créer 200 fiches	Créez 200 fiches dans LangGo.	2026-05-04 21:06:49.498+00	2026-05-06 16:18:30.087242+00
75	4	ja	200枚の単語カードを作成	LangGoで200枚の単語カードを作成する。	2026-05-04 21:06:49.498+00	2026-05-06 16:18:30.087242+00
76	4	ko	플래시카드 200개 만들기	LangGo에서 플래시카드 200개를 만드세요.	2026-05-04 21:06:49.498+00	2026-05-06 16:18:30.087242+00
79	4	vi	Tạo 200 thẻ ghi nhớ	Tạo 200 thẻ ghi nhớ trong LangGo.	2026-05-04 21:06:49.498+00	2026-05-06 16:18:30.087242+00
73	4	zh	建立 200 張單字卡	在 LangGo 中建立 200 張單字卡。	2026-05-04 21:06:49.498+00	2026-05-06 16:18:30.087242+00
74	4	zh-Hans	创建 200 张单词卡	在 LangGo 中创建 200 张单词卡。	2026-05-04 21:06:49.498+00	2026-05-06 16:18:30.087242+00
85	5	es	Crear 500 tarjetas	Crea 500 tarjetas en LangGo.	2026-05-04 21:07:12.125+00	2026-05-06 16:18:30.087242+00
84	5	fr	Créer 500 fiches	Créez 500 fiches dans LangGo.	2026-05-04 21:07:12.125+00	2026-05-06 16:18:30.087242+00
82	5	ja	500枚の単語カードを作成	LangGoで500枚の単語カードを作成する。	2026-05-04 21:07:12.125+00	2026-05-06 16:18:30.087242+00
83	5	ko	플래시카드 500개 만들기	LangGo에서 플래시카드 500개를 만드세요.	2026-05-04 21:07:12.125+00	2026-05-06 16:18:30.087242+00
86	5	vi	Tạo 500 thẻ ghi nhớ	Tạo 500 thẻ ghi nhớ trong LangGo.	2026-05-04 21:07:12.125+00	2026-05-06 16:18:30.087242+00
80	5	zh	建立 500 張單字卡	在 LangGo 中建立 500 張單字卡。	2026-05-04 21:07:12.125+00	2026-05-06 16:18:30.087242+00
81	5	zh-Hans	创建 500 张单词卡	在 LangGo 中创建 500 张单词卡。	2026-05-04 21:07:12.125+00	2026-05-06 16:18:30.087242+00
92	6	es	Crear 1000 tarjetas	Crea 1000 tarjetas en LangGo.	2026-05-04 21:07:24.168+00	2026-05-06 16:18:30.087242+00
91	6	fr	Créer 1000 fiches	Créez 1000 fiches dans LangGo.	2026-05-04 21:07:24.168+00	2026-05-06 16:18:30.087242+00
89	6	ja	1000枚の単語カードを作成	LangGoで1000枚の単語カードを作成する。	2026-05-04 21:07:24.168+00	2026-05-06 16:18:30.087242+00
90	6	ko	플래시카드 1000개 만들기	LangGo에서 플래시카드 1000개를 만드세요.	2026-05-04 21:07:24.168+00	2026-05-06 16:18:30.087242+00
93	6	vi	Tạo 1000 thẻ ghi nhớ	Tạo 1000 thẻ ghi nhớ trong LangGo.	2026-05-04 21:07:24.168+00	2026-05-06 16:18:30.087242+00
87	6	zh	建立 1000 張單字卡	在 LangGo 中建立 1000 張單字卡。	2026-05-04 21:07:24.168+00	2026-05-06 16:18:30.087242+00
88	6	zh-Hans	创建 1000 张单词卡	在 LangGo 中创建 1000 张单词卡。	2026-05-04 21:07:24.168+00	2026-05-06 16:18:30.087242+00
99	7	es	Crear 2000 tarjetas	Crea 2000 tarjetas en LangGo.	2026-05-04 21:07:42.908+00	2026-05-06 16:18:30.087242+00
98	7	fr	Créer 2000 fiches	Créez 2000 fiches dans LangGo.	2026-05-04 21:07:42.908+00	2026-05-06 16:18:30.087242+00
96	7	ja	2000枚の単語カードを作成	LangGoで2000枚の単語カードを作成する。	2026-05-04 21:07:42.908+00	2026-05-06 16:18:30.087242+00
97	7	ko	플래시카드 2000개 만들기	LangGo에서 플래시카드 2000개를 만드세요.	2026-05-04 21:07:42.908+00	2026-05-06 16:18:30.087242+00
100	7	vi	Tạo 2000 thẻ ghi nhớ	Tạo 2000 thẻ ghi nhớ trong LangGo.	2026-05-04 21:07:42.908+00	2026-05-06 16:18:30.087242+00
94	7	zh	建立 2000 張單字卡	在 LangGo 中建立 2000 張單字卡。	2026-05-04 21:07:42.908+00	2026-05-06 16:18:30.087242+00
95	7	zh-Hans	创建 2000 张单词卡	在 LangGo 中创建 2000 张单词卡。	2026-05-04 21:07:42.908+00	2026-05-06 16:18:30.087242+00
106	8	es	Crear 3000 tarjetas	Crea 3000 tarjetas en LangGo.	2026-05-04 21:08:00.024+00	2026-05-06 16:18:30.087242+00
105	8	fr	Créer 3000 fiches	Créez 3000 fiches dans LangGo.	2026-05-04 21:08:00.024+00	2026-05-06 16:18:30.087242+00
103	8	ja	3000枚の単語カードを作成	LangGoで3000枚の単語カードを作成する。	2026-05-04 21:08:00.024+00	2026-05-06 16:18:30.087242+00
104	8	ko	플래시카드 3000개 만들기	LangGo에서 플래시카드 3000개를 만드세요.	2026-05-04 21:08:00.024+00	2026-05-06 16:18:30.087242+00
107	8	vi	Tạo 3000 thẻ ghi nhớ	Tạo 3000 thẻ ghi nhớ trong LangGo.	2026-05-04 21:08:00.024+00	2026-05-06 16:18:30.087242+00
101	8	zh	建立 3000 張單字卡	在 LangGo 中建立 3000 張單字卡。	2026-05-04 21:08:00.024+00	2026-05-06 16:18:30.087242+00
102	8	zh-Hans	创建 3000 张单词卡	在 LangGo 中创建 3000 张单词卡。	2026-05-04 21:08:00.024+00	2026-05-06 16:18:30.087242+00
113	9	es	Crear 5000 tarjetas	Crea 5000 tarjetas en LangGo.	2026-05-04 21:08:17.555+00	2026-05-06 16:18:30.087242+00
112	9	fr	Créer 5000 fiches	Créez 5000 fiches dans LangGo.	2026-05-04 21:08:17.555+00	2026-05-06 16:18:30.087242+00
110	9	ja	5000枚の単語カードを作成	LangGoで5000枚の単語カードを作成する。	2026-05-04 21:08:17.555+00	2026-05-06 16:18:30.087242+00
111	9	ko	플래시카드 5000개 만들기	LangGo에서 플래시카드 5000개를 만드세요.	2026-05-04 21:08:17.555+00	2026-05-06 16:18:30.087242+00
114	9	vi	Tạo 5000 thẻ ghi nhớ	Tạo 5000 thẻ ghi nhớ trong LangGo.	2026-05-04 21:08:17.555+00	2026-05-06 16:18:30.087242+00
108	9	zh	建立 5000 張單字卡	在 LangGo 中建立 5000 張單字卡。	2026-05-04 21:08:17.555+00	2026-05-06 16:18:30.087242+00
109	9	zh-Hans	创建 5000 张单词卡	在 LangGo 中创建 5000 张单词卡。	2026-05-04 21:08:17.555+00	2026-05-06 16:18:30.087242+00
120	10	es	Completar 100 repasos	Completa 100 repasos de tarjetas en LangGo.	2026-05-04 21:09:14.216+00	2026-05-06 16:18:30.087242+00
119	10	fr	Terminer 100 révisions	Terminez 100 révisions de fiches dans LangGo.	2026-05-04 21:09:14.216+00	2026-05-06 16:18:30.087242+00
117	10	ja	100回の復習を完了	LangGoで単語カードの復習を100回完了する。	2026-05-04 21:09:14.216+00	2026-05-06 16:18:30.087242+00
118	10	ko	복습 100회 완료	LangGo에서 플래시카드 복습 100회를 완료하세요.	2026-05-04 21:09:14.216+00	2026-05-06 16:18:30.087242+00
121	10	vi	Hoàn thành 100 lượt ôn tập	Hoàn thành 100 lượt ôn tập thẻ ghi nhớ trong LangGo.	2026-05-04 21:09:14.216+00	2026-05-06 16:18:30.087242+00
115	10	zh	完成 100 次複習	在 LangGo 中完成 100 次單字卡複習。	2026-05-04 21:09:14.216+00	2026-05-06 16:18:30.087242+00
116	10	zh-Hans	完成 100 次复习	在 LangGo 中完成 100 次单词卡复习。	2026-05-04 21:09:14.216+00	2026-05-06 16:18:30.087242+00
127	11	es	Completar 200 repasos	Completa 200 repasos de tarjetas en LangGo.	2026-05-04 21:09:51.515+00	2026-05-06 16:18:30.087242+00
126	11	fr	Terminer 200 révisions	Terminez 200 révisions de fiches dans LangGo.	2026-05-04 21:09:51.515+00	2026-05-06 16:18:30.087242+00
124	11	ja	200回の復習を完了	LangGoで単語カードの復習を200回完了する。	2026-05-04 21:09:51.515+00	2026-05-06 16:18:30.087242+00
125	11	ko	복습 200회 완료	LangGo에서 플래시카드 복습 200회를 완료하세요.	2026-05-04 21:09:51.515+00	2026-05-06 16:18:30.087242+00
128	11	vi	Hoàn thành 200 lượt ôn tập	Hoàn thành 200 lượt ôn tập thẻ ghi nhớ trong LangGo.	2026-05-04 21:09:51.515+00	2026-05-06 16:18:30.087242+00
122	11	zh	完成 200 次複習	在 LangGo 中完成 200 次單字卡複習。	2026-05-04 21:09:51.515+00	2026-05-06 16:18:30.087242+00
123	11	zh-Hans	完成 200 次复习	在 LangGo 中完成 200 次单词卡复习。	2026-05-04 21:09:51.515+00	2026-05-06 16:18:30.087242+00
134	12	es	Completar 500 repasos	Completa 500 repasos de tarjetas en LangGo.	2026-05-04 21:10:14.686+00	2026-05-06 16:18:30.087242+00
133	12	fr	Terminer 500 révisions	Terminez 500 révisions de fiches dans LangGo.	2026-05-04 21:10:14.686+00	2026-05-06 16:18:30.087242+00
131	12	ja	500回の復習を完了	LangGoで単語カードの復習を500回完了する。	2026-05-04 21:10:14.686+00	2026-05-06 16:18:30.087242+00
132	12	ko	복습 500회 완료	LangGo에서 플래시카드 복습 500회를 완료하세요.	2026-05-04 21:10:14.686+00	2026-05-06 16:18:30.087242+00
135	12	vi	Hoàn thành 500 lượt ôn tập	Hoàn thành 500 lượt ôn tập thẻ ghi nhớ trong LangGo.	2026-05-04 21:10:14.686+00	2026-05-06 16:18:30.087242+00
129	12	zh	完成 500 次複習	在 LangGo 中完成 500 次單字卡複習。	2026-05-04 21:10:14.686+00	2026-05-06 16:18:30.087242+00
130	12	zh-Hans	完成 500 次复习	在 LangGo 中完成 500 次单词卡复习。	2026-05-04 21:10:14.686+00	2026-05-06 16:18:30.087242+00
141	13	es	Completar 1000 repasos	Completa 1000 repasos de tarjetas en LangGo.	2026-05-04 21:11:00.936+00	2026-05-06 16:18:30.087242+00
140	13	fr	Terminer 1000 révisions	Terminez 1000 révisions de fiches dans LangGo.	2026-05-04 21:11:00.936+00	2026-05-06 16:18:30.087242+00
138	13	ja	1000回の復習を完了	LangGoで単語カードの復習を1000回完了する。	2026-05-04 21:11:00.936+00	2026-05-06 16:18:30.087242+00
139	13	ko	복습 1000회 완료	LangGo에서 플래시카드 복습 1000회를 완료하세요.	2026-05-04 21:11:00.936+00	2026-05-06 16:18:30.087242+00
142	13	vi	Hoàn thành 1000 lượt ôn tập	Hoàn thành 1000 lượt ôn tập thẻ ghi nhớ trong LangGo.	2026-05-04 21:11:00.936+00	2026-05-06 16:18:30.087242+00
136	13	zh	完成 1000 次複習	在 LangGo 中完成 1000 次單字卡複習。	2026-05-04 21:11:00.936+00	2026-05-06 16:18:30.087242+00
137	13	zh-Hans	完成 1000 次复习	在 LangGo 中完成 1000 次单词卡复习。	2026-05-04 21:11:00.936+00	2026-05-06 16:18:30.087242+00
27	14	en	Complete 2000 Reviews	Complete 2000 flashcard reviews in LangGo.	2026-05-04 21:11:27.529+00	2026-05-06 16:18:30.087242+00
148	14	es	Completar 2000 repasos	Completa 2000 repasos de tarjetas en LangGo.	2026-05-04 21:11:27.529+00	2026-05-06 16:18:30.087242+00
147	14	fr	Terminer 2000 révisions	Terminez 2000 révisions de fiches dans LangGo.	2026-05-04 21:11:27.529+00	2026-05-06 16:18:30.087242+00
145	14	ja	2000回の復習を完了	LangGoで単語カードの復習を2000回完了する。	2026-05-04 21:11:27.529+00	2026-05-06 16:18:30.087242+00
146	14	ko	복습 2000회 완료	LangGo에서 플래시카드 복습 2000회를 완료하세요.	2026-05-04 21:11:27.529+00	2026-05-06 16:18:30.087242+00
149	14	vi	Hoàn thành 2000 lượt ôn tập	Hoàn thành 2000 lượt ôn tập thẻ ghi nhớ trong LangGo.	2026-05-04 21:11:27.529+00	2026-05-06 16:18:30.087242+00
143	14	zh	完成 2000 次複習	在 LangGo 中完成 2000 次單字卡複習。	2026-05-04 21:11:27.529+00	2026-05-06 16:18:30.087242+00
144	14	zh-Hans	完成 2000 次复习	在 LangGo 中完成 2000 次单词卡复习。	2026-05-04 21:11:27.529+00	2026-05-06 16:18:30.087242+00
29	15	en	Complete 3000 Reviews	Complete 3000 flashcard reviews in LangGo.	2026-05-04 21:12:08.462+00	2026-05-06 16:18:30.087242+00
155	15	es	Completar 3000 repasos	Completa 3000 repasos de tarjetas en LangGo.	2026-05-04 21:12:08.462+00	2026-05-06 16:18:30.087242+00
154	15	fr	Terminer 3000 révisions	Terminez 3000 révisions de fiches dans LangGo.	2026-05-04 21:12:08.462+00	2026-05-06 16:18:30.087242+00
152	15	ja	3000回の復習を完了	LangGoで単語カードの復習を3000回完了する。	2026-05-04 21:12:08.462+00	2026-05-06 16:18:30.087242+00
153	15	ko	복습 3000회 완료	LangGo에서 플래시카드 복습 3000회를 완료하세요.	2026-05-04 21:12:08.462+00	2026-05-06 16:18:30.087242+00
156	15	vi	Hoàn thành 3000 lượt ôn tập	Hoàn thành 3000 lượt ôn tập thẻ ghi nhớ trong LangGo.	2026-05-04 21:12:08.462+00	2026-05-06 16:18:30.087242+00
150	15	zh	完成 3000 次複習	在 LangGo 中完成 3000 次單字卡複習。	2026-05-04 21:12:08.462+00	2026-05-06 16:18:30.087242+00
151	15	zh-Hans	完成 3000 次复习	在 LangGo 中完成 3000 次单词卡复习。	2026-05-04 21:12:08.462+00	2026-05-06 16:18:30.087242+00
31	16	en	Complete 5000 Reviews	Complete 5000 flashcard reviews in LangGo.	2026-05-04 21:12:50.558+00	2026-05-06 16:18:30.087242+00
162	16	es	Completar 5000 repasos	Completa 5000 repasos de tarjetas en LangGo.	2026-05-04 21:12:50.558+00	2026-05-06 16:18:30.087242+00
161	16	fr	Terminer 5000 révisions	Terminez 5000 révisions de fiches dans LangGo.	2026-05-04 21:12:50.558+00	2026-05-06 16:18:30.087242+00
159	16	ja	5000回の復習を完了	LangGoで単語カードの復習を5000回完了する。	2026-05-04 21:12:50.558+00	2026-05-06 16:18:30.087242+00
160	16	ko	복습 5000회 완료	LangGo에서 플래시카드 복습 5000회를 완료하세요.	2026-05-04 21:12:50.558+00	2026-05-06 16:18:30.087242+00
163	16	vi	Hoàn thành 5000 lượt ôn tập	Hoàn thành 5000 lượt ôn tập thẻ ghi nhớ trong LangGo.	2026-05-04 21:12:50.558+00	2026-05-06 16:18:30.087242+00
157	16	zh	完成 5000 次複習	在 LangGo 中完成 5000 次單字卡複習。	2026-05-04 21:12:50.558+00	2026-05-06 16:18:30.087242+00
158	16	zh-Hans	完成 5000 次复习	在 LangGo 中完成 5000 次单词卡复习。	2026-05-04 21:12:50.558+00	2026-05-06 16:18:30.087242+00
33	17	en	Remember 10 Flashcards	Remember 10 flashcards in LangGo.	2026-05-04 21:47:22.961+00	2026-05-06 16:18:30.087242+00
169	17	es	Recordar 10 tarjetas	Recuerda 10 tarjetas en LangGo.	2026-05-04 21:47:22.961+00	2026-05-06 16:18:30.087242+00
168	17	fr	Mémoriser 10 fiches	Mémorisez 10 fiches dans LangGo.	2026-05-04 21:47:22.961+00	2026-05-06 16:18:30.087242+00
166	17	ja	10枚の単語カードを記憶	LangGoで10枚の単語カードを記憶する。	2026-05-04 21:47:22.961+00	2026-05-06 16:18:30.087242+00
167	17	ko	플래시카드 10개 기억하기	LangGo에서 플래시카드 10개를 기억하세요.	2026-05-04 21:47:22.961+00	2026-05-06 16:18:30.087242+00
170	17	vi	Ghi nhớ 10 thẻ ghi nhớ	Ghi nhớ 10 thẻ ghi nhớ trong LangGo.	2026-05-04 21:47:22.961+00	2026-05-06 16:18:30.087242+00
164	17	zh	記住 10 張單字卡	在 LangGo 中記住 10 張單字卡。	2026-05-04 21:47:22.961+00	2026-05-06 16:18:30.087242+00
165	17	zh-Hans	记住 10 张单词卡	在 LangGo 中记住 10 张单词卡。	2026-05-04 21:47:22.961+00	2026-05-06 16:18:30.087242+00
35	18	en	Remember 20 Flashcards	Remember 20 flashcards in LangGo.	2026-05-04 21:47:51.873+00	2026-05-06 16:18:30.087242+00
176	18	es	Recordar 20 tarjetas	Recuerda 20 tarjetas en LangGo.	2026-05-04 21:47:51.873+00	2026-05-06 16:18:30.087242+00
175	18	fr	Mémoriser 20 fiches	Mémorisez 20 fiches dans LangGo.	2026-05-04 21:47:51.873+00	2026-05-06 16:18:30.087242+00
173	18	ja	20枚の単語カードを記憶	LangGoで20枚の単語カードを記憶する。	2026-05-04 21:47:51.873+00	2026-05-06 16:18:30.087242+00
174	18	ko	플래시카드 20개 기억하기	LangGo에서 플래시카드 20개를 기억하세요.	2026-05-04 21:47:51.873+00	2026-05-06 16:18:30.087242+00
177	18	vi	Ghi nhớ 20 thẻ ghi nhớ	Ghi nhớ 20 thẻ ghi nhớ trong LangGo.	2026-05-04 21:47:51.873+00	2026-05-06 16:18:30.087242+00
171	18	zh	記住 20 張單字卡	在 LangGo 中記住 20 張單字卡。	2026-05-04 21:47:51.873+00	2026-05-06 16:18:30.087242+00
172	18	zh-Hans	记住 20 张单词卡	在 LangGo 中记住 20 张单词卡。	2026-05-04 21:47:51.873+00	2026-05-06 16:18:30.087242+00
37	19	en	Remember 50 Flashcards	Remember 50 flashcards in LangGo.	2026-05-04 21:48:14.065+00	2026-05-06 16:18:30.087242+00
183	19	es	Recordar 50 tarjetas	Recuerda 50 tarjetas en LangGo.	2026-05-04 21:48:14.065+00	2026-05-06 16:18:30.087242+00
182	19	fr	Mémoriser 50 fiches	Mémorisez 50 fiches dans LangGo.	2026-05-04 21:48:14.065+00	2026-05-06 16:18:30.087242+00
180	19	ja	50枚の単語カードを記憶	LangGoで50枚の単語カードを記憶する。	2026-05-04 21:48:14.065+00	2026-05-06 16:18:30.087242+00
181	19	ko	플래시카드 50개 기억하기	LangGo에서 플래시카드 50개를 기억하세요.	2026-05-04 21:48:14.065+00	2026-05-06 16:18:30.087242+00
184	19	vi	Ghi nhớ 50 thẻ ghi nhớ	Ghi nhớ 50 thẻ ghi nhớ trong LangGo.	2026-05-04 21:48:14.065+00	2026-05-06 16:18:30.087242+00
178	19	zh	記住 50 張單字卡	在 LangGo 中記住 50 張單字卡。	2026-05-04 21:48:14.065+00	2026-05-06 16:18:30.087242+00
179	19	zh-Hans	记住 50 张单词卡	在 LangGo 中记住 50 张单词卡。	2026-05-04 21:48:14.065+00	2026-05-06 16:18:30.087242+00
39	20	en	Remember 100 Flashcards	Remember 100 flashcards in LangGo.	2026-05-04 21:48:36.776+00	2026-05-06 16:18:30.087242+00
190	20	es	Recordar 100 tarjetas	Recuerda 100 tarjetas en LangGo.	2026-05-04 21:48:36.776+00	2026-05-06 16:18:30.087242+00
189	20	fr	Mémoriser 100 fiches	Mémorisez 100 fiches dans LangGo.	2026-05-04 21:48:36.776+00	2026-05-06 16:18:30.087242+00
187	20	ja	100枚の単語カードを記憶	LangGoで100枚の単語カードを記憶する。	2026-05-04 21:48:36.776+00	2026-05-06 16:18:30.087242+00
188	20	ko	플래시카드 100개 기억하기	LangGo에서 플래시카드 100개를 기억하세요.	2026-05-04 21:48:36.776+00	2026-05-06 16:18:30.087242+00
191	20	vi	Ghi nhớ 100 thẻ ghi nhớ	Ghi nhớ 100 thẻ ghi nhớ trong LangGo.	2026-05-04 21:48:36.776+00	2026-05-06 16:18:30.087242+00
185	20	zh	記住 100 張單字卡	在 LangGo 中記住 100 張單字卡。	2026-05-04 21:48:36.776+00	2026-05-06 16:18:30.087242+00
186	20	zh-Hans	记住 100 张单词卡	在 LangGo 中记住 100 张单词卡。	2026-05-04 21:48:36.776+00	2026-05-06 16:18:30.087242+00
41	21	en	Remember 200 Flashcards	Remember 200 flashcards in LangGo.	2026-05-04 21:49:18.334+00	2026-05-06 16:18:30.087242+00
197	21	es	Recordar 200 tarjetas	Recuerda 200 tarjetas en LangGo.	2026-05-04 21:49:18.334+00	2026-05-06 16:18:30.087242+00
196	21	fr	Mémoriser 200 fiches	Mémorisez 200 fiches dans LangGo.	2026-05-04 21:49:18.334+00	2026-05-06 16:18:30.087242+00
194	21	ja	200枚の単語カードを記憶	LangGoで200枚の単語カードを記憶する。	2026-05-04 21:49:18.334+00	2026-05-06 16:18:30.087242+00
195	21	ko	플래시카드 200개 기억하기	LangGo에서 플래시카드 200개를 기억하세요.	2026-05-04 21:49:18.334+00	2026-05-06 16:18:30.087242+00
198	21	vi	Ghi nhớ 200 thẻ ghi nhớ	Ghi nhớ 200 thẻ ghi nhớ trong LangGo.	2026-05-04 21:49:18.334+00	2026-05-06 16:18:30.087242+00
192	21	zh	記住 200 張單字卡	在 LangGo 中記住 200 張單字卡。	2026-05-04 21:49:18.334+00	2026-05-06 16:18:30.087242+00
193	21	zh-Hans	记住 200 张单词卡	在 LangGo 中记住 200 张单词卡。	2026-05-04 21:49:18.334+00	2026-05-06 16:18:30.087242+00
43	22	en	Remember 500 Flashcards	Remember 500 flashcards in LangGo.	2026-05-04 21:49:56.678+00	2026-05-06 16:18:30.087242+00
204	22	es	Recordar 500 tarjetas	Recuerda 500 tarjetas en LangGo.	2026-05-04 21:49:56.678+00	2026-05-06 16:18:30.087242+00
203	22	fr	Mémoriser 500 fiches	Mémorisez 500 fiches dans LangGo.	2026-05-04 21:49:56.678+00	2026-05-06 16:18:30.087242+00
201	22	ja	500枚の単語カードを記憶	LangGoで500枚の単語カードを記憶する。	2026-05-04 21:49:56.678+00	2026-05-06 16:18:30.087242+00
202	22	ko	플래시카드 500개 기억하기	LangGo에서 플래시카드 500개를 기억하세요.	2026-05-04 21:49:56.678+00	2026-05-06 16:18:30.087242+00
205	22	vi	Ghi nhớ 500 thẻ ghi nhớ	Ghi nhớ 500 thẻ ghi nhớ trong LangGo.	2026-05-04 21:49:56.678+00	2026-05-06 16:18:30.087242+00
199	22	zh	記住 500 張單字卡	在 LangGo 中記住 500 張單字卡。	2026-05-04 21:49:56.678+00	2026-05-06 16:18:30.087242+00
200	22	zh-Hans	记住 500 张单词卡	在 LangGo 中记住 500 张单词卡。	2026-05-04 21:49:56.678+00	2026-05-06 16:18:30.087242+00
45	23	en	Remember 1000 Flashcards	Remember 1000 flashcards in LangGo.	2026-05-04 21:50:31.416+00	2026-05-06 16:18:30.087242+00
211	23	es	Recordar 1000 tarjetas	Recuerda 1000 tarjetas en LangGo.	2026-05-04 21:50:31.416+00	2026-05-06 16:18:30.087242+00
210	23	fr	Mémoriser 1000 fiches	Mémorisez 1000 fiches dans LangGo.	2026-05-04 21:50:31.416+00	2026-05-06 16:18:30.087242+00
208	23	ja	1000枚の単語カードを記憶	LangGoで1000枚の単語カードを記憶する。	2026-05-04 21:50:31.416+00	2026-05-06 16:18:30.087242+00
209	23	ko	플래시카드 1000개 기억하기	LangGo에서 플래시카드 1000개를 기억하세요.	2026-05-04 21:50:31.416+00	2026-05-06 16:18:30.087242+00
212	23	vi	Ghi nhớ 1000 thẻ ghi nhớ	Ghi nhớ 1000 thẻ ghi nhớ trong LangGo.	2026-05-04 21:50:31.416+00	2026-05-06 16:18:30.087242+00
206	23	zh	記住 1000 張單字卡	在 LangGo 中記住 1000 張單字卡。	2026-05-04 21:50:31.416+00	2026-05-06 16:18:30.087242+00
207	23	zh-Hans	记住 1000 张单词卡	在 LangGo 中记住 1000 张单词卡。	2026-05-04 21:50:31.416+00	2026-05-06 16:18:30.087242+00
47	24	en	Remember 2000 Flashcards	Remember 2000 flashcards in LangGo.	2026-05-04 21:50:48.995+00	2026-05-06 16:18:30.087242+00
218	24	es	Recordar 2000 tarjetas	Recuerda 2000 tarjetas en LangGo.	2026-05-04 21:50:48.995+00	2026-05-06 16:18:30.087242+00
217	24	fr	Mémoriser 2000 fiches	Mémorisez 2000 fiches dans LangGo.	2026-05-04 21:50:48.995+00	2026-05-06 16:18:30.087242+00
215	24	ja	2000枚の単語カードを記憶	LangGoで2000枚の単語カードを記憶する。	2026-05-04 21:50:48.995+00	2026-05-06 16:18:30.087242+00
216	24	ko	플래시카드 2000개 기억하기	LangGo에서 플래시카드 2000개를 기억하세요.	2026-05-04 21:50:48.995+00	2026-05-06 16:18:30.087242+00
219	24	vi	Ghi nhớ 2000 thẻ ghi nhớ	Ghi nhớ 2000 thẻ ghi nhớ trong LangGo.	2026-05-04 21:50:48.995+00	2026-05-06 16:18:30.087242+00
213	24	zh	記住 2000 張單字卡	在 LangGo 中記住 2000 張單字卡。	2026-05-04 21:50:48.995+00	2026-05-06 16:18:30.087242+00
214	24	zh-Hans	记住 2000 张单词卡	在 LangGo 中记住 2000 张单词卡。	2026-05-04 21:50:48.995+00	2026-05-06 16:18:30.087242+00
49	25	en	Remember 3000 Flashcards	Remember 3000 flashcards in LangGo.	2026-05-04 21:51:18.454+00	2026-05-06 16:18:30.087242+00
225	25	es	Recordar 3000 tarjetas	Recuerda 3000 tarjetas en LangGo.	2026-05-04 21:51:18.454+00	2026-05-06 16:18:30.087242+00
224	25	fr	Mémoriser 3000 fiches	Mémorisez 3000 fiches dans LangGo.	2026-05-04 21:51:18.454+00	2026-05-06 16:18:30.087242+00
222	25	ja	3000枚の単語カードを記憶	LangGoで3000枚の単語カードを記憶する。	2026-05-04 21:51:18.454+00	2026-05-06 16:18:30.087242+00
223	25	ko	플래시카드 3000개 기억하기	LangGo에서 플래시카드 3000개를 기억하세요.	2026-05-04 21:51:18.454+00	2026-05-06 16:18:30.087242+00
226	25	vi	Ghi nhớ 3000 thẻ ghi nhớ	Ghi nhớ 3000 thẻ ghi nhớ trong LangGo.	2026-05-04 21:51:18.454+00	2026-05-06 16:18:30.087242+00
220	25	zh	記住 3000 張單字卡	在 LangGo 中記住 3000 張單字卡。	2026-05-04 21:51:18.454+00	2026-05-06 16:18:30.087242+00
221	25	zh-Hans	记住 3000 张单词卡	在 LangGo 中记住 3000 张单词卡。	2026-05-04 21:51:18.454+00	2026-05-06 16:18:30.087242+00
51	26	en	Remember 5000 Flashcards	Remember 5000 flashcards in LangGo.	2026-05-04 21:51:39.33+00	2026-05-06 16:18:30.087242+00
232	26	es	Recordar 5000 tarjetas	Recuerda 5000 tarjetas en LangGo.	2026-05-04 21:51:39.33+00	2026-05-06 16:18:30.087242+00
231	26	fr	Mémoriser 5000 fiches	Mémorisez 5000 fiches dans LangGo.	2026-05-04 21:51:39.33+00	2026-05-06 16:18:30.087242+00
229	26	ja	5000枚の単語カードを記憶	LangGoで5000枚の単語カードを記憶する。	2026-05-04 21:51:39.33+00	2026-05-06 16:18:30.087242+00
230	26	ko	플래시카드 5000개 기억하기	LangGo에서 플래시카드 5000개를 기억하세요.	2026-05-04 21:51:39.33+00	2026-05-06 16:18:30.087242+00
233	26	vi	Ghi nhớ 5000 thẻ ghi nhớ	Ghi nhớ 5000 thẻ ghi nhớ trong LangGo.	2026-05-04 21:51:39.33+00	2026-05-06 16:18:30.087242+00
227	26	zh	記住 5000 張單字卡	在 LangGo 中記住 5000 張單字卡。	2026-05-04 21:51:39.33+00	2026-05-06 16:18:30.087242+00
228	26	zh-Hans	记住 5000 张单词卡	在 LangGo 中记住 5000 张单词卡。	2026-05-04 21:51:39.33+00	2026-05-06 16:18:30.087242+00
\.


--
-- TOC entry 5114 (class 0 OID 148532)
-- Dependencies: 771
-- Data for Name: as_achievements; Type: TABLE DATA; Schema: achievement_system; Owner: -
--

COPY {{SCHEMA}}.as_achievements (id, code, event_name, icon_name, points, goal, created_at, updated_at) FROM stdin;
1	FLASHCARD_CREATE_10	flashcard.created	pencil	1	10	2026-05-04 21:05:25.127+00	2026-05-06 15:53:20.515831+00
2	FLASHCARD_CREATE_50	flashcard.created	square.and.pencil	1	50	2026-05-04 21:06:05.884+00	2026-05-06 15:53:20.515831+00
3	FLASHCARD_CREATE_100	flashcard.created	note.text.badge.plus	1	100	2026-05-04 21:06:27.41+00	2026-05-06 15:53:20.515831+00
4	FLASHCARD_CREATE_200	flashcard.created	text.badge.plus	1	200	2026-05-04 21:06:49.498+00	2026-05-06 15:53:20.515831+00
5	FLASHCARD_CREATE_500	flashcard.created	plus.square.on.square	1	500	2026-05-04 21:07:12.125+00	2026-05-06 15:53:20.515831+00
6	FLASHCARD_CREATE_1000	flashcard.created	rectangle.stack.badge.plus	1	1000	2026-05-04 21:07:24.168+00	2026-05-06 15:53:20.515831+00
7	FLASHCARD_CREATE_2000	flashcard.created	square.stack.3d.up	1	2000	2026-05-04 21:07:42.908+00	2026-05-06 15:53:20.515831+00
8	FLASHCARD_CREATE_3000	flashcard.created	books.vertical.fill	1	3000	2026-05-04 21:08:00.024+00	2026-05-06 15:53:20.515831+00
9	FLASHCARD_CREATE_5000	flashcard.created	archivebox.fill	1	5000	2026-05-04 21:08:17.555+00	2026-05-06 15:53:20.515831+00
10	FLASHCARD_REVIEW_100	flashcard.reviewed	play.circle	1	100	2026-05-04 21:09:14.216+00	2026-05-06 15:53:20.515831+00
11	FLASHCARD_REVIEW_200	flashcard.reviewed	play.circle.fill	1	200	2026-05-04 21:09:51.515+00	2026-05-06 15:53:20.515831+00
12	FLASHCARD_REVIEW_500	flashcard.reviewed	arrow.triangle.2.circlepath.circle	1	500	2026-05-04 21:10:14.686+00	2026-05-06 15:53:20.515831+00
13	FLASHCARD_REVIEW_1000	flashcard.reviewed	checkmark.circle	1	1000	2026-05-04 21:11:00.936+00	2026-05-06 15:53:20.515831+00
14	FLASHCARD_REVIEW_2000	flashcard.reviewed	checkmark.circle.fill	1	2000	2026-05-04 21:11:27.529+00	2026-05-06 15:53:20.515831+00
15	FLASHCARD_REVIEW_3000	flashcard.reviewed	checkmark.seal	1	3000	2026-05-04 21:12:08.462+00	2026-05-06 15:53:20.515831+00
16	FLASHCARD_REVIEW_5000	flashcard.reviewed	checkmark.seal.fill	1	5000	2026-05-04 21:12:50.558+00	2026-05-06 15:53:20.515831+00
17	FLASHCARD_REMEMBERED_10	flashcard.remembered	sparkles	1	10	2026-05-04 21:47:22.961+00	2026-05-06 15:53:20.515831+00
18	FLASHCARD_REMEMBERED_20	flashcard.remembered	star	1	20	2026-05-04 21:47:51.873+00	2026-05-06 15:53:20.515831+00
19	FLASHCARD_REMEMBERED_50	flashcard.remembered	star.fill	1	50	2026-05-04 21:48:14.065+00	2026-05-06 15:53:20.515831+00
20	FLASHCARD_REMEMBERED_100	flashcard.remembered	star.circle	1	100	2026-05-04 21:48:36.776+00	2026-05-06 15:53:20.515831+00
21	FLASHCARD_REMEMBERED_200	flashcard.remembered	star.circle.fill	1	200	2026-05-04 21:49:18.334+00	2026-05-06 15:53:20.515831+00
22	FLASHCARD_REMEMBERED_500	flashcard.remembered	flag.fill	1	500	2026-05-04 21:49:56.678+00	2026-05-06 15:53:20.515831+00
23	FLASHCARD_REMEMBERED_1000	flashcard.remembered	rosette	1	1000	2026-05-04 21:50:31.416+00	2026-05-06 15:53:20.515831+00
24	FLASHCARD_REMEMBERED_2000	flashcard.remembered	medal.fill	1	2000	2026-05-04 21:50:48.995+00	2026-05-06 15:53:20.515831+00
25	FLASHCARD_REMEMBERED_3000	flashcard.remembered	crown	1	3000	2026-05-04 21:51:18.454+00	2026-05-06 15:53:20.515831+00
26	FLASHCARD_REMEMBERED_5000	flashcard.remembered	crown.fill	1	5000	2026-05-04 21:51:39.33+00	2026-05-06 15:53:20.515831+00
\.


--
-- TOC entry 5116 (class 0 OID 148541)
-- Dependencies: 773
-- Data for Name: as_event_lists; Type: TABLE DATA; Schema: achievement_system; Owner: -
--

COPY {{SCHEMA}}.as_event_lists (id, event_name, points, created_at, updated_at) FROM stdin;
1	flashcard.created	1	2026-05-04 21:38:27.732+00	2026-05-04 21:38:27.732+00
2	flashcard.reviewed	1	2026-05-04 21:38:34.296+00	2026-05-04 21:38:34.296+00
3	flashcard.remembered	1	2026-05-04 21:38:49.875+00	2026-05-04 21:38:49.875+00
4	article.created	1	2026-05-04 21:39:52.327+00	2026-05-04 21:39:52.327+00
\.


--
-- TOC entry 5118 (class 0 OID 148548)
-- Dependencies: 775
-- Data for Name: as_event_logs; Type: TABLE DATA; Schema: achievement_system; Owner: -
--

COPY {{SCHEMA}}.as_event_logs (id, event_name, userid, username, payload_json, received_at, status, handle_result, handled_at) FROM stdin;
61	flashcard.reviewed	58	aug13	{"result": "wrong", "userId": 58, "eventId": "721c1324-dd53-4f59-92fc-ca707f74060c", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:34.065Z", "tierBefore": "new", "flashcardId": 3254}	2026-05-18 05:11:35.333651+00	handled	\N	2026-05-18 05:11:35.333651+00
63	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e8e4392d-a583-42cf-abec-8692899a70df", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:40.026Z", "tierBefore": "new", "flashcardId": 3255}	2026-05-18 05:11:41.114318+00	handled	\N	2026-05-18 05:11:41.114318+00
65	flashcard.reviewed	58	aug13	{"result": "wrong", "userId": 58, "eventId": "8b7fbb7b-0ce6-4713-84e6-f32a16154830", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:48.653Z", "tierBefore": "new", "flashcardId": 3256}	2026-05-18 05:11:49.510678+00	handled	\N	2026-05-18 05:11:49.510678+00
67	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "30a47293-fa08-4765-a95c-5768d0ab28c7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:51.653Z", "tierBefore": "new", "flashcardId": 3261}	2026-05-18 05:11:52.757081+00	handled	\N	2026-05-18 05:11:52.757081+00
69	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3d1ebcbc-dd67-4cdb-974b-ca761bde1122", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:53.762Z", "tierBefore": "new", "flashcardId": 3262}	2026-05-18 05:11:54.884346+00	handled	\N	2026-05-18 05:11:54.884346+00
71	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e4fca412-d961-4a68-8812-109749e0f88c", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:12:01.296Z", "tierBefore": "new", "flashcardId": 3269}	2026-05-18 05:12:02.381977+00	handled	\N	2026-05-18 05:12:02.381977+00
91	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "29730f6c-aa5c-4d22-9094-e16f2819ea57", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.134Z", "tierBefore": "new", "flashcardId": 3256}	2026-05-18 06:02:02.266592+00	handled	\N	2026-05-18 06:02:02.266592+00
92	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "789bd5b3-1721-484f-b3db-5292bb1c2b20", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:56.280Z", "tierBefore": "new", "flashcardId": 3094}	2026-05-18 06:02:02.328072+00	handled	\N	2026-05-18 06:02:02.328072+00
124	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "577b7aa9-0f86-45aa-b56d-699dbfa32546", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.367Z", "tierBefore": "new", "flashcardId": 3085}	2026-05-18 06:02:04.499417+00	handled	\N	2026-05-18 06:02:04.499417+00
129	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "002264bc-3487-4c7f-856a-e2675e6a66ad", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:56.688Z", "tierBefore": "new", "flashcardId": 3092}	2026-05-18 06:02:05.963395+00	handled	\N	2026-05-18 06:02:05.963395+00
133	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "2553d304-de76-47e3-ae1d-5c8fdc7cbb8a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.053Z", "tierBefore": "new", "flashcardId": 3091}	2026-05-18 06:02:06.982335+00	handled	\N	2026-05-18 06:02:06.982335+00
95	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "002264bc-3487-4c7f-856a-e2675e6a66ad", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:56.688Z", "tierBefore": "new", "flashcardId": 3092}	2026-05-18 06:02:02.366479+00	handled	\N	2026-05-18 06:02:02.366479+00
94	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "84a39124-1d3a-4694-852d-b1edc1da1315", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.077Z", "tierBefore": "new", "flashcardId": 3254}	2026-05-18 06:02:02.358337+00	handled	\N	2026-05-18 06:02:02.358337+00
93	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "577b7aa9-0f86-45aa-b56d-699dbfa32546", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.367Z", "tierBefore": "new", "flashcardId": 3085}	2026-05-18 06:02:02.358434+00	handled	\N	2026-05-18 06:02:02.358434+00
96	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "978a1785-2cc2-491e-a747-3fcd00ee20bf", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:56.188Z", "tierBefore": "new", "flashcardId": 3093}	2026-05-18 06:02:02.385985+00	handled	\N	2026-05-18 06:02:02.385985+00
108	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4a37d550-ce34-4256-a858-42174f57f31d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.596Z", "tierBefore": "new", "flashcardId": 3284}	2026-05-18 06:02:03.203763+00	handled	\N	2026-05-18 06:02:03.203763+00
111	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ba217fd6-ba1e-4c45-be0f-9bbdf796804f", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.592Z", "tierBefore": "new", "flashcardId": 3289}	2026-05-18 06:02:03.282329+00	handled	\N	2026-05-18 06:02:03.282329+00
130	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b290bc25-ebf1-4430-aca5-752ed610a979", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:00.150Z", "tierBefore": "new", "flashcardId": 3301}	2026-05-18 06:02:06.000912+00	handled	\N	2026-05-18 06:02:06.000912+00
97	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "9fa73317-5dcc-4d96-8b32-130fc6e28ea8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.496Z", "tierBefore": "new", "flashcardId": 3262}	2026-05-18 06:02:02.432619+00	handled	\N	2026-05-18 06:02:02.432619+00
98	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b8d94b6f-56e6-4f00-8f60-e855ada46e9a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:56.724Z", "tierBefore": "new", "flashcardId": 3253}	2026-05-18 06:02:02.398016+00	handled	\N	2026-05-18 06:02:02.398016+00
102	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "5bce2243-2d69-4cc3-872a-ac587ef42fae", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.526Z", "tierBefore": "new", "flashcardId": 3261}	2026-05-18 06:02:03.016979+00	handled	\N	2026-05-18 06:02:03.016979+00
105	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "cacf1d16-e9e7-4492-9a34-671b30b61c06", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.794Z", "tierBefore": "new", "flashcardId": 3272}	2026-05-18 06:02:03.120085+00	handled	\N	2026-05-18 06:02:03.120085+00
112	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4a91e980-56db-4445-933b-c7c300409a76", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.597Z", "tierBefore": "new", "flashcardId": 3285}	2026-05-18 06:02:03.308334+00	handled	\N	2026-05-18 06:02:03.308334+00
99	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "2553d304-de76-47e3-ae1d-5c8fdc7cbb8a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.053Z", "tierBefore": "new", "flashcardId": 3091}	2026-05-18 06:02:02.494039+00	handled	\N	2026-05-18 06:02:02.494039+00
118	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8b71b323-7f1b-4e47-b714-1511aa9592a6", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.442Z", "tierBefore": "new", "flashcardId": 3299}	2026-05-18 06:02:03.47463+00	handled	\N	2026-05-18 06:02:03.47463+00
100	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "6af5a0da-4ada-4783-b01b-7a312a1874f4", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.563Z", "tierBefore": "new", "flashcardId": 3286}	2026-05-18 06:02:02.989711+00	handled	\N	2026-05-18 06:02:02.989711+00
104	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3d46f046-6a69-4b2e-9689-7086d9d10906", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.598Z", "tierBefore": "new", "flashcardId": 3287}	2026-05-18 06:02:03.084273+00	handled	\N	2026-05-18 06:02:03.084273+00
113	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "433c9be4-8f4d-4477-b658-3053a535e0aa", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.724Z", "tierBefore": "new", "flashcardId": 3292}	2026-05-18 06:02:03.333911+00	handled	\N	2026-05-18 06:02:03.333911+00
116	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7c5cb912-5191-4def-8149-5d7ddfd4e0af", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.407Z", "tierBefore": "new", "flashcardId": 3294}	2026-05-18 06:02:03.419627+00	handled	\N	2026-05-18 06:02:03.419627+00
119	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "41f9f93c-51a5-40d8-b8d5-9dd7986741b2", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.502Z", "tierBefore": "new", "flashcardId": 3298}	2026-05-18 06:02:03.962845+00	handled	\N	2026-05-18 06:02:03.962845+00
123	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "9e40e754-0da7-40e3-8cda-8361964fdb26", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.473Z", "tierBefore": "new", "flashcardId": 3297}	2026-05-18 06:02:04.498875+00	handled	\N	2026-05-18 06:02:04.498875+00
101	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "66c2806d-5399-4a39-8887-1cdf6fbb7044", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.065Z", "tierBefore": "new", "flashcardId": 3084}	2026-05-18 06:02:02.986672+00	handled	\N	2026-05-18 06:02:02.986672+00
103	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "250f0541-0f97-47aa-9ed7-16b570a93b7f", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.905Z", "tierBefore": "new", "flashcardId": 3270}	2026-05-18 06:02:03.053598+00	handled	\N	2026-05-18 06:02:03.053598+00
106	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "d7d6fbf4-3c8c-4181-b80b-263e5621ab58", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.595Z", "tierBefore": "new", "flashcardId": 3290}	2026-05-18 06:02:03.147767+00	handled	\N	2026-05-18 06:02:03.147767+00
109	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ec96fe5f-9484-463c-bdc6-1b467871ec9d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.634Z", "tierBefore": "new", "flashcardId": 3288}	2026-05-18 06:02:03.231407+00	handled	\N	2026-05-18 06:02:03.231407+00
115	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e0cd307a-913a-448f-91af-9474ff1ef76a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.438Z", "tierBefore": "new", "flashcardId": 3295}	2026-05-18 06:02:03.394526+00	handled	\N	2026-05-18 06:02:03.394526+00
121	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "9c3f0164-dbe0-45a7-9718-1279fc74d78d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.376Z", "tierBefore": "new", "flashcardId": 3283}	2026-05-18 06:02:03.99047+00	handled	\N	2026-05-18 06:02:03.99047+00
125	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "45e0d8ec-09a6-4a9b-b7a2-4a859ae52d66", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.566Z", "tierBefore": "new", "flashcardId": 3303}	2026-05-18 06:02:05.005173+00	handled	\N	2026-05-18 06:02:05.005173+00
107	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "c0cfaf8c-c7c1-4719-a7ca-e5e33cde186b", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.988Z", "tierBefore": "new", "flashcardId": 3269}	2026-05-18 06:02:03.176621+00	handled	\N	2026-05-18 06:02:03.176621+00
110	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "17604917-46d6-468b-9f31-385418e57661", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.576Z", "tierBefore": "new", "flashcardId": 3282}	2026-05-18 06:02:03.256159+00	handled	\N	2026-05-18 06:02:03.256159+00
114	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "682b47bf-8c37-4328-8600-16e482f28e2a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.787Z", "tierBefore": "new", "flashcardId": 3291}	2026-05-18 06:02:03.365208+00	handled	\N	2026-05-18 06:02:03.365208+00
117	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "9d66690d-6e09-4469-b7ff-16ee2945d934", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.344Z", "tierBefore": "new", "flashcardId": 3293}	2026-05-18 06:02:03.447337+00	handled	\N	2026-05-18 06:02:03.447337+00
122	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "bef873d0-591c-43f3-b6d3-9cd0943b01ea", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.443Z", "tierBefore": "new", "flashcardId": 3296}	2026-05-18 06:02:04.019569+00	handled	\N	2026-05-18 06:02:04.019569+00
120	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "84a39124-1d3a-4694-852d-b1edc1da1315", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.077Z", "tierBefore": "new", "flashcardId": 3254}	2026-05-18 06:02:03.960564+00	handled	\N	2026-05-18 06:02:03.960564+00
126	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "978a1785-2cc2-491e-a747-3fcd00ee20bf", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:56.188Z", "tierBefore": "new", "flashcardId": 3093}	2026-05-18 06:02:05.000656+00	handled	\N	2026-05-18 06:02:05.000656+00
134	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3d46f046-6a69-4b2e-9689-7086d9d10906", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:58.598Z", "tierBefore": "new", "flashcardId": 3287}	2026-05-18 06:02:07.476717+00	handled	\N	2026-05-18 06:02:07.476717+00
127	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "560e3145-0b22-4b64-a8cd-34abe1883ff3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.349Z", "tierBefore": "new", "flashcardId": 3255}	2026-05-18 06:02:05.500981+00	handled	\N	2026-05-18 06:02:05.500981+00
132	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "9fa73317-5dcc-4d96-8b32-130fc6e28ea8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.496Z", "tierBefore": "new", "flashcardId": 3262}	2026-05-18 06:02:06.488736+00	handled	\N	2026-05-18 06:02:06.488736+00
135	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "41f9f93c-51a5-40d8-b8d5-9dd7986741b2", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.502Z", "tierBefore": "new", "flashcardId": 3298}	2026-05-18 06:02:07.944813+00	handled	\N	2026-05-18 06:02:07.944813+00
159	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "08728eba-d33e-47d9-8e01-350015ac5546", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:02.987Z", "tierBefore": "new", "flashcardId": 3286}	2026-05-18 06:03:04.12053+00	handled	\N	2026-05-18 06:03:04.12053+00
167	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "f9ab19ce-1f0a-425f-9ab3-55e1ad4dcddb", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:04.387Z", "tierBefore": "new", "flashcardId": 3284}	2026-05-18 06:03:05.504972+00	handled	\N	2026-05-18 06:03:05.504972+00
171	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "0ce1b11c-0646-45fb-89a4-29070a7ebf4b", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:00.986Z", "tierBefore": "new", "flashcardId": 3269}	2026-05-18 06:03:07.173934+00	handled	\N	2026-05-18 06:03:07.173934+00
183	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "1dc3b377-e395-437e-8ccc-897508948ffa", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:06.374Z", "tierBefore": "new", "flashcardId": 3261}	2026-05-18 06:03:08.076482+00	handled	\N	2026-05-18 06:03:08.076482+00
205	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "6b69d048-1ad0-4f18-9831-da1927549c66", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.524Z", "tierBefore": "new", "flashcardId": 3307}	2026-05-18 06:03:10.493241+00	handled	\N	2026-05-18 06:03:10.493241+00
160	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "395c9b8b-a665-4bf0-ada6-7bb677402cb8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:03.730Z", "tierBefore": "new", "flashcardId": 3282}	2026-05-18 06:03:04.749289+00	handled	\N	2026-05-18 06:03:04.749289+00
166	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "f9ab19ce-1f0a-425f-9ab3-55e1ad4dcddb", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:04.387Z", "tierBefore": "new", "flashcardId": 3284}	2026-05-18 06:03:05.481438+00	handled	\N	2026-05-18 06:03:05.481438+00
174	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7feb4808-4d1d-4750-a541-37735272fc45", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.833Z", "tierBefore": "new", "flashcardId": 3293}	2026-05-18 06:03:07.602484+00	handled	\N	2026-05-18 06:03:07.602484+00
188	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "da26cf42-7345-4550-b950-2266979ffca7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.734Z", "tierBefore": "new", "flashcardId": 3295}	2026-05-18 06:03:08.820445+00	handled	\N	2026-05-18 06:03:08.820445+00
207	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8d3e95c8-fe9b-4226-aac0-d13b41785d01", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.241Z", "tierBefore": "new", "flashcardId": 3302}	2026-05-18 06:03:11.333696+00	handled	\N	2026-05-18 06:03:11.333696+00
161	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "395c9b8b-a665-4bf0-ada6-7bb677402cb8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:03.730Z", "tierBefore": "new", "flashcardId": 3282}	2026-05-18 06:03:04.77535+00	handled	\N	2026-05-18 06:03:04.77535+00
178	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "c3ec2ccb-6b30-4a24-9772-86605073522d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.041Z", "tierBefore": "new", "flashcardId": 3285}	2026-05-18 06:03:07.663191+00	handled	\N	2026-05-18 06:03:07.663191+00
199	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b9af3363-6021-45df-bed3-b5e685f3f91a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.987Z", "tierBefore": "new", "flashcardId": 3298}	2026-05-18 06:03:09.175872+00	handled	\N	2026-05-18 06:03:09.175872+00
218	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b616a542-78f0-4a99-adc0-fd7de94a12ac", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.459Z", "tierBefore": "new", "flashcardId": 3308}	2026-05-18 06:03:13.447292+00	handled	\N	2026-05-18 06:03:13.447292+00
162	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e63c34ed-4a07-4903-a26b-a8634dba26ec", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:03.964Z", "tierBefore": "new", "flashcardId": 3289}	2026-05-18 06:03:04.997395+00	handled	\N	2026-05-18 06:03:04.997395+00
175	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "c3ec2ccb-6b30-4a24-9772-86605073522d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.041Z", "tierBefore": "new", "flashcardId": 3285}	2026-05-18 06:03:07.635293+00	handled	\N	2026-05-18 06:03:07.635293+00
182	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "1dc3b377-e395-437e-8ccc-897508948ffa", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:06.374Z", "tierBefore": "new", "flashcardId": 3261}	2026-05-18 06:03:08.049934+00	handled	\N	2026-05-18 06:03:08.049934+00
201	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "6b69d048-1ad0-4f18-9831-da1927549c66", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.524Z", "tierBefore": "new", "flashcardId": 3307}	2026-05-18 06:03:10.060107+00	handled	\N	2026-05-18 06:03:10.060107+00
196	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4581a618-4435-4712-b5d9-3cd403b98e66", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.949Z", "tierBefore": "new", "flashcardId": 3303}	2026-05-18 06:03:09.076155+00	handled	\N	2026-05-18 06:03:09.076155+00
197	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a8b72f92-eb3f-4f58-a7e2-bf439ccc4de5", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.022Z", "tierBefore": "new", "flashcardId": 3296}	2026-05-18 06:03:09.121661+00	handled	\N	2026-05-18 06:03:09.121661+00
198	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "9068a8d0-7cdd-447f-afec-5e84b3d92fb9", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.087Z", "tierBefore": "new", "flashcardId": 3297}	2026-05-18 06:03:09.183138+00	handled	\N	2026-05-18 06:03:09.183138+00
214	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "14d1ca9d-9ff7-4e64-b01c-ca2c1b3bdcbc", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.551Z", "tierBefore": "warmup", "flashcardId": 3085}	2026-05-18 06:03:12.291292+00	handled	\N	2026-05-18 06:03:12.291292+00
216	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "dd7b5549-fa51-4bad-b079-3bcf3b59da4d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.458Z", "tierBefore": "warmup", "flashcardId": 3083}	2026-05-18 06:03:12.730689+00	handled	\N	2026-05-18 06:03:12.730689+00
200	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a8b72f92-eb3f-4f58-a7e2-bf439ccc4de5", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.022Z", "tierBefore": "new", "flashcardId": 3296}	2026-05-18 06:03:09.648487+00	handled	\N	2026-05-18 06:03:09.648487+00
219	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "14d1ca9d-9ff7-4e64-b01c-ca2c1b3bdcbc", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.551Z", "tierBefore": "warmup", "flashcardId": 3085}	2026-05-18 06:03:13.84529+00	handled	\N	2026-05-18 06:03:13.84529+00
202	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "9068a8d0-7cdd-447f-afec-5e84b3d92fb9", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.087Z", "tierBefore": "new", "flashcardId": 3297}	2026-05-18 06:03:10.047332+00	handled	\N	2026-05-18 06:03:10.047332+00
203	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e707f5c8-4df7-4855-8f2e-86c4247d4557", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.686Z", "tierBefore": "new", "flashcardId": 3301}	2026-05-18 06:03:10.489869+00	handled	\N	2026-05-18 06:03:10.489869+00
204	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ebb0ff3a-a769-469f-b315-acbc691fa495", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.714Z", "tierBefore": "new", "flashcardId": 3305}	2026-05-18 06:03:10.516234+00	handled	\N	2026-05-18 06:03:10.516234+00
206	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e707f5c8-4df7-4855-8f2e-86c4247d4557", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.686Z", "tierBefore": "new", "flashcardId": 3301}	2026-05-18 06:03:10.952214+00	handled	\N	2026-05-18 06:03:10.952214+00
208	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ebb0ff3a-a769-469f-b315-acbc691fa495", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:08.714Z", "tierBefore": "new", "flashcardId": 3305}	2026-05-18 06:03:11.335542+00	handled	\N	2026-05-18 06:03:11.335542+00
209	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a60bc555-2eab-44df-89c8-e2885ddb6ea1", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.363Z", "tierBefore": "new", "flashcardId": 3306}	2026-05-18 06:03:11.772735+00	handled	\N	2026-05-18 06:03:11.772735+00
210	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "dd7b5549-fa51-4bad-b079-3bcf3b59da4d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.458Z", "tierBefore": "warmup", "flashcardId": 3083}	2026-05-18 06:03:11.793947+00	handled	\N	2026-05-18 06:03:11.793947+00
211	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8d3e95c8-fe9b-4226-aac0-d13b41785d01", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.241Z", "tierBefore": "new", "flashcardId": 3302}	2026-05-18 06:03:11.777648+00	handled	\N	2026-05-18 06:03:11.777648+00
212	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4f87c654-a2a5-4e83-8961-734aea9ef953", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.459Z", "tierBefore": "new", "flashcardId": 3304}	2026-05-18 06:03:11.817678+00	handled	\N	2026-05-18 06:03:11.817678+00
213	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b616a542-78f0-4a99-adc0-fd7de94a12ac", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.459Z", "tierBefore": "new", "flashcardId": 3308}	2026-05-18 06:03:11.840202+00	handled	\N	2026-05-18 06:03:11.840202+00
215	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a60bc555-2eab-44df-89c8-e2885ddb6ea1", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.363Z", "tierBefore": "new", "flashcardId": 3306}	2026-05-18 06:03:12.284302+00	handled	\N	2026-05-18 06:03:12.284302+00
242	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "31b23f93-b6f1-476d-8b77-8b79cfe9ecbf", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.455Z", "tierBefore": "new", "flashcardId": 3461}	2026-05-18 06:15:51.002624+00	handled	\N	2026-05-18 06:15:51.002624+00
243	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8804a76d-b7d9-45b9-a455-16ad5e84f04f", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.454Z", "tierBefore": "new", "flashcardId": 3468}	2026-05-18 06:15:51.041235+00	handled	\N	2026-05-18 06:15:51.041235+00
262	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7cdf7601-0ca2-4a3a-9784-f74b75aeacba", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:51.036Z", "tierBefore": "new", "flashcardId": 3476}	2026-05-18 06:15:54.951526+00	handled	\N	2026-05-18 06:15:54.951526+00
264	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4ca2ec97-fa97-49fc-97e1-a87709506e44", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:51.037Z", "tierBefore": "new", "flashcardId": 3477}	2026-05-18 06:15:55.344088+00	handled	\N	2026-05-18 06:15:55.344088+00
283	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b13c7ee4-960b-42c3-a745-f469db184c41", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.387Z", "tierBefore": "new", "flashcardId": 3488}	2026-05-18 06:15:58.610439+00	handled	\N	2026-05-18 06:15:58.610439+00
287	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ff4bcc4e-86ea-4d70-855d-9de8080dcbf1", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.539Z", "tierBefore": "new", "flashcardId": 3489}	2026-05-18 06:15:58.967137+00	handled	\N	2026-05-18 06:15:58.967137+00
244	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "389110a4-7742-46e0-84c5-ea05f2783ab8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.553Z", "tierBefore": "new", "flashcardId": 3469}	2026-05-18 06:15:51.652236+00	handled	\N	2026-05-18 06:15:51.652236+00
263	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a0a9b019-24fa-4c75-8d8f-410929cf9687", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:51.957Z", "tierBefore": "new", "flashcardId": 3479}	2026-05-18 06:15:55.346659+00	handled	\N	2026-05-18 06:15:55.346659+00
282	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ff4bcc4e-86ea-4d70-855d-9de8080dcbf1", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.539Z", "tierBefore": "new", "flashcardId": 3489}	2026-05-18 06:15:58.613973+00	handled	\N	2026-05-18 06:15:58.613973+00
245	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "389110a4-7742-46e0-84c5-ea05f2783ab8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.553Z", "tierBefore": "new", "flashcardId": 3469}	2026-05-18 06:15:51.674788+00	handled	\N	2026-05-18 06:15:51.674788+00
267	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a0a9b019-24fa-4c75-8d8f-410929cf9687", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:51.957Z", "tierBefore": "new", "flashcardId": 3479}	2026-05-18 06:15:55.747318+00	handled	\N	2026-05-18 06:15:55.747318+00
291	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a09bf45e-35ad-4fef-b8d7-dc3774ea3ebf", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.776Z", "tierBefore": "new", "flashcardId": 3491}	2026-05-18 06:15:59.36077+00	handled	\N	2026-05-18 06:15:59.36077+00
246	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4513826d-7d55-4aaa-91fa-55a4317d3b0c", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.842Z", "tierBefore": "new", "flashcardId": 3470}	2026-05-18 06:15:51.870303+00	handled	\N	2026-05-18 06:15:51.870303+00
265	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "657ce8f2-320d-4477-83d2-de7dfe848de8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.181Z", "tierBefore": "new", "flashcardId": 3480}	2026-05-18 06:15:55.74313+00	handled	\N	2026-05-18 06:15:55.74313+00
284	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a09bf45e-35ad-4fef-b8d7-dc3774ea3ebf", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.776Z", "tierBefore": "new", "flashcardId": 3491}	2026-05-18 06:15:58.958403+00	handled	\N	2026-05-18 06:15:58.958403+00
247	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "34bc7506-d410-4df3-9b72-afb612167771", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.886Z", "tierBefore": "new", "flashcardId": 3472}	2026-05-18 06:15:51.901136+00	handled	\N	2026-05-18 06:15:51.901136+00
266	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "5c2cd5ab-19fb-4e03-92d3-b037bb31a1a3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.215Z", "tierBefore": "new", "flashcardId": 3481}	2026-05-18 06:15:55.772529+00	handled	\N	2026-05-18 06:15:55.772529+00
285	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "29d923c1-db13-4844-bd44-44af5ddf2e14", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.758Z", "tierBefore": "new", "flashcardId": 3490}	2026-05-18 06:15:58.977461+00	handled	\N	2026-05-18 06:15:58.977461+00
248	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3b425084-53be-4550-a548-ddff7f9176c7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.924Z", "tierBefore": "new", "flashcardId": 3475}	2026-05-18 06:15:51.928636+00	handled	\N	2026-05-18 06:15:51.928636+00
268	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8d342829-9022-4182-a393-c0092e5a95fa", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.243Z", "tierBefore": "new", "flashcardId": 3482}	2026-05-18 06:15:55.79461+00	handled	\N	2026-05-18 06:15:55.79461+00
286	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "524100fb-cd06-4000-98c9-22c1a9294609", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.836Z", "tierBefore": "new", "flashcardId": 3492}	2026-05-18 06:15:58.995154+00	handled	\N	2026-05-18 06:15:58.995154+00
249	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4513826d-7d55-4aaa-91fa-55a4317d3b0c", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.842Z", "tierBefore": "new", "flashcardId": 3470}	2026-05-18 06:15:51.921848+00	handled	\N	2026-05-18 06:15:51.921848+00
273	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "657ce8f2-320d-4477-83d2-de7dfe848de8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.181Z", "tierBefore": "new", "flashcardId": 3480}	2026-05-18 06:15:56.214088+00	handled	\N	2026-05-18 06:15:56.214088+00
295	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "29d923c1-db13-4844-bd44-44af5ddf2e14", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.758Z", "tierBefore": "new", "flashcardId": 3490}	2026-05-18 06:15:59.786296+00	handled	\N	2026-05-18 06:15:59.786296+00
250	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7f68f3c1-8796-4f7a-8dac-02f1a25435cf", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.884Z", "tierBefore": "new", "flashcardId": 3471}	2026-05-18 06:15:51.956741+00	handled	\N	2026-05-18 06:15:51.956741+00
269	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "692b3db4-500c-4e31-a1e2-48eefdafb0f9", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.244Z", "tierBefore": "new", "flashcardId": 3483}	2026-05-18 06:15:55.819475+00	handled	\N	2026-05-18 06:15:55.819475+00
288	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a851fce0-7066-4695-9232-7bac55b27504", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.838Z", "tierBefore": "new", "flashcardId": 3494}	2026-05-18 06:15:59.019466+00	handled	\N	2026-05-18 06:15:59.019466+00
251	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "da1ca8ba-d309-4745-afc1-a58ede272aa3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.940Z", "tierBefore": "new", "flashcardId": 3474}	2026-05-18 06:15:51.988117+00	handled	\N	2026-05-18 06:15:51.988117+00
270	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b6855b6f-f083-4e1e-9079-848041f0ad52", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.262Z", "tierBefore": "new", "flashcardId": 3484}	2026-05-18 06:15:55.840122+00	handled	\N	2026-05-18 06:15:55.840122+00
289	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "064d41d9-26a7-4e07-9cbd-66d9648224be", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.840Z", "tierBefore": "new", "flashcardId": 3493}	2026-05-18 06:15:59.355027+00	handled	\N	2026-05-18 06:15:59.355027+00
252	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8b4490a8-6364-45f6-8e87-8eb927eaf8db", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.974Z", "tierBefore": "new", "flashcardId": 3473}	2026-05-18 06:15:52.019203+00	handled	\N	2026-05-18 06:15:52.019203+00
271	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "2b9141df-1ff0-4bd7-98ae-4e93913b66f4", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.322Z", "tierBefore": "new", "flashcardId": 3485}	2026-05-18 06:15:56.20657+00	handled	\N	2026-05-18 06:15:56.20657+00
290	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "395a6611-f301-47ac-a966-207482314146", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.902Z", "tierBefore": "new", "flashcardId": 3495}	2026-05-18 06:15:59.372908+00	handled	\N	2026-05-18 06:15:59.372908+00
253	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "91ddbbca-231f-47f1-b0fb-043d8cdee698", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:51.022Z", "tierBefore": "new", "flashcardId": 3478}	2026-05-18 06:15:52.054016+00	handled	\N	2026-05-18 06:15:52.054016+00
272	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b72cb1f0-23b2-45fe-a7ba-3b4c38a72e9e", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.385Z", "tierBefore": "new", "flashcardId": 3486}	2026-05-18 06:15:56.226993+00	handled	\N	2026-05-18 06:15:56.226993+00
292	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "d9fac769-e5a2-4169-8ec7-87257c9c5b5b", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.963Z", "tierBefore": "new", "flashcardId": 3497}	2026-05-18 06:15:59.391507+00	handled	\N	2026-05-18 06:15:59.391507+00
254	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7cdf7601-0ca2-4a3a-9784-f74b75aeacba", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:51.036Z", "tierBefore": "new", "flashcardId": 3476}	2026-05-18 06:15:52.080113+00	handled	\N	2026-05-18 06:15:52.080113+00
255	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4ca2ec97-fa97-49fc-97e1-a87709506e44", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:51.037Z", "tierBefore": "new", "flashcardId": 3477}	2026-05-18 06:15:52.142504+00	handled	\N	2026-05-18 06:15:52.142504+00
274	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b13c7ee4-960b-42c3-a745-f469db184c41", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.387Z", "tierBefore": "new", "flashcardId": 3488}	2026-05-18 06:15:56.24819+00	handled	\N	2026-05-18 06:15:56.24819+00
275	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "587cd95c-2eba-40e5-bbc0-2788c6cb1c61", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.388Z", "tierBefore": "new", "flashcardId": 3487}	2026-05-18 06:15:56.269795+00	handled	\N	2026-05-18 06:15:56.269795+00
293	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "666c72a7-5021-43d3-8eec-55810ce79ad5", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.976Z", "tierBefore": "new", "flashcardId": 3496}	2026-05-18 06:15:59.409706+00	handled	\N	2026-05-18 06:15:59.409706+00
294	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "eadd165b-2116-4492-94a3-091676194570", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:53.995Z", "tierBefore": "new", "flashcardId": 3498}	2026-05-18 06:15:59.428927+00	handled	\N	2026-05-18 06:15:59.428927+00
256	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "34bc7506-d410-4df3-9b72-afb612167771", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.886Z", "tierBefore": "new", "flashcardId": 3472}	2026-05-18 06:15:52.330211+00	handled	\N	2026-05-18 06:15:52.330211+00
276	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "5c2cd5ab-19fb-4e03-92d3-b037bb31a1a3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.215Z", "tierBefore": "new", "flashcardId": 3481}	2026-05-18 06:15:56.606602+00	handled	\N	2026-05-18 06:15:56.606602+00
296	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "182b92e6-e72f-495b-90b7-ead183f44755", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:54.866Z", "tierBefore": "new", "flashcardId": 3499}	2026-05-18 06:16:00.131585+00	handled	\N	2026-05-18 06:16:00.131585+00
257	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3b425084-53be-4550-a548-ddff7f9176c7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.924Z", "tierBefore": "new", "flashcardId": 3475}	2026-05-18 06:15:52.718226+00	handled	\N	2026-05-18 06:15:52.718226+00
277	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8d342829-9022-4182-a393-c0092e5a95fa", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.243Z", "tierBefore": "new", "flashcardId": 3482}	2026-05-18 06:15:56.943617+00	handled	\N	2026-05-18 06:15:56.943617+00
297	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "6958195b-2e11-4bb9-8d1c-6c877947da98", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:55.085Z", "tierBefore": "new", "flashcardId": 3500}	2026-05-18 06:16:00.449843+00	handled	\N	2026-05-18 06:16:00.449843+00
258	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7f68f3c1-8796-4f7a-8dac-02f1a25435cf", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.884Z", "tierBefore": "new", "flashcardId": 3471}	2026-05-18 06:15:53.368838+00	handled	\N	2026-05-18 06:15:53.368838+00
278	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "692b3db4-500c-4e31-a1e2-48eefdafb0f9", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.244Z", "tierBefore": "new", "flashcardId": 3483}	2026-05-18 06:15:57.290229+00	handled	\N	2026-05-18 06:15:57.290229+00
298	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e3e1ce26-5e62-4679-b0bf-bd1e9a5dc990", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:55.086Z", "tierBefore": "new", "flashcardId": 3501}	2026-05-18 06:16:00.770954+00	handled	\N	2026-05-18 06:16:00.770954+00
259	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "da1ca8ba-d309-4745-afc1-a58ede272aa3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.940Z", "tierBefore": "new", "flashcardId": 3474}	2026-05-18 06:15:53.769364+00	handled	\N	2026-05-18 06:15:53.769364+00
279	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b6855b6f-f083-4e1e-9079-848041f0ad52", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.262Z", "tierBefore": "new", "flashcardId": 3484}	2026-05-18 06:15:57.635788+00	handled	\N	2026-05-18 06:15:57.635788+00
299	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e93bf02f-f3e1-4f9f-8894-a74c20aba613", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:55.115Z", "tierBefore": "new", "flashcardId": 3502}	2026-05-18 06:16:01.10575+00	handled	\N	2026-05-18 06:16:01.10575+00
260	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8b4490a8-6364-45f6-8e87-8eb927eaf8db", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:50.974Z", "tierBefore": "new", "flashcardId": 3473}	2026-05-18 06:15:54.155408+00	handled	\N	2026-05-18 06:15:54.155408+00
280	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "2b9141df-1ff0-4bd7-98ae-4e93913b66f4", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.322Z", "tierBefore": "new", "flashcardId": 3485}	2026-05-18 06:15:57.953577+00	handled	\N	2026-05-18 06:15:57.953577+00
300	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4a581957-b4d9-4e6f-93be-e9d551c22fd1", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:55.477Z", "tierBefore": "new", "flashcardId": 3508}	2026-05-18 06:16:01.42237+00	handled	\N	2026-05-18 06:16:01.42237+00
46	flashcard.created	58	aug13	{"userId": 58, "eventId": "flashcard.created:3287", "username": "aug13", "eventType": "flashcard.created", "occurredAt": "2026-05-17T22:13:36.332Z", "flashcardId": 3287}	2026-05-17 22:13:37.480562+00	handled	\N	2026-05-17 22:13:37.480562+00
47	flashcard.created	58	aug13	{"userId": 58, "eventId": "flashcard.created:3287", "username": "aug13", "eventType": "flashcard.created", "occurredAt": "2026-05-17T22:13:36.332Z", "flashcardId": 3287}	2026-05-17 22:13:37.505688+00	handled	\N	2026-05-17 22:13:37.505688+00
32	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3274", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:57:27.103Z", "flashcardId": 3274}	2026-05-17 18:57:27.244278+00	handled	\N	2026-05-17 18:57:27.244278+00
131	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "dea2b9b1-eb4b-401c-b7ce-1b0ce2433873", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:00.120Z", "tierBefore": "new", "flashcardId": 3307}	2026-05-18 06:02:06.490461+00	handled	\N	2026-05-18 06:02:06.490461+00
33	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3275", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:58:11.090Z", "flashcardId": 3275}	2026-05-17 18:58:11.208562+00	handled	\N	2026-05-17 18:58:11.208562+00
1	flashcard.reviewed	8	vivian	{"userid": "8", "username": "vivian"}	2026-05-11 06:24:03.117857+00	handled	\N	2026-05-11 06:24:03.117857+00
2	flashcard.reviewed	8	vivian	{"userid": "8", "username": "vivian"}	2026-05-11 06:25:01.327114+00	handled	\N	2026-05-11 06:25:01.327114+00
3	flashcard.reviewed	8	vivian	{"userid": "8", "username": "vivian"}	2026-05-11 06:34:00.414913+00	handled	\N	2026-05-11 06:34:00.414913+00
7	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3249", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T17:16:20.014Z", "flashcardId": 3249}	2026-05-17 17:16:20.383732+00	handled	\N	2026-05-17 17:16:20.383732+00
8	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3250", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T17:26:46.573Z", "flashcardId": 3250}	2026-05-17 17:26:46.693062+00	handled	\N	2026-05-17 17:26:46.693062+00
9	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3251", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T17:27:29.981Z", "flashcardId": 3251}	2026-05-17 17:27:30.09534+00	handled	\N	2026-05-17 17:27:30.09534+00
10	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3252", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T17:29:00.855Z", "flashcardId": 3252}	2026-05-17 17:29:00.937576+00	handled	\N	2026-05-17 17:29:00.937576+00
12	flashcard.created	60	chinese2	{"userId": 60, "eventId": "flashcard.created:3257", "username": "chinese2", "eventType": "flashcard.created", "occurredAt": "2026-05-17T17:33:06.508Z", "flashcardId": 3257}	2026-05-17 17:33:06.603957+00	handled	\N	2026-05-17 17:33:06.603957+00
13	flashcard.reviewed	60	chinese2	{"result": "correct", "userId": 60, "eventId": "flashcard.reviewed:2972:60:2026-05-17T17:33:34.204Z", "username": "chinese2", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-17T17:33:34.204Z", "tierBefore": "new", "flashcardId": 2972}	2026-05-17 17:33:34.34884+00	handled	\N	2026-05-17 17:33:34.34884+00
14	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3001", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-12T02:38:59.747Z", "flashcardId": 3001}	2026-05-17 17:52:53.168298+00	handled	\N	2026-05-17 17:52:53.168298+00
15	flashcard.reviewed	8	vivian	{"result": "correct", "userId": 8, "eventId": "flashcard.reviewed:2001:8:2026-05-11T12:01:00.000Z", "username": "vivian", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-11T12:01:00.000Z", "tierBefore": "new", "flashcardId": 2001}	2026-05-17 17:52:58.174726+00	handled	\N	2026-05-17 17:52:58.174726+00
16	flashcard.reviewed	8	vivian	{"result": "correct", "userId": 8, "eventId": "flashcard.reviewed:2001:8:2026-05-11T12:01:00.000Z", "username": "vivian", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-11T12:01:00.000Z", "tierBefore": "new", "flashcardId": 2001}	2026-05-17 17:52:58.83259+00	handled	\N	2026-05-17 17:52:58.83259+00
17	flashcard.reviewed	8	vivian	{"result": "correct", "userId": 8, "eventId": "flashcard.reviewed:3001:8:2026-05-12T02:38:59.747Z", "username": "vivian", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-12T02:38:59.747Z", "tierBefore": "new", "flashcardId": 3001}	2026-05-17 17:52:59.628696+00	handled	\N	2026-05-17 17:52:59.628696+00
18	article.created	12	alice	{"userId": 12, "eventId": "article.created:5001", "username": "alice", "articleId": 5001, "eventType": "article.created", "occurredAt": "2026-05-11T12:02:00.000Z"}	2026-05-17 17:53:00.245823+00	handled	\N	2026-05-17 17:53:00.245823+00
19	article.created	8	vivian	{"userId": 8, "eventId": "article.created:7001", "username": "vivian", "articleId": 7001, "eventType": "article.created", "occurredAt": "2026-05-12T02:38:59.747Z"}	2026-05-17 17:53:00.629043+00	handled	\N	2026-05-17 17:53:00.629043+00
21	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3259", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:23:51.375Z", "flashcardId": 3259}	2026-05-17 18:23:51.614984+00	handled	\N	2026-05-17 18:23:51.614984+00
22	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3260", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:24:33.271Z", "flashcardId": 3260}	2026-05-17 18:24:33.38469+00	handled	\N	2026-05-17 18:24:33.38469+00
23	flashcard.reviewed	60	chinese2	{"result": "correct", "userId": 60, "eventId": "flashcard.reviewed:2994:60:2026-05-17T18:31:24.428Z", "username": "chinese2", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-17T18:31:24.428Z", "tierBefore": "new", "flashcardId": 2994}	2026-05-17 18:31:24.549668+00	handled	\N	2026-05-17 18:31:24.549668+00
24	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3263", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:35:56.595Z", "flashcardId": 3263}	2026-05-17 18:35:56.757532+00	handled	\N	2026-05-17 18:35:56.757532+00
25	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3264", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:37:39.238Z", "flashcardId": 3264}	2026-05-17 18:37:39.336719+00	handled	\N	2026-05-17 18:37:39.336719+00
26	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3265", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:40:33.869Z", "flashcardId": 3265}	2026-05-17 18:40:33.97577+00	handled	\N	2026-05-17 18:40:33.97577+00
27	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3266", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:41:05.122Z", "flashcardId": 3266}	2026-05-17 18:41:05.239256+00	handled	\N	2026-05-17 18:41:05.239256+00
28	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3267", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:43:18.518Z", "flashcardId": 3267}	2026-05-17 18:43:18.633084+00	handled	\N	2026-05-17 18:43:18.633084+00
29	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3268", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:46:45.984Z", "flashcardId": 3268}	2026-05-17 18:46:46.28073+00	handled	\N	2026-05-17 18:46:46.28073+00
30	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3271", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:50:22.119Z", "flashcardId": 3271}	2026-05-17 18:50:22.293639+00	handled	\N	2026-05-17 18:50:22.293639+00
31	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3273", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:55:30.090Z", "flashcardId": 3273}	2026-05-17 18:55:30.330829+00	handled	\N	2026-05-17 18:55:30.330829+00
34	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3276", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T18:59:40.129Z", "flashcardId": 3276}	2026-05-17 18:59:40.273674+00	handled	\N	2026-05-17 18:59:40.273674+00
35	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3277", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T19:00:40.868Z", "flashcardId": 3277}	2026-05-17 19:00:41.03164+00	handled	\N	2026-05-17 19:00:41.03164+00
36	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3278", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T19:01:14.852Z", "flashcardId": 3278}	2026-05-17 19:01:14.97465+00	handled	\N	2026-05-17 19:01:14.97465+00
37	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3279", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T19:04:15.625Z", "flashcardId": 3279}	2026-05-17 19:04:15.790256+00	handled	\N	2026-05-17 19:04:15.790256+00
38	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3280", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T19:04:29.049Z", "flashcardId": 3280}	2026-05-17 19:04:29.189246+00	handled	\N	2026-05-17 19:04:29.189246+00
39	flashcard.created	8	vivian	{"userId": 8, "eventId": "flashcard.created:3281", "username": "vivian", "eventType": "flashcard.created", "occurredAt": "2026-05-17T19:05:27.496Z", "flashcardId": 3281}	2026-05-17 19:05:27.616279+00	handled	\N	2026-05-17 19:05:27.616279+00
40	flashcard.created	58	aug13	{"userId": 58, "eventId": "flashcard.created:3282", "username": "aug13", "eventType": "flashcard.created", "occurredAt": "2026-05-17T19:21:48.286Z", "flashcardId": 3282}	2026-05-17 19:21:49.635602+00	handled	\N	2026-05-17 19:21:49.635602+00
41	flashcard.created	58	aug13	{"userId": 58, "eventId": "flashcard.created:3283", "username": "aug13", "eventType": "flashcard.created", "occurredAt": "2026-05-17T19:23:19.846Z", "flashcardId": 3283}	2026-05-17 19:23:20.904091+00	handled	\N	2026-05-17 19:23:20.904091+00
42	flashcard.created	58	aug13	{"userId": 58, "eventId": "flashcard.created:3284", "username": "aug13", "eventType": "flashcard.created", "occurredAt": "2026-05-17T19:24:28.412Z", "flashcardId": 3284}	2026-05-17 19:24:29.524098+00	handled	\N	2026-05-17 19:24:29.524098+00
43	flashcard.created	58	aug13	{"userId": 58, "eventId": "flashcard.created:3285", "username": "aug13", "eventType": "flashcard.created", "occurredAt": "2026-05-17T21:11:05.269Z", "flashcardId": 3285}	2026-05-17 21:11:06.803568+00	handled	\N	2026-05-17 21:11:06.803568+00
44	flashcard.created	58	aug13	{"userId": 58, "eventId": "flashcard.created:3286", "username": "aug13", "eventType": "flashcard.created", "occurredAt": "2026-05-17T22:12:27.440Z", "flashcardId": 3286}	2026-05-17 22:12:28.951659+00	handled	\N	2026-05-17 22:12:28.951659+00
45	flashcard.created	58	aug13	{"userId": 58, "eventId": "flashcard.created:3286", "username": "aug13", "eventType": "flashcard.created", "occurredAt": "2026-05-17T22:12:27.440Z", "flashcardId": 3286}	2026-05-17 22:12:29.041141+00	handled	\N	2026-05-17 22:12:29.041141+00
48	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "flashcard.reviewed:3091:58:2026-05-18T04:11:24.118Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:11:24.118Z", "tierBefore": "new", "flashcardId": 3091}	2026-05-18 04:11:25.835466+00	handled	\N	2026-05-18 04:11:25.835466+00
49	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "flashcard.reviewed:3091:58:2026-05-18T04:11:24.118Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:11:24.118Z", "tierBefore": "new", "flashcardId": 3091}	2026-05-18 04:11:25.900289+00	handled	\N	2026-05-18 04:11:25.900289+00
50	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "flashcard.reviewed:3092:58:2026-05-18T04:26:21.778Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "tierAfter": "new", "occurredAt": "2026-05-18T04:26:21.778Z", "tierBefore": "new", "flashcardId": 3092}	2026-05-18 04:26:23.338844+00	handled	\N	2026-05-18 04:26:23.338844+00
51	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "flashcard.reviewed:3092:58:2026-05-18T04:26:21.778Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "tierAfter": "new", "occurredAt": "2026-05-18T04:26:21.778Z", "tierBefore": "new", "flashcardId": 3092}	2026-05-18 04:26:23.509546+00	handled	\N	2026-05-18 04:26:23.509546+00
52	flashcard.reviewed	60	chinese2	{"result": "correct", "userId": 60, "eventId": "flashcard.reviewed:3207:60:2026-05-18T04:42:03.278Z", "username": "chinese2", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:42:03.278Z", "tierBefore": "new", "flashcardId": 3207}	2026-05-18 04:42:04.71423+00	handled	\N	2026-05-18 04:42:04.71423+00
53	flashcard.reviewed	60	chinese2	{"result": "correct", "userId": 60, "eventId": "flashcard.reviewed:3207:60:2026-05-18T04:42:03.278Z", "username": "chinese2", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:42:03.278Z", "tierBefore": "new", "flashcardId": 3207}	2026-05-18 04:42:04.971784+00	handled	\N	2026-05-18 04:42:04.971784+00
54	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "flashcard.reviewed:3093:58:2026-05-18T04:49:04.208Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:49:04.208Z", "tierBefore": "new", "flashcardId": 3093}	2026-05-18 04:49:05.379891+00	handled	\N	2026-05-18 04:49:05.379891+00
55	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "flashcard.reviewed:3093:58:2026-05-18T04:49:04.208Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:49:04.208Z", "tierBefore": "new", "flashcardId": 3093}	2026-05-18 04:49:05.407513+00	handled	\N	2026-05-18 04:49:05.407513+00
56	flashcard.reviewed	58	aug13	{"result": "wrong", "userId": 58, "eventId": "flashcard.reviewed:3094:58:2026-05-18T04:49:20.666Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:49:20.666Z", "tierBefore": "new", "flashcardId": 3094}	2026-05-18 04:49:21.582636+00	handled	\N	2026-05-18 04:49:21.582636+00
57	flashcard.reviewed	58	aug13	{"result": "wrong", "userId": 58, "eventId": "flashcard.reviewed:3094:58:2026-05-18T04:49:20.666Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:49:20.666Z", "tierBefore": "new", "flashcardId": 3094}	2026-05-18 04:49:21.610623+00	handled	\N	2026-05-18 04:49:21.610623+00
58	flashcard.reviewed	58	aug13	{"result": "wrong", "userId": 58, "eventId": "flashcard.reviewed:3253:58:2026-05-18T04:58:28.351Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:58:28.351Z", "tierBefore": "new", "flashcardId": 3253}	2026-05-18 04:58:29.27952+00	handled	\N	2026-05-18 04:58:29.27952+00
59	flashcard.reviewed	58	aug13	{"result": "wrong", "userId": 58, "eventId": "flashcard.reviewed:3253:58:2026-05-18T04:58:28.351Z", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T04:58:28.351Z", "tierBefore": "new", "flashcardId": 3253}	2026-05-18 04:58:29.302234+00	handled	\N	2026-05-18 04:58:29.302234+00
60	flashcard.reviewed	58	aug13	{"result": "wrong", "userId": 58, "eventId": "721c1324-dd53-4f59-92fc-ca707f74060c", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:34.065Z", "tierBefore": "new", "flashcardId": 3254}	2026-05-18 05:11:35.279318+00	handled	\N	2026-05-18 05:11:35.279318+00
62	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e8e4392d-a583-42cf-abec-8692899a70df", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:40.026Z", "tierBefore": "new", "flashcardId": 3255}	2026-05-18 05:11:41.090097+00	handled	\N	2026-05-18 05:11:41.090097+00
64	flashcard.reviewed	58	aug13	{"result": "wrong", "userId": 58, "eventId": "8b7fbb7b-0ce6-4713-84e6-f32a16154830", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:48.653Z", "tierBefore": "new", "flashcardId": 3256}	2026-05-18 05:11:49.485535+00	handled	\N	2026-05-18 05:11:49.485535+00
66	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "30a47293-fa08-4765-a95c-5768d0ab28c7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:51.653Z", "tierBefore": "new", "flashcardId": 3261}	2026-05-18 05:11:52.730452+00	handled	\N	2026-05-18 05:11:52.730452+00
68	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3d1ebcbc-dd67-4cdb-974b-ca761bde1122", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:11:53.762Z", "tierBefore": "new", "flashcardId": 3262}	2026-05-18 05:11:54.857657+00	handled	\N	2026-05-18 05:11:54.857657+00
70	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e4fca412-d961-4a68-8812-109749e0f88c", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T05:12:01.296Z", "tierBefore": "new", "flashcardId": 3269}	2026-05-18 05:12:02.355281+00	handled	\N	2026-05-18 05:12:02.355281+00
72	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "04b52b75-7284-41b7-8062-5bc0da0bd701", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.273Z", "tierBefore": "new", "flashcardId": 3086}	2026-05-18 06:02:01.764167+00	handled	\N	2026-05-18 06:02:01.764167+00
73	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "16f5a273-a1d8-4058-a2d9-c57650dc1f0d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.080Z", "tierBefore": "new", "flashcardId": 3083}	2026-05-18 06:02:01.769294+00	handled	\N	2026-05-18 06:02:01.769294+00
74	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "53a436d4-16ce-4f3e-a42d-c2dbba8c41c7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.478Z", "tierBefore": "new", "flashcardId": 3090}	2026-05-18 06:02:01.830197+00	handled	\N	2026-05-18 06:02:01.830197+00
75	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "cfcd06ed-1549-49a3-ba88-859cc802d887", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.112Z", "tierBefore": "new", "flashcardId": 3081}	2026-05-18 06:02:01.873618+00	handled	\N	2026-05-18 06:02:01.873618+00
76	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3e2a1902-4544-461b-973e-7e20a1ebecd7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.382Z", "tierBefore": "new", "flashcardId": 3089}	2026-05-18 06:02:01.882102+00	handled	\N	2026-05-18 06:02:01.882102+00
77	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "d36ae5de-32ec-4d5c-a1e3-fde9cd344ef0", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.306Z", "tierBefore": "new", "flashcardId": 3088}	2026-05-18 06:02:01.903086+00	handled	\N	2026-05-18 06:02:01.903086+00
78	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "29730f6c-aa5c-4d22-9094-e16f2819ea57", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.134Z", "tierBefore": "new", "flashcardId": 3256}	2026-05-18 06:02:01.973601+00	handled	\N	2026-05-18 06:02:01.973601+00
79	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ba050c4a-5812-4cff-b32c-2eea929a9888", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.370Z", "tierBefore": "new", "flashcardId": 3087}	2026-05-18 06:02:01.992264+00	handled	\N	2026-05-18 06:02:01.992264+00
80	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "16f5a273-a1d8-4058-a2d9-c57650dc1f0d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.080Z", "tierBefore": "new", "flashcardId": 3083}	2026-05-18 06:02:01.979519+00	handled	\N	2026-05-18 06:02:01.979519+00
81	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "04b52b75-7284-41b7-8062-5bc0da0bd701", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.273Z", "tierBefore": "new", "flashcardId": 3086}	2026-05-18 06:02:01.979257+00	handled	\N	2026-05-18 06:02:01.979257+00
82	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "53a436d4-16ce-4f3e-a42d-c2dbba8c41c7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.478Z", "tierBefore": "new", "flashcardId": 3090}	2026-05-18 06:02:02.02471+00	handled	\N	2026-05-18 06:02:02.02471+00
83	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "66c2806d-5399-4a39-8887-1cdf6fbb7044", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.065Z", "tierBefore": "new", "flashcardId": 3084}	2026-05-18 06:02:02.094108+00	handled	\N	2026-05-18 06:02:02.094108+00
84	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3e2a1902-4544-461b-973e-7e20a1ebecd7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.382Z", "tierBefore": "new", "flashcardId": 3089}	2026-05-18 06:02:02.055595+00	handled	\N	2026-05-18 06:02:02.055595+00
85	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "789bd5b3-1721-484f-b3db-5292bb1c2b20", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:56.280Z", "tierBefore": "new", "flashcardId": 3094}	2026-05-18 06:02:02.130505+00	handled	\N	2026-05-18 06:02:02.130505+00
86	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "cfcd06ed-1549-49a3-ba88-859cc802d887", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.112Z", "tierBefore": "new", "flashcardId": 3081}	2026-05-18 06:02:02.113925+00	handled	\N	2026-05-18 06:02:02.113925+00
87	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b8d94b6f-56e6-4f00-8f60-e855ada46e9a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:56.724Z", "tierBefore": "new", "flashcardId": 3253}	2026-05-18 06:02:02.204617+00	handled	\N	2026-05-18 06:02:02.204617+00
89	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ba050c4a-5812-4cff-b32c-2eea929a9888", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.370Z", "tierBefore": "new", "flashcardId": 3087}	2026-05-18 06:02:02.21539+00	handled	\N	2026-05-18 06:02:02.21539+00
88	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "d36ae5de-32ec-4d5c-a1e3-fde9cd344ef0", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:55.306Z", "tierBefore": "new", "flashcardId": 3088}	2026-05-18 06:02:02.207003+00	handled	\N	2026-05-18 06:02:02.207003+00
90	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "560e3145-0b22-4b64-a8cd-34abe1883ff3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:57.349Z", "tierBefore": "new", "flashcardId": 3255}	2026-05-18 06:02:02.284283+00	handled	\N	2026-05-18 06:02:02.284283+00
128	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "2b3b2046-9fd2-44b7-88dd-a7ec19a5445d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:01:59.650Z", "tierBefore": "new", "flashcardId": 3300}	2026-05-18 06:02:05.968454+00	handled	\N	2026-05-18 06:02:05.968454+00
136	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b953f504-3737-4cf9-adf5-c9987b56ca95", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:48.975Z", "tierBefore": "new", "flashcardId": 3094}	2026-05-18 06:02:50.248314+00	handled	\N	2026-05-18 06:02:50.248314+00
137	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b953f504-3737-4cf9-adf5-c9987b56ca95", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:48.975Z", "tierBefore": "new", "flashcardId": 3094}	2026-05-18 06:02:50.275602+00	handled	\N	2026-05-18 06:02:50.275602+00
138	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "2ad92804-65c5-432c-8c40-56f5464060ec", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:48.858Z", "tierBefore": "new", "flashcardId": 3087}	2026-05-18 06:02:50.791352+00	handled	\N	2026-05-18 06:02:50.791352+00
139	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "2ad92804-65c5-432c-8c40-56f5464060ec", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:48.858Z", "tierBefore": "new", "flashcardId": 3087}	2026-05-18 06:02:50.815064+00	handled	\N	2026-05-18 06:02:50.815064+00
140	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7e0e71c3-18be-43e7-9314-2ae8e66d8fff", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:48.823Z", "tierBefore": "new", "flashcardId": 3088}	2026-05-18 06:02:51.366149+00	handled	\N	2026-05-18 06:02:51.366149+00
141	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7e0e71c3-18be-43e7-9314-2ae8e66d8fff", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:48.823Z", "tierBefore": "new", "flashcardId": 3088}	2026-05-18 06:02:51.388969+00	handled	\N	2026-05-18 06:02:51.388969+00
142	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "31456a64-ab54-4a74-921b-db1fcaa4a8e3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:49.006Z", "tierBefore": "new", "flashcardId": 3084}	2026-05-18 06:02:51.726708+00	handled	\N	2026-05-18 06:02:51.726708+00
143	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8bf50fa2-deae-4bcf-8e11-23db375702c9", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:49.044Z", "tierBefore": "new", "flashcardId": 3086}	2026-05-18 06:02:51.756712+00	handled	\N	2026-05-18 06:02:51.756712+00
144	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "31456a64-ab54-4a74-921b-db1fcaa4a8e3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:49.006Z", "tierBefore": "new", "flashcardId": 3084}	2026-05-18 06:02:51.749967+00	handled	\N	2026-05-18 06:02:51.749967+00
145	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8bf50fa2-deae-4bcf-8e11-23db375702c9", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:49.044Z", "tierBefore": "new", "flashcardId": 3086}	2026-05-18 06:02:51.781122+00	handled	\N	2026-05-18 06:02:51.781122+00
146	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3ec871ae-9e26-4fbb-8e2f-2802d757b401", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:51.078Z", "tierBefore": "new", "flashcardId": 3253}	2026-05-18 06:02:52.083882+00	handled	\N	2026-05-18 06:02:52.083882+00
147	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3ec871ae-9e26-4fbb-8e2f-2802d757b401", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:51.078Z", "tierBefore": "new", "flashcardId": 3253}	2026-05-18 06:02:52.108165+00	handled	\N	2026-05-18 06:02:52.108165+00
148	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ee834fc1-6b1b-48f0-b26f-5ebd7d36156c", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:52.041Z", "tierBefore": "new", "flashcardId": 3256}	2026-05-18 06:02:53.004953+00	handled	\N	2026-05-18 06:02:53.004953+00
149	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7c8ee7bf-2991-4082-8afc-47e905ba658b", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:52.021Z", "tierBefore": "new", "flashcardId": 3254}	2026-05-18 06:02:53.033706+00	handled	\N	2026-05-18 06:02:53.033706+00
150	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ee834fc1-6b1b-48f0-b26f-5ebd7d36156c", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:52.041Z", "tierBefore": "new", "flashcardId": 3256}	2026-05-18 06:02:53.02787+00	handled	\N	2026-05-18 06:02:53.02787+00
151	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7c8ee7bf-2991-4082-8afc-47e905ba658b", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:52.021Z", "tierBefore": "new", "flashcardId": 3254}	2026-05-18 06:02:53.059383+00	handled	\N	2026-05-18 06:02:53.059383+00
152	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "631183af-bf62-45a2-aa06-8859ff11a6d8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:52.900Z", "tierBefore": "new", "flashcardId": 3081}	2026-05-18 06:03:03.287372+00	handled	\N	2026-05-18 06:03:03.287372+00
153	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "631183af-bf62-45a2-aa06-8859ff11a6d8", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:52.900Z", "tierBefore": "new", "flashcardId": 3081}	2026-05-18 06:03:03.310411+00	handled	\N	2026-05-18 06:03:03.310411+00
154	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "1be5a884-a3cf-45d5-ae15-131cc8b65795", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:58.961Z", "tierBefore": "new", "flashcardId": 3272}	2026-05-18 06:03:03.668456+00	handled	\N	2026-05-18 06:03:03.668456+00
155	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7df04e49-770e-4c0c-a4d5-a82d2e3a62ba", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:59.552Z", "tierBefore": "new", "flashcardId": 3270}	2026-05-18 06:03:03.703447+00	handled	\N	2026-05-18 06:03:03.703447+00
156	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "1be5a884-a3cf-45d5-ae15-131cc8b65795", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:58.961Z", "tierBefore": "new", "flashcardId": 3272}	2026-05-18 06:03:03.699668+00	handled	\N	2026-05-18 06:03:03.699668+00
157	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7df04e49-770e-4c0c-a4d5-a82d2e3a62ba", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:02:59.552Z", "tierBefore": "new", "flashcardId": 3270}	2026-05-18 06:03:03.731368+00	handled	\N	2026-05-18 06:03:03.731368+00
158	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "08728eba-d33e-47d9-8e01-350015ac5546", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:02.987Z", "tierBefore": "new", "flashcardId": 3286}	2026-05-18 06:03:04.101222+00	handled	\N	2026-05-18 06:03:04.101222+00
163	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e63c34ed-4a07-4903-a26b-a8634dba26ec", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:03.964Z", "tierBefore": "new", "flashcardId": 3289}	2026-05-18 06:03:05.020477+00	handled	\N	2026-05-18 06:03:05.020477+00
164	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e40e6fe9-a18b-4a32-8bcd-8697306b4a87", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:03.964Z", "tierBefore": "new", "flashcardId": 3290}	2026-05-18 06:03:05.04571+00	handled	\N	2026-05-18 06:03:05.04571+00
165	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e40e6fe9-a18b-4a32-8bcd-8697306b4a87", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:03.964Z", "tierBefore": "new", "flashcardId": 3290}	2026-05-18 06:03:05.031524+00	handled	\N	2026-05-18 06:03:05.031524+00
168	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "98ff8384-308b-4753-99a0-f34cf9d938a3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.283Z", "tierBefore": "new", "flashcardId": 3288}	2026-05-18 06:03:06.28478+00	handled	\N	2026-05-18 06:03:06.28478+00
169	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "98ff8384-308b-4753-99a0-f34cf9d938a3", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.283Z", "tierBefore": "new", "flashcardId": 3288}	2026-05-18 06:03:06.313499+00	handled	\N	2026-05-18 06:03:06.313499+00
170	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "0ce1b11c-0646-45fb-89a4-29070a7ebf4b", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:00.986Z", "tierBefore": "new", "flashcardId": 3269}	2026-05-18 06:03:07.14759+00	handled	\N	2026-05-18 06:03:07.14759+00
172	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "1adc5db0-c98b-4fd9-afa5-980edc928255", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.834Z", "tierBefore": "new", "flashcardId": 3291}	2026-05-18 06:03:07.536054+00	handled	\N	2026-05-18 06:03:07.536054+00
173	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "1adc5db0-c98b-4fd9-afa5-980edc928255", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.834Z", "tierBefore": "new", "flashcardId": 3291}	2026-05-18 06:03:07.570078+00	handled	\N	2026-05-18 06:03:07.570078+00
176	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7feb4808-4d1d-4750-a541-37735272fc45", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.833Z", "tierBefore": "new", "flashcardId": 3293}	2026-05-18 06:03:07.631941+00	handled	\N	2026-05-18 06:03:07.631941+00
177	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a98fda25-cc32-4ac2-8a9d-8be233e0a62d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.790Z", "tierBefore": "new", "flashcardId": 3292}	2026-05-18 06:03:07.668504+00	handled	\N	2026-05-18 06:03:07.668504+00
179	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7de6efbb-d63f-4d1f-b787-8ccda421a7dd", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.282Z", "tierBefore": "new", "flashcardId": 3287}	2026-05-18 06:03:07.704652+00	handled	\N	2026-05-18 06:03:07.704652+00
180	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "a98fda25-cc32-4ac2-8a9d-8be233e0a62d", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.790Z", "tierBefore": "new", "flashcardId": 3292}	2026-05-18 06:03:07.699856+00	handled	\N	2026-05-18 06:03:07.699856+00
181	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "7de6efbb-d63f-4d1f-b787-8ccda421a7dd", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:05.282Z", "tierBefore": "new", "flashcardId": 3287}	2026-05-18 06:03:07.73538+00	handled	\N	2026-05-18 06:03:07.73538+00
184	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ccfeb59b-536e-4bc1-bde9-b975bc832380", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:06.584Z", "tierBefore": "new", "flashcardId": 3283}	2026-05-18 06:03:08.377987+00	handled	\N	2026-05-18 06:03:08.377987+00
185	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e4195a46-0740-4e0c-ad55-3a38aa257331", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:06.821Z", "tierBefore": "new", "flashcardId": 3294}	2026-05-18 06:03:08.404098+00	handled	\N	2026-05-18 06:03:08.404098+00
186	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "ccfeb59b-536e-4bc1-bde9-b975bc832380", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:06.584Z", "tierBefore": "new", "flashcardId": 3283}	2026-05-18 06:03:08.400687+00	handled	\N	2026-05-18 06:03:08.400687+00
187	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "e4195a46-0740-4e0c-ad55-3a38aa257331", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:06.821Z", "tierBefore": "new", "flashcardId": 3294}	2026-05-18 06:03:08.431269+00	handled	\N	2026-05-18 06:03:08.431269+00
189	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "da26cf42-7345-4550-b950-2266979ffca7", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.734Z", "tierBefore": "new", "flashcardId": 3295}	2026-05-18 06:03:08.842975+00	handled	\N	2026-05-18 06:03:08.842975+00
190	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "2eac7548-7639-4989-bffe-9b198f793e1b", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.930Z", "tierBefore": "new", "flashcardId": 3299}	2026-05-18 06:03:08.975817+00	handled	\N	2026-05-18 06:03:08.975817+00
191	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "5ef763da-bb33-4132-9c69-2c29b8702270", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.946Z", "tierBefore": "new", "flashcardId": 3300}	2026-05-18 06:03:09.00916+00	handled	\N	2026-05-18 06:03:09.00916+00
192	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "2eac7548-7639-4989-bffe-9b198f793e1b", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.930Z", "tierBefore": "new", "flashcardId": 3299}	2026-05-18 06:03:08.998869+00	handled	\N	2026-05-18 06:03:08.998869+00
193	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4581a618-4435-4712-b5d9-3cd403b98e66", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.949Z", "tierBefore": "new", "flashcardId": 3303}	2026-05-18 06:03:09.056952+00	handled	\N	2026-05-18 06:03:09.056952+00
194	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b9af3363-6021-45df-bed3-b5e685f3f91a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.987Z", "tierBefore": "new", "flashcardId": 3298}	2026-05-18 06:03:09.083537+00	handled	\N	2026-05-18 06:03:09.083537+00
195	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "5ef763da-bb33-4132-9c69-2c29b8702270", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:07.946Z", "tierBefore": "new", "flashcardId": 3300}	2026-05-18 06:03:09.077295+00	handled	\N	2026-05-18 06:03:09.077295+00
217	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "4f87c654-a2a5-4e83-8961-734aea9ef953", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:03:09.459Z", "tierBefore": "new", "flashcardId": 3304}	2026-05-18 06:03:13.088263+00	handled	\N	2026-05-18 06:03:13.088263+00
220	flashcard.reviewed	58	manual	{"result": "correct", "userId": 58, "eventId": "b08875be-d12c-4a5f-ad77-2b77e4426051", "username": "manual", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:08:32.166Z", "tierBefore": "new", "flashcardId": 999999}	2026-05-18 06:08:32.512339+00	handled	\N	2026-05-18 06:08:32.512339+00
221	flashcard.reviewed	58	manual	{"result": "correct", "userId": 58, "eventId": "b08875be-d12c-4a5f-ad77-2b77e4426051", "username": "manual", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:08:32.166Z", "tierBefore": "new", "flashcardId": 999999}	2026-05-18 06:08:32.542862+00	handled	\N	2026-05-18 06:08:32.542862+00
222	flashcard.reviewed	58	module-test	{"result": "correct", "userId": 58, "eventId": "92cb7b5e-ee8b-4026-b631-0d5c030b709d", "username": "module-test", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:09:04.883Z", "tierBefore": "new", "flashcardId": 999998}	2026-05-18 06:09:05.220753+00	handled	\N	2026-05-18 06:09:05.220753+00
223	flashcard.reviewed	58	module-test	{"result": "correct", "userId": 58, "eventId": "92cb7b5e-ee8b-4026-b631-0d5c030b709d", "username": "module-test", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:09:04.883Z", "tierBefore": "new", "flashcardId": 999998}	2026-05-18 06:09:05.24814+00	handled	\N	2026-05-18 06:09:05.24814+00
224	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "c19f6965-e799-4603-aee8-5734ef68dec1", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.278Z", "tierBefore": "new", "flashcardId": 3463}	2026-05-18 06:15:50.411987+00	handled	\N	2026-05-18 06:15:50.411987+00
225	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "c19f6965-e799-4603-aee8-5734ef68dec1", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.278Z", "tierBefore": "new", "flashcardId": 3463}	2026-05-18 06:15:50.425746+00	handled	\N	2026-05-18 06:15:50.425746+00
227	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "877732c5-ed6c-437d-a973-49f245e0f1ef", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.366Z", "tierBefore": "new", "flashcardId": 3464}	2026-05-18 06:15:50.654086+00	handled	\N	2026-05-18 06:15:50.654086+00
228	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "c2ea9860-34d5-4ef0-a4f0-1f2954b31ed0", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.082Z", "tierBefore": "new", "flashcardId": 3459}	2026-05-18 06:15:50.65764+00	handled	\N	2026-05-18 06:15:50.65764+00
226	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "c2ea9860-34d5-4ef0-a4f0-1f2954b31ed0", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.082Z", "tierBefore": "new", "flashcardId": 3459}	2026-05-18 06:15:50.610665+00	handled	\N	2026-05-18 06:15:50.610665+00
229	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "68ea71b5-ec11-4b00-bd76-74bcdca775ee", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.418Z", "tierBefore": "new", "flashcardId": 3466}	2026-05-18 06:15:50.614123+00	handled	\N	2026-05-18 06:15:50.614123+00
230	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "26c28eb5-4e98-4c77-a442-c26f4a5ad03e", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.422Z", "tierBefore": "new", "flashcardId": 3462}	2026-05-18 06:15:50.611789+00	handled	\N	2026-05-18 06:15:50.611789+00
231	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "8804a76d-b7d9-45b9-a455-16ad5e84f04f", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.454Z", "tierBefore": "new", "flashcardId": 3468}	2026-05-18 06:15:50.706737+00	handled	\N	2026-05-18 06:15:50.706737+00
232	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3ea8d048-9bb8-4850-b6d7-0ee2b367fadd", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.402Z", "tierBefore": "new", "flashcardId": 3467}	2026-05-18 06:15:50.706648+00	handled	\N	2026-05-18 06:15:50.706648+00
233	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "f533d17d-ea8c-4919-80ea-c8d187eda336", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.436Z", "tierBefore": "new", "flashcardId": 3460}	2026-05-18 06:15:50.705966+00	handled	\N	2026-05-18 06:15:50.705966+00
234	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "02538cfe-54fc-453d-b9bb-229fa3582e7a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.450Z", "tierBefore": "new", "flashcardId": 3465}	2026-05-18 06:15:50.747531+00	handled	\N	2026-05-18 06:15:50.747531+00
235	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "68ea71b5-ec11-4b00-bd76-74bcdca775ee", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.418Z", "tierBefore": "new", "flashcardId": 3466}	2026-05-18 06:15:50.750717+00	handled	\N	2026-05-18 06:15:50.750717+00
236	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "31b23f93-b6f1-476d-8b77-8b79cfe9ecbf", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.455Z", "tierBefore": "new", "flashcardId": 3461}	2026-05-18 06:15:50.879467+00	handled	\N	2026-05-18 06:15:50.879467+00
238	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "877732c5-ed6c-437d-a973-49f245e0f1ef", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.366Z", "tierBefore": "new", "flashcardId": 3464}	2026-05-18 06:15:50.872597+00	handled	\N	2026-05-18 06:15:50.872597+00
237	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "26c28eb5-4e98-4c77-a442-c26f4a5ad03e", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.422Z", "tierBefore": "new", "flashcardId": 3462}	2026-05-18 06:15:50.789295+00	handled	\N	2026-05-18 06:15:50.789295+00
239	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "3ea8d048-9bb8-4850-b6d7-0ee2b367fadd", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.402Z", "tierBefore": "new", "flashcardId": 3467}	2026-05-18 06:15:50.913633+00	handled	\N	2026-05-18 06:15:50.913633+00
240	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "f533d17d-ea8c-4919-80ea-c8d187eda336", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.436Z", "tierBefore": "new", "flashcardId": 3460}	2026-05-18 06:15:50.93131+00	handled	\N	2026-05-18 06:15:50.93131+00
241	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "02538cfe-54fc-453d-b9bb-229fa3582e7a", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:49.450Z", "tierBefore": "new", "flashcardId": 3465}	2026-05-18 06:15:50.983575+00	handled	\N	2026-05-18 06:15:50.983575+00
261	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "91ddbbca-231f-47f1-b0fb-043d8cdee698", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:51.022Z", "tierBefore": "new", "flashcardId": 3478}	2026-05-18 06:15:54.568789+00	handled	\N	2026-05-18 06:15:54.568789+00
281	flashcard.reviewed	58	aug13	{"result": "correct", "userId": 58, "eventId": "b72cb1f0-23b2-45fe-a7ba-3b4c38a72e9e", "username": "aug13", "effective": true, "eventType": "flashcard.reviewed", "occurredAt": "2026-05-18T06:15:52.385Z", "tierBefore": "new", "flashcardId": 3486}	2026-05-18 06:15:58.290258+00	handled	\N	2026-05-18 06:15:58.290258+00
\.


--
-- TOC entry 5120 (class 0 OID 148555)
-- Dependencies: 777
-- Data for Name: as_user_achievements; Type: TABLE DATA; Schema: achievement_system; Owner: -
--

COPY {{SCHEMA}}.as_user_achievements (id, userid, username, achievement_id, progress, achieved, achieved_at, created_at, updated_at) FROM stdin;
1	60	chinese2	1	10	t	2026-05-04 23:31:14.68+00	2026-05-04 22:29:34.025+00	2026-05-04 23:31:14.806+00
10	60	chinese2	10	100	t	2026-05-07 22:29:09.739+00	2026-05-04 22:29:36.526+00	2026-05-07 22:29:09.866+00
17	60	chinese2	17	0	f	\N	2026-05-04 22:29:38.109+00	2026-05-04 22:29:38.109+00
18	60	chinese2	18	0	f	\N	2026-05-04 22:29:38.332+00	2026-05-04 22:29:38.332+00
19	60	chinese2	19	0	f	\N	2026-05-04 22:29:38.552+00	2026-05-04 22:29:38.552+00
20	60	chinese2	20	0	f	\N	2026-05-04 22:29:38.763+00	2026-05-04 22:29:38.763+00
21	60	chinese2	21	0	f	\N	2026-05-04 22:29:38.984+00	2026-05-04 22:29:38.984+00
22	60	chinese2	22	0	f	\N	2026-05-04 22:29:39.245+00	2026-05-04 22:29:39.245+00
23	60	chinese2	23	0	f	\N	2026-05-04 22:29:39.469+00	2026-05-04 22:29:39.469+00
24	60	chinese2	24	0	f	\N	2026-05-04 22:29:39.694+00	2026-05-04 22:29:39.694+00
25	60	chinese2	25	0	f	\N	2026-05-04 22:29:39.922+00	2026-05-04 22:29:39.922+00
26	60	chinese2	26	0	f	\N	2026-05-04 22:29:40.155+00	2026-05-04 22:29:40.155+00
27	8	vivian	1	10	t	2026-05-06 06:02:12.072+00	2026-05-06 02:06:31.781+00	2026-05-06 06:02:12.087+00
28	8	vivian	2	50	t	2026-05-10 17:56:51.422+00	2026-05-06 02:06:32.152+00	2026-05-10 17:56:51.455+00
11	60	chinese2	11	188	f	\N	2026-05-04 22:29:36.751+00	2026-05-18 04:42:04.971784+00
54	58	aug13	2	22	f	\N	2026-05-05 23:55:26.655+00	2026-05-17 22:13:37.505688+00
36	8	vivian	10	100	t	2026-05-06 02:15:33.338+00	2026-05-06 02:06:32.63+00	2026-05-06 02:15:33.349+00
37	8	vivian	11	200	t	2026-05-07 04:41:36.998+00	2026-05-06 02:06:32.649+00	2026-05-07 04:41:37.018+00
38	8	vivian	12	500	t	2026-05-08 06:09:31.298+00	2026-05-06 02:06:32.717+00	2026-05-08 06:09:31.313+00
43	8	vivian	17	0	f	\N	2026-05-06 02:06:34.471+00	2026-05-06 02:06:34.471+00
44	8	vivian	18	0	f	\N	2026-05-06 02:06:34.535+00	2026-05-06 02:06:34.535+00
45	8	vivian	19	0	f	\N	2026-05-06 02:06:34.555+00	2026-05-06 02:06:34.555+00
46	8	vivian	20	0	f	\N	2026-05-06 02:06:34.581+00	2026-05-06 02:06:34.581+00
47	8	vivian	21	0	f	\N	2026-05-06 02:06:34.627+00	2026-05-06 02:06:34.627+00
48	8	vivian	22	0	f	\N	2026-05-06 02:06:34.646+00	2026-05-06 02:06:34.646+00
49	8	vivian	23	0	f	\N	2026-05-06 02:06:34.666+00	2026-05-06 02:06:34.666+00
50	8	vivian	24	0	f	\N	2026-05-06 02:06:34.684+00	2026-05-06 02:06:34.684+00
51	8	vivian	25	0	f	\N	2026-05-06 02:06:34.709+00	2026-05-06 02:06:34.709+00
52	8	vivian	26	0	f	\N	2026-05-06 02:06:34.732+00	2026-05-06 02:06:34.732+00
53	58	aug13	1	10	t	2026-05-05 23:56:56.811+00	2026-05-05 23:55:26.371+00	2026-05-05 23:56:56.931+00
69	58	aug13	17	0	f	\N	2026-05-05 23:55:29.786+00	2026-05-05 23:55:29.786+00
70	58	aug13	18	0	f	\N	2026-05-05 23:55:30+00	2026-05-05 23:55:30+00
71	58	aug13	19	0	f	\N	2026-05-05 23:55:30.209+00	2026-05-05 23:55:30.209+00
72	58	aug13	20	0	f	\N	2026-05-05 23:55:30.419+00	2026-05-05 23:55:30.419+00
73	58	aug13	21	0	f	\N	2026-05-05 23:55:30.659+00	2026-05-05 23:55:30.659+00
74	58	aug13	22	0	f	\N	2026-05-05 23:55:30.862+00	2026-05-05 23:55:30.862+00
75	58	aug13	23	0	f	\N	2026-05-05 23:55:31.062+00	2026-05-05 23:55:31.062+00
76	58	aug13	24	0	f	\N	2026-05-05 23:55:31.309+00	2026-05-05 23:55:31.309+00
77	58	aug13	25	0	f	\N	2026-05-05 23:55:31.517+00	2026-05-05 23:55:31.517+00
78	58	aug13	26	0	f	\N	2026-05-05 23:55:31.73+00	2026-05-05 23:55:31.73+00
79	71	chinese3@langgo.ca	1	10	t	2026-05-06 00:09:58.865+00	2026-05-06 00:00:59.948+00	2026-05-06 00:09:58.997+00
80	71	chinese3@langgo.ca	2	17	f	\N	2026-05-06 00:01:00.735+00	2026-05-06 00:16:32.974+00
81	71	chinese3@langgo.ca	3	17	f	\N	2026-05-06 00:01:01.855+00	2026-05-06 00:16:33.522+00
82	71	chinese3@langgo.ca	4	17	f	\N	2026-05-06 00:01:02.487+00	2026-05-06 00:16:34.1+00
83	71	chinese3@langgo.ca	5	17	f	\N	2026-05-06 00:01:03.309+00	2026-05-06 00:16:34.679+00
84	71	chinese3@langgo.ca	6	17	f	\N	2026-05-06 00:01:03.725+00	2026-05-06 00:16:35.249+00
85	71	chinese3@langgo.ca	7	17	f	\N	2026-05-06 00:01:03.973+00	2026-05-06 00:16:35.803+00
86	71	chinese3@langgo.ca	8	17	f	\N	2026-05-06 00:01:05.296+00	2026-05-06 00:16:36.366+00
87	71	chinese3@langgo.ca	9	17	f	\N	2026-05-06 00:01:06.248+00	2026-05-06 00:16:36.962+00
88	71	chinese3@langgo.ca	10	17	f	\N	2026-05-06 00:01:06.662+00	2026-05-06 00:16:53.413+00
89	71	chinese3@langgo.ca	11	17	f	\N	2026-05-06 00:01:06.965+00	2026-05-06 00:16:53.956+00
90	71	chinese3@langgo.ca	12	17	f	\N	2026-05-06 00:01:07.215+00	2026-05-06 00:16:54.487+00
2	60	chinese2	2	12	f	\N	2026-05-04 22:29:34.667+00	2026-05-17 17:33:06.603957+00
3	60	chinese2	3	12	f	\N	2026-05-04 22:29:34.911+00	2026-05-17 17:33:06.603957+00
4	60	chinese2	4	12	f	\N	2026-05-04 22:29:35.142+00	2026-05-17 17:33:06.603957+00
5	60	chinese2	5	12	f	\N	2026-05-04 22:29:35.372+00	2026-05-17 17:33:06.603957+00
6	60	chinese2	6	12	f	\N	2026-05-04 22:29:35.597+00	2026-05-17 17:33:06.603957+00
7	60	chinese2	7	12	f	\N	2026-05-04 22:29:35.828+00	2026-05-17 17:33:06.603957+00
8	60	chinese2	8	12	f	\N	2026-05-04 22:29:36.062+00	2026-05-17 17:33:06.603957+00
55	58	aug13	3	22	f	\N	2026-05-05 23:55:26.911+00	2026-05-17 22:13:37.505688+00
56	58	aug13	4	22	f	\N	2026-05-05 23:55:27.126+00	2026-05-17 22:13:37.505688+00
57	58	aug13	5	22	f	\N	2026-05-05 23:55:27.329+00	2026-05-17 22:13:37.505688+00
58	58	aug13	6	22	f	\N	2026-05-05 23:55:27.553+00	2026-05-17 22:13:37.505688+00
59	58	aug13	7	22	f	\N	2026-05-05 23:55:27.763+00	2026-05-17 22:13:37.505688+00
60	58	aug13	8	22	f	\N	2026-05-05 23:55:27.972+00	2026-05-17 22:13:37.505688+00
39	8	vivian	13	850	f	\N	2026-05-06 02:06:32.731+00	2026-05-17 17:52:59.628696+00
12	60	chinese2	12	188	f	\N	2026-05-04 22:29:36.981+00	2026-05-18 04:42:04.971784+00
13	60	chinese2	13	188	f	\N	2026-05-04 22:29:37.213+00	2026-05-18 04:42:04.971784+00
14	60	chinese2	14	188	f	\N	2026-05-04 22:29:37.441+00	2026-05-18 04:42:04.971784+00
15	60	chinese2	15	188	f	\N	2026-05-04 22:29:37.663+00	2026-05-18 04:42:04.971784+00
16	60	chinese2	16	188	f	\N	2026-05-04 22:29:37.886+00	2026-05-18 04:42:04.971784+00
91	71	chinese3@langgo.ca	13	17	f	\N	2026-05-06 00:01:07.499+00	2026-05-06 00:16:55.011+00
92	71	chinese3@langgo.ca	14	17	f	\N	2026-05-06 00:01:07.749+00	2026-05-06 00:16:55.538+00
93	71	chinese3@langgo.ca	15	17	f	\N	2026-05-06 00:01:08.018+00	2026-05-06 00:16:56.07+00
94	71	chinese3@langgo.ca	16	17	f	\N	2026-05-06 00:01:08.366+00	2026-05-06 00:16:56.621+00
95	71	chinese3@langgo.ca	17	0	f	\N	2026-05-06 00:01:08.771+00	2026-05-06 00:01:08.771+00
96	71	chinese3@langgo.ca	18	0	f	\N	2026-05-06 00:01:09.155+00	2026-05-06 00:01:09.155+00
97	71	chinese3@langgo.ca	19	0	f	\N	2026-05-06 00:01:09.503+00	2026-05-06 00:01:09.503+00
98	71	chinese3@langgo.ca	20	0	f	\N	2026-05-06 00:01:09.754+00	2026-05-06 00:01:09.754+00
99	71	chinese3@langgo.ca	21	0	f	\N	2026-05-06 00:01:10.004+00	2026-05-06 00:01:10.004+00
100	71	chinese3@langgo.ca	22	0	f	\N	2026-05-06 00:01:10.257+00	2026-05-06 00:01:10.257+00
101	71	chinese3@langgo.ca	23	0	f	\N	2026-05-06 00:01:10.504+00	2026-05-06 00:01:10.504+00
102	71	chinese3@langgo.ca	24	0	f	\N	2026-05-06 00:01:10.738+00	2026-05-06 00:01:10.738+00
103	71	chinese3@langgo.ca	25	0	f	\N	2026-05-06 00:01:11.022+00	2026-05-06 00:01:11.022+00
104	71	chinese3@langgo.ca	26	0	f	\N	2026-05-06 00:01:11.273+00	2026-05-06 00:01:11.273+00
106	41	july15	1	0	f	\N	2026-05-08 23:32:39.09+00	2026-05-08 23:32:39.09+00
107	41	july15	2	0	f	\N	2026-05-08 23:32:39.317+00	2026-05-08 23:32:39.317+00
110	41	july15	3	0	f	\N	2026-05-08 23:32:39.53+00	2026-05-08 23:32:39.53+00
111	41	july15	4	0	f	\N	2026-05-08 23:32:39.753+00	2026-05-08 23:32:39.753+00
114	41	july15	5	0	f	\N	2026-05-08 23:32:39.965+00	2026-05-08 23:32:39.965+00
116	41	july15	6	0	f	\N	2026-05-08 23:32:40.181+00	2026-05-08 23:32:40.181+00
117	41	july15	7	0	f	\N	2026-05-08 23:32:40.41+00	2026-05-08 23:32:40.41+00
120	41	july15	8	0	f	\N	2026-05-08 23:32:40.621+00	2026-05-08 23:32:40.621+00
122	41	july15	9	0	f	\N	2026-05-08 23:32:40.827+00	2026-05-08 23:32:40.827+00
124	41	july15	10	0	f	\N	2026-05-08 23:32:41.041+00	2026-05-08 23:32:41.041+00
126	41	july15	11	0	f	\N	2026-05-08 23:32:41.255+00	2026-05-08 23:32:41.255+00
128	41	july15	12	0	f	\N	2026-05-08 23:32:41.454+00	2026-05-08 23:32:41.454+00
130	41	july15	13	0	f	\N	2026-05-08 23:32:41.657+00	2026-05-08 23:32:41.657+00
132	41	july15	14	0	f	\N	2026-05-08 23:32:41.866+00	2026-05-08 23:32:41.866+00
134	41	july15	15	0	f	\N	2026-05-08 23:32:42.078+00	2026-05-08 23:32:42.078+00
136	41	july15	16	0	f	\N	2026-05-08 23:32:42.286+00	2026-05-08 23:32:42.286+00
138	41	july15	17	0	f	\N	2026-05-08 23:32:42.501+00	2026-05-08 23:32:42.501+00
140	41	july15	18	0	f	\N	2026-05-08 23:32:42.746+00	2026-05-08 23:32:42.746+00
142	41	july15	19	0	f	\N	2026-05-08 23:32:42.954+00	2026-05-08 23:32:42.954+00
144	41	july15	20	0	f	\N	2026-05-08 23:32:43.153+00	2026-05-08 23:32:43.153+00
146	41	july15	21	0	f	\N	2026-05-08 23:32:43.374+00	2026-05-08 23:32:43.374+00
148	41	july15	22	0	f	\N	2026-05-08 23:32:43.581+00	2026-05-08 23:32:43.581+00
150	41	july15	23	0	f	\N	2026-05-08 23:32:43.786+00	2026-05-08 23:32:43.786+00
152	41	july15	24	0	f	\N	2026-05-08 23:32:43.999+00	2026-05-08 23:32:43.999+00
154	41	july15	25	0	f	\N	2026-05-08 23:32:44.198+00	2026-05-08 23:32:44.198+00
156	41	july15	26	0	f	\N	2026-05-08 23:32:44.409+00	2026-05-08 23:32:44.409+00
158	30	july7	1	0	f	\N	2026-05-09 00:50:53.525+00	2026-05-09 00:50:53.525+00
160	30	july7	2	0	f	\N	2026-05-09 00:50:53.75+00	2026-05-09 00:50:53.75+00
162	30	july7	3	0	f	\N	2026-05-09 00:50:53.96+00	2026-05-09 00:50:53.96+00
164	30	july7	4	0	f	\N	2026-05-09 00:50:54.169+00	2026-05-09 00:50:54.169+00
166	30	july7	5	0	f	\N	2026-05-09 00:50:54.378+00	2026-05-09 00:50:54.378+00
168	30	july7	6	0	f	\N	2026-05-09 00:50:54.586+00	2026-05-09 00:50:54.586+00
170	30	july7	7	0	f	\N	2026-05-09 00:50:54.795+00	2026-05-09 00:50:54.795+00
172	30	july7	8	0	f	\N	2026-05-09 00:50:55.006+00	2026-05-09 00:50:55.006+00
174	30	july7	9	0	f	\N	2026-05-09 00:50:55.216+00	2026-05-09 00:50:55.216+00
176	30	july7	10	0	f	\N	2026-05-09 00:50:55.428+00	2026-05-09 00:50:55.428+00
178	30	july7	11	0	f	\N	2026-05-09 00:50:55.637+00	2026-05-09 00:50:55.637+00
180	30	july7	12	0	f	\N	2026-05-09 00:50:55.849+00	2026-05-09 00:50:55.849+00
182	30	july7	13	0	f	\N	2026-05-09 00:50:56.057+00	2026-05-09 00:50:56.057+00
184	30	july7	14	0	f	\N	2026-05-09 00:50:56.264+00	2026-05-09 00:50:56.264+00
186	30	july7	15	0	f	\N	2026-05-09 00:50:56.473+00	2026-05-09 00:50:56.473+00
188	30	july7	16	0	f	\N	2026-05-09 00:50:56.68+00	2026-05-09 00:50:56.68+00
190	30	july7	17	0	f	\N	2026-05-09 00:50:56.891+00	2026-05-09 00:50:56.891+00
192	30	july7	18	0	f	\N	2026-05-09 00:50:57.099+00	2026-05-09 00:50:57.099+00
194	30	july7	19	0	f	\N	2026-05-09 00:50:57.313+00	2026-05-09 00:50:57.313+00
196	30	july7	20	0	f	\N	2026-05-09 00:50:57.52+00	2026-05-09 00:50:57.52+00
198	30	july7	21	0	f	\N	2026-05-09 00:50:57.729+00	2026-05-09 00:50:57.729+00
200	30	july7	22	0	f	\N	2026-05-09 00:50:57.942+00	2026-05-09 00:50:57.942+00
202	30	july7	23	0	f	\N	2026-05-09 00:50:58.153+00	2026-05-09 00:50:58.153+00
204	30	july7	24	0	f	\N	2026-05-09 00:50:58.365+00	2026-05-09 00:50:58.365+00
206	30	july7	25	0	f	\N	2026-05-09 00:50:58.571+00	2026-05-09 00:50:58.571+00
208	30	july7	26	0	f	\N	2026-05-09 00:50:58.78+00	2026-05-09 00:50:58.78+00
61	58	aug13	9	22	f	\N	2026-05-05 23:55:28.163+00	2026-05-17 22:13:37.505688+00
40	8	vivian	14	850	f	\N	2026-05-06 02:06:32.751+00	2026-05-17 17:52:59.628696+00
41	8	vivian	15	850	f	\N	2026-05-06 02:06:34.418+00	2026-05-17 17:52:59.628696+00
42	8	vivian	16	850	f	\N	2026-05-06 02:06:34.439+00	2026-05-17 17:52:59.628696+00
209	12	alice	1	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
210	12	alice	2	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
211	12	alice	3	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
212	12	alice	4	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
9	60	chinese2	9	12	f	\N	2026-05-04 22:29:36.296+00	2026-05-17 17:33:06.603957+00
213	12	alice	5	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
214	12	alice	6	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
215	12	alice	7	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
216	12	alice	8	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
217	12	alice	9	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
218	12	alice	10	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
219	12	alice	11	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
220	12	alice	12	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
221	12	alice	13	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
222	12	alice	14	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
223	12	alice	15	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
224	12	alice	16	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
225	12	alice	17	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
226	12	alice	18	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
227	12	alice	19	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
228	12	alice	20	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
229	12	alice	21	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
230	12	alice	22	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
231	12	alice	23	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
232	12	alice	24	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
233	12	alice	25	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
234	12	alice	26	0	f	\N	2026-05-17 17:53:00.245823+00	2026-05-17 17:53:00.245823+00
66	58	aug13	14	251	f	\N	2026-05-05 23:55:29.174+00	2026-05-18 06:16:01.42237+00
30	8	vivian	4	116	f	\N	2026-05-06 02:06:32.441+00	2026-05-17 19:05:27.616279+00
31	8	vivian	5	116	f	\N	2026-05-06 02:06:32.474+00	2026-05-17 19:05:27.616279+00
32	8	vivian	6	116	f	\N	2026-05-06 02:06:32.521+00	2026-05-17 19:05:27.616279+00
29	8	vivian	3	100	t	2026-05-17 18:24:33.398+00	2026-05-06 02:06:32.257+00	2026-05-17 18:24:33.38469+00
33	8	vivian	7	116	f	\N	2026-05-06 02:06:32.545+00	2026-05-17 19:05:27.616279+00
34	8	vivian	8	116	f	\N	2026-05-06 02:06:32.564+00	2026-05-17 19:05:27.616279+00
35	8	vivian	9	116	f	\N	2026-05-06 02:06:32.581+00	2026-05-17 19:05:27.616279+00
64	58	aug13	12	251	f	\N	2026-05-05 23:55:28.762+00	2026-05-18 06:16:01.42237+00
65	58	aug13	13	251	f	\N	2026-05-05 23:55:28.97+00	2026-05-18 06:16:01.42237+00
67	58	aug13	15	251	f	\N	2026-05-05 23:55:29.38+00	2026-05-18 06:16:01.42237+00
68	58	aug13	16	251	f	\N	2026-05-05 23:55:29.591+00	2026-05-18 06:16:01.42237+00
63	58	aug13	11	200	t	2026-05-18 06:15:55.795+00	2026-05-05 23:55:28.56+00	2026-05-18 06:15:51.956741+00
62	58	aug13	10	100	t	2026-05-18 06:02:53.386+00	2026-05-05 23:55:28.356+00	2026-05-18 06:02:53.033706+00
\.


--
-- TOC entry 5133 (class 0 OID 0)
-- Dependencies: 768
-- Name: as_achievement_change_logs_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_achievement_change_logs_id_seq', 1827, true);


--
-- TOC entry 5134 (class 0 OID 0)
-- Dependencies: 770
-- Name: as_achievement_translations_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_achievement_translations_id_seq', 233, true);


--
-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 772
-- Name: as_achievements_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_achievements_id_seq', 26, true);


--
-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 774
-- Name: as_event_lists_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_event_lists_id_seq', 4, true);


--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 776
-- Name: as_event_logs_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_event_logs_id_seq', 300, true);


--
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 778
-- Name: as_user_achievements_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_user_achievements_id_seq', 260, true);


--
-- TOC entry 4940 (class 2606 OID 148572)
-- Name: as_achievement_change_logs as_achievement_change_logs_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs
    ADD CONSTRAINT as_achievement_change_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4943 (class 2606 OID 148574)
-- Name: as_achievement_translations as_achievement_translations_achievement_id_locale_key; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_translations
    ADD CONSTRAINT as_achievement_translations_achievement_id_locale_key UNIQUE (achievement_id, locale);


--
-- TOC entry 4946 (class 2606 OID 148576)
-- Name: as_achievement_translations as_achievement_translations_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_translations
    ADD CONSTRAINT as_achievement_translations_pkey PRIMARY KEY (id);


--
-- TOC entry 4948 (class 2606 OID 148578)
-- Name: as_achievements as_achievements_code_key; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievements
    ADD CONSTRAINT as_achievements_code_key UNIQUE (code);


--
-- TOC entry 4951 (class 2606 OID 148580)
-- Name: as_achievements as_achievements_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievements
    ADD CONSTRAINT as_achievements_pkey PRIMARY KEY (id);


--
-- TOC entry 4954 (class 2606 OID 148582)
-- Name: as_event_lists as_event_lists_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_event_lists
    ADD CONSTRAINT as_event_lists_pkey PRIMARY KEY (id);


--
-- TOC entry 4957 (class 2606 OID 148584)
-- Name: as_event_logs as_event_logs_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_event_logs
    ADD CONSTRAINT as_event_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4962 (class 2606 OID 148586)
-- Name: as_user_achievements as_user_achievements_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_user_achievements
    ADD CONSTRAINT as_user_achievements_pkey PRIMARY KEY (id);


--
-- TOC entry 4964 (class 2606 OID 148588)
-- Name: as_user_achievements as_user_achievements_userid_achievement_id_key; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_user_achievements
    ADD CONSTRAINT as_user_achievements_userid_achievement_id_key UNIQUE (userid, achievement_id);


--
-- TOC entry 4936 (class 1259 OID 148589)
-- Name: as_achievement_change_logs_achievement_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_change_logs_achievement_idx ON {{SCHEMA}}.as_achievement_change_logs USING btree (achievement_id);


--
-- TOC entry 4937 (class 1259 OID 148590)
-- Name: as_achievement_change_logs_created_at_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_change_logs_created_at_idx ON {{SCHEMA}}.as_achievement_change_logs USING btree (created_at DESC);


--
-- TOC entry 4938 (class 1259 OID 148591)
-- Name: as_achievement_change_logs_event_log_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_change_logs_event_log_idx ON {{SCHEMA}}.as_achievement_change_logs USING btree (event_log_id);


--
-- TOC entry 4941 (class 1259 OID 148592)
-- Name: as_achievement_change_logs_userid_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_change_logs_userid_idx ON {{SCHEMA}}.as_achievement_change_logs USING btree (userid);


--
-- TOC entry 4944 (class 1259 OID 148593)
-- Name: as_achievement_translations_locale_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_translations_locale_idx ON {{SCHEMA}}.as_achievement_translations USING btree (locale);


--
-- TOC entry 4949 (class 1259 OID 148594)
-- Name: as_achievements_event_name_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievements_event_name_idx ON {{SCHEMA}}.as_achievements USING btree (event_name);


--
-- TOC entry 4952 (class 1259 OID 148595)
-- Name: as_event_lists_event_name_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_event_lists_event_name_idx ON {{SCHEMA}}.as_event_lists USING btree (event_name);


--
-- TOC entry 4955 (class 1259 OID 148596)
-- Name: as_event_logs_event_name_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_event_logs_event_name_idx ON {{SCHEMA}}.as_event_logs USING btree (event_name);


--
-- TOC entry 4958 (class 1259 OID 148597)
-- Name: as_event_logs_received_at_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_event_logs_received_at_idx ON {{SCHEMA}}.as_event_logs USING btree (received_at DESC);


--
-- TOC entry 4959 (class 1259 OID 148598)
-- Name: as_event_logs_userid_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_event_logs_userid_idx ON {{SCHEMA}}.as_event_logs USING btree (userid);


--
-- TOC entry 4960 (class 1259 OID 148599)
-- Name: as_user_achievements_achievement_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_user_achievements_achievement_idx ON {{SCHEMA}}.as_user_achievements USING btree (achievement_id);


--
-- TOC entry 4965 (class 1259 OID 148600)
-- Name: as_user_achievements_userid_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_user_achievements_userid_idx ON {{SCHEMA}}.as_user_achievements USING btree (userid);


--
-- TOC entry 4966 (class 2606 OID 148601)
-- Name: as_achievement_change_logs as_achievement_change_logs_achievement_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs
    ADD CONSTRAINT as_achievement_change_logs_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES {{SCHEMA}}.as_achievements(id) ON DELETE CASCADE;


--
-- TOC entry 4967 (class 2606 OID 148606)
-- Name: as_achievement_change_logs as_achievement_change_logs_event_log_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs
    ADD CONSTRAINT as_achievement_change_logs_event_log_id_fkey FOREIGN KEY (event_log_id) REFERENCES {{SCHEMA}}.as_event_logs(id) ON DELETE CASCADE;


--
-- TOC entry 4968 (class 2606 OID 148611)
-- Name: as_achievement_change_logs as_achievement_change_logs_user_achievement_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs
    ADD CONSTRAINT as_achievement_change_logs_user_achievement_id_fkey FOREIGN KEY (user_achievement_id) REFERENCES {{SCHEMA}}.as_user_achievements(id) ON DELETE CASCADE;


--
-- TOC entry 4969 (class 2606 OID 148616)
-- Name: as_achievement_translations as_achievement_translations_achievement_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_translations
    ADD CONSTRAINT as_achievement_translations_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES {{SCHEMA}}.as_achievements(id) ON DELETE CASCADE;


--
-- TOC entry 4970 (class 2606 OID 148621)
-- Name: as_user_achievements as_user_achievements_achievement_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_user_achievements
    ADD CONSTRAINT as_user_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES {{SCHEMA}}.as_achievements(id) ON DELETE CASCADE;


-- Completed on 2026-05-18 00:16:05 PDT

--
-- PostgreSQL database dump complete
--

