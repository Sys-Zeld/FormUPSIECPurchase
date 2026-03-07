--
-- PostgreSQL database dump
--

\restrict t4nefhyqdmJ3eHEaazsfQlwSnjx3mHsvFQUDMhMXTDnleFFmKMk5lRIw8PTbEva

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

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
-- Name: answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.answers (
    submission_id bigint NOT NULL,
    field_id text NOT NULL,
    value text
);


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_settings (
    key text NOT NULL,
    value text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


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
    status text DEFAULT 'draft'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    profile_id bigint,
    contact_email text DEFAULT ''::text NOT NULL,
    contact_phone text DEFAULT ''::text NOT NULL,
    project_name text DEFAULT ''::text NOT NULL,
    site_name text DEFAULT ''::text NOT NULL,
    address text DEFAULT ''::text NOT NULL
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
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    label text,
    section text,
    field_type text,
    unit text,
    enum_options jsonb,
    has_default boolean,
    default_value jsonb,
    display_order integer
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
-- Name: field_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_settings (
    field_id text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


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
-- Name: submission_field_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_field_settings (
    submission_id bigint NOT NULL,
    field_id text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id bigint NOT NULL,
    token text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL
);


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


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
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: token_creation_audit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_creation_audit ALTER COLUMN id SET DEFAULT nextval('public.token_creation_audit_id_seq'::regclass);


--
-- Data for Name: answers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.answers (submission_id, field_id, value) FROM stdin;
7	purchaser	EDISA ESTAÇÃO PETROBRAS
7	purchaser_contact	VITOR SUARES
8	purchaser	PETROBRAS EDISA
8	purchaser_contact	FERNANDO
9	purchaser_contact	FERNANDO
9	purchaser	PETROBRAS
9	specification_reference	PR02-00
9	quantity_of_units	1
9	application	
2	purchaser	PETROBRAS
2	purchaser_contact	ANDRE
2	specification_reference	PR02-00
2	date	2026-03-03
2	project	PT69-UPS-01
2	ups_manufacturer	CHLORIDE
2	ups_model	CP60
2	quantity_of_units	1
2	application	PROJETO DE MODERNIZAÇÃO DE UPS
2	tag_number	UP-35-001
2	end_user	PETROBRAS
2	operating_mode	
2	efficiency_classification	class 2
2	rated_output_active_power	100
2	rated_output_apparent_power	99
2	minimum_load_percentage_for_efficiency_declaration	25
2	ups_classification	VFI
2	power_circuit_topology	COM TRAFO
2	input_neutral_requirements	SIM
2	output_neutral_requirements	SIM
2	overload_capability	
2	short_circuit_capability	50
2	output_power_factor	1
2	output_voltage_distortion_with_linear_load	5
2	output_voltage_distortion_with_non_linear_load	2
2	load_power_factor_range	1
5	purchaser	Petrobras
5	purchaser_contact	Andre
5	specification_reference	NA
5	date	2026-03-03
5	project	PTR001
5	ups_manufacturer	Chloride
5	ups_model	CP60
5	quantity_of_units	1
5	application	Teste de projeto
5	tag_number	Uls
5	end_user	
\.


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_settings (key, value, updated_at) FROM stdin;
public_token_access_enabled	true	2026-03-07 01:36:57.299839-03
\.


--
-- Data for Name: equipment_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment_documents (id, equipment_id, original_name, stored_name, relative_path, external_url, mime_type, size_bytes, created_at) FROM stdin;
1	1	1933636.pdf	e8981b83ef7746b3bbbbc17e43354f38_1933636_1772833137894.pdf	/dados/docs/e8981b83ef7746b3bbbbc17e43354f38_1933636_1772833137894.pdf	http://192.168.1.6:3000/dados/docs/e8981b83ef7746b3bbbbc17e43354f38_1933636_1772833137894.pdf	application/pdf	650112	2026-03-06 18:38:57.896781-03
2	1	1933636.pdf	e8981b83ef7746b3bbbbc17e43354f38_1933636_1772833626287.pdf	/dados/docs/e8981b83ef7746b3bbbbc17e43354f38_1933636_1772833626287.pdf	http://192.168.1.6:3000/dados/docs/e8981b83ef7746b3bbbbc17e43354f38_1933636_1772833626287.pdf	application/pdf	650112	2026-03-06 18:47:06.289095-03
3	2	Battery Sizing.pdf	ada0413e57ba4fd0b48d34040113132e_battery_sizing_1772843280368.pdf	/dados/docs/ada0413e57ba4fd0b48d34040113132e_battery_sizing_1772843280368.pdf	http://192.168.1.6:3000/dados/docs/ada0413e57ba4fd0b48d34040113132e_battery_sizing_1772843280368.pdf	application/pdf	1478534	2026-03-06 21:28:00.371111-03
\.


--
-- Data for Name: equipment_enabled_fields; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment_enabled_fields (id, equipment_id, field_id, created_at) FROM stdin;
48	1	1	2026-03-06 20:14:34.002304-03
49	1	2	2026-03-06 20:14:34.002304-03
50	1	3	2026-03-06 20:14:34.002304-03
51	1	4	2026-03-06 20:14:34.002304-03
52	1	5	2026-03-06 20:14:34.002304-03
53	1	6	2026-03-06 20:14:34.002304-03
54	1	7	2026-03-06 20:14:34.002304-03
55	1	8	2026-03-06 20:14:34.002304-03
56	1	9	2026-03-06 20:14:34.002304-03
57	1	10	2026-03-06 20:14:34.002304-03
58	1	11	2026-03-06 20:14:34.002304-03
59	1	12	2026-03-06 20:14:34.002304-03
60	1	13	2026-03-06 20:14:34.002304-03
61	1	14	2026-03-06 20:14:34.002304-03
62	1	15	2026-03-06 20:14:34.002304-03
63	1	16	2026-03-06 20:14:34.002304-03
64	1	17	2026-03-06 20:14:34.002304-03
65	1	18	2026-03-06 20:14:34.002304-03
66	1	19	2026-03-06 20:14:34.002304-03
67	1	20	2026-03-06 20:14:34.002304-03
68	1	21	2026-03-06 20:14:34.002304-03
69	1	22	2026-03-06 20:14:34.002304-03
70	1	23	2026-03-06 20:14:34.002304-03
71	1	24	2026-03-06 20:14:34.002304-03
72	1	25	2026-03-06 20:14:34.002304-03
73	1	26	2026-03-06 20:14:34.002304-03
74	1	27	2026-03-06 20:14:34.002304-03
75	1	28	2026-03-06 20:14:34.002304-03
76	1	29	2026-03-06 20:14:34.002304-03
77	1	30	2026-03-06 20:14:34.002304-03
78	1	31	2026-03-06 20:14:34.002304-03
79	1	32	2026-03-06 20:14:34.002304-03
80	1	33	2026-03-06 20:14:34.002304-03
81	1	34	2026-03-06 20:14:34.002304-03
82	1	35	2026-03-06 20:14:34.002304-03
83	1	36	2026-03-06 20:14:34.002304-03
84	1	37	2026-03-06 20:14:34.002304-03
85	1	38	2026-03-06 20:14:34.002304-03
86	1	39	2026-03-06 20:14:34.002304-03
87	1	40	2026-03-06 20:14:34.002304-03
88	1	41	2026-03-06 20:14:34.002304-03
89	1	42	2026-03-06 20:14:34.002304-03
90	1	44	2026-03-06 20:14:34.002304-03
91	1	45	2026-03-06 20:14:34.002304-03
92	1	46	2026-03-06 20:14:34.002304-03
93	1	47	2026-03-06 20:14:34.002304-03
94	2	1	2026-03-06 21:01:45.397239-03
95	2	2	2026-03-06 21:01:45.397239-03
96	2	3	2026-03-06 21:01:45.397239-03
97	2	4	2026-03-06 21:01:45.397239-03
98	2	5	2026-03-06 21:01:45.397239-03
99	2	6	2026-03-06 21:01:45.397239-03
100	2	7	2026-03-06 21:01:45.397239-03
101	2	8	2026-03-06 21:01:45.397239-03
102	2	9	2026-03-06 21:01:45.397239-03
103	2	10	2026-03-06 21:01:45.397239-03
104	2	11	2026-03-06 21:01:45.397239-03
105	2	12	2026-03-06 21:01:45.397239-03
106	2	13	2026-03-06 21:01:45.397239-03
107	2	14	2026-03-06 21:01:45.397239-03
108	2	15	2026-03-06 21:01:45.397239-03
109	2	16	2026-03-06 21:01:45.397239-03
110	2	17	2026-03-06 21:01:45.397239-03
111	2	18	2026-03-06 21:01:45.397239-03
112	2	19	2026-03-06 21:01:45.397239-03
113	2	20	2026-03-06 21:01:45.397239-03
114	2	21	2026-03-06 21:01:45.397239-03
115	2	22	2026-03-06 21:01:45.397239-03
116	2	23	2026-03-06 21:01:45.397239-03
117	2	24	2026-03-06 21:01:45.397239-03
118	2	25	2026-03-06 21:01:45.397239-03
119	2	26	2026-03-06 21:01:45.397239-03
120	2	27	2026-03-06 21:01:45.397239-03
121	2	28	2026-03-06 21:01:45.397239-03
122	2	29	2026-03-06 21:01:45.397239-03
123	2	30	2026-03-06 21:01:45.397239-03
124	2	31	2026-03-06 21:01:45.397239-03
125	2	32	2026-03-06 21:01:45.397239-03
126	2	33	2026-03-06 21:01:45.397239-03
127	2	34	2026-03-06 21:01:45.397239-03
128	2	35	2026-03-06 21:01:45.397239-03
129	2	36	2026-03-06 21:01:45.397239-03
130	2	37	2026-03-06 21:01:45.397239-03
131	2	38	2026-03-06 21:01:45.397239-03
132	2	39	2026-03-06 21:01:45.397239-03
133	2	40	2026-03-06 21:01:45.397239-03
134	2	41	2026-03-06 21:01:45.397239-03
135	2	42	2026-03-06 21:01:45.397239-03
136	2	43	2026-03-06 21:01:45.397239-03
137	2	44	2026-03-06 21:01:45.397239-03
138	2	45	2026-03-06 21:01:45.397239-03
139	2	46	2026-03-06 21:01:45.397239-03
140	2	47	2026-03-06 21:01:45.397239-03
\.


--
-- Data for Name: equipment_field_values; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment_field_values (id, equipment_id, field_id, value, created_at, updated_at) FROM stdin;
14	1	20	false	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
15	1	21	10	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
16	1	22	2	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
17	1	24	"3PhN"	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
18	1	26	true	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
19	1	27	false	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
20	1	28	false	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
21	1	29	10	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
22	1	30	2	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
23	1	31	true	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
24	1	33	"3PhN"	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
25	1	35	true	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
26	1	36	true	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
27	1	37	1	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
28	1	38	0.8	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
29	1	40	"VRLA"	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
30	1	41	"20h"	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
31	1	42	"5 anos"	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
32	1	44	0.82	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
33	1	45	"VFI SS 111"	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
136	2	3	0.8	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
137	2	5	78	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
138	2	6	"IP21"	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
139	2	7	70	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
140	2	8	1000	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
141	2	9	95	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
142	2	10	2	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
143	2	11	40	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
144	2	12	"PD2"	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
145	2	14	"3PhN"	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
146	2	16	true	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
147	2	18	false	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
148	2	19	5	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
149	2	20	false	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
150	2	21	10	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
151	2	22	2	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
152	2	24	"3PhN"	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
1	1	3	0.8	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
2	1	5	78	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
3	1	6	"IP21"	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
4	1	7	70	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
5	1	8	1000	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
6	1	9	95	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
7	1	10	2	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
8	1	11	40	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
9	1	12	"PD2"	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
43	1	13	220	2026-03-06 18:47:06.081218-03	2026-03-06 19:43:00.492498-03
10	1	14	"3PhN"	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
11	1	16	true	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
12	1	18	false	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
13	1	19	5	2026-03-06 12:22:57.03227-03	2026-03-06 19:43:00.492498-03
153	2	26	true	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
154	2	27	false	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
155	2	28	false	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
156	2	29	10	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
157	2	30	2	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
158	2	31	true	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
159	2	33	"3PhN"	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
160	2	35	true	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
161	2	36	true	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
162	2	37	1	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
163	2	38	0.8	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
164	2	40	"VRLA"	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
165	2	41	"2h"	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
166	2	42	"5 anos"	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
167	2	44	0.82	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
168	2	45	"VFI SS 111"	2026-03-06 21:02:29.432558-03	2026-03-06 21:28:00.194105-03
\.


--
-- Data for Name: equipments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipments (id, token, purchaser, purchaser_contact, status, created_at, updated_at, profile_id, contact_email, contact_phone, project_name, site_name, address) FROM stdin;
1	e8981b83ef7746b3bbbbc17e43354f38	PETROBRAS EDISA	FERNANDO	draft	2026-03-06 12:22:50.592076-03	2026-03-06 20:14:34.002304-03	1	fernando.edisa@petrobras.com.br	21989604747	PR-01	EDISA	CAMINHO XXX
2	ada0413e57ba4fd0b48d34040113132e	TESTE	ANDRE	draft	2026-03-06 21:01:45.397239-03	2026-03-06 21:28:00.194105-03	\N	vitor.j.suares@gmail.com	+246 21989604747	VITOR DE JESUS SUARES	EDISA	Caminho Boqueirão, 336
\.


--
-- Data for Name: field_profile_fields; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.field_profile_fields (id, profile_id, field_id, created_at, is_enabled, label, section, field_type, unit, enum_options, has_default, default_value, display_order) FROM stdin;
1	1	1	2026-03-06 12:21:22.061457-03	t	Potência nominal requerida	Dados Gerais	number	kVA	\N	f	\N	0
2	1	2	2026-03-06 12:21:22.061457-03	t	Potência nominal requerida	Dados Gerais	number	kW	\N	f	\N	1
3	1	3	2026-03-06 12:21:22.061457-03	t	Fator de potência requerido	Dados Gerais	number	fp	\N	t	"0.8"	2
4	1	4	2026-03-06 12:21:22.061457-03	t	Topologia de aterramento	Dados Gerais	enum	\N	["TT", "TN", "IT"]	f	\N	3
5	1	5	2026-03-06 12:21:22.061457-03	t	Ruído audível máximo	Dados Gerais	number	dBA	\N	t	"78"	4
6	1	6	2026-03-06 12:21:22.061457-03	t	Grau de proteção	Dados Gerais	text	\N	\N	t	"IP21"	5
7	1	7	2026-03-06 12:21:22.061457-03	t	Pressão mínima do ar ambiente permitida	Dados Gerais	number	kPa	\N	t	"70"	6
8	1	8	2026-03-06 12:21:22.061457-03	t	Elevação máxima	Condições Ambientais	number	metros	\N	t	"1000"	1007
9	1	9	2026-03-06 12:21:22.061457-03	t	Umidade relativa	Condições Ambientais	number	%	\N	t	"95"	1008
10	1	10	2026-03-06 12:21:22.061457-03	t	H2S e concentração salina	Condições Ambientais	number	ppm	\N	t	"2"	1009
11	1	11	2026-03-06 12:21:22.061457-03	t	Temperatura máxima de operação	Condições Ambientais	number	°C	\N	t	"40"	1010
12	1	12	2026-03-06 12:21:22.061457-03	t	Grau de poluição	Condições Ambientais	text	\N	\N	t	"PD2"	1011
13	1	13	2026-03-06 12:21:22.061457-03	t	Tensão nominal	AC Entrada Retificador	number	volts	\N	f	\N	2012
14	1	14	2026-03-06 12:21:22.061457-03	t	Número de fases	AC Entrada Retificador	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	2013
15	1	15	2026-03-06 12:21:22.061457-03	t	Frequência nominal	AC Entrada Retificador	number	Hz	\N	f	\N	2014
16	1	16	2026-03-06 12:21:22.061457-03	t	Transformador isolador	AC Entrada Retificador	boolean	\N	\N	t	"true"	2015
17	1	17	2026-03-06 12:21:22.061457-03	t	Tipo de retificador	AC Entrada Retificador	enum	\N	["6 Pulsos", "12 Pulsos", "PFC"]	f	\N	2016
18	1	18	2026-03-06 12:21:22.061457-03	t	Disjuntor de entrada	AC Entrada Retificador	boolean	\N	\N	t	"false"	2017
19	1	19	2026-03-06 12:21:22.061457-03	t	Máximo harmônico de entrada	AC Entrada Retificador	number	%	\N	t	"5"	2018
20	1	20	2026-03-06 12:21:22.061457-03	t	Filtro de harmônicos de entrada	AC Entrada Retificador	boolean	\N	\N	t	"false"	2019
21	1	21	2026-03-06 12:21:22.061457-03	t	Faixa de tolerância de tensão de entrada	AC Entrada Retificador	number	%	\N	t	"10"	2020
22	1	22	2026-03-06 12:21:22.061457-03	t	Faixa de tolerância de frequência de entrada	AC Entrada Retificador	number	%	\N	t	"2"	2021
23	1	23	2026-03-06 12:21:22.061457-03	t	Tensão nominal	AC Bypass	number	volts	\N	f	\N	3022
24	1	24	2026-03-06 12:21:22.061457-03	t	Número de fases	AC Bypass	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	3023
25	1	25	2026-03-06 12:21:22.061457-03	t	Frequência nominal	AC Bypass	number	Hz	\N	f	\N	3024
26	1	26	2026-03-06 12:21:22.061457-03	t	Transformador isolador	AC Bypass	boolean	\N	\N	t	"true"	3025
27	1	27	2026-03-06 12:21:22.061457-03	t	Disjuntor de entrada	AC Bypass	boolean	\N	\N	t	"false"	3026
28	1	28	2026-03-06 12:21:22.061457-03	t	Regulador de tensão	AC Bypass	boolean	\N	\N	t	"false"	3027
29	1	29	2026-03-06 12:21:22.061457-03	t	Faixa de tolerância de tensão de entrada	AC Bypass	number	%	\N	t	"10"	3028
30	1	30	2026-03-06 12:21:22.061457-03	t	Faixa de tolerância de frequência de entrada	AC Bypass	number	%	\N	t	"2"	3029
31	1	31	2026-03-06 12:21:22.061457-03	t	Bypass mecânico requerido	AC Bypass	boolean	\N	\N	t	"true"	3030
32	1	32	2026-03-06 12:21:22.061457-03	t	Tensão nominal	Saída AC	number	volts	\N	f	\N	4031
33	1	33	2026-03-06 12:21:22.061457-03	t	Número de fases	Saída AC	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	4032
34	1	34	2026-03-06 12:21:22.061457-03	t	Frequência nominal	Saída AC	number	Hz	\N	f	\N	4033
35	1	35	2026-03-06 12:21:22.061457-03	t	Transformador isolador	Saída AC	boolean	\N	\N	t	"true"	4034
36	1	36	2026-03-06 12:21:22.061457-03	t	Chave de isolamento de saída	Saída AC	boolean	\N	\N	t	"true"	4035
37	1	37	2026-03-06 12:21:22.061457-03	t	Tolerância de tensão de saída em carga total	Saída AC	number	%	\N	t	"1"	4036
38	1	38	2026-03-06 12:21:22.061457-03	t	Fator de potência de saída	Saída AC	number	\N	\N	t	"0.8"	4037
39	1	39	2026-03-06 12:21:22.061457-03	t	Desequilíbrio de tensão com 100% de desequilíbrio de carga	Saída AC	number	%	\N	f	\N	4038
40	1	40	2026-03-06 12:21:22.061457-03	t	Tipo de bateria	Armazenamento de Energia (Bateria)	enum	\N	["VRLA", "NiCad", "Vent", "SMC"]	t	"VRLA"	5039
41	1	41	2026-03-06 12:21:22.061457-03	t	Autonomia esperada	Armazenamento de Energia (Bateria)	text	\N	\N	t	"2h"	5040
42	1	42	2026-03-06 12:21:22.061457-03	t	Vida útil de projeto	Armazenamento de Energia (Bateria)	text	\N	\N	t	"5 anos"	5041
43	1	43	2026-03-06 12:21:22.061457-03	t	Fabricante desejado	Armazenamento de Energia (Bateria)	text	\N	\N	f	\N	5042
44	1	44	2026-03-06 12:21:22.061457-03	t	Eficiência AC/AC mínima	Desempenho e Topologia	number	\N	\N	t	"0.82"	6043
45	1	45	2026-03-06 12:21:22.061457-03	t	Classe de desempenho	Desempenho e Topologia	text	\N	\N	t	"VFI SS 111"	6044
46	1	46	2026-03-06 12:21:22.061457-03	t	Configuração	Desempenho e Topologia	enum	\N	["Single", "Parallel", "Redundant", "Dual Bus", "Bypass"]	f	\N	6045
47	1	47	2026-03-06 12:21:22.061457-03	t	Topologia	Desempenho e Topologia	enum	\N	["Double Conversion", "Line-interactive", "Standby"]	f	\N	6046
\.


--
-- Data for Name: field_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.field_profiles (id, name, created_at, updated_at) FROM stdin;
1	UPS CHLORIDE	2026-03-06 12:21:22.061457-03	2026-03-06 12:21:22.061457-03
\.


--
-- Data for Name: field_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.field_settings (field_id, enabled, updated_at) FROM stdin;
purchaser	t	2026-03-03 23:53:17.809194-03
purchaser_contact	t	2026-03-03 23:53:17.809194-03
specification_reference	t	2026-03-03 23:53:17.809194-03
date	t	2026-03-03 23:53:17.809194-03
project	t	2026-03-03 23:53:17.809194-03
ups_manufacturer	f	2026-03-03 23:53:17.809194-03
ups_model	f	2026-03-03 23:53:17.809194-03
quantity_of_units	t	2026-03-03 23:53:17.809194-03
application	t	2026-03-03 23:53:17.809194-03
tag_number	t	2026-03-03 23:53:17.809194-03
end_user	f	2026-03-03 23:53:17.809194-03
operating_mode	t	2026-03-03 23:53:17.809194-03
efficiency_classification	t	2026-03-03 23:53:17.809194-03
rated_output_active_power	t	2026-03-03 23:53:17.809194-03
rated_output_apparent_power	t	2026-03-03 23:53:17.809194-03
minimum_load_percentage_for_efficiency_declaration	t	2026-03-03 23:53:17.809194-03
ups_classification	t	2026-03-03 23:53:17.809194-03
power_circuit_topology	t	2026-03-03 23:53:17.809194-03
input_neutral_requirements	t	2026-03-03 23:53:17.809194-03
output_neutral_requirements	t	2026-03-03 23:53:17.809194-03
overload_capability	t	2026-03-03 23:53:17.809194-03
short_circuit_capability	t	2026-03-03 23:53:17.809194-03
output_power_factor	t	2026-03-03 23:53:17.809194-03
output_voltage_distortion_with_linear_load	t	2026-03-03 23:53:17.809194-03
output_voltage_distortion_with_non_linear_load	t	2026-03-03 23:53:17.809194-03
load_power_factor_range	t	2026-03-03 23:53:17.809194-03
operating_temperature_range	t	2026-03-03 23:53:17.809194-03
relative_humidity	t	2026-03-03 23:53:17.809194-03
altitude_without_derating	t	2026-03-03 23:53:17.809194-03
acoustic_noise	t	2026-03-03 23:53:17.809194-03
heat_dissipation	t	2026-03-03 23:53:17.809194-03
degree_of_protection_ip	t	2026-03-03 23:53:17.809194-03
storage_temperature_range	t	2026-03-03 23:53:17.809194-03
transport_temperature_range	t	2026-03-03 23:53:17.809194-03
input_voltage_and_number_of_phases	t	2026-03-03 23:53:17.809194-03
input_voltage_tolerance	t	2026-03-03 23:53:17.809194-03
input_frequency_and_tolerance	t	2026-03-03 23:53:17.809194-03
input_frequency_range_for_operation_on_bypass	t	2026-03-03 23:53:17.809194-03
input_power_factor_at_rated_load	t	2026-03-03 23:53:17.809194-03
input_current_distortion_at_rated_load	t	2026-03-03 23:53:17.809194-03
output_voltage_and_number_of_phases	t	2026-03-03 23:53:17.809194-03
output_voltage_regulation	t	2026-03-03 23:53:17.809194-03
output_voltage_tolerance	t	2026-03-03 23:53:17.809194-03
output_frequency_and_tolerance	t	2026-03-03 23:53:17.809194-03
voltage_unbalance	t	2026-03-03 23:53:17.809194-03
frequency_synchronization_range	t	2026-03-03 23:53:17.809194-03
transient_voltage_response	t	2026-03-03 23:53:17.809194-03
crest_factor_capability	t	2026-03-03 23:53:17.809194-03
static_bypass_type	t	2026-03-03 23:53:17.809194-03
bypass_voltage_and_phases	t	2026-03-03 23:53:17.809194-03
bypass_frequency_and_tolerance	t	2026-03-03 23:53:17.809194-03
transfer_conditions_to_bypass	t	2026-03-03 23:53:17.809194-03
maintenance_bypass_requirement	t	2026-03-03 23:53:17.809194-03
battery_type	t	2026-03-03 23:53:17.809194-03
battery_voltage	t	2026-03-03 23:53:17.809194-03
battery_autonomy_time_at_rated_load	t	2026-03-03 23:53:17.809194-03
recharge_time	t	2026-03-03 23:53:17.809194-03
number_of_battery_strings	t	2026-03-03 23:53:17.809194-03
battery_monitoring_features	t	2026-03-03 23:53:17.809194-03
local_hmi_display	t	2026-03-03 23:53:17.809194-03
dry_contacts	t	2026-03-03 23:53:17.809194-03
serial_communication_interface	t	2026-03-03 23:53:17.809194-03
network_communication_interface	t	2026-03-03 23:53:17.809194-03
remote_monitoring_software	t	2026-03-03 23:53:17.809194-03
event_logging	t	2026-03-03 23:53:17.809194-03
compliance_to_iec_62040_1	t	2026-03-03 23:53:17.809194-03
compliance_to_iec_62040_2	t	2026-03-03 23:53:17.809194-03
compliance_to_iec_62040_3	t	2026-03-03 23:53:17.809194-03
routine_test_requirements	t	2026-03-03 23:53:17.809194-03
type_test_evidence	t	2026-03-03 23:53:17.809194-03
factory_acceptance_test	t	2026-03-03 23:53:17.809194-03
site_acceptance_test	t	2026-03-03 23:53:17.809194-03
required_documents_and_drawings	t	2026-03-03 23:53:17.809194-03
\.


--
-- Data for Name: fields; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fields (id, key, label, section, field_type, unit, enum_options, has_default, default_value, display_order, created_at, updated_at) FROM stdin;
1	geral_potencia_nominal_requerida_kva	Potência nominal requerida	Dados Gerais	number	kVA	\N	f	\N	0	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
2	geral_potencia_nominal_requerida_kw	Potência nominal requerida	Dados Gerais	number	kW	\N	f	\N	1	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
3	geral_fator_potencia_requerido	Fator de potência requerido	Dados Gerais	number	fp	\N	t	0.8	2	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
4	geral_topologia_aterramento	Topologia de aterramento	Dados Gerais	enum	\N	["TT", "TN", "IT"]	f	\N	3	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
5	geral_ruido_audivel_maximo	Ruído audível máximo	Dados Gerais	number	dBA	\N	t	78	4	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
6	geral_grau_protecao	Grau de proteção	Dados Gerais	text	\N	\N	t	"IP21"	5	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
7	geral_pressao_minima_ar_ambiente	Pressão mínima do ar ambiente permitida	Dados Gerais	number	kPa	\N	t	70	6	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
8	ambiental_elevacao_maxima	Elevação máxima	Condições Ambientais	number	metros	\N	t	1000	1007	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
9	ambiental_umidade_relativa	Umidade relativa	Condições Ambientais	number	%	\N	t	95	1008	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
10	ambiental_h2s_concentracao_salina	H2S e concentração salina	Condições Ambientais	number	ppm	\N	t	2	1009	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
11	ambiental_temperatura_maxima_operacao	Temperatura máxima de operação	Condições Ambientais	number	°C	\N	t	40	1010	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
12	ambiental_grau_poluicao	Grau de poluição	Condições Ambientais	text	\N	\N	t	"PD2"	1011	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
13	retificador_tensao_nominal	Tensão nominal	AC Entrada Retificador	number	volts	\N	f	\N	2012	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
14	retificador_numero_fases	Número de fases	AC Entrada Retificador	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	2013	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
15	retificador_frequencia_nominal	Frequência nominal	AC Entrada Retificador	number	Hz	\N	f	\N	2014	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
16	retificador_transformador_isolador	Transformador isolador	AC Entrada Retificador	boolean	\N	\N	t	true	2015	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
17	retificador_tipo_retificador	Tipo de retificador	AC Entrada Retificador	enum	\N	["6 Pulsos", "12 Pulsos", "PFC"]	f	\N	2016	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
18	retificador_disjuntor_entrada	Disjuntor de entrada	AC Entrada Retificador	boolean	\N	\N	t	false	2017	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
19	retificador_maximo_harmonico_entrada	Máximo harmônico de entrada	AC Entrada Retificador	number	%	\N	t	5	2018	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
20	retificador_filtro_harmonicos_entrada	Filtro de harmônicos de entrada	AC Entrada Retificador	boolean	\N	\N	t	false	2019	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
21	retificador_faixa_tolerancia_tensao_entrada	Faixa de tolerância de tensão de entrada	AC Entrada Retificador	number	%	\N	t	10	2020	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
22	retificador_faixa_tolerancia_frequencia_entrada	Faixa de tolerância de frequência de entrada	AC Entrada Retificador	number	%	\N	t	2	2021	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
23	bypass_tensao_nominal	Tensão nominal	AC Bypass	number	volts	\N	f	\N	3022	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
24	bypass_numero_fases	Número de fases	AC Bypass	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	3023	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
25	bypass_frequencia_nominal	Frequência nominal	AC Bypass	number	Hz	\N	f	\N	3024	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
26	bypass_transformador_isolador	Transformador isolador	AC Bypass	boolean	\N	\N	t	true	3025	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
27	bypass_disjuntor_entrada	Disjuntor de entrada	AC Bypass	boolean	\N	\N	t	false	3026	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
28	bypass_regulador_tensao	Regulador de tensão	AC Bypass	boolean	\N	\N	t	false	3027	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
29	bypass_faixa_tolerancia_tensao_entrada	Faixa de tolerância de tensão de entrada	AC Bypass	number	%	\N	t	10	3028	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
30	bypass_faixa_tolerancia_frequencia_entrada	Faixa de tolerância de frequência de entrada	AC Bypass	number	%	\N	t	2	3029	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
31	bypass_mecanico_requerido	Bypass mecânico requerido	AC Bypass	boolean	\N	\N	t	true	3030	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
32	saida_tensao_nominal	Tensão nominal	Saída AC	number	volts	\N	f	\N	4031	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
33	saida_numero_fases	Número de fases	Saída AC	enum	\N	["2Ph", "3Ph", "3PhN"]	t	"3PhN"	4032	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
34	saida_frequencia_nominal	Frequência nominal	Saída AC	number	Hz	\N	f	\N	4033	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
35	saida_transformador_isolador	Transformador isolador	Saída AC	boolean	\N	\N	t	true	4034	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
36	saida_chave_isolamento_saida	Chave de isolamento de saída	Saída AC	boolean	\N	\N	t	true	4035	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
37	saida_tolerancia_tensao_saida_carga_total	Tolerância de tensão de saída em carga total	Saída AC	number	%	\N	t	1	4036	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
38	saida_fator_potencia_saida	Fator de potência de saída	Saída AC	number	\N	\N	t	0.8	4037	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
39	saida_desequilibrio_tensao_carga_100	Desequilíbrio de tensão com 100% de desequilíbrio de carga	Saída AC	number	%	\N	f	\N	4038	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
40	bateria_tipo	Tipo de bateria	Armazenamento de Energia (Bateria)	enum	\N	["VRLA", "NiCad", "Vent", "SMC"]	t	"VRLA"	5039	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
41	bateria_autonomia_esperada	Autonomia esperada	Armazenamento de Energia (Bateria)	text	\N	\N	t	"2h"	5040	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
42	bateria_vida_util_projeto	Vida útil de projeto	Armazenamento de Energia (Bateria)	text	\N	\N	t	"5 anos"	5041	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
43	bateria_fabricante_desejado	Fabricante desejado	Armazenamento de Energia (Bateria)	text	\N	\N	f	\N	5042	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
44	desempenho_eficiencia_ac_ac_minima	Eficiência AC/AC mínima	Desempenho e Topologia	number	\N	\N	t	0.82	6043	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
45	desempenho_classe	Classe de desempenho	Desempenho e Topologia	text	\N	\N	t	"VFI SS 111"	6044	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
46	desempenho_configuracao	Configuração	Desempenho e Topologia	enum	\N	["Single", "Parallel", "Redundant", "Dual Bus", "Bypass"]	f	\N	6045	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
47	desempenho_topologia	Topologia	Desempenho e Topologia	enum	\N	["Double Conversion", "Line-interactive", "Standby"]	f	\N	6046	2026-03-06 12:19:53.27012-03	2026-03-06 12:19:53.27012-03
\.


--
-- Data for Name: submission_field_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.submission_field_settings (submission_id, field_id, enabled, updated_at) FROM stdin;
8	purchaser	t	2026-03-04 00:12:09.031784-03
8	purchaser_contact	t	2026-03-04 00:12:09.031784-03
8	specification_reference	t	2026-03-04 00:12:09.031784-03
8	date	t	2026-03-04 00:12:09.031784-03
8	project	t	2026-03-04 00:12:09.031784-03
8	ups_manufacturer	t	2026-03-04 00:12:09.031784-03
8	ups_model	t	2026-03-04 00:12:09.031784-03
8	quantity_of_units	f	2026-03-04 00:12:09.031784-03
8	application	f	2026-03-04 00:12:09.031784-03
8	tag_number	t	2026-03-04 00:12:09.031784-03
8	end_user	f	2026-03-04 00:12:09.031784-03
8	operating_mode	t	2026-03-04 00:12:09.031784-03
8	efficiency_classification	t	2026-03-04 00:12:09.031784-03
8	rated_output_active_power	t	2026-03-04 00:12:09.031784-03
8	rated_output_apparent_power	t	2026-03-04 00:12:09.031784-03
8	minimum_load_percentage_for_efficiency_declaration	t	2026-03-04 00:12:09.031784-03
8	ups_classification	t	2026-03-04 00:12:09.031784-03
8	power_circuit_topology	f	2026-03-04 00:12:09.031784-03
8	input_neutral_requirements	t	2026-03-04 00:12:09.031784-03
8	output_neutral_requirements	f	2026-03-04 00:12:09.031784-03
8	overload_capability	f	2026-03-04 00:12:09.031784-03
8	short_circuit_capability	t	2026-03-04 00:12:09.031784-03
8	output_power_factor	t	2026-03-04 00:12:09.031784-03
8	output_voltage_distortion_with_linear_load	f	2026-03-04 00:12:09.031784-03
8	output_voltage_distortion_with_non_linear_load	f	2026-03-04 00:12:09.031784-03
8	load_power_factor_range	f	2026-03-04 00:12:09.031784-03
8	operating_temperature_range	t	2026-03-04 00:12:09.031784-03
8	relative_humidity	t	2026-03-04 00:12:09.031784-03
8	altitude_without_derating	t	2026-03-04 00:12:09.031784-03
8	acoustic_noise	f	2026-03-04 00:12:09.031784-03
8	heat_dissipation	f	2026-03-04 00:12:09.031784-03
8	degree_of_protection_ip	t	2026-03-04 00:12:09.031784-03
8	storage_temperature_range	t	2026-03-04 00:12:09.031784-03
8	transport_temperature_range	t	2026-03-04 00:12:09.031784-03
8	input_voltage_and_number_of_phases	f	2026-03-04 00:12:09.031784-03
8	input_voltage_tolerance	f	2026-03-04 00:12:09.031784-03
8	input_frequency_and_tolerance	t	2026-03-04 00:12:09.031784-03
8	input_frequency_range_for_operation_on_bypass	f	2026-03-04 00:12:09.031784-03
8	input_power_factor_at_rated_load	f	2026-03-04 00:12:09.031784-03
8	input_current_distortion_at_rated_load	f	2026-03-04 00:12:09.031784-03
8	output_voltage_and_number_of_phases	f	2026-03-04 00:12:09.031784-03
8	output_voltage_regulation	f	2026-03-04 00:12:09.031784-03
8	output_voltage_tolerance	t	2026-03-04 00:12:09.031784-03
8	output_frequency_and_tolerance	f	2026-03-04 00:12:09.031784-03
8	voltage_unbalance	t	2026-03-04 00:12:09.031784-03
8	frequency_synchronization_range	f	2026-03-04 00:12:09.031784-03
8	transient_voltage_response	t	2026-03-04 00:12:09.031784-03
8	crest_factor_capability	f	2026-03-04 00:12:09.031784-03
8	static_bypass_type	f	2026-03-04 00:12:09.031784-03
8	bypass_voltage_and_phases	t	2026-03-04 00:12:09.031784-03
8	bypass_frequency_and_tolerance	t	2026-03-04 00:12:09.031784-03
8	transfer_conditions_to_bypass	t	2026-03-04 00:12:09.031784-03
8	maintenance_bypass_requirement	t	2026-03-04 00:12:09.031784-03
8	battery_type	f	2026-03-04 00:12:09.031784-03
8	battery_voltage	f	2026-03-04 00:12:09.031784-03
8	battery_autonomy_time_at_rated_load	f	2026-03-04 00:12:09.031784-03
8	recharge_time	t	2026-03-04 00:12:09.031784-03
8	number_of_battery_strings	f	2026-03-04 00:12:09.031784-03
8	battery_monitoring_features	f	2026-03-04 00:12:09.031784-03
8	local_hmi_display	t	2026-03-04 00:12:09.031784-03
8	dry_contacts	t	2026-03-04 00:12:09.031784-03
8	serial_communication_interface	t	2026-03-04 00:12:09.031784-03
8	network_communication_interface	t	2026-03-04 00:12:09.031784-03
8	remote_monitoring_software	t	2026-03-04 00:12:09.031784-03
8	event_logging	t	2026-03-04 00:12:09.031784-03
8	compliance_to_iec_62040_1	t	2026-03-04 00:12:09.031784-03
8	compliance_to_iec_62040_2	t	2026-03-04 00:12:09.031784-03
8	compliance_to_iec_62040_3	t	2026-03-04 00:12:09.031784-03
8	routine_test_requirements	t	2026-03-04 00:12:09.031784-03
8	type_test_evidence	t	2026-03-04 00:12:09.031784-03
8	factory_acceptance_test	t	2026-03-04 00:12:09.031784-03
8	site_acceptance_test	t	2026-03-04 00:12:09.031784-03
8	required_documents_and_drawings	t	2026-03-04 00:12:09.031784-03
9	purchaser	t	2026-03-04 09:54:57.071352-03
9	purchaser_contact	f	2026-03-04 09:54:57.071352-03
9	specification_reference	t	2026-03-04 09:54:57.071352-03
9	date	f	2026-03-04 09:54:57.071352-03
9	project	f	2026-03-04 09:54:57.071352-03
9	ups_manufacturer	f	2026-03-04 09:54:57.071352-03
9	ups_model	f	2026-03-04 09:54:57.071352-03
9	quantity_of_units	t	2026-03-04 09:54:57.071352-03
9	application	t	2026-03-04 09:54:57.071352-03
9	tag_number	f	2026-03-04 09:54:57.071352-03
9	end_user	f	2026-03-04 09:54:57.071352-03
9	operating_mode	f	2026-03-04 09:54:57.071352-03
9	efficiency_classification	f	2026-03-04 09:54:57.071352-03
9	rated_output_active_power	t	2026-03-04 09:54:57.071352-03
9	rated_output_apparent_power	t	2026-03-04 09:54:57.071352-03
9	minimum_load_percentage_for_efficiency_declaration	f	2026-03-04 09:54:57.071352-03
9	ups_classification	f	2026-03-04 09:54:57.071352-03
9	power_circuit_topology	f	2026-03-04 09:54:57.071352-03
9	input_neutral_requirements	t	2026-03-04 09:54:57.071352-03
9	output_neutral_requirements	t	2026-03-04 09:54:57.071352-03
9	overload_capability	f	2026-03-04 09:54:57.071352-03
9	short_circuit_capability	f	2026-03-04 09:54:57.071352-03
9	output_power_factor	f	2026-03-04 09:54:57.071352-03
9	output_voltage_distortion_with_linear_load	f	2026-03-04 09:54:57.071352-03
9	output_voltage_distortion_with_non_linear_load	f	2026-03-04 09:54:57.071352-03
9	load_power_factor_range	f	2026-03-04 09:54:57.071352-03
9	operating_temperature_range	f	2026-03-04 09:54:57.071352-03
9	relative_humidity	f	2026-03-04 09:54:57.071352-03
9	altitude_without_derating	f	2026-03-04 09:54:57.071352-03
9	acoustic_noise	f	2026-03-04 09:54:57.071352-03
9	heat_dissipation	f	2026-03-04 09:54:57.071352-03
9	degree_of_protection_ip	f	2026-03-04 09:54:57.071352-03
9	storage_temperature_range	f	2026-03-04 09:54:57.071352-03
9	transport_temperature_range	f	2026-03-04 09:54:57.071352-03
9	input_voltage_and_number_of_phases	f	2026-03-04 09:54:57.071352-03
9	input_voltage_tolerance	f	2026-03-04 09:54:57.071352-03
9	input_frequency_and_tolerance	f	2026-03-04 09:54:57.071352-03
9	input_frequency_range_for_operation_on_bypass	f	2026-03-04 09:54:57.071352-03
9	input_power_factor_at_rated_load	f	2026-03-04 09:54:57.071352-03
9	input_current_distortion_at_rated_load	f	2026-03-04 09:54:57.071352-03
9	output_voltage_and_number_of_phases	f	2026-03-04 09:54:57.071352-03
9	output_voltage_regulation	f	2026-03-04 09:54:57.071352-03
9	output_voltage_tolerance	f	2026-03-04 09:54:57.071352-03
9	output_frequency_and_tolerance	f	2026-03-04 09:54:57.071352-03
9	voltage_unbalance	f	2026-03-04 09:54:57.071352-03
9	frequency_synchronization_range	f	2026-03-04 09:54:57.071352-03
9	transient_voltage_response	f	2026-03-04 09:54:57.071352-03
9	crest_factor_capability	f	2026-03-04 09:54:57.071352-03
9	static_bypass_type	f	2026-03-04 09:54:57.071352-03
9	bypass_voltage_and_phases	f	2026-03-04 09:54:57.071352-03
9	bypass_frequency_and_tolerance	f	2026-03-04 09:54:57.071352-03
9	transfer_conditions_to_bypass	f	2026-03-04 09:54:57.071352-03
9	maintenance_bypass_requirement	f	2026-03-04 09:54:57.071352-03
9	battery_type	f	2026-03-04 09:54:57.071352-03
9	battery_voltage	f	2026-03-04 09:54:57.071352-03
9	battery_autonomy_time_at_rated_load	f	2026-03-04 09:54:57.071352-03
9	recharge_time	f	2026-03-04 09:54:57.071352-03
9	number_of_battery_strings	f	2026-03-04 09:54:57.071352-03
9	battery_monitoring_features	f	2026-03-04 09:54:57.071352-03
9	local_hmi_display	f	2026-03-04 09:54:57.071352-03
9	dry_contacts	f	2026-03-04 09:54:57.071352-03
9	serial_communication_interface	f	2026-03-04 09:54:57.071352-03
9	network_communication_interface	f	2026-03-04 09:54:57.071352-03
9	remote_monitoring_software	f	2026-03-04 09:54:57.071352-03
9	event_logging	f	2026-03-04 09:54:57.071352-03
9	compliance_to_iec_62040_1	f	2026-03-04 09:54:57.071352-03
9	compliance_to_iec_62040_2	f	2026-03-04 09:54:57.071352-03
9	compliance_to_iec_62040_3	f	2026-03-04 09:54:57.071352-03
9	routine_test_requirements	f	2026-03-04 09:54:57.071352-03
9	type_test_evidence	f	2026-03-04 09:54:57.071352-03
9	factory_acceptance_test	f	2026-03-04 09:54:57.071352-03
9	site_acceptance_test	f	2026-03-04 09:54:57.071352-03
9	required_documents_and_drawings	f	2026-03-04 09:54:57.071352-03
\.


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.submissions (id, token, created_at, updated_at, status) FROM stdin;
2	9540875b71204313b2791cc2506efd81	2026-03-03 17:40:36.859-03	2026-03-03 17:44:53.686-03	draft
4	0bdfa4a5ddce4810916ec2784c449b1d	2026-03-03 18:04:23.698-03	2026-03-03 18:04:23.698-03	draft
5	e3a73b79968c49c2a88628cf43358ee0	2026-03-03 18:05:42.889-03	2026-03-03 18:41:13.221-03	draft
6	778901d32f6a4a33b88bf1089fdb4bf7	2026-03-03 23:51:46.685-03	2026-03-03 23:51:46.685-03	draft
7	2f82c8e63feb4e819a27ca0c9fb547cc	2026-03-04 00:03:28.809-03	2026-03-04 00:03:28.811-03	draft
8	bc92d29e3a3e4557b7588ee5cdb84353	2026-03-04 00:12:08.987-03	2026-03-04 00:12:09.046-03	draft
9	a856327046464a608068b5a3438af706	2026-03-04 09:54:57.016-03	2026-03-04 09:58:02.575-03	draft
\.


--
-- Data for Name: token_creation_audit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.token_creation_audit (id, equipment_id, channel, ip_hash, browser_session_hash, user_agent_hash, created_at) FROM stdin;
43	\N	public	1e8bd7ea1666a0aa43faac6924963c0cbfa18d817336c038a90bfbd1b569eac3	a219b842908bde3b2a04dd5a773fb4de6b11040a6c358edb1a03cfc4ae7c7528	8dd685dc63f29b1ae3842b5d73670a9e218aa4f53b7f9b7257190aef47e4d11a	2026-03-07 01:44:16.760019-03
\.


--
-- Name: equipment_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipment_documents_id_seq', 3, true);


--
-- Name: equipment_enabled_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipment_enabled_fields_id_seq', 140, true);


--
-- Name: equipment_field_values_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipment_field_values_id_seq', 333, true);


--
-- Name: equipments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipments_id_seq', 44, true);


--
-- Name: field_profile_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.field_profile_fields_id_seq', 47, true);


--
-- Name: field_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.field_profiles_id_seq', 1, true);


--
-- Name: fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fields_id_seq', 3102, true);


--
-- Name: submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.submissions_id_seq', 9, true);


--
-- Name: token_creation_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.token_creation_audit_id_seq', 43, true);


--
-- Name: answers answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (submission_id, field_id);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (key);


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
-- Name: field_settings field_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_settings
    ADD CONSTRAINT field_settings_pkey PRIMARY KEY (field_id);


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
-- Name: submission_field_settings submission_field_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_field_settings
    ADD CONSTRAINT submission_field_settings_pkey PRIMARY KEY (submission_id, field_id);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: submissions submissions_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_token_key UNIQUE (token);


--
-- Name: token_creation_audit token_creation_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_creation_audit
    ADD CONSTRAINT token_creation_audit_pkey PRIMARY KEY (id);


--
-- Name: answers answers_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


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
-- Name: submission_field_settings submission_field_settings_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_field_settings
    ADD CONSTRAINT submission_field_settings_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: token_creation_audit token_creation_audit_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_creation_audit
    ADD CONSTRAINT token_creation_audit_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipments(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict t4nefhyqdmJ3eHEaazsfQlwSnjx3mHsvFQUDMhMXTDnleFFmKMk5lRIw8PTbEva

