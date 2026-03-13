--
-- PostgreSQL database dump
--

\restrict jQ0psSXzL20xLYVesJJqRWDEo6Rnx4n1xGUjmE9fVFrAS97KIiUrcNcOQX4W5PY

-- Dumped from database version 15.16 (Debian 15.16-0+deb12u1)
-- Dumped by pg_dump version 15.16 (Debian 15.16-0+deb12u1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id bigint NOT NULL,
    name text NOT NULL,
    key_prefix text NOT NULL,
    key_hash text NOT NULL,
    scopes jsonb DEFAULT '[]'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    expires_at timestamp with time zone,
    last_used_at timestamp with time zone,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_keys_id_seq OWNED BY public.api_keys.id;


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_settings (
    key text NOT NULL,
    value text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: backup_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.backup_files (
    id bigint NOT NULL,
    file_name text NOT NULL,
    file_path text NOT NULL,
    folder_path text NOT NULL,
    size_bytes bigint DEFAULT 0 NOT NULL,
    backup_timestamp timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: backup_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.backup_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: backup_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.backup_files_id_seq OWNED BY public.backup_files.id;


--
-- Name: equipment_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipment_documents (
    id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    original_name text NOT NULL,
    stored_name text NOT NULL,
    relative_path text NOT NULL,
    external_url text NOT NULL,
    mime_type text NOT NULL,
    size_bytes bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: equipment_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.equipment_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.equipment_documents_id_seq OWNED BY public.equipment_documents.id;


--
-- Name: equipment_enabled_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipment_enabled_fields (
    id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    field_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: equipment_enabled_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.equipment_enabled_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_enabled_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.equipment_enabled_fields_id_seq OWNED BY public.equipment_enabled_fields.id;


--
-- Name: equipment_field_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipment_field_values (
    id bigint NOT NULL,
    equipment_id bigint NOT NULL,
    field_id bigint NOT NULL,
    value jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: equipment_field_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.equipment_field_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_field_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.equipment_field_values_id_seq OWNED BY public.equipment_field_values.id;


--
-- Name: equipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipments (
    id bigint NOT NULL,
    token text NOT NULL,
    purchaser text DEFAULT ''::text NOT NULL,
    purchaser_contact text DEFAULT ''::text NOT NULL,
    contact_email text DEFAULT ''::text NOT NULL,
    contact_phone text DEFAULT ''::text NOT NULL,
    project_name text DEFAULT ''::text NOT NULL,
    site_name text DEFAULT ''::text NOT NULL,
    address text DEFAULT ''::text NOT NULL,
    profile_id bigint,
    status text DEFAULT 'draft'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: equipments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.equipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.equipments_id_seq OWNED BY public.equipments.id;


--
-- Name: field_profile_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_profile_fields (
    id bigint NOT NULL,
    profile_id bigint NOT NULL,
    field_id bigint NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    label text,
    section text,
    field_type text,
    unit text,
    enum_options jsonb,
    has_default boolean,
    default_value jsonb,
    display_order integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_required boolean DEFAULT false NOT NULL
);


--
-- Name: field_profile_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.field_profile_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: field_profile_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.field_profile_fields_id_seq OWNED BY public.field_profile_fields.id;


--
-- Name: field_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_profiles (
    id bigint NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: field_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.field_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: field_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.field_profiles_id_seq OWNED BY public.field_profiles.id;


--
-- Name: fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fields (
    id bigint NOT NULL,
    key text NOT NULL,
    label text NOT NULL,
    section text NOT NULL,
    field_type text NOT NULL,
    unit text,
    enum_options jsonb,
    has_default boolean DEFAULT false NOT NULL,
    default_value jsonb,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fields_id_seq OWNED BY public.fields.id;


--
-- Name: token_creation_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_creation_audit (
    id bigint NOT NULL,
    equipment_id bigint,
    channel text DEFAULT 'admin'::text NOT NULL,
    ip_hash text,
    browser_session_hash text,
    user_agent_hash text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: token_creation_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.token_creation_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: token_creation_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.token_creation_audit_id_seq OWNED BY public.token_creation_audit.id;


--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);


--
-- Name: backup_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backup_files ALTER COLUMN id SET DEFAULT nextval('public.backup_files_id_seq'::regclass);


--
-- Name: equipment_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_documents ALTER COLUMN id SET DEFAULT nextval('public.equipment_documents_id_seq'::regclass);


--
-- Name: equipment_enabled_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_enabled_fields ALTER COLUMN id SET DEFAULT nextval('public.equipment_enabled_fields_id_seq'::regclass);


--
-- Name: equipment_field_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_field_values ALTER COLUMN id SET DEFAULT nextval('public.equipment_field_values_id_seq'::regclass);


--
-- Name: equipments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipments ALTER COLUMN id SET DEFAULT nextval('public.equipments_id_seq'::regclass);


--
-- Name: field_profile_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_profile_fields ALTER COLUMN id SET DEFAULT nextval('public.field_profile_fields_id_seq'::regclass);


--
-- Name: field_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_profiles ALTER COLUMN id SET DEFAULT nextval('public.field_profiles_id_seq'::regclass);


--
-- Name: fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields ALTER COLUMN id SET DEFAULT nextval('public.fields_id_seq'::regclass);


--
-- Name: token_creation_audit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_creation_audit ALTER COLUMN id SET DEFAULT nextval('public.token_creation_audit_id_seq'::regclass);


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.api_keys (id, name, key_prefix, key_hash, scopes, is_active, expires_at, last_used_at, revoked_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_settings (key, value, updated_at) FROM stdin;
public_token_access_enabled	true	2026-03-12 17:10:45.332575+00
\.


--
-- Data for Name: equipment_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment_documents (id, equipment_id, original_name, stored_name, relative_path, external_url, mime_type, size_bytes, created_at) FROM stdin;
1	2	alarm gas.pdf	da86a90f1fcd4a3f915ec995e626eebc_alarm_gas_1773408087046.pdf	/dados/docs/da86a90f1fcd4a3f915ec995e626eebc_alarm_gas_1773408087046.pdf	https://100.54.0.109/dados/docs/da86a90f1fcd4a3f915ec995e626eebc_alarm_gas_1773408087046.pdf	application/pdf	116819	2026-03-13 13:21:27.051527+00
\.


--
-- Data for Name: equipment_enabled_fields; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment_enabled_fields (id, equipment_id, field_id, created_at) FROM stdin;
93	2	95	2026-03-13 13:20:02.284642+00
94	2	96	2026-03-13 13:20:02.284642+00
95	2	97	2026-03-13 13:20:02.284642+00
96	2	98	2026-03-13 13:20:02.284642+00
97	2	99	2026-03-13 13:20:02.284642+00
98	2	100	2026-03-13 13:20:02.284642+00
99	2	101	2026-03-13 13:20:02.284642+00
100	2	102	2026-03-13 13:20:02.284642+00
101	2	103	2026-03-13 13:20:02.284642+00
102	2	104	2026-03-13 13:20:02.284642+00
103	2	105	2026-03-13 13:20:02.284642+00
104	2	106	2026-03-13 13:20:02.284642+00
105	2	107	2026-03-13 13:20:02.284642+00
106	2	108	2026-03-13 13:20:02.284642+00
107	2	109	2026-03-13 13:20:02.284642+00
108	2	110	2026-03-13 13:20:02.284642+00
109	2	111	2026-03-13 13:20:02.284642+00
110	2	112	2026-03-13 13:20:02.284642+00
111	2	113	2026-03-13 13:20:02.284642+00
112	2	114	2026-03-13 13:20:02.284642+00
113	2	115	2026-03-13 13:20:02.284642+00
114	2	116	2026-03-13 13:20:02.284642+00
115	2	117	2026-03-13 13:20:02.284642+00
116	2	118	2026-03-13 13:20:02.284642+00
117	2	119	2026-03-13 13:20:02.284642+00
118	2	120	2026-03-13 13:20:02.284642+00
119	2	121	2026-03-13 13:20:02.284642+00
120	2	122	2026-03-13 13:20:02.284642+00
121	2	123	2026-03-13 13:20:02.284642+00
122	2	124	2026-03-13 13:20:02.284642+00
123	2	125	2026-03-13 13:20:02.284642+00
124	2	126	2026-03-13 13:20:02.284642+00
125	2	127	2026-03-13 13:20:02.284642+00
126	2	128	2026-03-13 13:20:02.284642+00
127	2	129	2026-03-13 13:20:02.284642+00
128	2	130	2026-03-13 13:20:02.284642+00
129	2	131	2026-03-13 13:20:02.284642+00
130	2	132	2026-03-13 13:20:02.284642+00
131	2	133	2026-03-13 13:20:02.284642+00
132	2	134	2026-03-13 13:20:02.284642+00
133	2	135	2026-03-13 13:20:02.284642+00
134	2	136	2026-03-13 13:20:02.284642+00
135	2	137	2026-03-13 13:20:02.284642+00
136	2	138	2026-03-13 13:20:02.284642+00
137	2	139	2026-03-13 13:20:02.284642+00
138	2	140	2026-03-13 13:20:02.284642+00
139	2	141	2026-03-13 13:20:02.284642+00
141	3	272	2026-03-13 14:13:00.772799+00
\.


--
-- Data for Name: equipment_field_values; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment_field_values (id, equipment_id, field_id, value, created_at, updated_at) FROM stdin;
1	2	95	100	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
2	2	96	80	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
3	2	97	0.8	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
4	2	98	"IT"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
5	2	99	78	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
6	2	100	"IP21"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
7	2	101	70	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
8	2	102	1000	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
9	2	103	95	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
10	2	104	2	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
11	2	105	40	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
12	2	106	"PD2"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
13	2	108	"3PhN"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
14	2	110	true	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
15	2	112	false	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
16	2	113	5	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
17	2	114	false	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
18	2	115	10	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
19	2	116	2	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
20	2	117	220	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
21	2	118	"3PhN"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
22	2	120	true	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
23	2	121	false	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
24	2	122	false	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
25	2	123	10	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
26	2	124	2	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
27	2	125	true	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
28	2	127	"3PhN"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
29	2	129	true	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
30	2	130	true	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
31	2	131	1	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
32	2	132	0.8	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
33	2	134	"VRLA"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
34	2	135	"2h"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
35	2	136	"5anos"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
36	2	138	0.82	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
37	2	139	"VFI SS 111"	2026-03-13 13:20:49.659628+00	2026-03-13 13:21:26.202099+00
\.


--
-- Data for Name: equipments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipments (id, token, purchaser, purchaser_contact, contact_email, contact_phone, project_name, site_name, address, profile_id, status, created_at, updated_at) FROM stdin;
2	da86a90f1fcd4a3f915ec995e626eebc	PETROBRAS	FERNANDO	vitor.j.suares@gmail.com	+246 21989604747	PRT-01	EDISA	FAKDFADSFJDKLF	1	draft	2026-03-13 13:20:02.284642+00	2026-03-13 13:21:26.202099+00
3	022d4b536dad40d290de60a26d8cc883	FULAO DE TAL	VITOR	vitor.j.suares@gmail.com	+246 21989604747	ZZX	SSS	XXXX	4	draft	2026-03-13 13:27:01.82113+00	2026-03-13 14:13:00.772799+00
\.


--
-- Data for Name: field_profile_fields; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.field_profile_fields (id, profile_id, field_id, is_enabled, label, section, field_type, unit, enum_options, has_default, default_value, display_order, created_at, is_required) FROM stdin;
1	1	95	t	Potencia nominal requerida (kVA)	Dados Gerais	number	kVA	[]	f	\N	1	2026-03-12 16:35:47.71371+00	f
2	1	96	t	Potencia nominal requerida Power (kW)	Dados Gerais	number	kW	[]	f	\N	2	2026-03-12 16:35:47.720495+00	f
3	1	97	t	Fator de potencia requerida	Dados Gerais	number	fP	[]	t	0.8	3	2026-03-12 16:35:47.72538+00	f
4	1	98	t	Topologia aterramento	Dados Gerais	enum	\N	["TT", "TN", "IT"]	f	\N	4	2026-03-12 16:35:47.730645+00	f
5	1	99	t	Ruido audivel maximo	Dados Gerais	number	dBA	[]	t	78	5	2026-03-12 16:35:47.735725+00	f
6	1	100	t	Grau de protecao	Dados Gerais	text	\N	[]	t	"IP21"	6	2026-03-12 16:35:47.74014+00	f
7	1	101	t	Pressao do ar ambiente minima permitida	Dados Gerais	number	Kpa	[]	t	70	7	2026-03-12 16:35:47.745322+00	f
8	1	102	t	Elevacao maxima	Condicoes ambientais	number	metros	[]	t	1000	1	2026-03-12 16:35:47.750546+00	f
9	1	103	t	Umidade relativa	Condicoes ambientais	number	%	[]	t	95	2	2026-03-12 16:35:47.755415+00	f
10	1	104	t	H2S e concentracao salina	Condicoes ambientais	number	ppm	[]	t	2	3	2026-03-12 16:35:47.761408+00	f
11	1	105	t	Temperatura maxima de operacao	Condicoes ambientais	number	Celso	[]	t	40	4	2026-03-12 16:35:47.765973+00	f
12	1	106	t	Grau de poluicao	Condicoes ambientais	text	\N	[]	t	"PD2"	5	2026-03-12 16:35:47.770419+00	f
13	1	107	t	Tensao nominal	AC Entrada Retificador (Secao 1)	number	Volts	[]	f	\N	1	2026-03-12 16:35:47.775165+00	f
14	1	108	t	Numero de fase	AC Entrada Retificador (Secao 1)	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	2	2026-03-12 16:35:47.780411+00	f
15	1	109	t	Frequencia nominal	AC Entrada Retificador (Secao 1)	number	Hz	[]	f	\N	3	2026-03-12 16:35:47.785249+00	f
16	1	110	t	Transformador Isolador	AC Entrada Retificador (Secao 1)	boolean	\N	[]	t	true	4	2026-03-12 16:35:47.78946+00	f
17	1	111	t	Tipo retificador	AC Entrada Retificador (Secao 1)	enum	\N	["6 Pulso", "12 Pulso", "PFC"]	f	\N	5	2026-03-12 16:35:47.794635+00	f
18	1	112	t	Disjuntor entrada	AC Entrada Retificador (Secao 1)	boolean	\N	[]	t	false	6	2026-03-12 16:35:47.800525+00	f
19	1	113	t	Maximo harmonico de entrada	AC Entrada Retificador (Secao 1)	number	%	[]	t	5	7	2026-03-12 16:35:47.804951+00	f
20	1	114	t	Filtro de harmonico de entrada	AC Entrada Retificador (Secao 1)	boolean	\N	[]	t	false	8	2026-03-12 16:35:47.808914+00	f
21	1	115	t	Faixa de tolerancia de tensao de entrada (+%, -%)	AC Entrada Retificador (Secao 1)	number	%	[]	t	10	9	2026-03-12 16:35:47.813436+00	f
22	1	116	t	Faixa de tolerancia de frequencia de entrada (+%, -%)	AC Entrada Retificador (Secao 1)	number	%	[]	t	2	10	2026-03-12 16:35:47.818118+00	f
23	1	117	t	Tensao nominal	AC by-pass (Secao 2)	number	Volts	[]	f	\N	1	2026-03-12 16:35:47.822883+00	f
24	1	118	t	Numero de fase	AC by-pass (Secao 2)	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	2	2026-03-12 16:35:47.827051+00	f
25	1	119	t	Frequencia nominal	AC by-pass (Secao 2)	number	Hz	[]	f	\N	3	2026-03-12 16:35:47.830828+00	f
26	1	120	t	Transformador Isolador	AC by-pass (Secao 2)	boolean	\N	[]	t	true	4	2026-03-12 16:35:47.834683+00	f
27	1	121	t	Disjuntor de entrada	AC by-pass (Secao 2)	boolean	\N	[]	t	false	5	2026-03-12 16:35:47.838706+00	f
28	1	122	t	Regulador de voltagem	AC by-pass (Secao 2)	boolean	\N	[]	t	false	6	2026-03-12 16:35:47.844199+00	f
29	1	123	t	Faixa de tolerancia de tensao de entrada (+%, -%)	AC by-pass (Secao 2)	number	%	[]	t	10	7	2026-03-12 16:35:47.848164+00	f
30	1	124	t	Faixa de tolerancia de frequencia de entrada (+%, -%)	AC by-pass (Secao 2)	number	%	[]	t	2	8	2026-03-12 16:35:47.851881+00	f
31	1	125	t	Bypass mecanico requerido	AC by-pass (Secao 2)	boolean	\N	[]	t	true	9	2026-03-12 16:35:47.855832+00	f
32	1	126	t	Tensao nominal	Saida AC (Secao 3)	number	volts	[]	f	\N	1	2026-03-12 16:35:47.859519+00	f
33	1	127	t	Numero de fases	Saida AC (Secao 3)	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	2	2026-03-12 16:35:47.863527+00	f
34	1	128	t	Frequencia nominal	Saida AC (Secao 3)	number	Hz	[]	f	\N	3	2026-03-12 16:35:47.867669+00	f
35	1	129	t	Transformador isolador	Saida AC (Secao 3)	boolean	\N	[]	t	true	4	2026-03-12 16:35:47.871907+00	f
36	1	130	t	Chave de isolamento saida	Saida AC (Secao 3)	boolean	\N	[]	t	true	5	2026-03-12 16:35:47.875716+00	f
37	1	131	t	Tolerancia de tensao de saida full load	Saida AC (Secao 3)	number	%	[]	t	1	6	2026-03-12 16:35:47.879373+00	f
38	1	132	t	Fator de potencia de saida	Saida AC (Secao 3)	number	\N	[]	t	0.8	7	2026-03-12 16:35:47.88309+00	f
39	1	133	t	Desequilibrio de tensao resultante de 100 % de razao de desequilibrio de carga	Saida AC (Secao 3)	number	%	[]	f	\N	8	2026-03-12 16:35:47.887162+00	f
40	1	134	t	Tipo de Bateria	Store energy (bateria) (Secao 4)	enum	\N	["VRLA", "NiCad", "Vent", "SMC"]	t	"VRLA"	1	2026-03-12 16:35:47.890995+00	f
41	1	135	t	Autonomia esperada	Store energy (bateria) (Secao 4)	text	\N	[]	t	"2h"	2	2026-03-12 16:35:47.894719+00	f
42	1	136	t	Designer de vida	Store energy (bateria) (Secao 4)	text	\N	[]	t	"5anos"	3	2026-03-12 16:35:47.901256+00	f
43	1	137	t	Fabricante desejado	Store energy (bateria) (Secao 4)	text	\N	[]	f	\N	4	2026-03-12 16:35:47.909484+00	f
44	1	138	t	Eficiencia AC/AC minima	Desempenho e topologia	number	\N	[]	t	0.82	1	2026-03-12 16:35:47.91388+00	f
45	1	139	t	Classe de desempenho	Desempenho e topologia	text	\N	[]	t	"VFI SS 111"	2	2026-03-12 16:35:47.918356+00	f
46	1	140	t	Configuracao	Desempenho e topologia	enum	\N	["Single", "Parallel", "Redundant", "Dual bus", "Bypass"]	f	\N	3	2026-03-12 16:35:47.923182+00	f
47	1	141	t	Topologia	Desempenho e topologia	enum	\N	["Double Conversion", "Line-interactive", "Standby"]	f	\N	4	2026-03-12 16:35:47.928387+00	f
83	2	236	t	Unidade de negócio	Localização	text	\N	[]	f	\N	1	2026-03-12 21:17:31.478442+00	f
84	2	237	t	Área operacional	Localização	text	\N	[]	f	\N	2	2026-03-12 21:17:31.478442+00	f
85	2	238	t	Local de instalação do equipamento	Localização	text	\N	[]	f	\N	3	2026-03-12 21:17:31.478442+00	f
86	2	239	t	Elevação (acima do nível do mar)	Altitude	number	m	[]	f	\N	4	2026-03-12 21:17:31.478442+00	f
87	2	240	t	Precipitação pluviométrica (média anual / mensal máx.)	Condições climáticas	text	\N	[]	f	\N	5	2026-03-12 21:17:31.478442+00	f
88	2	241	t	Temperatura ambiente (variação mín.~ máx. / média)	Condições climáticas	text	°C	[]	f	\N	6	2026-03-12 21:17:31.478442+00	f
89	2	242	t	Umidade relativa do ar (variação mín.~ máx.)	Condições climáticas	text	%	[]	f	\N	7	2026-03-12 21:17:31.478442+00	f
90	2	243	t	Identificação	Geral	text	\N	[]	f	\N	8	2026-03-12 21:17:31.478442+00	f
91	2	244	t	Quantidade	Geral	number	\N	[]	f	\N	9	2026-03-12 21:17:31.478442+00	f
92	2	245	t	Fabricante	Geral	text	\N	[]	f	\N	10	2026-03-12 21:17:31.478442+00	f
93	2	246	t	Modelo	Geral	text	\N	[]	f	\N	11	2026-03-12 21:17:31.478442+00	f
94	2	247	t	Classificação da área (classificada / não classificada)	Características específicas da instalação	enum	\N	["classificada", "não classificada"]	f	\N	12	2026-03-12 21:17:31.478442+00	f
95	2	248	t	Tipo de instalação abrigada / não abrigada	Características específicas da instalação	enum	\N	["abrigada", "não abrigada"]	f	\N	13	2026-03-12 21:17:31.478442+00	f
96	2	249	t	Regime de trabalho	Características específicas da instalação	text	\N	[]	f	\N	14	2026-03-12 21:17:31.478442+00	f
97	2	250	t	Tipo	Nobreak	text	\N	[]	f	\N	15	2026-03-12 21:17:31.478442+00	f
98	2	251	t	Configuração	Nobreak	text	\N	[]	f	\N	16	2026-03-12 21:17:31.478442+00	f
99	2	252	t	Gabinete	Dados Construtivos	text	\N	[]	f	\N	17	2026-03-12 21:17:31.478442+00	f
100	2	253	t	Classificação do Invólucro	Dados Construtivos	text	\N	[]	f	\N	18	2026-03-12 21:17:31.478442+00	f
101	2	254	t	Montagem	Dados Construtivos	text	\N	[]	f	\N	19	2026-03-12 21:17:31.478442+00	f
102	2	255	t	Pintura	Dados Construtivos	text	\N	[]	f	\N	20	2026-03-12 21:17:31.478442+00	f
103	2	256	t	Acesso	Dados Construtivos	text	\N	[]	f	\N	21	2026-03-12 21:17:31.478442+00	f
104	2	257	t	Entrada/Saída de Cabos	Dados Construtivos	text	\N	[]	f	\N	22	2026-03-12 21:17:31.478442+00	f
105	2	258	t	Movimentação	Dados Construtivos	text	\N	[]	f	\N	23	2026-03-12 21:17:31.478442+00	f
106	2	259	t	Dimensões - Nobreak (A X L X P)	Dados Construtivos	text	mm	[]	f	\N	24	2026-03-12 21:17:31.478442+00	f
107	2	260	t	Dimensões - Banco de Baterias (A X L X P)	Dados Construtivos	text	mm	[]	f	\N	25	2026-03-12 21:17:31.478442+00	f
108	2	261	t	Peso Total	Dados Construtivos	number	kg	[]	f	\N	26	2026-03-12 21:17:31.478442+00	f
109	2	262	t	Tensão	Parâmetros De Entrada	text	V	[]	f	\N	27	2026-03-12 21:17:31.478442+00	f
110	2	263	t	Frequência	Parâmetros De Entrada	text	Hz	[]	f	\N	28	2026-03-12 21:17:31.478442+00	f
111	2	264	t	Corrente	Parâmetros De Entrada	text	A	[]	f	\N	29	2026-03-12 21:17:31.478442+00	f
112	2	265	t	Distorção Harmônica de Corrente	Parâmetros De Entrada	text	%	[]	f	\N	30	2026-03-12 21:17:31.478442+00	f
113	2	266	t	Fator de Potência	Parâmetros De Entrada	text	\N	[]	f	\N	31	2026-03-12 21:17:31.478442+00	f
114	2	267	t	Tipo de Retificador	Parâmetros De Entrada	text	\N	[]	f	\N	32	2026-03-12 21:17:31.478442+00	f
115	2	268	t	Módulo de Adequação de Tensão	Parâmetros De Entrada	text	\N	[]	f	\N	33	2026-03-12 21:17:31.478442+00	f
116	2	269	t	Conexão de Entrada	Parâmetros De Entrada	text	\N	[]	f	\N	34	2026-03-12 21:17:31.478442+00	f
117	2	270	t	Potência	Parâmetros De Saída	text	kW	[]	f	\N	35	2026-03-12 21:17:31.478442+00	f
120	4	272	t	Novo campo	General	text	\N	\N	f	\N	1	2026-03-13 13:26:03.134156+00	f
\.


--
-- Data for Name: field_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.field_profiles (id, name, created_at, updated_at) FROM stdin;
1	PADRÃO CHLORIDE	2026-03-12 16:35:47.702498+00	2026-03-12 16:35:47.702498+00
2	Perfil de Formulário Nobreak	2026-03-12 21:17:31.269957+00	2026-03-12 21:17:31.478442+00
4	TOMADA MARCH	2026-03-13 13:25:21.800082+00	2026-03-13 13:26:03.134156+00
\.


--
-- Data for Name: fields; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fields (id, key, label, section, field_type, unit, enum_options, has_default, default_value, display_order, created_at, updated_at) FROM stdin;
1	geral_potencia_nominal_requerida_kva	Potência nominal requerida	Dados Gerais	number	kVA	\N	f	\N	0	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
2	geral_potencia_nominal_requerida_kw	Potência nominal requerida	Dados Gerais	number	kW	\N	f	\N	1	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
3	geral_fator_potencia_requerido	Fator de potência requerido	Dados Gerais	number	fp	\N	t	0.8	2	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
4	geral_topologia_aterramento	Topologia de aterramento	Dados Gerais	enum	\N	["TT", "TN", "IT"]	f	\N	3	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
5	geral_ruido_audivel_maximo	Ruído audível máximo	Dados Gerais	number	dBA	\N	t	78	4	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
6	geral_grau_protecao	Grau de proteção	Dados Gerais	text	\N	\N	t	"IP21"	5	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
7	geral_pressao_minima_ar_ambiente	Pressão mínima do ar ambiente permitida	Dados Gerais	number	kPa	\N	t	70	6	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
8	ambiental_elevacao_maxima	Elevação máxima	Condições Ambientais	number	metros	\N	t	1000	1007	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
9	ambiental_umidade_relativa	Umidade relativa	Condições Ambientais	number	%	\N	t	95	1008	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
10	ambiental_h2s_concentracao_salina	H2S e concentração salina	Condições Ambientais	number	ppm	\N	t	2	1009	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
11	ambiental_temperatura_maxima_operacao	Temperatura máxima de operação	Condições Ambientais	number	°C	\N	t	40	1010	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
12	ambiental_grau_poluicao	Grau de poluição	Condições Ambientais	text	\N	\N	t	"PD2"	1011	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
13	retificador_tensao_nominal	Tensão nominal	AC Entrada Retificador	number	volts	\N	f	\N	2012	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
14	retificador_numero_fases	Número de fases	AC Entrada Retificador	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	2013	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
15	retificador_frequencia_nominal	Frequência nominal	AC Entrada Retificador	number	Hz	\N	f	\N	2014	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
16	retificador_transformador_isolador	Transformador isolador	AC Entrada Retificador	boolean	\N	\N	t	true	2015	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
17	retificador_tipo_retificador	Tipo de retificador	AC Entrada Retificador	enum	\N	["6 Pulsos", "12 Pulsos", "PFC"]	f	\N	2016	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
18	retificador_disjuntor_entrada	Disjuntor de entrada	AC Entrada Retificador	boolean	\N	\N	t	false	2017	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
19	retificador_maximo_harmonico_entrada	Máximo harmônico de entrada	AC Entrada Retificador	number	%	\N	t	5	2018	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
20	retificador_filtro_harmonicos_entrada	Filtro de harmônicos de entrada	AC Entrada Retificador	boolean	\N	\N	t	false	2019	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
21	retificador_faixa_tolerancia_tensao_entrada	Faixa de tolerância de tensão de entrada	AC Entrada Retificador	number	%	\N	t	10	2020	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
22	retificador_faixa_tolerancia_frequencia_entrada	Faixa de tolerância de frequência de entrada	AC Entrada Retificador	number	%	\N	t	2	2021	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
23	bypass_tensao_nominal	Tensão nominal	AC Bypass	number	volts	\N	f	\N	3022	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
24	bypass_numero_fases	Número de fases	AC Bypass	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	3023	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
25	bypass_frequencia_nominal	Frequência nominal	AC Bypass	number	Hz	\N	f	\N	3024	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
26	bypass_transformador_isolador	Transformador isolador	AC Bypass	boolean	\N	\N	t	true	3025	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
27	bypass_disjuntor_entrada	Disjuntor de entrada	AC Bypass	boolean	\N	\N	t	false	3026	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
28	bypass_regulador_tensao	Regulador de tensão	AC Bypass	boolean	\N	\N	t	false	3027	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
29	bypass_faixa_tolerancia_tensao_entrada	Faixa de tolerância de tensão de entrada	AC Bypass	number	%	\N	t	10	3028	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
30	bypass_faixa_tolerancia_frequencia_entrada	Faixa de tolerância de frequência de entrada	AC Bypass	number	%	\N	t	2	3029	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
31	bypass_mecanico_requerido	Bypass mecânico requerido	AC Bypass	boolean	\N	\N	t	true	3030	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
32	saida_tensao_nominal	Tensão nominal	Saída AC	number	volts	\N	f	\N	4031	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
33	saida_numero_fases	Número de fases	Saída AC	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	4032	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
34	saida_frequencia_nominal	Frequência nominal	Saída AC	number	Hz	\N	f	\N	4033	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
35	saida_transformador_isolador	Transformador isolador	Saída AC	boolean	\N	\N	t	true	4034	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
36	saida_chave_isolamento_saida	Chave de isolamento de saída	Saída AC	boolean	\N	\N	t	true	4035	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
37	saida_tolerancia_tensao_saida_carga_total	Tolerância de tensão de saída em carga total	Saída AC	number	%	\N	t	1	4036	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
38	saida_fator_potencia_saida	Fator de potência de saída	Saída AC	number	\N	\N	t	0.8	4037	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
39	saida_desequilibrio_tensao_carga_100	Desequilíbrio de tensão com 100% de desequilíbrio de carga	Saída AC	number	%	\N	f	\N	4038	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
40	bateria_tipo	Tipo de bateria	Armazenamento de Energia (Bateria)	enum	\N	["VRLA", "NiCad", "Vent", "SMC"]	t	"VRLA"	5039	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
41	bateria_autonomia_esperada	Autonomia esperada	Armazenamento de Energia (Bateria)	text	\N	\N	t	"2h"	5040	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
42	bateria_vida_util_projeto	Vida útil de projeto	Armazenamento de Energia (Bateria)	text	\N	\N	t	"5 anos"	5041	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
43	bateria_fabricante_desejado	Fabricante desejado	Armazenamento de Energia (Bateria)	text	\N	\N	f	\N	5042	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
44	desempenho_eficiencia_ac_ac_minima	Eficiência AC/AC mínima	Desempenho e Topologia	number	\N	\N	t	0.82	6043	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
45	desempenho_classe	Classe de desempenho	Desempenho e Topologia	text	\N	\N	t	"VFI SS 111"	6044	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
46	desempenho_configuracao	Configuração	Desempenho e Topologia	enum	\N	["Single", "Parallel", "Redundant", "Dual Bus", "Bypass"]	f	\N	6045	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
47	desempenho_topologia	Topologia	Desempenho e Topologia	enum	\N	["Double Conversion", "Line-interactive", "Standby"]	f	\N	6046	2026-03-12 16:35:31.686796+00	2026-03-12 16:35:47.584656+00
95	potencia_nominal_requerida_kva	Potencia nominal requerida (kVA)	Dados Gerais	number	kVA	[]	f	\N	1	2026-03-12 16:35:47.712098+00	2026-03-12 16:35:47.712098+00
96	potencia_nominal_requerida_kw	Potencia nominal requerida Power (kW)	Dados Gerais	number	kW	[]	f	\N	2	2026-03-12 16:35:47.719401+00	2026-03-12 16:35:47.719401+00
97	fator_potencia_requerida	Fator de potencia requerida	Dados Gerais	number	fP	[]	t	0.8	3	2026-03-12 16:35:47.724165+00	2026-03-12 16:35:47.724165+00
98	topologia_aterramento	Topologia aterramento	Dados Gerais	enum	\N	["TT", "TN", "IT"]	f	\N	4	2026-03-12 16:35:47.729317+00	2026-03-12 16:35:47.729317+00
99	ruido_audivel_maximo	Ruido audivel maximo	Dados Gerais	number	dBA	[]	t	78	5	2026-03-12 16:35:47.734607+00	2026-03-12 16:35:47.734607+00
100	grau_protecao	Grau de protecao	Dados Gerais	text	\N	[]	t	"IP21"	6	2026-03-12 16:35:47.738961+00	2026-03-12 16:35:47.738961+00
101	pressao_ar_ambiente_minima	Pressao do ar ambiente minima permitida	Dados Gerais	number	Kpa	[]	t	70	7	2026-03-12 16:35:47.744253+00	2026-03-12 16:35:47.744253+00
102	elevacao_maxima	Elevacao maxima	Condicoes ambientais	number	metros	[]	t	1000	1	2026-03-12 16:35:47.749543+00	2026-03-12 16:35:47.749543+00
103	umidade_relativa	Umidade relativa	Condicoes ambientais	number	%	[]	t	95	2	2026-03-12 16:35:47.754452+00	2026-03-12 16:35:47.754452+00
104	h2s_concentracao_salina	H2S e concentracao salina	Condicoes ambientais	number	ppm	[]	t	2	3	2026-03-12 16:35:47.760273+00	2026-03-12 16:35:47.760273+00
105	temperatura_max_operacao	Temperatura maxima de operacao	Condicoes ambientais	number	Celso	[]	t	40	4	2026-03-12 16:35:47.764675+00	2026-03-12 16:35:47.764675+00
106	grau_poluicao	Grau de poluicao	Condicoes ambientais	text	\N	[]	t	"PD2"	5	2026-03-12 16:35:47.769377+00	2026-03-12 16:35:47.769377+00
107	ret_tensao_nominal	Tensao nominal	AC Entrada Retificador (Secao 1)	number	Volts	[]	f	\N	1	2026-03-12 16:35:47.773915+00	2026-03-12 16:35:47.773915+00
108	ret_numero_fase	Numero de fase	AC Entrada Retificador (Secao 1)	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	2	2026-03-12 16:35:47.779228+00	2026-03-12 16:35:47.779228+00
109	ret_frequencia_nominal	Frequencia nominal	AC Entrada Retificador (Secao 1)	number	Hz	[]	f	\N	3	2026-03-12 16:35:47.78434+00	2026-03-12 16:35:47.78434+00
110	ret_transformador_isolador	Transformador Isolador	AC Entrada Retificador (Secao 1)	boolean	\N	[]	t	true	4	2026-03-12 16:35:47.788455+00	2026-03-12 16:35:47.788455+00
111	ret_tipo_retificador	Tipo retificador	AC Entrada Retificador (Secao 1)	enum	\N	["6 Pulso", "12 Pulso", "PFC"]	f	\N	5	2026-03-12 16:35:47.793627+00	2026-03-12 16:35:47.793627+00
112	ret_disjuntor_entrada	Disjuntor entrada	AC Entrada Retificador (Secao 1)	boolean	\N	[]	t	false	6	2026-03-12 16:35:47.799587+00	2026-03-12 16:35:47.799587+00
113	ret_max_harmonico_entrada	Maximo harmonico de entrada	AC Entrada Retificador (Secao 1)	number	%	[]	t	5	7	2026-03-12 16:35:47.804015+00	2026-03-12 16:35:47.804015+00
114	ret_filtro_harmonico_entrada	Filtro de harmonico de entrada	AC Entrada Retificador (Secao 1)	boolean	\N	[]	t	false	8	2026-03-12 16:35:47.807938+00	2026-03-12 16:35:47.807938+00
115	ret_tol_tensao_entrada	Faixa de tolerancia de tensao de entrada (+%, -%)	AC Entrada Retificador (Secao 1)	number	%	[]	t	10	9	2026-03-12 16:35:47.812541+00	2026-03-12 16:35:47.812541+00
116	ret_tol_freq_entrada	Faixa de tolerancia de frequencia de entrada (+%, -%)	AC Entrada Retificador (Secao 1)	number	%	[]	t	2	10	2026-03-12 16:35:47.81702+00	2026-03-12 16:35:47.81702+00
117	byp_tensao_nominal	Tensao nominal	AC by-pass (Secao 2)	number	Volts	[]	f	\N	1	2026-03-12 16:35:47.821838+00	2026-03-12 16:35:47.821838+00
118	byp_numero_fase	Numero de fase	AC by-pass (Secao 2)	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	2	2026-03-12 16:35:47.825983+00	2026-03-12 16:35:47.825983+00
119	byp_frequencia_nominal	Frequencia nominal	AC by-pass (Secao 2)	number	Hz	[]	f	\N	3	2026-03-12 16:35:47.829895+00	2026-03-12 16:35:47.829895+00
120	byp_transformador_isolador	Transformador Isolador	AC by-pass (Secao 2)	boolean	\N	[]	t	true	4	2026-03-12 16:35:47.833726+00	2026-03-12 16:35:47.833726+00
121	byp_disjuntor_entrada	Disjuntor de entrada	AC by-pass (Secao 2)	boolean	\N	[]	t	false	5	2026-03-12 16:35:47.83772+00	2026-03-12 16:35:47.83772+00
122	byp_regulador_voltagem	Regulador de voltagem	AC by-pass (Secao 2)	boolean	\N	[]	t	false	6	2026-03-12 16:35:47.843293+00	2026-03-12 16:35:47.843293+00
123	byp_tol_tensao_entrada	Faixa de tolerancia de tensao de entrada (+%, -%)	AC by-pass (Secao 2)	number	%	[]	t	10	7	2026-03-12 16:35:47.84725+00	2026-03-12 16:35:47.84725+00
124	byp_tol_freq_entrada	Faixa de tolerancia de frequencia de entrada (+%, -%)	AC by-pass (Secao 2)	number	%	[]	t	2	8	2026-03-12 16:35:47.850983+00	2026-03-12 16:35:47.850983+00
125	byp_bypass_mecanico_requerido	Bypass mecanico requerido	AC by-pass (Secao 2)	boolean	\N	[]	t	true	9	2026-03-12 16:35:47.855048+00	2026-03-12 16:35:47.855048+00
126	out_tensao_nominal	Tensao nominal	Saida AC (Secao 3)	number	volts	[]	f	\N	1	2026-03-12 16:35:47.85867+00	2026-03-12 16:35:47.85867+00
127	out_numero_fases	Numero de fases	Saida AC (Secao 3)	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	2	2026-03-12 16:35:47.862666+00	2026-03-12 16:35:47.862666+00
128	out_frequencia_nominal	Frequencia nominal	Saida AC (Secao 3)	number	Hz	[]	f	\N	3	2026-03-12 16:35:47.866849+00	2026-03-12 16:35:47.866849+00
129	out_transformador_isolador	Transformador isolador	Saida AC (Secao 3)	boolean	\N	[]	t	true	4	2026-03-12 16:35:47.871045+00	2026-03-12 16:35:47.871045+00
130	out_chave_isolamento	Chave de isolamento saida	Saida AC (Secao 3)	boolean	\N	[]	t	true	5	2026-03-12 16:35:47.874949+00	2026-03-12 16:35:47.874949+00
131	out_tolerancia_tensao_full_load	Tolerancia de tensao de saida full load	Saida AC (Secao 3)	number	%	[]	t	1	6	2026-03-12 16:35:47.878584+00	2026-03-12 16:35:47.878584+00
132	out_fator_potencia	Fator de potencia de saida	Saida AC (Secao 3)	number	\N	[]	t	0.8	7	2026-03-12 16:35:47.882297+00	2026-03-12 16:35:47.882297+00
133	out_desequilibrio_tensao	Desequilibrio de tensao resultante de 100 % de razao de desequilibrio de carga	Saida AC (Secao 3)	number	%	[]	f	\N	8	2026-03-12 16:35:47.886087+00	2026-03-12 16:35:47.886087+00
134	bat_tipo_bateria	Tipo de Bateria	Store energy (bateria) (Secao 4)	enum	\N	["VRLA", "NiCad", "Vent", "SMC"]	t	"VRLA"	1	2026-03-12 16:35:47.890208+00	2026-03-12 16:35:47.890208+00
135	bat_autonomia_esperada	Autonomia esperada	Store energy (bateria) (Secao 4)	text	\N	[]	t	"2h"	2	2026-03-12 16:35:47.893823+00	2026-03-12 16:35:47.893823+00
136	bat_designer_vida	Designer de vida	Store energy (bateria) (Secao 4)	text	\N	[]	t	"5anos"	3	2026-03-12 16:35:47.900013+00	2026-03-12 16:35:47.900013+00
137	bat_fabricante_desejado	Fabricante desejado	Store energy (bateria) (Secao 4)	text	\N	[]	f	\N	4	2026-03-12 16:35:47.90811+00	2026-03-12 16:35:47.90811+00
138	desempenho_eficiencia_acac_min	Eficiencia AC/AC minima	Desempenho e topologia	number	\N	[]	t	0.82	1	2026-03-12 16:35:47.913023+00	2026-03-12 16:35:47.913023+00
139	desempenho_classe_1	Classe de desempenho	Desempenho e topologia	text	\N	[]	t	"VFI SS 111"	2	2026-03-12 16:35:47.917322+00	2026-03-12 16:35:47.917322+00
140	desempenho_configuracao_1	Configuracao	Desempenho e topologia	enum	\N	["Single", "Parallel", "Redundant", "Dual bus", "Bypass"]	f	\N	3	2026-03-12 16:35:47.922153+00	2026-03-12 16:35:47.922153+00
141	desempenho_topologia_1	Topologia	Desempenho e topologia	enum	\N	["Double Conversion", "Line-interactive", "Standby"]	f	\N	4	2026-03-12 16:35:47.927428+00	2026-03-12 16:35:47.927428+00
236	unidade_de_negocio	Unidade de negócio	Localização	text	\N	[]	f	\N	1	2026-03-12 21:17:31.277383+00	2026-03-12 21:17:31.277383+00
237	area_operacional	Área operacional	Localização	text	\N	[]	f	\N	2	2026-03-12 21:17:31.283887+00	2026-03-12 21:17:31.283887+00
238	local_instalacao_equipamento	Local de instalação do equipamento	Localização	text	\N	[]	f	\N	3	2026-03-12 21:17:31.289637+00	2026-03-12 21:17:31.289637+00
239	elevacao_acima_nivel_mar	Elevação (acima do nível do mar)	Altitude	number	m	[]	f	\N	1	2026-03-12 21:17:31.295198+00	2026-03-12 21:17:31.295198+00
240	precipitacao_pluviometrica	Precipitação pluviométrica (média anual / mensal máx.)	Condições climáticas	text	\N	[]	f	\N	1	2026-03-12 21:17:31.301054+00	2026-03-12 21:17:31.301054+00
241	temperatura_ambiente	Temperatura ambiente (variação mín.~ máx. / média)	Condições climáticas	text	°C	[]	f	\N	2	2026-03-12 21:17:31.307917+00	2026-03-12 21:17:31.307917+00
242	umidade_relativa_ar	Umidade relativa do ar (variação mín.~ máx.)	Condições climáticas	text	%	[]	f	\N	3	2026-03-12 21:17:31.314222+00	2026-03-12 21:17:31.314222+00
243	identificacao	Identificação	Geral	text	\N	[]	f	\N	1	2026-03-12 21:17:31.319696+00	2026-03-12 21:17:31.319696+00
244	quantidade	Quantidade	Geral	number	\N	[]	f	\N	2	2026-03-12 21:17:31.325462+00	2026-03-12 21:17:31.325462+00
245	fabricante	Fabricante	Geral	text	\N	[]	f	\N	3	2026-03-12 21:17:31.331239+00	2026-03-12 21:17:31.331239+00
246	modelo	Modelo	Geral	text	\N	[]	f	\N	4	2026-03-12 21:17:31.336625+00	2026-03-12 21:17:31.336625+00
247	classificacao_area	Classificação da área (classificada / não classificada)	Características específicas da instalação	enum	\N	["classificada", "não classificada"]	f	\N	1	2026-03-12 21:17:31.342435+00	2026-03-12 21:17:31.342435+00
248	tipo_instalacao	Tipo de instalação abrigada / não abrigada	Características específicas da instalação	enum	\N	["abrigada", "não abrigada"]	f	\N	2	2026-03-12 21:17:31.347657+00	2026-03-12 21:17:31.347657+00
249	regime_trabalho	Regime de trabalho	Características específicas da instalação	text	\N	[]	f	\N	3	2026-03-12 21:17:31.355057+00	2026-03-12 21:17:31.355057+00
250	tipo_nobreak	Tipo	Nobreak	text	\N	[]	f	\N	1	2026-03-12 21:17:31.360604+00	2026-03-12 21:17:31.360604+00
251	configuracao_nobreak	Configuração	Nobreak	text	\N	[]	f	\N	2	2026-03-12 21:17:31.365805+00	2026-03-12 21:17:31.365805+00
252	gabinete	Gabinete	Dados Construtivos	text	\N	[]	f	\N	1	2026-03-12 21:17:31.371435+00	2026-03-12 21:17:31.371435+00
253	classificacao_involucro	Classificação do Invólucro	Dados Construtivos	text	\N	[]	f	\N	2	2026-03-12 21:17:31.377975+00	2026-03-12 21:17:31.377975+00
254	montagem	Montagem	Dados Construtivos	text	\N	[]	f	\N	3	2026-03-12 21:17:31.383649+00	2026-03-12 21:17:31.383649+00
255	pintura	Pintura	Dados Construtivos	text	\N	[]	f	\N	4	2026-03-12 21:17:31.388869+00	2026-03-12 21:17:31.388869+00
256	acesso	Acesso	Dados Construtivos	text	\N	[]	f	\N	5	2026-03-12 21:17:31.393628+00	2026-03-12 21:17:31.393628+00
257	entrada_saida_cabos	Entrada/Saída de Cabos	Dados Construtivos	text	\N	[]	f	\N	6	2026-03-12 21:17:31.399032+00	2026-03-12 21:17:31.399032+00
258	movimentacao	Movimentação	Dados Construtivos	text	\N	[]	f	\N	7	2026-03-12 21:17:31.404142+00	2026-03-12 21:17:31.404142+00
259	dimensoes_nobreak	Dimensões - Nobreak (A X L X P)	Dados Construtivos	text	mm	[]	f	\N	8	2026-03-12 21:17:31.409277+00	2026-03-12 21:17:31.409277+00
260	dimensoes_banco_baterias	Dimensões - Banco de Baterias (A X L X P)	Dados Construtivos	text	mm	[]	f	\N	9	2026-03-12 21:17:31.414488+00	2026-03-12 21:17:31.414488+00
261	peso_total	Peso Total	Dados Construtivos	number	kg	[]	f	\N	10	2026-03-12 21:17:31.419585+00	2026-03-12 21:17:31.419585+00
262	tensao_entrada	Tensão	Parâmetros De Entrada	text	V	[]	f	\N	1	2026-03-12 21:17:31.425067+00	2026-03-12 21:17:31.425067+00
263	frequencia_entrada	Frequência	Parâmetros De Entrada	text	Hz	[]	f	\N	2	2026-03-12 21:17:31.431719+00	2026-03-12 21:17:31.431719+00
264	corrente_entrada	Corrente	Parâmetros De Entrada	text	A	[]	f	\N	3	2026-03-12 21:17:31.438291+00	2026-03-12 21:17:31.438291+00
265	distorcao_harmonica_corrente	Distorção Harmônica de Corrente	Parâmetros De Entrada	text	%	[]	f	\N	4	2026-03-12 21:17:31.444181+00	2026-03-12 21:17:31.444181+00
266	fator_potencia_entrada	Fator de Potência	Parâmetros De Entrada	text	\N	[]	f	\N	5	2026-03-12 21:17:31.449718+00	2026-03-12 21:17:31.449718+00
267	tipo_retificador	Tipo de Retificador	Parâmetros De Entrada	text	\N	[]	f	\N	6	2026-03-12 21:17:31.455566+00	2026-03-12 21:17:31.455566+00
268	modulo_adequacao_tensao	Módulo de Adequação de Tensão	Parâmetros De Entrada	text	\N	[]	f	\N	7	2026-03-12 21:17:31.461114+00	2026-03-12 21:17:31.461114+00
269	conexao_entrada	Conexão de Entrada	Parâmetros De Entrada	text	\N	[]	f	\N	8	2026-03-12 21:17:31.466736+00	2026-03-12 21:17:31.466736+00
270	potencia_saida	Potência	Parâmetros De Saída	text	kW	[]	f	\N	1	2026-03-12 21:17:31.4734+00	2026-03-12 21:17:31.4734+00
271	novo_campo	Novo campo	General	text	\N	[]	f	\N	1	2026-03-12 21:57:27.457776+00	2026-03-12 21:57:27.457776+00
272	novo_campo_1	Novo campo	General	text	\N	[]	f	\N	1	2026-03-13 13:25:21.80591+00	2026-03-13 13:25:21.80591+00
\.


--
-- Data for Name: token_creation_audit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.token_creation_audit (id, equipment_id, channel, ip_hash, browser_session_hash, user_agent_hash, created_at) FROM stdin;
1	\N	public	31dc3a8eabb9093633644b55ceceb6ab4be36f62b3d37dde2e6850446553a7c0	ddb13386487c418896487f200316b6ab9fad55be65480f2b7e27ec6f5096247d	387004e5da007087c21e48fad262294a2f7951ddcf9233e534b0422107981d42	2026-03-12 17:10:46.401784+00
2	\N	public	31dc3a8eabb9093633644b55ceceb6ab4be36f62b3d37dde2e6850446553a7c0	7403c641b28b8ae524fdfca7a88c3d5a3766e4586fca77f61703e3d85af2779c	06bc34a696f90be5b9ba6eef5b1b821805cc1bc7569dd37a622f9232c6f08ee9	2026-03-13 11:06:08.663712+00
3	\N	public	31dc3a8eabb9093633644b55ceceb6ab4be36f62b3d37dde2e6850446553a7c0	ddb13386487c418896487f200316b6ab9fad55be65480f2b7e27ec6f5096247d	387004e5da007087c21e48fad262294a2f7951ddcf9233e534b0422107981d42	2026-03-13 13:44:22.541965+00
\.


--
-- Name: api_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.api_keys_id_seq', 1, false);


--
-- Name: backup_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.backup_files_id_seq', 128, true);


--
-- Name: equipment_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipment_documents_id_seq', 1, true);


--
-- Name: equipment_enabled_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipment_enabled_fields_id_seq', 141, true);


--
-- Name: equipment_field_values_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipment_field_values_id_seq', 74, true);


--
-- Name: equipments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipments_id_seq', 3, true);


--
-- Name: field_profile_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.field_profile_fields_id_seq', 120, true);


--
-- Name: field_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.field_profiles_id_seq', 4, true);


--
-- Name: fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fields_id_seq', 272, true);


--
-- Name: token_creation_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.token_creation_audit_id_seq', 3, true);


--
-- Name: api_keys api_keys_key_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_key_hash_key UNIQUE (key_hash);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (key);


--
-- Name: backup_files backup_files_file_path_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backup_files
    ADD CONSTRAINT backup_files_file_path_key UNIQUE (file_path);


--
-- Name: backup_files backup_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backup_files
    ADD CONSTRAINT backup_files_pkey PRIMARY KEY (id);


--
-- Name: equipment_documents equipment_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_documents
    ADD CONSTRAINT equipment_documents_pkey PRIMARY KEY (id);


--
-- Name: equipment_enabled_fields equipment_enabled_fields_equipment_id_field_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_enabled_fields
    ADD CONSTRAINT equipment_enabled_fields_equipment_id_field_id_key UNIQUE (equipment_id, field_id);


--
-- Name: equipment_enabled_fields equipment_enabled_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_enabled_fields
    ADD CONSTRAINT equipment_enabled_fields_pkey PRIMARY KEY (id);


--
-- Name: equipment_field_values equipment_field_values_equipment_id_field_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_field_values
    ADD CONSTRAINT equipment_field_values_equipment_id_field_id_key UNIQUE (equipment_id, field_id);


--
-- Name: equipment_field_values equipment_field_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_field_values
    ADD CONSTRAINT equipment_field_values_pkey PRIMARY KEY (id);


--
-- Name: equipments equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_pkey PRIMARY KEY (id);


--
-- Name: equipments equipments_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_token_key UNIQUE (token);


--
-- Name: field_profile_fields field_profile_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_profile_fields
    ADD CONSTRAINT field_profile_fields_pkey PRIMARY KEY (id);


--
-- Name: field_profile_fields field_profile_fields_profile_id_field_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_profile_fields
    ADD CONSTRAINT field_profile_fields_profile_id_field_id_key UNIQUE (profile_id, field_id);


--
-- Name: field_profiles field_profiles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_profiles
    ADD CONSTRAINT field_profiles_name_key UNIQUE (name);


--
-- Name: field_profiles field_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_profiles
    ADD CONSTRAINT field_profiles_pkey PRIMARY KEY (id);


--
-- Name: fields fields_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_key_key UNIQUE (key);


--
-- Name: fields fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- Name: token_creation_audit token_creation_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_creation_audit
    ADD CONSTRAINT token_creation_audit_pkey PRIMARY KEY (id);


--
-- Name: idx_api_keys_active_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_api_keys_active_hash ON public.api_keys USING btree (is_active, key_hash);


--
-- Name: idx_backup_files_path_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_backup_files_path_unique ON public.backup_files USING btree (file_path);


--
-- Name: equipment_documents equipment_documents_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_documents
    ADD CONSTRAINT equipment_documents_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipments(id) ON DELETE CASCADE;


--
-- Name: equipment_enabled_fields equipment_enabled_fields_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_enabled_fields
    ADD CONSTRAINT equipment_enabled_fields_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipments(id) ON DELETE CASCADE;


--
-- Name: equipment_enabled_fields equipment_enabled_fields_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_enabled_fields
    ADD CONSTRAINT equipment_enabled_fields_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(id) ON DELETE CASCADE;


--
-- Name: equipment_field_values equipment_field_values_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_field_values
    ADD CONSTRAINT equipment_field_values_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipments(id) ON DELETE CASCADE;


--
-- Name: equipment_field_values equipment_field_values_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_field_values
    ADD CONSTRAINT equipment_field_values_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(id) ON DELETE CASCADE;


--
-- Name: equipments equipments_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.field_profiles(id) ON DELETE SET NULL;


--
-- Name: field_profile_fields field_profile_fields_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_profile_fields
    ADD CONSTRAINT field_profile_fields_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(id) ON DELETE CASCADE;


--
-- Name: field_profile_fields field_profile_fields_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_profile_fields
    ADD CONSTRAINT field_profile_fields_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.field_profiles(id) ON DELETE CASCADE;


--
-- Name: token_creation_audit token_creation_audit_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_creation_audit
    ADD CONSTRAINT token_creation_audit_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipments(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict jQ0psSXzL20xLYVesJJqRWDEo6Rnx4n1xGUjmE9fVFrAS97KIiUrcNcOQX4W5PY

