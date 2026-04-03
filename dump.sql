--
-- PostgreSQL database dump
--

\restrict eTHZEYgX3DhCinCcYOag9b7YFLbMOUl3WwYGaDgrGKqyMEMaBNRSacFZmCFF6ot

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: botypeenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.botypeenum AS ENUM (
    'BO1',
    'BO3',
    'BO5'
);


ALTER TYPE public.botypeenum OWNER TO postgres;

--
-- Name: mapnameenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.mapnameenum AS ENUM (
    'DUST2',
    'MIRAGE',
    'ANUBIS',
    'INFERNO',
    'NUKE',
    'ANCIENT',
    'TRAIN'
);


ALTER TYPE public.mapnameenum OWNER TO postgres;

--
-- Name: matchstatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.matchstatus AS ENUM (
    'ENDED',
    'ONGOING',
    'UPCOMING'
);


ALTER TYPE public.matchstatus OWNER TO postgres;

--
-- Name: playerroleenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.playerroleenum AS ENUM (
    'RIFLER',
    'SNIPER',
    'IGL',
    'SUPPORT',
    'ENTRY'
);


ALTER TYPE public.playerroleenum OWNER TO postgres;

--
-- Name: regionenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.regionenum AS ENUM (
    'CIS',
    'EU',
    'NA',
    'SA',
    'ASIA',
    'OCE',
    'MENA'
);


ALTER TYPE public.regionenum OWNER TO postgres;

--
-- Name: stageenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.stageenum AS ENUM (
    'GROUP_STAGE',
    'QUARTER_FINAL',
    'SEMIFINAL',
    'FINAL'
);


ALTER TYPE public.stageenum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: matches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.matches (
    id integer NOT NULL,
    team1_id integer NOT NULL,
    team2_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    bo_type public.botypeenum NOT NULL,
    stage public.stageenum NOT NULL,
    status public.matchstatus NOT NULL,
    score_team1 integer NOT NULL,
    score_team2 integer NOT NULL,
    winner_id integer,
    stream_url character varying,
    match_page_url character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT check_teams_not_equal CHECK ((team1_id <> team2_id))
);


ALTER TABLE public.matches OWNER TO postgres;

--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.matches_id_seq OWNER TO postgres;

--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;


--
-- Name: matches_maps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.matches_maps (
    id integer NOT NULL,
    match_id integer,
    map_order integer NOT NULL,
    map_name public.mapnameenum NOT NULL,
    picked_by_team_id integer,
    score_team1 integer NOT NULL,
    score_team2 integer NOT NULL,
    winner_id integer
);


ALTER TABLE public.matches_maps OWNER TO postgres;

--
-- Name: matches_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.matches_maps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.matches_maps_id_seq OWNER TO postgres;

--
-- Name: matches_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.matches_maps_id_seq OWNED BY public.matches_maps.id;


--
-- Name: player_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_stats (
    id integer NOT NULL,
    match_map_id integer NOT NULL,
    player_id integer NOT NULL,
    kills double precision NOT NULL,
    deaths double precision NOT NULL,
    assists double precision NOT NULL,
    adr double precision NOT NULL,
    kast double precision NOT NULL,
    rating double precision NOT NULL,
    hs_percentage double precision NOT NULL
);


ALTER TABLE public.player_stats OWNER TO postgres;

--
-- Name: player_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_stats_id_seq OWNER TO postgres;

--
-- Name: player_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_stats_id_seq OWNED BY public.player_stats.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    id integer NOT NULL,
    nickname character varying NOT NULL,
    real_name character varying NOT NULL,
    country_code character varying(2) NOT NULL,
    role public.playerroleenum,
    photo_url character varying,
    team_id integer,
    is_active boolean NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    description text,
    hltv_url character varying
);


ALTER TABLE public.players OWNER TO postgres;

--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.players_id_seq OWNER TO postgres;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name character varying NOT NULL,
    short_name character varying NOT NULL,
    slug character varying NOT NULL,
    country_code character varying(2) NOT NULL,
    region public.regionenum NOT NULL,
    logo_url character varying,
    description character varying,
    is_active boolean NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.teams OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teams_id_seq OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Name: matches_maps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches_maps ALTER COLUMN id SET DEFAULT nextval('public.matches_maps_id_seq'::regclass);


