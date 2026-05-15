--
-- PostgreSQL database dump
--

-- Dumped from database version 14.22
-- Dumped by pg_dump version 14.18 (Homebrew)

-- Started on 2026-05-10 23:35:47 PDT

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
-- TOC entry 7 (class 2615 OID 94792)
-- Name: achievement_system; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA {{SCHEMA}};


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 332 (class 1259 OID 95080)
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
-- TOC entry 331 (class 1259 OID 95079)
-- Name: as_achievement_change_logs_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_achievement_change_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4250 (class 0 OID 0)
-- Dependencies: 331
-- Name: as_achievement_change_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_achievement_change_logs_id_seq OWNED BY {{SCHEMA}}.as_achievement_change_logs.id;


--
-- TOC entry 321 (class 1259 OID 94793)
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
-- TOC entry 322 (class 1259 OID 94801)
-- Name: as_achievement_translations_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_achievement_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4251 (class 0 OID 0)
-- Dependencies: 322
-- Name: as_achievement_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_achievement_translations_id_seq OWNED BY {{SCHEMA}}.as_achievement_translations.id;


--
-- TOC entry 323 (class 1259 OID 94802)
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
-- TOC entry 324 (class 1259 OID 94810)
-- Name: as_achievements_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4252 (class 0 OID 0)
-- Dependencies: 324
-- Name: as_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_achievements_id_seq OWNED BY {{SCHEMA}}.as_achievements.id;


--
-- TOC entry 325 (class 1259 OID 94811)
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
-- TOC entry 326 (class 1259 OID 94817)
-- Name: as_event_lists_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_event_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4253 (class 0 OID 0)
-- Dependencies: 326
-- Name: as_event_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_event_lists_id_seq OWNED BY {{SCHEMA}}.as_event_lists.id;


--
-- TOC entry 330 (class 1259 OID 95070)
-- Name: as_event_logs; Type: TABLE; Schema: achievement_system; Owner: -
--