--
-- Name: player_stats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_stats ALTER COLUMN id SET DEFAULT nextval('public.player_stats_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.matches (id, team1_id, team2_id, start_time, bo_type, stage, status, score_team1, score_team2, winner_id, stream_url, match_page_url, created_at) FROM stdin;
1	3	8	2026-05-10 18:00:00	BO3	GROUP_STAGE	UPCOMING	2	1	3	https://twitch.com/pgl	\N	2026-03-25 13:18:35.481971
2	1	2	2026-05-10 21:30:00	BO5	SEMIFINAL	ONGOING	2	3	2	https://twitch.com/pgl	\N	2026-03-25 13:20:05.139346
3	7	5	2026-05-11 15:30:00	BO1	FINAL	ENDED	1	0	7	https://twitch.com/pgl	\N	2026-03-25 13:21:16.006711
\.


--
-- Data for Name: matches_maps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.matches_maps (id, match_id, map_order, map_name, picked_by_team_id, score_team1, score_team2, winner_id) FROM stdin;
1	1	1	DUST2	3	13	9	3
2	1	2	NUKE	8	7	13	8
3	1	3	ANUBIS	\N	16	14	3
4	2	1	INFERNO	1	13	6	1
9	3	3	NUKE	\N	18	16	7
10	2	4	DUST2	2	13	8	1
11	2	5	ANUBIS	\N	4	13	2
6	2	3	MIRAGE	2	6	13	2
5	2	2	TRAIN	1	3	13	2
\.


--
-- Data for Name: player_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_stats (id, match_map_id, player_id, kills, deaths, assists, adr, kast, rating, hs_percentage) FROM stdin;
1	1	1	10	19	0	108.42	74.11	0.36	31.44
2	1	2	22	21	6	91.12	75.79	0.52	34.86
3	1	3	12	22	4	109.29	68.03	0.34	41.18
4	1	4	23	10	5	99	69.35	0.69	56.85
5	1	5	18	27	3	109.4	77.48	0.41	69.49
6	1	17	15	23	4	70.53	70.05	0.31	67.96
7	1	19	30	22	4	92.65	76.51	0.66	46.45
8	1	16	10	17	7	75.69	69.74	0.31	33.9
9	1	18	19	25	8	92.44	83.86	0.44	35.78
10	1	20	27	22	6	101.86	67.69	0.6	50.26
11	2	1	20	15	2	69.87	65.18	0.51	39.19
12	2	2	26	17	10	80.17	70.58	0.64	39.55
13	2	3	23	19	0	80.93	79.57	0.58	64.88
14	2	4	13	18	10	73.51	61.34	0.32	65.31
15	2	5	18	25	6	107.72	68.36	0.41	61.01
16	2	17	24	25	5	74.79	64.55	0.45	31.29
17	2	19	23	15	1	81.83	80.94	0.64	49.63
18	2	16	12	21	6	91.93	72.51	0.33	38.63
19	2	18	13	19	0	78.84	61.51	0.32	48.81
20	2	20	24	25	10	77.96	67.07	0.46	44.02
21	3	1	16	17	1	79.29	60.95	0.38	58.12
22	3	2	27	23	4	86.46	62.87	0.49	50.27
23	3	3	22	15	6	66.45	69.5	0.48	56.75
24	3	4	21	26	6	86.1	76.09	0.42	51.03
25	3	5	23	15	6	107.73	60.5	0.55	63.88
26	3	17	28	23	6	85	80.01	0.55	66.01
27	3	19	21	24	2	86.7	60.66	0.4	42.85
28	3	16	19	16	6	68.83	81.24	0.47	38.57
29	3	18	22	13	9	102.38	66.96	0.57	40.57
30	3	20	24	26	3	97.79	78.54	0.49	47.23
31	4	26	28	25	0	109.81	62.37	0.6	69.77
32	4	27	21	18	0	75.49	61.14	0.49	37.06
33	4	28	14	12	1	101.1	64.96	0.5	58.53
34	4	29	14	14	9	104.88	62.73	0.47	54.65
35	4	30	23	29	8	62.11	61.19	0.33	62.01
36	4	31	15	12	4	97.1	76.99	0.55	42.28
37	4	35	13	19	2	109.06	61.99	0.38	39.36
38	4	32	28	14	0	98.73	84.98	0.82	61.75
39	4	33	26	12	9	72.18	68.59	0.71	53.76
40	4	34	26	21	8	98.95	81.72	0.66	49.9
41	9	44	12	17	9	64.56	79.67	0.36	41.77
42	9	41	10	18	10	62.59	79.98	0.32	35.06
43	9	42	12	30	1	90.42	81.69	0.3	44.2
44	9	43	15	10	2	73	64.39	0.43	60.2
45	9	45	18	18	5	62.96	72.01	0.39	39.68
46	9	6	30	30	8	80.67	67.04	0.45	34.87
47	9	7	12	12	3	108.74	71.3	0.47	62.69
48	9	8	16	19	3	60.21	76.99	0.37	51.34
49	9	9	25	19	8	101.39	60.1	0.51	48.02
50	9	10	20	19	8	100.22	78.99	0.51	43.05
51	10	26	29	15	2	82	61.24	0.69	59.34
52	10	27	30	16	3	85.03	66.44	0.71	61.99
53	10	28	22	24	4	93.56	63.54	0.45	53.66
54	10	29	28	24	1	84.98	68.14	0.56	54.27
55	10	30	16	10	2	61.43	82.29	0.53	56.25
56	10	31	27	14	10	98.23	68.87	0.72	42.77
57	10	35	15	14	1	88.62	71.57	0.48	50.17
58	10	32	25	28	5	66.68	64.65	0.4	50.77
59	10	33	10	27	8	72.02	71.04	0.16	52.91
60	10	34	12	17	8	94.14	77.38	0.41	55.66
61	11	26	19	16	4	64.4	70.52	0.51	36.19
62	11	27	24	14	1	107.66	76.03	0.76	52.77
63	11	28	15	29	10	75.63	81.76	0.24	30.65
64	11	29	12	15	2	78.54	69.14	0.38	54.16
65	11	30	27	16	4	107.78	71.72	0.78	38.32
66	11	31	24	15	8	98.36	78.03	0.73	32.62
67	11	35	11	19	3	97.71	78.57	0.35	61.18
68	11	32	13	27	2	65.59	77.7	0.19	36.13
69	11	33	28	10	3	105	80.4	0.93	67.68
70	11	34	16	23	5	91.29	60.8	0.34	39.61
71	6	26	26	30	3	61.68	79.77	0.44	48.06
72	6	27	28	20	6	76.59	64.98	0.62	68.85
73	6	28	12	11	6	68.58	75.6	0.44	65.66
74	6	29	14	28	4	86.47	77.92	0.26	56.07
75	6	30	26	21	8	87.74	66.78	0.59	46
76	6	31	20	22	4	83.21	75.97	0.47	61.51
77	6	35	21	13	6	105.97	77.92	0.68	40.49
78	6	32	13	22	3	87.11	73.94	0.32	53.88
79	6	33	12	19	5	104.6	79.78	0.4	49.89
80	6	34	28	30	9	99.23	66.58	0.51	68.24
81	5	26	19	28	4	77.68	68.03	0.31	34.72
82	5	27	26	12	4	77.19	60.8	0.76	37.9
83	5	28	17	24	3	97.18	81.88	0.42	53.69
84	5	29	15	24	3	85.49	66.92	0.3	50.54
85	5	30	18	11	8	85.47	66.1	0.61	60.34
86	5	31	13	27	5	100.73	62.11	0.21	62.88
87	5	35	12	18	9	60.02	82.71	0.33	40.83
88	5	32	27	28	6	100.23	60.32	0.53	32.9
89	5	33	10	16	2	74.03	72.82	0.32	30.3
90	5	34	11	15	6	62.82	76.22	0.35	41.28
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players (id, nickname, real_name, country_code, role, photo_url, team_id, is_active, created_at, description, hltv_url) FROM stdin;
3	magixx	Борис Воробьёв	RU	IGL	/static/photos/team-spirit/magixx.png	3	t	2026-03-23 14:18:26.500525	Борис “magixx” Воробьёв — важнейший элемент системы Team Spirit, сочетающий в себе опыт, дисциплину и гибкость. В роли IGL он помогает команде принимать правильные решения в сложных игровых ситуациях, контролируя темп и структуру раундов. Его вклад не всегда выражается в статистике, но именно за счёт таких игроков команды выигрывают крупные турниры и стабильно держатся на тир-1 уровне.	https://www.hltv.org/stats/players/18317/magixx
4	sh1ro	Дмитрий Соколов	RU	SNIPER	/static/photos/team-spirit/sh1ro.png	3	t	2026-03-23 14:18:26.500525	Дмитрий “sh1ro” Соколов — один из самых стабильных снайперов в мире CS. Его стиль игры отличается холодной расчетливостью, минимальным количеством ошибок и невероятной эффективностью в клатч-ситуациях. Ранее он был ключевым игроком Cloud9, с которыми выигрывал крупные турниры и стабильно входил в топ HLTV. В составе Team Spirit он усилил команду, добавив ей стабильность и контроль в решающих моментах матчей.	https://www.hltv.org/stats/players/16920/sh1ro
5	tN1R	Андрей Татаринович	BY	RIFLER	/static/photos/team-spirit/tN1R.png	3	t	2026-03-23 14:18:26.500525	Андрей “tN1R” Татаринович — стабильный rifler, усиливающий состав Team Spirit своей дисциплинированной и надёжной игрой. Он не стремится к ярким хайлайтам, но регулярно выполняет свою роль на высоком уровне, обеспечивая команде баланс и стабильность. Его вклад особенно заметен в долгих сериях и напряжённых матчах против сильнейших соперников.	https://www.hltv.org/stats/players/19808/tn1r
6	bLitz	Гаридмагнай Бямбасурэн	MN	IGL	/static/photos/the-mongolz/bLitz.png	5	t	2026-03-23 14:18:26.500525	Гаридмагнай “bLitz” Бямбасурэн — капитан и лидер MongolZ, сыгравший ключевую роль в выходе команды на международную сцену. Под его руководством коллектив стабильно участвует в крупных турнирах и квалификациях, представляя Азию на тир-1 уровне.	https://www.hltv.org/stats/players/20194/blitz
8	mzinho	Аюш Батболд	MN	RIFLER	/static/photos/the-mongolz/mzinho.png	5	t	2026-03-23 14:18:26.500525	Аюш “mzinho” Батболд — молодой rifler, демонстрирующий быстрый рост на профессиональной сцене. Его агрессивная игра и уверенность позволяют команде бороться с соперниками на международных турнирах.	https://www.hltv.org/stats/players/21001/mzinho
12	HeavyGod	Никита Мартыненко	IL	RIFLER	/static/photos/g2-esports/HeavyGod.png	4	t	2026-03-23 14:18:26.500525	Никита “HeavyGod” Мартыненко — молодой талант, который быстро адаптировался к тир-1 уровню. Он усиливает состав G2 своей агрессией и уверенностью в дуэлях.	https://www.hltv.org/stats/players/20447/heavygod
14	MATYS	Матуш Шимко	SK	ENTRY	/static/photos/g2-esports/MATYS.png	4	t	2026-03-23 14:18:26.500525	Матуш “MATYS” Шимко — перспективный entry-фраггер, усиливающий темп игры команды. Его агрессивный стиль позволяет G2 создавать давление.	https://www.hltv.org/stats/players/21062/matys
17	XANTARES	Исмаилджан Дёрткардеш	TR	ENTRY	/static/photos/aurora/XANTARES.png	8	t	2026-03-23 14:18:26.500525	Исмаилджан “XANTARES” Дёрткардеш — легендарный aim-игрок, известный своей механикой и доминацией на HLTV. Один из самых опасных rifler мира.	https://www.hltv.org/stats/players/7938/xantares
19	soulfly	Джанер Кесичи	TR	SUPPORT	/static/photos/aurora/soulfly.png	8	t	2026-03-23 14:18:26.500525	Джанер “soulfly” Кесичи — support-игрок, обеспечивающий баланс команды и стабильность в раундах.	https://www.hltv.org/stats/players/20968/soulfly
7	Techno	Содбаяр Мунхболд	MN	SUPPORT	/static/photos/the-mongolz/Techno.png	5	t	2026-03-23 14:18:26.500525	Содбаяр “Techno” Мунхболд — support-игрок, обеспечивающий структуру и баланс команды. Он играет важную роль в удержании позиций и создании пространства для тиммейтов, помогая MongolZ конкурировать с более опытными составами.	https://www.hltv.org/stats/players/20275/techno
2	zont1x	Мирослав Плахотя	UA	SUPPORT	/static/photos/team-spirit/zont1x.png	3	t	2026-03-23 14:18:26.500525	Мирослав “zont1x” Плахотя — универсальный игрок, выполняющий ключевые support-функции в составе Team Spirit. Его задача — создавать пространство для звёзд команды, обеспечивать контроль карты и поддерживать структуру раундов. Несмотря на менее заметную роль, именно такие игроки делают возможными победы на высоком уровне, особенно в матчах против топ-команд мировой сцены.	https://www.hltv.org/stats/players/20423/zont1x
39	torzsi	Адам Торжаш	HU	SNIPER	/static/photos/mouz/torzsi.png	6	t	2026-03-23 14:18:26.500525	Адам “torzsi” Торжаш — основной AWP команды, отвечающий за контроль и стабильные фраги. Его игра помогает MOUZ удерживать позиции в матчах против топ-команд, а опыт выступлений на крупных турнирах укрепляет его статус на сцене.	https://www.hltv.org/stats/players/18072/torzsi
44	YEKINDAR	Марекс Галинскис	LV	ENTRY	/static/photos/furia/YEKINDAR.png	7	t	2026-03-23 14:18:26.500525	Марекс “YEKINDAR” Галинскис — один из самых агрессивных entry-фраггеров в мире. Ранее он блистал в Virtus.pro и Liquid, где показывал высокий impact и помогал командам достигать успеха на крупных турнирах.	https://www.hltv.org/stats/players/13915/yekindar
50	Alkaren	Алимжан Битимбай	KZ	SNIPER	/static/photos/heroic/Alkaren.png	9	t	2026-03-23 14:18:26.500525	Алимжан “Alkaren” Битимбай — представитель Казахстана на профессиональной сцене, что уже делает его заметной фигурой для региональных болельщиков. Его игра строится на стремлении развиваться и адаптироваться к требованиям современной CS-сцены. В составе Heroic он получает опыт игры против сильных соперников, что способствует его росту как профессионального игрока.	https://www.hltv.org/stats/players/23600/alkaren
9	910	Усухбаяр Банзрагч	MN	SNIPER	/static/photos/the-mongolz/910.png	5	t	2026-03-23 14:18:26.500525	Усухбаяр “910” Банзрагч — снайпер команды, отвечающий за ключевые фраги в решающих моментах. Его игра помогает MongolZ закрепляться на сцене и выходить на крупные турниры.	https://www.hltv.org/stats/players/21809/910
10	cobrazera	Отгонлхагва Батжаргал	MN	ENTRY	/static/photos/the-mongolz/cobrazera.png	5	t	2026-03-23 14:18:26.500525	Отгонхжаргал “cobrazera” Батжаргал — entry-фраггер, создающий давление на соперников. Его агрессивный стиль помогает команде выигрывать важные раунды.	https://www.hltv.org/stats/players/23402/cobrazera
24	dav1g	Давид Гранде	ES	SUPPORT	/static/photos/gentle-mates/dav1g.png	10	t	2026-03-23 14:18:26.500525	Давид “dav1g” Гранде — support-игрок, обеспечивающий структуру команды.	https://www.hltv.org/stats/players/19509/dav1g
35	kyousuke	Максим Лукин	RU	ENTRY	/static/photos/team-falcons/kyousuke.png	2	t	2026-03-23 14:18:26.500525	Максим “kyousuke” Лукин — молодой и перспективный игрок, который только начинает свой путь на профессиональной сцене. Несмотря на возраст, он уже показывает уверенную игру и быстро адаптируется к уровню тир-1 матчей. Его потенциал делает его важной частью будущего команды.	https://www.hltv.org/stats/players/24177/kyousuke
13	SunPayus	Альваро Гарсия	ES	SNIPER	/static/photos/g2-esports/SunPayus.png	4	t	2026-03-23 14:18:26.500525	Альваро “SunPayus” Гарсия — AWP-игрок высокого уровня, известный по выступлениям за ENCE. Он стабильно показывает результат на международной сцене и приносит команде важные фраги.	https://www.hltv.org/stats/players/19164/sunpayus
15	NertZ	Гай Илуз	IL	RIFLER	/static/photos/g2-esports/NertZ.png	4	t	2026-03-23 14:18:26.500525	Гай “NertZ” Илуз — rifler с опытом тир-1 сцены, ранее выступал за ENCE и другие команды, показывая стабильный уровень.	https://www.hltv.org/stats/players/9436/nertz
16	MAJ3R	Энгин Кюпели	TR	IGL	/static/photos/aurora/MAJ3R.png	8	t	2026-03-23 14:18:26.500525	Энгин “MAJ3R” Кюпели — опытный капитан и лидер турецкой сцены. Он много лет выступает на международных турнирах и ведёт команды на высокий уровень.	https://www.hltv.org/stats/players/150/maj3r
18	woxic	Озгюр Экер	TR	SNIPER	/static/photos/aurora/woxic.png	8	t	2026-03-23 14:18:26.500525	Озгюр “woxic” Экер — агрессивный AWP-игрок, ранее выступал за mousesports и показывал высокий уровень на тир-1 турнирах.	https://www.hltv.org/stats/players/8574/woxic
20	Wicadia	Али Хайдар Ялчын	TR	RIFLER	/static/photos/aurora/Wicadia.png	8	t	2026-03-23 14:18:26.500525	Али “Wicadia” Хайдар Ялчин — молодой rifler, быстро развивающийся и усиливающий состав Aurora.	https://www.hltv.org/stats/players/21243/wicadia
21	alex	Алехандро Масанет	ES	IGL	/static/photos/gentle-mates/alex.png	10	t	2026-03-23 14:18:26.500525	Александро “alex” Масанет — опытный капитан, выступавший на мейджорах и крупных турнирах. Известен своим лидерством и пониманием игры.	https://www.hltv.org/stats/players/8371/alex
23	sausol	Сауль Кастаньо	ES	RIFLER	/static/photos/gentle-mates/sausol.png	10	t	2026-03-23 14:18:26.500525	Сауль “sausol” Кастаньо — молодой игрок, демонстрирующий рост и потенциал.	https://www.hltv.org/stats/players/18749/sausol
22	mopoz	Алехандро Фернандес-Кехо Кано	ES	ENTRY	/static/photos/gentle-mates/mopoz.png	10	t	2026-03-23 14:18:26.500525	Алехандро “mopoz” Фернандес — rifler с опытом международных турниров, стабильно выступает на сцене.	https://www.hltv.org/stats/players/9254/mopoz
25	MartinezSa	Антонио Мартинес	ES	SNIPER	/static/photos/gentle-mates/MartinezSa.png	10	t	2026-03-23 14:18:26.500525	Антонио “MartinezSa” Мартинес — AWP-игрок, ключевой элемент команды в решающих раундах.	https://www.hltv.org/stats/players/21239/martinezsa
28	xiELO	Владислав Лысов	RU	RIFLER	/static/photos/parivision/xiELO.png	1	t	2026-03-23 14:18:26.500525	Владислав “xiELO” Лысов — rifler, играющий важную роль в структуре PARIVISION. Он отвечает за удержание позиций, грамотные размены и стабильность в ключевых раундах. Его вклад часто остаётся “за кадром”, но именно такие игроки позволяют команде держать баланс между агрессией и контролем. Участие в международных матчах и регулярная практика против сильных соперников помогают ему постепенно закрепляться на высоком уровне и развиваться внутри системы команды.	https://www.hltv.org/stats/players/22471/xielo
29	nota	Эмиль Москвитин	RU	SUPPORT	/static/photos/parivision/nota.png	1	t	2026-03-23 14:18:26.500525	Эмиль “nota” Москвитин — support-игрок, который обеспечивает дисциплину и порядок в игре команды. Его задачи включают контроль карты, помощь в разменах и создание условий для звёздных игроков. Nota играет важную роль в реализации стратегий капитана, позволяя команде действовать слаженно даже в напряжённых ситуациях. Его вклад особенно заметен в матчах, где важна структура и минимизация ошибок, что критично для выступлений на серьёзных турнирах.	https://www.hltv.org/stats/players/22929/nota
30	zweih	Иван Гогин	RU	RIFLER	/static/photos/parivision/zweih.png	1	t	2026-03-23 14:18:26.500525	Иван “zweih” Гогин — перспективный rifler, добавляющий команде огневую мощь и агрессию. Его стиль сочетает уверенную стрельбу и готовность брать на себя инициативу в сложных ситуациях. Выступая на профессиональной сцене, он постепенно набирает опыт и учится играть против топовых соперников. В составе PARIVISION он является важной частью роста команды, дополняя более опытных игроков и усиливая общий потенциал коллектива.	https://www.hltv.org/stats/players/23685/zweih
32	TeSeS	Рене Мадсен	DK	SUPPORT	/static/photos/team-falcons/TeSeS.png	2	t	2026-03-23 14:18:26.500525	Рене “TeSeS” Мадсен — опытный rifler, известный по выступлениям за Heroic, где он выигрывал крупные турниры и стабильно играл на тир-1 уровне. Его стиль игры отличается надёжностью и способностью выполнять сложные роли в команде. В составе Falcons он приносит стабильность, опыт и понимание игры на высшем уровне.	https://www.hltv.org/stats/players/12018/teses
33	m0NESY	Илья Осипов	RU	SNIPER	/static/photos/team-falcons/m0NESY.png	2	t	2026-03-23 14:18:26.500525	Илья “m0NESY” Осипов — один из самых талантливых снайперов нового поколения. Ещё в составе NAVI Junior он привлёк внимание своей агрессивной и уверенной игрой, после чего перешёл в G2, где быстро стал ключевым игроком. Он регулярно показывает хайлайты мирового уровня и уже выигрывал крупные турниры. Его стиль сочетает в себе агрессию, скорость реакции и нестандартные решения.	https://www.hltv.org/stats/players/19230/m0nesy
59	cmtry	Кристиян Митев	BG	IGL	/static/photos/fut-esports/cmtry.png	12	t	2026-03-23 14:18:26.500525	Кристиан “cmtry” Митев — support-игрок, обеспечивающий дисциплину и порядок в игре команды. Его задачи включают помощь тиммейтам, контроль карты и участие в разменах. Такие игроки являются фундаментом команды, позволяя ей действовать более организованно.	https://www.hltv.org/stats/players/22674/cmtry
37	Jimpphat	Йими Сало	FI	RIFLER	/static/photos/mouz/Jimpphat.png	6	t	2026-03-23 14:18:26.500525	Йими “Jimpphat” Сало — один из самых перспективных молодых игроков Европы. Несмотря на возраст, он уже демонстрирует зрелую игру, отличное понимание позиций и стабильную стрельбу. Его быстрое развитие и уверенность делают его важной частью будущего MOUZ.	https://www.hltv.org/stats/players/18850/jimpphat
38	Spinx	Лотан Гилади	IL	SUPPORT	/static/photos/mouz/Spinx.png	6	t	2026-03-23 14:18:26.500525	Лотан “Spinx” Гилади — rifler мирового уровня, ранее блиставший в ENCE и Vitality. Он участвовал в победах на крупных турнирах и стабильно входил в число сильнейших игроков по статистике. Его стабильность и умение играть в сложных ситуациях делают его ключевым элементом команды.	https://www.hltv.org/stats/players/18221/spinx
40	xertioN	Дориан Берман	IL	ENTRY	/static/photos/mouz/xertioN.png	6	t	2026-03-23 14:18:26.500525	Дориан “xertioN” Берман — агрессивный rifler, создающий давление и пространство для команды. Его стиль игры делает его опасным в дуэлях, а вклад в атакующие действия помогает MOUZ диктовать темп матчей.	https://www.hltv.org/stats/players/20312/xertion
42	KSCERATO	Кайке Керато	BR	RIFLER	/static/photos/furia/KSCERATO.png	7	t	2026-03-23 14:18:26.500525	Кайке “KSCERATO” Керато — один из самых стабильных rifler мира. На протяжении нескольких лет он входит в число лучших игроков по версии HLTV, демонстрируя высокий уровень стрельбы и понимания игры. Его стабильность делает его ключевым игроком FURIA.	https://www.hltv.org/stats/players/15631/kscerato
43	molodoy	Данил Голубенко	KZ	SNIPER	/static/photos/furia/molodoy.png	7	t	2026-03-23 14:18:26.500525	Данил “molodoy” Голубенко — молодой игрок, который постепенно закрепляется на профессиональной сцене. Его уверенная игра и стремление развиваться делают его перспективным элементом состава.	https://www.hltv.org/stats/players/24144/molodoy
45	yuurih	Юрий Сантос	BR	SUPPORT	/static/photos/furia/yuurih.png	7	t	2026-03-23 14:18:26.500525	Юрий “yuurih” Сантос — стабильный rifler, который на протяжении многих лет остаётся ключевым игроком FURIA. Его вклад в результаты команды и выступления на крупных турнирах делает его одним из лидеров состава.	https://www.hltv.org/stats/players/12553/yuurih
47	nilo	Линус Бергман	SE	RIFLER	/static/photos/heroic/nilo.png	9	t	2026-03-23 14:18:26.500525	Линус “nilo” Бергман — один из самых перспективных молодых игроков Европы, привлекающий внимание своим хладнокровием и стабильностью. Его стиль сочетает аккуратную стрельбу и грамотное позиционирование, что позволяет ему уверенно выступать даже против более опытных соперников. В составе Heroic он получает возможность развиваться на высоком уровне, постепенно раскрывая свой потенциал на международной сцене.	https://www.hltv.org/stats/players/20119/nilo
48	susp	Тим Онгстрём	SE	SUPPORT	/static/photos/heroic/susp.png	9	t	2026-03-23 14:18:26.500525	Тим “susp” Онгстрём — support-игрок, выполняющий важную роль в структуре команды. Его задачи включают контроль карты, помощь в разменах и обеспечение стабильности в раундах. Такие игроки редко попадают в хайлайты, но именно благодаря их работе команда способна действовать слаженно и эффективно, особенно в матчах против сильных соперников на крупных турнирах.	https://www.hltv.org/stats/players/21163/susp
36	Brollan	Людвиг Бролин	SE	IGL	/static/photos/mouz/Brollan.png	6	t	2026-03-23 14:18:26.500525	Людвиг “Brollan” Бролин — опытный rifler, известный по выступлениям за Fnatic и другим тир-1 командам. Он участвовал в мейджорах и крупных турнирах, где стабильно показывал высокий уровень стрельбы. В составе MOUZ он приносит опыт и уверенность, помогая команде бороться с сильнейшими соперниками на международной сцене.	https://www.hltv.org/stats/players/13666/brollan
41	FalleN	Габриэль Толедо	BR	IGL	/static/photos/furia/FalleN.png	7	t	2026-03-23 14:18:26.500525	Габриэль “FalleN” Толедо — легенда Counter-Strike и двукратный чемпион мейджоров. Его вклад в развитие сцены огромен: он не только выигрывал крупнейшие турниры, но и сформировал стиль игры бразильских команд. В составе FURIA он приносит опыт, лидерство и стратегическое мышление.	https://www.hltv.org/stats/players/2023/fallen
52	Bymas	Ауримас Пипирас	LT	ENTRY	/static/photos/monte/Bymas.png	11	t	2026-03-23 14:18:26.500525	Ауримас “Bymas” Пипирас — игрок с опытом выступлений за FaZe Clan, где он участвовал в матчах против сильнейших команд мира. Этот опыт тир-1 сцены сформировал его как универсального rifler, способного адаптироваться к разным ролям. В Monte он приносит не только огневую мощь, но и понимание того, как играть на высоком уровне против топовых соперников.	https://www.hltv.org/stats/players/19015/bymas
53	afro	Орельен Драпье	FR	SNIPER	/static/photos/monte/afro.png	11	t	2026-03-23 14:18:26.500525	Орельен “afro” Драпье — AWP-игрок, известный своей стабильной игрой на европейской сцене. Его стиль сочетает аккуратность и уверенность, что позволяет ему регулярно приносить команде важные фраги. В составе Monte он играет ключевую роль в удержании позиций и контроле раундов, особенно в защите.	https://www.hltv.org/stats/players/19926/afro
54	Gizmy	Мартин Вражнов	BG	SUPPORT	/static/photos/monte/Gizmy.png	11	t	2026-03-23 14:18:26.500525	Мартин “Gizmy” Вражнов — молодой игрок, демонстрирующий постепенный рост и развитие на профессиональной сцене. Его участие в международных матчах помогает ему набирать опыт, а уверенная стрельба и стремление к развитию делают его перспективным элементом команды.	https://www.hltv.org/stats/players/21816/gizmy
55	AZUWU	Кристиан Янков	BG	RIFLER	/static/photos/monte/AZUWU.png	11	t	2026-03-23 14:18:26.500525	Кристиан “AZUWU” Янков — rifler, который дополняет состав Monte своей стабильной игрой и командной дисциплиной. Он выполняет важные роли в раундах, помогая удерживать баланс между агрессией и контролем. Его вклад особенно заметен в долгих матчах, где важна стабильность и минимизация ошибок.	https://www.hltv.org/stats/players/22106/azuwu
56	dem0n	Дамьян Христов	BG	ENTRY	/static/photos/fut-esports/dem0n.png	12	t	2026-03-23 14:18:26.500525	Дамьян “dem0n” Христов — rifler, выступающий на европейской сцене и постепенно закрепляющийся в профессиональной среде. Его игра характеризуется уверенностью в дуэлях и стремлением к развитию. Участие в международных квалификациях и турнирах позволяет ему набирать опыт и повышать уровень игры.	https://www.hltv.org/stats/players/20584/dem0n
58	Krabeni	Кристиан Станчев	BG	SUPPORT	/static/photos/fut-esports/Krabeni.png	12	t	2026-03-23 14:18:26.500525	Кристиан “Krabeni” Станчев — стабильный игрок состава, принимающий участие в региональных и международных турнирах. Его вклад заключается в выполнении ключевых ролей и поддержании структуры команды, что особенно важно для коллективов, находящихся в стадии развития.	https://www.hltv.org/stats/players/22203/krabeni
60	dziugss	Джюгас Степонавичюс	LT	SNIPER	/static/photos/fut-esports/dziugss.png	12	t	2026-03-23 14:18:26.500525	Джюгас “dziugss” Степонавичюс — игрок, представляющий Литву на профессиональной сцене. Он участвует в европейских турнирах и квалификациях, набирая опыт и развиваясь как игрок. Его стремление к прогрессу и участие в командной игре делают его важной частью FUT Esports.	https://www.hltv.org/stats/players/23553/dziugss
1	donk	Данил Крышковец	RU	ENTRY	/static/photos/team-spirit/donk.png	3	t	2026-03-23 14:18:26.500525	Данил “donk” Крышковец — один из самых ярких молодых талантов современной CS-сцены. Его агрессивный стиль entry-фраггера и феноменальный aim сделали его ключевым фактором доминации Team Spirit на международных турнирах. Уже в раннем возрасте он начал показывать уровень, сравнимый с топ-игроками мира, регулярно решая раунды в одиночку. Его вклад в победы команды и глубокие проходы на крупных ивентах закрепил за ним статус будущей суперзвезды сцены.	https://www.hltv.org/stats/players/21167/donk
51	Rainwaker	Любослав Панайотов	BG	IGL	/static/photos/monte/Rainwaker.png	11	t	2026-03-23 14:18:26.500525	Любослав “Rainwaker” Панайотов — опытный rifler, выступавший на мейджорах и крупных международных турнирах. Его игра отличается стабильностью и пониманием командных ролей, что делает его важным элементом состава Monte. Он способен удерживать позиции, грамотно размениваться и сохранять контроль в сложных раундах, что особенно важно на высоком уровне конкуренции.	https://www.hltv.org/stats/players/17145/rainwaker
27	BELCHONOKK	Андрей Ясинский	RU	ENTRY	/static/photos/parivision/BELCHONOKK.png	1	t	2026-03-23 14:18:26.500525	Андрей “BELCHONOKK” Ясинский — молодой rifler, который постепенно закрепляется на профессиональной сцене. Его игра строится на дисциплине и понимании командных ролей: он не стремится к хайлайтам, но стабильно выполняет задачи, необходимые для победы. Участие в матчах против более сильных соперников даёт ему опыт тир-1 уровня, а в составе PARIVISION он получает возможность расти рядом с такими игроками, как Jame. Его потенциал заметен в уверенной стрельбе и способности адаптироваться к темпу игры команды.	https://www.hltv.org/stats/players/19235/belchonokk
11	huNter-	Неманья Ковач	BA	IGL	/static/photos/g2-esports/huNter-.png	4	t	2026-03-23 14:18:26.500525	Неманья “huNter-” Ковач — один из самых стабильных rifler на тир-1 сцене. За годы в G2 он участвовал в победах на крупных турнирах и стабильно показывал высокий уровень. Его опыт и стрельба делают его ключевым игроком команды.	https://www.hltv.org/stats/players/3972/hunter
26	Jame	Джами Али	RU	IGL	/static/photos/parivision/Jame.png	1	t	2026-03-23 14:18:26.500525	Джами “Jame” Али — один из самых узнаваемых капитанов и AWP-игроков современной сцены. Его стиль — это контроль темпа, дисциплина и холодный расчёт, благодаря которым он привёл Outsiders к победе на мейджоре и закрепился в истории CS как MVP крупнейшего турнира. Jame умеет выигрывать не за счёт хаоса, а за счёт идеального понимания экономики, позиций и таймингов. В PARIVISION он остаётся центром системы: вокруг его решений строится игра команды, а его стабильность и опыт позволяют коллективу конкурировать с сильнейшими соперниками.	https://www.hltv.org/stats/players/13776/jame
31	NiKo	Никола Ковач	BA	RIFLER	/static/photos/team-falcons/NiKo.png	2	t	2026-03-23 14:18:26.500525	Никола “NiKo” Ковач — один из величайших rifler в истории Counter-Strike. За свою карьеру он выступал за топ-организации, включая FaZe и G2, выигрывал крупные турниры и неоднократно входил в топ игроков мира по версии HLTV. Его механика, aim и понимание игры сделали его эталоном для rifler-игроков. В составе Falcons он приносит не только огневую мощь, но и огромный опыт тир-1 сцены.	https://www.hltv.org/stats/players/3741/niko
34	kyxsan	Дамьян Стоилковски	MK	IGL	/static/photos/team-falcons/kyxsan.png	2	t	2026-03-23 14:18:26.500525	Дамьян “kyxsan” Стоилковски — капитан и стратег команды, отвечающий за игровую структуру и принятие решений. Несмотря на сравнительно меньший опыт на тир-1 уровне, он уже показал способность вести команду и адаптироваться к сильным соперникам. Его роль особенно важна в построении командной игры и развитии состава.	https://www.hltv.org/stats/players/19677/kyxsan
46	xfl0ud	Ясин Коч	TR	ENTRY	/static/photos/heroic/xfl0ud.png	9	t	2026-03-23 14:18:26.500525	Ясин “xfl0ud” Коч — rifler, постепенно закрепляющийся на международной сцене и набирающий опыт в матчах против сильных соперников. Его игра строится на дисциплине, понимании позиций и умении поддерживать команду в сложных ситуациях. Несмотря на относительно небольшой опыт тир-1, он уже демонстрирует уверенность в стрельбе и способность адаптироваться к высокому темпу игры, что делает его важным элементом обновлённого состава Heroic.	https://www.hltv.org/stats/players/19187/xfl0ud
49	Chr1zN	Кристоффер Сторгор	DK	IGL	/static/photos/heroic/Chr1zN.png	9	t	2026-03-23 14:18:26.500525	Кристоффер “Chr1zN” Сторгор — rifler, усиливающий огневую мощь команды и способный брать на себя инициативу в ключевых моментах. Его игра отличается агрессией и уверенностью, что помогает Heroic создавать давление на соперника. Участие в международных матчах позволяет ему набирать опыт и постепенно закрепляться на более высоком уровне.	https://www.hltv.org/stats/players/21983/chr1zn
57	lauNX	Лауренциу Цырля	RO	RIFLER	/static/photos/fut-esports/lauNX.png	12	t	2026-03-23 14:18:26.500525	Лауренциу “lauNX” Цырля — один из наиболее известных игроков состава, ранее выступавший на HLTV-турнирах и демонстрировавший высокий потенциал. Его стиль игры сочетает агрессию и хорошую механику, что делает его важным элементом команды. Он уже имеет опыт игры против сильных соперников и способен показывать высокий уровень.	https://www.hltv.org/stats/players/20761/launx
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams (id, name, short_name, slug, country_code, region, logo_url, description, is_active, created_at) FROM stdin;
5	The MongolZ	MongolZ	the-mongolz	MN	ASIA	/static/logos/the-mongolz.png	The MongolZ — это уже не “милая история из Азии”, а полноценная большая сила мирового CS. Liquipedia прямо отмечает их как первую азиатскую команду, дошедшую до №1 и в HLTV Ranking, и в Valve Ranking, а по турнирным и командным страницам ядро выглядит так: Гаридмагнай “bLitz” Бямбасурэн, Содбаяр “Techno4K” Мөнхболд, Усухбаяр “910” Банзрагч, Аюш “mzinho” Батболд и Азбаяр “Senzu” Мөнхболд. Это команда, у которой чувствуется и национальный характер, и игровая наглость: они не признают авторитетов, не боятся темпа и не сбавляют обороты просто потому, что напротив более громкое имя. The MongolZ играют как буря в степи — быстро, резко и без сантиментов. И именно поэтому они так опасны: они не про уважение к фавориту, они про удар в лицо фавориту.	t	2026-03-20 16:45:40.091392
4	G2 Esports	G2	g2-esports	DE	EU	/static/logos/g2-esports.png	G2 Esports сейчас — это уже не прежняя версия бренда, а новая глава, написанная другим почерком. По страницам EPL Season 23, IEM Kraków 2026, BLAST Rivals Spring 2026 и PGL Astana 2026 у G2 проходят Неманья “huNter-” Ковач, Марио “malbsMd” Самайоа, Никита “HeavyGod” Мартининко, Альваро “SunPayus” Гарсия и Матуш “matys” Шимко, а тренирует их Ээту “sAw” Саха. Это не команда, которая держится на одном чуде или одной суперзвезде; наоборот, тут чувствуется попытка собрать гибкий, многослойный состав, где огневая мощь сочетается с тактикой и глубиной ролей. G2 остаётся командой шоу — но уже шоу, которое старается жить не только хайлайтами, а результатом. Когда этот ростер ловит ритм, он выглядит как состав, способный обыгрывать сильнейших не вспышкой, а системным качеством.	t	2026-03-20 16:45:40.091392
8	Aurora Gaming	Aurora	aurora	RS	EU	/static/logos/aurora.png	Aurora Gaming — команда, которая выглядит как смесь грубой огневой мощи и большого турецкого характера. На Liquipedia по состоянию на март 2026 у Aurora проходят Энгин “MAJ3R” Кюпели, Эфекан “soulfly” Каракая, Али “Wicadia” Хайдар Ялчын, Озгюр “woxic” Экер и Исмаилджан “XANTARES” Дорткардеш; более ранние страницы 2025 года ещё фиксировали вариант с jottAAA, что только подчёркивает, как живо менялась эта команда. В их игре всегда чувствуется опасность, потому что XANTARES и woxic — это имена, которые могут зажечь карту буквально за пару раундов, а рядом есть структура и лидерство MAJ3R. Aurora — не про стерильный CS: это команда вспышек, силы, драйва и очень высокого потолка, если всё складывается. Когда их ритм совпадает с картой, соперник внезапно обнаруживает, что уже не играет в свой матч — он просто пытается пережить чужой шторм.	t	2026-03-20 16:45:40.091392
10	Gentle Mates	M8	gentle-mates	FR	EU	/static/logos/gentle-mates.png	Gentle Mates — это не просто французский бренд, а очень любопытная и уже вполне серьёзная испаноязычная сила. Liquipedia фиксирует, что организация вошла в CS2 в августе 2025 года, подписав состав Iberian Soul, а к марту 2026 в ростере проходят Алехандро “alex” Масанет Кандела, Алехандро “mopoz” Фернандес-Кехо Кано, Пере “sausol” Солсона Саумель, Давид “dav1g” Грано Флоренса и Антонио “Martinez” Мартинес Санчес. И это уже не просто команда с красивым именем: в феврале 2026 Gentle Mates выиграли IstanbuLAN 2026, а в матчевой статистике Liquipedia у них на отрезке до конца февраля значится 37 побед при 21 поражении. Это ростер, в котором есть и опыт alex, и драйв mopoz, и плотная иберийская связка по ролям. Gentle Mates выглядят как команда, которая пришла не для того, чтобы быть симпатичным новым участником, а чтобы реально кусать сцену за место повыше.	t	2026-03-20 16:45:40.091392
1	PARIVISION	PARI	parivision	RU	CIS	/static/logos/parivision.png	PARIVISION — это команда, которая больше не выглядит как сюрприз недели: это уже серьёзная сила верхнего эшелона, и цифры это подтверждают. На 9 марта 2026 года они шли в глобальном VRS на 4-м месте, а на Liquipedia прямо отмечен их триумф на BLAST Bounty Winter 2026. Вокруг Жами “Jame” Али — IGL и AWP в одном лице — собран очень цельный состав: BELCHONOKK, nota, xiELO и юный zweih, а за кулисами всем этим дирижирует Дастан “dastan” Акбаев. Это ростер, где нет лишнего шума: холодный темп Jame, жёсткая дисциплина и ощущение, что каждая ошибка соперника будет наказана сразу. PARIVISION сейчас — не команда-однодневка, а один из самых опасных проектов СНГ-сцены, и если они заходят в плей-офф, это уже не история про апсет, а история про реальную заявку на титул.	t	2026-03-20 16:45:40.091392
2	Team Falcons	Falcons	team-falcons	SA	MENA	/static/logos/team-falcons.png	Team Falcons — это состав, в котором звёздность больше не рекламный слоган, а факт турнирной жизни. На Liquipedia по BLAST Bounty Winter 2026 и VRS марта 2026 у Falcons проходят Никола “NiKo” Ковач, Илья “m0NESY” Осипов, Рене “TeSeS” Мадсен, Дамьян “kyxsan” Стоилковски и Максим “kyousuke” Лукин; отдельно страница kyousuke уже указывает его как игрока Falcons. Это сочетание элитного опыта и молодой дерзости делает команду особенно страшной: NiKo и m0NESY дают класс мирового уровня, а kyousuke добавляет тот самый заряд, который делает ростер не просто сильным, а живым, острым и голодным до больших побед. Falcons играют с вайбом команды, которая не собирается довольствоваться полуфиналами: у них слишком много огня, слишком много качества и слишком высокий потолок, чтобы не метить в самую вершину. Если этот состав окончательно склеится как единое целое, сцена получит не просто фаворита турниров, а настоящую машину давления.Team Falcons — это состав, в котором звёздность больше не рекламный слоган, а факт турнирной жизни. На Liquipedia по BLAST Bounty Winter 2026 и VRS марта 2026 у Falcons проходят Никола “NiKo” Ковач, Илья “m0NESY” Осипов, Рене “TeSeS” Мадсен, Дамьян “kyxsan” Стоилковски и Максим “kyousuke” Лукин; отдельно страница kyousuke уже указывает его как игрока Falcons. Это сочетание элитного опыта и молодой дерзости делает команду особенно страшной: NiKo и m0NESY дают класс мирового уровня, а kyousuke добавляет тот самый заряд, который делает ростер не просто сильным, а живым, острым и голодным до больших побед. Falcons играют с вайбом команды, которая не собирается довольствоваться полуфиналами: у них слишком много огня, слишком много качества и слишком высокий потолок, чтобы не метить в самую вершину. Если этот состав окончательно склеится как единое целое, сцена получит не просто фаворита турниров, а настоящую машину давления.	t	2026-03-20 16:45:40.091392
6	MOUZ	MOUZ	mouz	DE	EU	/static/logos/mouz.png	MOUZ — это команда, в которой современный тактический CS2 выглядит почти эталонно. По PGL Astana 2026, BLAST Open Fall 2025, EPL Season 22 и BLAST Open Spring 2026 у них проходит очень мощное ядро: Адам “torzsi” Торжаш, Дориан “xertioN” Берман, Йими “Jimpphat” Сало, Людвиг “Brollan” Бролин и Лотан “Spinx” Гилади, а тренирует их Торбьёрн “sycrone” Нильсен. На 9 марта 2026 MOUZ стояли вторыми в VRS, и это идеально отражает их статус: это не команда хаоса, а команда продуманного давления и качественного mid-round. У них нет необходимости выигрывать только через ярость или флик — они умеют разбирать соперника шаг за шагом, раунд за раундом, до полного удушья. MOUZ сейчас — это не просто топ-состав, а интеллектуальный хищник сцены: холодный, выверенный и смертельно опасный на длинной дистанции.	t	2026-03-20 16:45:40.091392
7	FURIA Esports	FURIA	furia	BR	SA	/static/logos/furia.png	FURIA — это команда, где бразильская ярость получила новую, ещё более злую форму. По BLAST Frequent Flyers 2026, PGL Astana 2026, IEM Kraków 2026 и BLAST Rivals Spring 2026 у них подтверждается состав из Юрия “yuurih” Бойана, Кайке “KSCERATO” Керато, Габриэля “FalleN” Толедо, Данила “molodoy” Голубенко и Марекса “YEKINDAR” Галинскиса. На 9 марта 2026 FURIA шла третьей в VRS, и это уже не романтика, а весомый аргумент. Главная интрига этой версии FURIA — как опыт KSCERATO и FalleN сочетается с безумной энергией molodoy и агрессией YEKINDAR: в результате получается состав, который может и душить, и взрываться, и разваливать раунды серией индивидуальных решений. FURIA по-прежнему играет с элементом хаоса, но теперь это хаос не без руля — это хаос с мотором, картой и конкретной целью: вернуться в элиту не на имени, а на силе.	t	2026-03-20 16:45:40.091392
9	Heroic	Heroic	heroic	DK	EU	/static/logos/heroic.png	HEROIC сейчас — это история перестройки, но перестройки амбициозной, а не скромной. По VRS от 2 марта 2026 у команды проходят Каспер “Chr1zN” Сёренсен, Линус “nilo” Бергман, Линус “susp” Йоханссон, Дениз “xfl0ud” Коч и Кристофер “yxngstxr” Йонсен, а более ранние турнирные страницы 2025 года фиксировали и предыдущие варианты ростера. Это уже не тот HEROIC, который жил славой старой эпохи, — это новая версия клуба, которая заново пытается собрать идентичность через молодость, дисциплину и европейскую жёсткость. У них пока нет ауры команды, которая просто заходит и душит всех именем, но есть другое: желание вернуться наверх через тяжёлую работу и чёткую систему. HEROIC опасен именно этим — когда такой клуб собирает новый позвоночник, его недооценка часто становится первой большой ошибкой соперника.	t	2026-03-20 16:45:40.091392
11	Monte	Monte	monte	UA	EU	/static/logos/monte.png	Monte — это команда, которая живёт не пафосом бренда, а честной боевой вязкостью. По BC.Game Masters Championship, EPL Season 23 Online Stage и ряду турниров европейской сцены в составе Monte на начало 2026 года проходят Кирон “Gizmy” Джеймс, Орельен “afro” Драпье, Адам “AZUWU” Уэллс, Ауримас “Bymas” Пипирас и Кристиян “Rainwaker” Петков, а тренирует их Райнхард “kakafu” Прайзер. Это очень рабочий, колючий состав: здесь нет ощущения глянца, зато есть ощущение команды, которая умеет страдать, выживать и отвечать ударом на удар. Monte не обязательно будет самой яркой страницей турнира — но это почти всегда страница, где фавориту становится неудобно. И иногда этого уже достаточно, чтобы перевернуть сетку и сорвать чужую красивую историю.	t	2026-03-20 16:45:40.091392
12	FUT Esports	FUT	fut-esports	TR	EU	/static/logos/fut-esports.png	FUT Esports — это уже не просто турецкий тег с амбициями, а европейский микс, который всё заметнее цепляется за большие турниры. По Liquipedia на рубеже февраля–марта 2026 у FUT проходят Никита “dem0n” Панченко, Флатрон “Krabeni” Халими, Микита “cmtry” Самолотов, Густавас “dziugss” Степонавичюс и Лауренциу “lauNX” Цырля, а страницы PGL Bucharest 2026, PGL Astana 2026 и BLAST Rivals Spring 2026 подтверждают их присутствие в актуальном турнирном пуле. У команды в матчевой статистике на отрезке до марта 2026 значится 51 победа при 33 поражениях, и это уже показатель живого, зубастого ростера, а не случайного состава из квалификаций. FUT сейчас выглядит как команда, которая пока не получила статус монстра, но уже умеет ломать ожидания: у них есть молодой огонь, есть IGL в лице Krabeni, есть AWP-потенциал cmtry и хватает энергии, чтобы навязать драку даже тем, кто на бумаге сильнее. Это не проект “на потом” — это проект, который уже стучится в дверь тир-1.	t	2026-03-20 16:45:40.091392
3	Team Spirit	Spirit	team-spirit	RU	CIS	/static/logos/team-spirit.png	Team Spirit — одна из сильнейших организаций современной CS-сцены, представляющая регион СНГ. Команда получила мировое признание благодаря сочетанию дисциплины, тактической глубины и яркого индивидуального мастерства игроков. С обновлением состава Spirit не просто закрепились на тир-1 уровне, но и начали уверенно конкурировать с топ-командами мира.\n\nГлавная сила коллектива — баланс между агрессией и контролем. Игроки вроде donk и sh1ro формируют мощное ядро: один создаёт давление и ломает оборону соперников, другой обеспечивает стабильность и точность в ключевых раундах. В сочетании с выстроенной командной игрой это делает Spirit крайне неудобным оппонентом на любой карте.\n\nЗа последние годы организация добилась серьёзных успехов на международной арене, регулярно доходя до поздних стадий крупных турниров и закрепляясь среди лучших команд мира. Их результаты — это не случайность, а итог системной работы и постоянного развития состава.\n\nНа PGL Astana 2026 Team Spirit рассматриваются как один из главных претендентов на титул. Их текущая форма и уровень игры позволяют рассчитывать на глубокий проход и борьбу за чемпионство.	t	2026-03-20 16:45:40.091392
\.


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.matches_id_seq', 5, true);


--
-- Name: matches_maps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.matches_maps_id_seq', 11, true);


--
-- Name: player_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_stats_id_seq', 90, true);


--
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.players_id_seq', 60, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teams_id_seq', 12, true);