CREATE TABLE {{SCHEMA}}.as_event_logs (
    id bigint NOT NULL,
    event_name character varying(255) NOT NULL,
    userid character varying(255),
    username character varying(255),
    payload_json jsonb NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 329 (class 1259 OID 95069)
-- Name: as_event_logs_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_event_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4254 (class 0 OID 0)
-- Dependencies: 329
-- Name: as_event_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_event_logs_id_seq OWNED BY {{SCHEMA}}.as_event_logs.id;


--
-- TOC entry 327 (class 1259 OID 94818)
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
-- TOC entry 328 (class 1259 OID 94827)
-- Name: as_user_achievements_id_seq; Type: SEQUENCE; Schema: achievement_system; Owner: -
--

CREATE SEQUENCE {{SCHEMA}}.as_user_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4255 (class 0 OID 0)
-- Dependencies: 328
-- Name: as_user_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: achievement_system; Owner: -
--

ALTER SEQUENCE {{SCHEMA}}.as_user_achievements_id_seq OWNED BY {{SCHEMA}}.as_user_achievements.id;


--
-- TOC entry 4057 (class 2604 OID 95083)
-- Name: as_achievement_change_logs id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_achievement_change_logs_id_seq'::regclass);


--
-- TOC entry 4041 (class 2604 OID 94828)
-- Name: as_achievement_translations id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_translations ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_achievement_translations_id_seq'::regclass);


--
-- TOC entry 4045 (class 2604 OID 94829)
-- Name: as_achievements id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievements ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_achievements_id_seq'::regclass);


--
-- TOC entry 4049 (class 2604 OID 94830)
-- Name: as_event_lists id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_event_lists ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_event_lists_id_seq'::regclass);


--
-- TOC entry 4055 (class 2604 OID 95073)
-- Name: as_event_logs id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_event_logs ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_event_logs_id_seq'::regclass);


--
-- TOC entry 4054 (class 2604 OID 94831)
-- Name: as_user_achievements id; Type: DEFAULT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_user_achievements ALTER COLUMN id SET DEFAULT nextval('{{SCHEMA}}.as_user_achievements_id_seq'::regclass);


--
-- TOC entry 4244 (class 0 OID 95080)
-- Dependencies: 332
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
\.


--
-- TOC entry 4233 (class 0 OID 94793)
-- Dependencies: 321
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
-- TOC entry 4235 (class 0 OID 94802)
-- Dependencies: 323
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
-- TOC entry 4237 (class 0 OID 94811)
-- Dependencies: 325
-- Data for Name: as_event_lists; Type: TABLE DATA; Schema: achievement_system; Owner: -
--

COPY {{SCHEMA}}.as_event_lists (id, event_name, points, created_at, updated_at) FROM stdin;
1	flashcard.created	1	2026-05-04 21:38:27.732+00	2026-05-04 21:38:27.732+00
2	flashcard.reviewed	1	2026-05-04 21:38:34.296+00	2026-05-04 21:38:34.296+00
3	flashcard.remembered	1	2026-05-04 21:38:49.875+00	2026-05-04 21:38:49.875+00
4	article.created	1	2026-05-04 21:39:52.327+00	2026-05-04 21:39:52.327+00
\.


--
-- TOC entry 4242 (class 0 OID 95070)
-- Dependencies: 330
-- Data for Name: as_event_logs; Type: TABLE DATA; Schema: achievement_system; Owner: -
--

COPY {{SCHEMA}}.as_event_logs (id, event_name, userid, username, payload_json, received_at) FROM stdin;
1	flashcard.reviewed	8	vivian	{"userid": "8", "username": "vivian"}	2026-05-11 06:24:03.117857+00
2	flashcard.reviewed	8	vivian	{"userid": "8", "username": "vivian"}	2026-05-11 06:25:01.327114+00
3	flashcard.reviewed	8	vivian	{"userid": "8", "username": "vivian"}	2026-05-11 06:34:00.414913+00
\.


--
-- TOC entry 4239 (class 0 OID 94818)
-- Dependencies: 327
-- Data for Name: as_user_achievements; Type: TABLE DATA; Schema: achievement_system; Owner: -
--

COPY {{SCHEMA}}.as_user_achievements (id, userid, username, achievement_id, progress, achieved, achieved_at, created_at, updated_at) FROM stdin;
1	60	chinese2	1	10	t	2026-05-04 23:31:14.68+00	2026-05-04 22:29:34.025+00	2026-05-04 23:31:14.806+00
2	60	chinese2	2	11	f	\N	2026-05-04 22:29:34.667+00	2026-05-04 23:31:20.574+00
3	60	chinese2	3	11	f	\N	2026-05-04 22:29:34.911+00	2026-05-04 23:31:21.119+00
4	60	chinese2	4	11	f	\N	2026-05-04 22:29:35.142+00	2026-05-04 23:31:21.656+00
5	60	chinese2	5	11	f	\N	2026-05-04 22:29:35.372+00	2026-05-04 23:31:22.178+00
6	60	chinese2	6	11	f	\N	2026-05-04 22:29:35.597+00	2026-05-04 23:31:22.718+00
7	60	chinese2	7	11	f	\N	2026-05-04 22:29:35.828+00	2026-05-04 23:31:23.242+00
8	60	chinese2	8	11	f	\N	2026-05-04 22:29:36.062+00	2026-05-04 23:31:23.78+00
9	60	chinese2	9	11	f	\N	2026-05-04 22:29:36.296+00	2026-05-04 23:31:24.318+00
10	60	chinese2	10	100	t	2026-05-07 22:29:09.739+00	2026-05-04 22:29:36.526+00	2026-05-07 22:29:09.866+00
11	60	chinese2	11	184	f	\N	2026-05-04 22:29:36.751+00	2026-05-09 08:25:37.402+00
12	60	chinese2	12	184	f	\N	2026-05-04 22:29:36.981+00	2026-05-09 08:25:37.564+00
13	60	chinese2	13	184	f	\N	2026-05-04 22:29:37.213+00	2026-05-09 08:25:37.675+00
14	60	chinese2	14	184	f	\N	2026-05-04 22:29:37.441+00	2026-05-09 08:25:37.789+00
15	60	chinese2	15	184	f	\N	2026-05-04 22:29:37.663+00	2026-05-09 08:25:37.833+00
16	60	chinese2	16	184	f	\N	2026-05-04 22:29:37.886+00	2026-05-09 08:25:39.488+00
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
29	8	vivian	3	93	f	\N	2026-05-06 02:06:32.257+00	2026-05-10 19:06:21.774+00
30	8	vivian	4	93	f	\N	2026-05-06 02:06:32.441+00	2026-05-10 19:06:21.987+00
31	8	vivian	5	93	f	\N	2026-05-06 02:06:32.474+00	2026-05-10 19:06:22.157+00
32	8	vivian	6	93	f	\N	2026-05-06 02:06:32.521+00	2026-05-10 19:06:22.259+00
33	8	vivian	7	93	f	\N	2026-05-06 02:06:32.545+00	2026-05-10 19:06:22.325+00
34	8	vivian	8	93	f	\N	2026-05-06 02:06:32.564+00	2026-05-10 19:06:22.377+00
35	8	vivian	9	93	f	\N	2026-05-06 02:06:32.581+00	2026-05-10 19:06:22.416+00
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
54	58	aug13	2	14	f	\N	2026-05-05 23:55:26.655+00	2026-05-05 23:57:20.122+00
55	58	aug13	3	14	f	\N	2026-05-05 23:55:26.911+00	2026-05-05 23:57:20.654+00
56	58	aug13	4	14	f	\N	2026-05-05 23:55:27.126+00	2026-05-05 23:57:21.176+00
57	58	aug13	5	14	f	\N	2026-05-05 23:55:27.329+00	2026-05-05 23:57:21.703+00
58	58	aug13	6	14	f	\N	2026-05-05 23:55:27.553+00	2026-05-05 23:57:22.238+00
59	58	aug13	7	14	f	\N	2026-05-05 23:55:27.763+00	2026-05-05 23:57:22.73+00
60	58	aug13	8	14	f	\N	2026-05-05 23:55:27.972+00	2026-05-05 23:57:23.275+00
61	58	aug13	9	14	f	\N	2026-05-05 23:55:28.163+00	2026-05-05 23:57:23.888+00
62	58	aug13	10	0	f	\N	2026-05-05 23:55:28.356+00	2026-05-05 23:55:28.356+00
63	58	aug13	11	0	f	\N	2026-05-05 23:55:28.56+00	2026-05-05 23:55:28.56+00
64	58	aug13	12	0	f	\N	2026-05-05 23:55:28.762+00	2026-05-05 23:55:28.762+00
65	58	aug13	13	0	f	\N	2026-05-05 23:55:28.97+00	2026-05-05 23:55:28.97+00
66	58	aug13	14	0	f	\N	2026-05-05 23:55:29.174+00	2026-05-05 23:55:29.174+00
67	58	aug13	15	0	f	\N	2026-05-05 23:55:29.38+00	2026-05-05 23:55:29.38+00
68	58	aug13	16	0	f	\N	2026-05-05 23:55:29.591+00	2026-05-05 23:55:29.591+00
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
39	8	vivian	13	847	f	\N	2026-05-06 02:06:32.731+00	2026-05-11 06:34:00.414913+00
88	71	chinese3@langgo.ca	10	17	f	\N	2026-05-06 00:01:06.662+00	2026-05-06 00:16:53.413+00
89	71	chinese3@langgo.ca	11	17	f	\N	2026-05-06 00:01:06.965+00	2026-05-06 00:16:53.956+00
90	71	chinese3@langgo.ca	12	17	f	\N	2026-05-06 00:01:07.215+00	2026-05-06 00:16:54.487+00
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
40	8	vivian	14	847	f	\N	2026-05-06 02:06:32.751+00	2026-05-11 06:34:00.414913+00
41	8	vivian	15	847	f	\N	2026-05-06 02:06:34.418+00	2026-05-11 06:34:00.414913+00
42	8	vivian	16	847	f	\N	2026-05-06 02:06:34.439+00	2026-05-11 06:34:00.414913+00
\.


--
-- TOC entry 4256 (class 0 OID 0)
-- Dependencies: 331
-- Name: as_achievement_change_logs_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_achievement_change_logs_id_seq', 12, true);


--
-- TOC entry 4257 (class 0 OID 0)
-- Dependencies: 322
-- Name: as_achievement_translations_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_achievement_translations_id_seq', 233, true);


--
-- TOC entry 4258 (class 0 OID 0)
-- Dependencies: 324
-- Name: as_achievements_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_achievements_id_seq', 26, true);


--
-- TOC entry 4259 (class 0 OID 0)
-- Dependencies: 326
-- Name: as_event_lists_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_event_lists_id_seq', 4, true);


--
-- TOC entry 4260 (class 0 OID 0)
-- Dependencies: 329
-- Name: as_event_logs_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_event_logs_id_seq', 3, true);


--
-- TOC entry 4261 (class 0 OID 0)
-- Dependencies: 328
-- Name: as_user_achievements_id_seq; Type: SEQUENCE SET; Schema: achievement_system; Owner: -
--

SELECT pg_catalog.setval('{{SCHEMA}}.as_user_achievements_id_seq', 208, true);


--
-- TOC entry 4087 (class 2606 OID 95088)
-- Name: as_achievement_change_logs as_achievement_change_logs_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs
    ADD CONSTRAINT as_achievement_change_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4060 (class 2606 OID 94833)
-- Name: as_achievement_translations as_achievement_translations_achievement_id_locale_key; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_translations
    ADD CONSTRAINT as_achievement_translations_achievement_id_locale_key UNIQUE (achievement_id, locale);


--
-- TOC entry 4063 (class 2606 OID 94835)
-- Name: as_achievement_translations as_achievement_translations_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_translations
    ADD CONSTRAINT as_achievement_translations_pkey PRIMARY KEY (id);


--
-- TOC entry 4065 (class 2606 OID 94837)
-- Name: as_achievements as_achievements_code_key; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievements
    ADD CONSTRAINT as_achievements_code_key UNIQUE (code);


--
-- TOC entry 4068 (class 2606 OID 94839)
-- Name: as_achievements as_achievements_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievements
    ADD CONSTRAINT as_achievements_pkey PRIMARY KEY (id);


--
-- TOC entry 4071 (class 2606 OID 94841)
-- Name: as_event_lists as_event_lists_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_event_lists
    ADD CONSTRAINT as_event_lists_pkey PRIMARY KEY (id);


--
-- TOC entry 4080 (class 2606 OID 95078)
-- Name: as_event_logs as_event_logs_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_event_logs
    ADD CONSTRAINT as_event_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4074 (class 2606 OID 94843)
-- Name: as_user_achievements as_user_achievements_pkey; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_user_achievements
    ADD CONSTRAINT as_user_achievements_pkey PRIMARY KEY (id);


--
-- TOC entry 4076 (class 2606 OID 94845)
-- Name: as_user_achievements as_user_achievements_userid_achievement_id_key; Type: CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_user_achievements
    ADD CONSTRAINT as_user_achievements_userid_achievement_id_key UNIQUE (userid, achievement_id);


--
-- TOC entry 4083 (class 1259 OID 95109)
-- Name: as_achievement_change_logs_achievement_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_change_logs_achievement_idx ON {{SCHEMA}}.as_achievement_change_logs USING btree (achievement_id);


--
-- TOC entry 4084 (class 1259 OID 95110)
-- Name: as_achievement_change_logs_created_at_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_change_logs_created_at_idx ON {{SCHEMA}}.as_achievement_change_logs USING btree (created_at DESC);


--
-- TOC entry 4085 (class 1259 OID 95107)
-- Name: as_achievement_change_logs_event_log_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_change_logs_event_log_idx ON {{SCHEMA}}.as_achievement_change_logs USING btree (event_log_id);


--
-- TOC entry 4088 (class 1259 OID 95108)
-- Name: as_achievement_change_logs_userid_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_change_logs_userid_idx ON {{SCHEMA}}.as_achievement_change_logs USING btree (userid);


--
-- TOC entry 4061 (class 1259 OID 94846)
-- Name: as_achievement_translations_locale_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievement_translations_locale_idx ON {{SCHEMA}}.as_achievement_translations USING btree (locale);


--
-- TOC entry 4066 (class 1259 OID 94847)
-- Name: as_achievements_event_name_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_achievements_event_name_idx ON {{SCHEMA}}.as_achievements USING btree (event_name);


--
-- TOC entry 4069 (class 1259 OID 94848)
-- Name: as_event_lists_event_name_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_event_lists_event_name_idx ON {{SCHEMA}}.as_event_lists USING btree (event_name);


--
-- TOC entry 4078 (class 1259 OID 95104)
-- Name: as_event_logs_event_name_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_event_logs_event_name_idx ON {{SCHEMA}}.as_event_logs USING btree (event_name);


--
-- TOC entry 4081 (class 1259 OID 95106)
-- Name: as_event_logs_received_at_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_event_logs_received_at_idx ON {{SCHEMA}}.as_event_logs USING btree (received_at DESC);


--
-- TOC entry 4082 (class 1259 OID 95105)
-- Name: as_event_logs_userid_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_event_logs_userid_idx ON {{SCHEMA}}.as_event_logs USING btree (userid);


--
-- TOC entry 4072 (class 1259 OID 94849)
-- Name: as_user_achievements_achievement_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_user_achievements_achievement_idx ON {{SCHEMA}}.as_user_achievements USING btree (achievement_id);


--
-- TOC entry 4077 (class 1259 OID 94850)
-- Name: as_user_achievements_userid_idx; Type: INDEX; Schema: achievement_system; Owner: -
--

CREATE INDEX as_user_achievements_userid_idx ON {{SCHEMA}}.as_user_achievements USING btree (userid);


--
-- TOC entry 4092 (class 2606 OID 95094)
-- Name: as_achievement_change_logs as_achievement_change_logs_achievement_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs
    ADD CONSTRAINT as_achievement_change_logs_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES {{SCHEMA}}.as_achievements(id) ON DELETE CASCADE;


--
-- TOC entry 4091 (class 2606 OID 95089)
-- Name: as_achievement_change_logs as_achievement_change_logs_event_log_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs
    ADD CONSTRAINT as_achievement_change_logs_event_log_id_fkey FOREIGN KEY (event_log_id) REFERENCES {{SCHEMA}}.as_event_logs(id) ON DELETE CASCADE;


--
-- TOC entry 4093 (class 2606 OID 95099)
-- Name: as_achievement_change_logs as_achievement_change_logs_user_achievement_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_change_logs
    ADD CONSTRAINT as_achievement_change_logs_user_achievement_id_fkey FOREIGN KEY (user_achievement_id) REFERENCES {{SCHEMA}}.as_user_achievements(id) ON DELETE CASCADE;


--
-- TOC entry 4089 (class 2606 OID 94851)
-- Name: as_achievement_translations as_achievement_translations_achievement_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_achievement_translations
    ADD CONSTRAINT as_achievement_translations_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES {{SCHEMA}}.as_achievements(id) ON DELETE CASCADE;


--
-- TOC entry 4090 (class 2606 OID 94856)
-- Name: as_user_achievements as_user_achievements_achievement_id_fkey; Type: FK CONSTRAINT; Schema: achievement_system; Owner: -
--

ALTER TABLE ONLY {{SCHEMA}}.as_user_achievements
    ADD CONSTRAINT as_user_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES {{SCHEMA}}.as_achievements(id) ON DELETE CASCADE;


-- Completed on 2026-05-10 23:35:50 PDT

--
-- PostgreSQL database dump complete
--