--
-- Name: matches_maps matches_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches_maps
    ADD CONSTRAINT matches_maps_pkey PRIMARY KEY (id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: player_stats player_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_stats
    ADD CONSTRAINT player_stats_pkey PRIMARY KEY (id);


--
-- Name: players players_nickname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_nickname_key UNIQUE (nickname);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: teams teams_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_slug_key UNIQUE (slug);


--
-- Name: matches_maps matches_maps_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches_maps
    ADD CONSTRAINT matches_maps_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id) ON DELETE CASCADE;


--
-- Name: matches_maps matches_maps_picked_by_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches_maps
    ADD CONSTRAINT matches_maps_picked_by_team_id_fkey FOREIGN KEY (picked_by_team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: matches_maps matches_maps_winner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches_maps
    ADD CONSTRAINT matches_maps_winner_id_fkey FOREIGN KEY (winner_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: matches matches_team1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_team1_id_fkey FOREIGN KEY (team1_id) REFERENCES public.teams(id);


--
-- Name: matches matches_team2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_team2_id_fkey FOREIGN KEY (team2_id) REFERENCES public.teams(id);


--
-- Name: matches matches_winner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_winner_id_fkey FOREIGN KEY (winner_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: player_stats player_stats_match_map_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_stats
    ADD CONSTRAINT player_stats_match_map_id_fkey FOREIGN KEY (match_map_id) REFERENCES public.matches_maps(id) ON DELETE CASCADE;


--
-- Name: player_stats player_stats_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_stats
    ADD CONSTRAINT player_stats_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: players players_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict eTHZEYgX3DhCinCcYOag9b7YFLbMOUl3WwYGaDgrGKqyMEMaBNRSacFZmCFF6ot

