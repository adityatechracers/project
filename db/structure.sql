--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_credits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_credits (
    id integer NOT NULL,
    amount numeric(9,2),
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_credits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_credits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_credits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_credits_id_seq OWNED BY account_credits.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activities (
    id integer NOT NULL,
    event_type character varying(255),
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    loggable_id integer,
    loggable_type character varying(255)
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: appointments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE appointments (
    id integer NOT NULL,
    user_id integer,
    job_id integer,
    start_datetime timestamp without time zone NOT NULL,
    end_datetime timestamp without time zone,
    notes text,
    email_before_appointment boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id integer,
    sent_reminder boolean DEFAULT false,
    sent_confirmation boolean DEFAULT true,
    deleted_at timestamp without time zone
);


--
-- Name: appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE appointments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE appointments_id_seq OWNED BY appointments.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying(255),
    slug character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: change_orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE change_orders (
    id integer NOT NULL,
    change_description text DEFAULT ''::text NOT NULL,
    user_id integer,
    proposal_id integer,
    version_id integer,
    proposal_amount_change numeric(9,2) DEFAULT 0,
    job_amount_change numeric(9,2) DEFAULT 0,
    budgeted_hours_change integer DEFAULT 0,
    expected_start_date_new date,
    expected_end_date_new date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: change_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE change_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE change_orders_id_seq OWNED BY change_orders.id;


--
-- Name: communications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE communications (
    id integer NOT NULL,
    job_id integer,
    user_id integer,
    details text DEFAULT ''::text NOT NULL,
    outcome character varying(255),
    action character varying(255),
    datetime timestamp without time zone,
    datetime_exact boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    next_step character varying(255),
    type character varying(255),
    organization_id integer,
    note character varying(255),
    deleted_at timestamp without time zone
);


--
-- Name: communications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE communications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: communications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE communications_id_seq OWNED BY communications.id;


--
-- Name: contact_ratings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_ratings (
    id integer NOT NULL,
    contact_id integer,
    rating_id integer,
    stage text
);


--
-- Name: contact_ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_ratings_id_seq OWNED BY contact_ratings.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts (
    id integer NOT NULL,
    first_name character varying(255) DEFAULT ''::character varying NOT NULL,
    last_name character varying(255) DEFAULT ''::character varying NOT NULL,
    phone character varying(255) DEFAULT ''::character varying NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    address character varying(255) DEFAULT ''::character varying NOT NULL,
    address2 character varying(255),
    city character varying(255) DEFAULT ''::character varying NOT NULL,
    region character varying(255),
    zip character varying(255) DEFAULT ''::character varying NOT NULL,
    country character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id integer,
    company character varying(255),
    deleted_at timestamp without time zone,
    time_zone character varying(255),
    zestimate integer,
    discard_zestimate boolean DEFAULT false
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: crews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE crews (
    id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id integer,
    color character varying(255),
    deleted_at timestamp without time zone,
    wage_rate numeric(9,2)
);


--
-- Name: crews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE crews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE crews_id_seq OWNED BY crews.id;


--
-- Name: crews_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE crews_users (
    id integer NOT NULL,
    user_id integer,
    crew_id integer
);


--
-- Name: crews_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE crews_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crews_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE crews_users_id_seq OWNED BY crews_users.id;


--
-- Name: email_template_token_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE email_template_token_sets (
    id integer NOT NULL,
    template_name character varying(255),
    available_tokens text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: email_template_token_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_template_token_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_template_token_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_template_token_sets_id_seq OWNED BY email_template_token_sets.id;


--
-- Name: email_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE email_templates (
    id integer NOT NULL,
    organization_id integer,
    name character varying(255),
    subject text DEFAULT ''::text NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    enabled boolean,
    master boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    lang character varying(255) DEFAULT 'en'::character varying NOT NULL,
    mail_to_cc character varying(255),
    priority integer
);


--
-- Name: email_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_templates_id_seq OWNED BY email_templates.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    name character varying(255),
    creator character varying(255),
    start timestamp without time zone,
    status character varying(255),
    link character varying(255),
    calendar character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: expense_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE expense_categories (
    id integer NOT NULL,
    organization_id integer,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    major_expense boolean DEFAULT false NOT NULL
);


--
-- Name: expense_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE expense_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: expense_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE expense_categories_id_seq OWNED BY expense_categories.id;


--
-- Name: expenses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE expenses (
    id integer NOT NULL,
    job_id integer NOT NULL,
    organization_id integer,
    amount numeric(9,2) DEFAULT 0 NOT NULL,
    description text,
    date_of_expense date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    user_id integer,
    expense_category_id integer,
    vendor_category_id integer
);


--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE expenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE expenses_id_seq OWNED BY expenses.id;


--
-- Name: froala_image_uploads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE froala_image_uploads (
    id integer NOT NULL,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image character varying(255) NOT NULL
);


--
-- Name: froala_image_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE froala_image_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: froala_image_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE froala_image_uploads_id_seq OWNED BY froala_image_uploads.id;


--
-- Name: geocodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geocodes (
    id integer NOT NULL,
    latitude numeric(15,12),
    longitude numeric(15,12),
    query character varying(255),
    street character varying(255),
    locality character varying(255),
    region character varying(255),
    postal_code character varying(255),
    country character varying(255),
    "precision" character varying(255)
);


--
-- Name: geocodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geocodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geocodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geocodes_id_seq OWNED BY geocodes.id;


--
-- Name: geocodings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geocodings (
    id integer NOT NULL,
    geocodable_id integer,
    geocode_id integer,
    geocodable_type character varying(255)
);


--
-- Name: geocodings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geocodings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geocodings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geocodings_id_seq OWNED BY geocodings.id;


--
-- Name: google_calendars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE google_calendars (
    id integer NOT NULL,
    calendar_id character varying(255),
    title character varying(255),
    time_zone character varying(255),
    access_role character varying(255),
    "primary" boolean DEFAULT false NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    shared boolean DEFAULT false NOT NULL
);


--
-- Name: google_calendars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE google_calendars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: google_calendars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE google_calendars_id_seq OWNED BY google_calendars.id;


--
-- Name: google_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE google_events (
    id integer NOT NULL,
    event_id text,
    title character varying(255),
    start_datetime timestamp without time zone,
    end_datetime timestamp without time zone,
    status character varying(255),
    description text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    google_calendar_id integer
);


--
-- Name: google_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE google_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: google_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE google_events_id_seq OWNED BY google_events.id;


--
-- Name: inquiries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inquiries (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: inquiries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inquiries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inquiries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inquiries_id_seq OWNED BY inquiries.id;


--
-- Name: job_feedbacks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_feedbacks (
    id integer NOT NULL,
    job_id integer,
    name character varying(255),
    feedback text,
    complete boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    customer_sig text,
    instructions_displayed text
);


--
-- Name: job_feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_feedbacks_id_seq OWNED BY job_feedbacks.id;


--
-- Name: job_schedule_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_schedule_entries (
    id integer NOT NULL,
    job_id integer NOT NULL,
    start_datetime timestamp without time zone NOT NULL,
    end_datetime timestamp without time zone NOT NULL,
    notes text,
    is_touch_up boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    system_generated boolean DEFAULT false NOT NULL,
    crew_id integer,
    sent_notification boolean DEFAULT false NOT NULL,
    should_send_notification boolean DEFAULT false
);


--
-- Name: job_schedule_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_schedule_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_schedule_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_schedule_entries_id_seq OWNED BY job_schedule_entries.id;


--
-- Name: job_schedule_entry_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_schedule_entry_users (
    id integer NOT NULL,
    user_id integer,
    job_schedule_entry_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_schedule_entry_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_schedule_entry_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_schedule_entry_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_schedule_entry_users_id_seq OWNED BY job_schedule_entry_users.id;


--
-- Name: job_schedule_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_schedule_notifications (
    id integer NOT NULL,
    job_schedule_entry_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_schedule_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_schedule_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_schedule_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_schedule_notifications_id_seq OWNED BY job_schedule_notifications.id;


--
-- Name: job_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_users (
    id integer NOT NULL,
    user_id integer,
    job_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: job_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_users_id_seq OWNED BY job_users.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id integer NOT NULL,
    title character varying(255),
    lead_source_id integer,
    contact_id integer,
    details text,
    probability integer,
    state character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    email_customer boolean DEFAULT false,
    crew_id integer,
    organization_id integer,
    estimated_amount numeric(9,2) DEFAULT 0,
    state_change_date timestamp without time zone,
    deleted_at timestamp without time zone,
    added_by integer,
    crew_wage_rate numeric(9,2),
    crew_expense_id integer,
    guid character varying(255),
    expected_start_date date,
    expected_end_date date,
    date_of_first_job_schedule_entry date,
    dead boolean DEFAULT false NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: lead_sources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lead_sources (
    id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    modifiable boolean DEFAULT true,
    deleted_at timestamp without time zone
);


--
-- Name: lead_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lead_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lead_sources_id_seq OWNED BY lead_sources.id;


--
-- Name: lead_uploads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lead_uploads (
    id integer NOT NULL,
    csv_file_name character varying(255),
    csv_content_type character varying(255),
    csv_file_size integer,
    csv_updated_at timestamp without time zone,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lead_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lead_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lead_uploads_id_seq OWNED BY lead_uploads.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    guid character varying(255),
    premium_override boolean,
    stripe_plan_id character varying(255),
    stripe_customer_token character varying(255),
    last_payment_successful boolean,
    last_payment_date timestamp without time zone,
    stripe_plan_name character varying(255),
    name_on_credit_card character varying(255),
    last_four_digits character varying(255),
    address character varying(255),
    address_2 character varying(255),
    city character varying(255),
    region character varying(255),
    zip character varying(255),
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    phone character varying(255),
    fax character varying(255),
    license_number character varying(255),
    logo_file_name character varying(255),
    logo_content_type character varying(255),
    logo_file_size integer,
    logo_updated_at timestamp without time zone,
    timecard_lock_period character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true,
    trial_start_date timestamp without time zone,
    embed_help_text text,
    embed_thank_you text,
    time_zone character varying(255),
    trial_end_date timestamp without time zone,
    country character varying(255),
    proposal_style character varying(255) DEFAULT 'CorkCRM'::character varying NOT NULL,
    uses_crew_commissions boolean DEFAULT false NOT NULL,
    website_url character varying(255),
    proposal_banner_text text,
    proposal_paper_size character varying(255) DEFAULT 'A4'::character varying NOT NULL,
    default_signature text,
    auto_sign_proposals boolean DEFAULT false NOT NULL,
    feedback_portal_text text,
    feedback_portal_show_signature boolean DEFAULT false NOT NULL,
    proposal_options text,
    num_allowed_users integer DEFAULT 1 NOT NULL,
    parent_organization_id integer,
    user_signatures text,
    last_failed_payment_date date,
    show_zestimate boolean,
    is_parse boolean DEFAULT false,
    show_customer_rating boolean
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: page_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE page_items (
    id integer NOT NULL,
    name character varying(255),
    page_id integer,
    content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: page_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE page_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE page_items_id_seq OWNED BY page_items.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pages (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pages_id_seq OWNED BY pages.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payments (
    id integer NOT NULL,
    job_id integer NOT NULL,
    organization_id integer,
    date_paid date,
    amount numeric(9,2) DEFAULT 0 NOT NULL,
    payment_type character varying(255),
    notes character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE posts (
    id integer NOT NULL,
    title character varying(255),
    meta_title character varying(255),
    meta_description text,
    summary text,
    description text,
    slug character varying(255),
    published_date timestamp without time zone,
    category_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: proposal_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE proposal_files (
    id integer NOT NULL,
    file character varying(255),
    original_file_name character varying(255),
    proposal_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type character varying(255)
);


--
-- Name: proposal_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE proposal_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposal_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE proposal_files_id_seq OWNED BY proposal_files.id;


--
-- Name: proposal_item_responses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE proposal_item_responses (
    id integer NOT NULL,
    proposal_template_item_id integer,
    proposal_section_response_id integer,
    include_exclude_option character varying(255),
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255)
);


--
-- Name: proposal_item_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE proposal_item_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposal_item_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE proposal_item_responses_id_seq OWNED BY proposal_item_responses.id;


--
-- Name: proposal_section_responses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE proposal_section_responses (
    id integer NOT NULL,
    proposal_template_section_id integer,
    proposal_id integer,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: proposal_section_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE proposal_section_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposal_section_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE proposal_section_responses_id_seq OWNED BY proposal_section_responses.id;


--
-- Name: proposal_template_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE proposal_template_items (
    id integer NOT NULL,
    name character varying(255),
    default_note_text text,
    help_text character varying(255),
    default_include_exclude_option character varying(255),
    proposal_template_section_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "position" integer,
    deleted_at timestamp without time zone
);


--
-- Name: proposal_template_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE proposal_template_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposal_template_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE proposal_template_items_id_seq OWNED BY proposal_template_items.id;


--
-- Name: proposal_template_sections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE proposal_template_sections (
    id integer NOT NULL,
    name character varying(255),
    default_description text,
    proposal_template_id integer,
    background_color character varying(255),
    foreground_color character varying(255),
    show_include_exclude_options boolean DEFAULT true,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: proposal_template_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE proposal_template_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposal_template_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE proposal_template_sections_id_seq OWNED BY proposal_template_sections.id;


--
-- Name: proposal_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE proposal_templates (
    id integer NOT NULL,
    name character varying(255),
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true,
    agreement text,
    deleted_at timestamp without time zone,
    type character varying(255)
);


--
-- Name: proposal_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE proposal_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposal_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE proposal_templates_id_seq OWNED BY proposal_templates.id;


--
-- Name: proposals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE proposals (
    title character varying(255),
    job_id integer NOT NULL,
    proposal_template_id integer,
    proposal_number integer,
    address character varying(255),
    city character varying(255),
    region character varying(255),
    zip character varying(255),
    license_number character varying(255),
    proposal_date date,
    sales_person_id integer,
    contractor_id integer,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    address2 character varying(255),
    country character varying(255),
    notes text,
    signed_by integer,
    customer_sig_printed_name character varying(255),
    customer_sig text,
    customer_sig_user_id integer,
    contractor_sig_printed_name character varying(255),
    contractor_sig text,
    contractor_sig_user_id integer,
    proposal_state character varying(255),
    amount numeric(9,2) DEFAULT 0 NOT NULL,
    agreement text,
    customer_sig_datetime timestamp without time zone,
    contractor_sig_datetime timestamp without time zone,
    guid character varying(255) NOT NULL,
    budgeted_hours integer DEFAULT 0 NOT NULL,
    id integer NOT NULL,
    deleted_at timestamp without time zone,
    added_by integer,
    expected_start_date date,
    expected_end_date date,
    deposit_amount numeric(5,2) DEFAULT 0,
    proposal_address character varying(255)
);


--
-- Name: proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE proposals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE proposals_id_seq OWNED BY proposals.id;


--
-- Name: quick_book_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_book_sessions (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    secret character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    realm_id character varying(255) NOT NULL,
    reconnect_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quick_book_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quick_book_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_book_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quick_book_sessions_id_seq OWNED BY quick_book_sessions.id;


--
-- Name: quick_books_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_books_accounts (
    organization_id integer NOT NULL,
    quick_books_id character varying(255) NOT NULL,
    type character varying(255),
    company_id character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quick_books_customers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_books_customers (
    ref character varying(255) NOT NULL,
    organization_id integer NOT NULL,
    company_id character varying(255) NOT NULL,
    quick_books_id character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact_id integer NOT NULL
);


--
-- Name: quick_books_estimates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_books_estimates (
    id integer NOT NULL,
    sub_customer_id integer NOT NULL,
    quick_books_id character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quick_books_estimates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quick_books_estimates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_books_estimates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quick_books_estimates_id_seq OWNED BY quick_books_estimates.id;


--
-- Name: quick_books_expense_line_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_books_expense_line_items (
    qb_purchase_id character varying(255) NOT NULL,
    qb_line_item_id character varying(255) NOT NULL,
    amount numeric(8,2) NOT NULL,
    description character varying(255),
    expense_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sub_customer_id integer NOT NULL
);


--
-- Name: quick_books_invoices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_books_invoices (
    id integer NOT NULL,
    sub_customer_id integer NOT NULL,
    quick_books_id character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    amount numeric(8,2) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quick_books_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quick_books_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_books_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quick_books_invoices_id_seq OWNED BY quick_books_invoices.id;


--
-- Name: quick_books_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_books_items (
    organization_id integer NOT NULL,
    quick_books_id character varying(255) NOT NULL,
    name character varying(255),
    company_id character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quick_books_payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_books_payments (
    id integer NOT NULL,
    quick_books_id character varying(255) NOT NULL,
    amount numeric(8,2) NOT NULL,
    notes character varying(255),
    payment_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sub_customer_id integer NOT NULL
);


--
-- Name: quick_books_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quick_books_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_books_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quick_books_payments_id_seq OWNED BY quick_books_payments.id;


--
-- Name: quick_books_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_books_sessions (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    secret character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    realm_id character varying(255) NOT NULL,
    reconnect_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quick_books_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quick_books_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_books_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quick_books_sessions_id_seq OWNED BY quick_books_sessions.id;


--
-- Name: quick_books_sub_customers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quick_books_sub_customers (
    id integer NOT NULL,
    proposal_id integer NOT NULL,
    quick_books_id character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    customer_id character varying(255)
);


--
-- Name: quick_books_sub_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quick_books_sub_customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_books_sub_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quick_books_sub_customers_id_seq OWNED BY quick_books_sub_customers.id;


--
-- Name: quotes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quotes (
    id integer NOT NULL,
    quote character varying(255),
    author character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quotes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quotes_id_seq OWNED BY quotes.id;


--
-- Name: ratings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ratings (
    id integer NOT NULL,
    rating text
);


--
-- Name: ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ratings_id_seq OWNED BY ratings.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255),
    resource_id integer,
    resource_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: timecards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE timecards (
    id integer NOT NULL,
    job_id integer NOT NULL,
    organization_id integer,
    user_id integer NOT NULL,
    start_datetime timestamp without time zone NOT NULL,
    end_datetime timestamp without time zone NOT NULL,
    notes text,
    state character varying(255),
    amount numeric(9,2),
    duration double precision,
    pay_rate numeric(9,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: timecards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE timecards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timecards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE timecards_id_seq OWNED BY timecards.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id integer,
    last_name character varying(255) DEFAULT ''::character varying NOT NULL,
    first_name character varying(255) DEFAULT ''::character varying NOT NULL,
    phone character varying(255),
    address character varying(255),
    address2 character varying(255),
    city character varying(255),
    region character varying(255),
    zip character varying(255),
    active boolean DEFAULT true,
    can_view_leads boolean DEFAULT true,
    can_manage_leads boolean DEFAULT true,
    can_view_appointments boolean DEFAULT true,
    can_manage_appointments boolean DEFAULT true,
    can_view_all_jobs boolean DEFAULT true,
    can_view_own_jobs boolean DEFAULT true,
    can_manage_jobs boolean DEFAULT true,
    can_view_all_proposals boolean DEFAULT true,
    can_view_assigned_proposals boolean DEFAULT true,
    can_manage_proposals boolean DEFAULT true,
    can_be_assigned_appointments boolean DEFAULT true,
    can_be_assigned_jobs boolean DEFAULT true,
    role character varying(255) DEFAULT 'Owner'::character varying,
    country character varying(255),
    pay_rate numeric(9,2) DEFAULT 0,
    admin_can_view_failing_credit_cards boolean DEFAULT false,
    admin_can_view_billing_history boolean DEFAULT false,
    admin_can_manage_accounts boolean DEFAULT false,
    admin_can_manage_trials boolean DEFAULT false,
    admin_can_manage_cms boolean DEFAULT false,
    admin_can_become_user boolean DEFAULT false,
    admin_receives_notifications boolean DEFAULT false,
    super boolean DEFAULT false,
    can_make_timecards boolean DEFAULT true,
    language character varying(255) DEFAULT 'en'::character varying NOT NULL,
    can_view_all_contacts boolean DEFAULT false,
    can_manage_all_contacts boolean DEFAULT false,
    appointments_color character varying(255),
    google_auth_token character varying(255),
    google_auth_refresh_token character varying(255),
    google_auth_expires_at timestamp without time zone,
    connected_to_google boolean DEFAULT false NOT NULL,
    google_email character varying(255),
    image character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users_roles (
    user_id integer,
    role_id integer
);


--
-- Name: vendor_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vendor_categories (
    id integer NOT NULL,
    organization_id integer,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: vendor_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vendor_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vendor_categories_id_seq OWNED BY vendor_categories.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone,
    object_changes text
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_credits ALTER COLUMN id SET DEFAULT nextval('account_credits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY appointments ALTER COLUMN id SET DEFAULT nextval('appointments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY change_orders ALTER COLUMN id SET DEFAULT nextval('change_orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY communications ALTER COLUMN id SET DEFAULT nextval('communications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_ratings ALTER COLUMN id SET DEFAULT nextval('contact_ratings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY crews ALTER COLUMN id SET DEFAULT nextval('crews_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY crews_users ALTER COLUMN id SET DEFAULT nextval('crews_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_template_token_sets ALTER COLUMN id SET DEFAULT nextval('email_template_token_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_templates ALTER COLUMN id SET DEFAULT nextval('email_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY expense_categories ALTER COLUMN id SET DEFAULT nextval('expense_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY expenses ALTER COLUMN id SET DEFAULT nextval('expenses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY froala_image_uploads ALTER COLUMN id SET DEFAULT nextval('froala_image_uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geocodes ALTER COLUMN id SET DEFAULT nextval('geocodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geocodings ALTER COLUMN id SET DEFAULT nextval('geocodings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY google_calendars ALTER COLUMN id SET DEFAULT nextval('google_calendars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY google_events ALTER COLUMN id SET DEFAULT nextval('google_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inquiries ALTER COLUMN id SET DEFAULT nextval('inquiries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_feedbacks ALTER COLUMN id SET DEFAULT nextval('job_feedbacks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_schedule_entries ALTER COLUMN id SET DEFAULT nextval('job_schedule_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_schedule_entry_users ALTER COLUMN id SET DEFAULT nextval('job_schedule_entry_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_schedule_notifications ALTER COLUMN id SET DEFAULT nextval('job_schedule_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_users ALTER COLUMN id SET DEFAULT nextval('job_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lead_sources ALTER COLUMN id SET DEFAULT nextval('lead_sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lead_uploads ALTER COLUMN id SET DEFAULT nextval('lead_uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY page_items ALTER COLUMN id SET DEFAULT nextval('page_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposal_files ALTER COLUMN id SET DEFAULT nextval('proposal_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposal_item_responses ALTER COLUMN id SET DEFAULT nextval('proposal_item_responses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposal_section_responses ALTER COLUMN id SET DEFAULT nextval('proposal_section_responses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposal_template_items ALTER COLUMN id SET DEFAULT nextval('proposal_template_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposal_template_sections ALTER COLUMN id SET DEFAULT nextval('proposal_template_sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposal_templates ALTER COLUMN id SET DEFAULT nextval('proposal_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposals ALTER COLUMN id SET DEFAULT nextval('proposals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quick_book_sessions ALTER COLUMN id SET DEFAULT nextval('quick_book_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quick_books_estimates ALTER COLUMN id SET DEFAULT nextval('quick_books_estimates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quick_books_invoices ALTER COLUMN id SET DEFAULT nextval('quick_books_invoices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quick_books_payments ALTER COLUMN id SET DEFAULT nextval('quick_books_payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quick_books_sessions ALTER COLUMN id SET DEFAULT nextval('quick_books_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quick_books_sub_customers ALTER COLUMN id SET DEFAULT nextval('quick_books_sub_customers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quotes ALTER COLUMN id SET DEFAULT nextval('quotes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings ALTER COLUMN id SET DEFAULT nextval('ratings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY timecards ALTER COLUMN id SET DEFAULT nextval('timecards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vendor_categories ALTER COLUMN id SET DEFAULT nextval('vendor_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: account_credits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_credits
    ADD CONSTRAINT account_credits_pkey PRIMARY KEY (id);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: change_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY change_orders
    ADD CONSTRAINT change_orders_pkey PRIMARY KEY (id);


--
-- Name: communications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY communications
    ADD CONSTRAINT communications_pkey PRIMARY KEY (id);


--
-- Name: contact_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_ratings
    ADD CONSTRAINT contact_ratings_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: crews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY crews
    ADD CONSTRAINT crews_pkey PRIMARY KEY (id);


--
-- Name: crews_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY crews_users
    ADD CONSTRAINT crews_users_pkey PRIMARY KEY (id);


--
-- Name: email_template_token_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_template_token_sets
    ADD CONSTRAINT email_template_token_sets_pkey PRIMARY KEY (id);


--
-- Name: email_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_templates
    ADD CONSTRAINT email_templates_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: expense_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY expense_categories
    ADD CONSTRAINT expense_categories_pkey PRIMARY KEY (id);


--
-- Name: expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


--
-- Name: froala_image_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY froala_image_uploads
    ADD CONSTRAINT froala_image_uploads_pkey PRIMARY KEY (id);


--
-- Name: geocodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geocodes
    ADD CONSTRAINT geocodes_pkey PRIMARY KEY (id);


--
-- Name: geocodings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geocodings
    ADD CONSTRAINT geocodings_pkey PRIMARY KEY (id);


--
-- Name: google_calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY google_calendars
    ADD CONSTRAINT google_calendars_pkey PRIMARY KEY (id);


--
-- Name: google_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY google_events
    ADD CONSTRAINT google_events_pkey PRIMARY KEY (id);


--
-- Name: inquiries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inquiries
    ADD CONSTRAINT inquiries_pkey PRIMARY KEY (id);


--
-- Name: job_feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_feedbacks
    ADD CONSTRAINT job_feedbacks_pkey PRIMARY KEY (id);


--
-- Name: job_schedule_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_schedule_entries
    ADD CONSTRAINT job_schedule_entries_pkey PRIMARY KEY (id);


--
-- Name: job_schedule_entry_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_schedule_entry_users
    ADD CONSTRAINT job_schedule_entry_users_pkey PRIMARY KEY (id);


--
-- Name: job_schedule_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_schedule_notifications
    ADD CONSTRAINT job_schedule_notifications_pkey PRIMARY KEY (id);


--
-- Name: job_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_users
    ADD CONSTRAINT job_users_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: lead_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lead_sources
    ADD CONSTRAINT lead_sources_pkey PRIMARY KEY (id);


--
-- Name: lead_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lead_uploads
    ADD CONSTRAINT lead_uploads_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: page_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY page_items
    ADD CONSTRAINT page_items_pkey PRIMARY KEY (id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: proposal_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY proposal_files
    ADD CONSTRAINT proposal_files_pkey PRIMARY KEY (id);


--
-- Name: proposal_item_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY proposal_item_responses
    ADD CONSTRAINT proposal_item_responses_pkey PRIMARY KEY (id);


--
-- Name: proposal_section_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY proposal_section_responses
    ADD CONSTRAINT proposal_section_responses_pkey PRIMARY KEY (id);


--
-- Name: proposal_template_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY proposal_template_items
    ADD CONSTRAINT proposal_template_items_pkey PRIMARY KEY (id);


--
-- Name: proposal_template_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY proposal_template_sections
    ADD CONSTRAINT proposal_template_sections_pkey PRIMARY KEY (id);


--
-- Name: proposal_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY proposal_templates
    ADD CONSTRAINT proposal_templates_pkey PRIMARY KEY (id);


--
-- Name: proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY proposals
    ADD CONSTRAINT proposals_pkey PRIMARY KEY (id);


--
-- Name: quick_book_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quick_book_sessions
    ADD CONSTRAINT quick_book_sessions_pkey PRIMARY KEY (id);


--
-- Name: quick_books_estimates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quick_books_estimates
    ADD CONSTRAINT quick_books_estimates_pkey PRIMARY KEY (id);


--
-- Name: quick_books_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quick_books_invoices
    ADD CONSTRAINT quick_books_invoices_pkey PRIMARY KEY (id);


--
-- Name: quick_books_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quick_books_payments
    ADD CONSTRAINT quick_books_payments_pkey PRIMARY KEY (id);


--
-- Name: quick_books_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quick_books_sessions
    ADD CONSTRAINT quick_books_sessions_pkey PRIMARY KEY (id);


--
-- Name: quick_books_sub_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quick_books_sub_customers
    ADD CONSTRAINT quick_books_sub_customers_pkey PRIMARY KEY (id);


--
-- Name: quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT quotes_pkey PRIMARY KEY (id);


--
-- Name: ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: timecards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY timecards
    ADD CONSTRAINT timecards_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendor_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vendor_categories
    ADD CONSTRAINT vendor_categories_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: contacts_searchable_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX contacts_searchable_address ON contacts USING gin (to_tsvector('english'::regconfig, (address)::text));


--
-- Name: contacts_searchable_address2; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX contacts_searchable_address2 ON contacts USING gin (to_tsvector('english'::regconfig, (address2)::text));


--
-- Name: contacts_searchable_city; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX contacts_searchable_city ON contacts USING gin (to_tsvector('english'::regconfig, (city)::text));


--
-- Name: contacts_searchable_country; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX contacts_searchable_country ON contacts USING gin (to_tsvector('english'::regconfig, (country)::text));


--
-- Name: contacts_searchable_first_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX contacts_searchable_first_name ON contacts USING gin (to_tsvector('english'::regconfig, (first_name)::text));


--
-- Name: contacts_searchable_last_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX contacts_searchable_last_name ON contacts USING gin (to_tsvector('english'::regconfig, (last_name)::text));


--
-- Name: contacts_searchable_region; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX contacts_searchable_region ON contacts USING gin (to_tsvector('english'::regconfig, (region)::text));


--
-- Name: contacts_searchable_zip; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX contacts_searchable_zip ON contacts USING gin (to_tsvector('english'::regconfig, (zip)::text));


--
-- Name: geocodes_country_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodes_country_index ON geocodes USING btree (country);


--
-- Name: geocodes_latitude_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodes_latitude_index ON geocodes USING btree (latitude);


--
-- Name: geocodes_locality_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodes_locality_index ON geocodes USING btree (locality);


--
-- Name: geocodes_longitude_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodes_longitude_index ON geocodes USING btree (longitude);


--
-- Name: geocodes_postal_code_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodes_postal_code_index ON geocodes USING btree (postal_code);


--
-- Name: geocodes_precision_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodes_precision_index ON geocodes USING btree ("precision");


--
-- Name: geocodes_query_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX geocodes_query_index ON geocodes USING btree (query);


--
-- Name: geocodes_region_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodes_region_index ON geocodes USING btree (region);


--
-- Name: geocodings_geocodable_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodings_geocodable_id_index ON geocodings USING btree (geocodable_id);


--
-- Name: geocodings_geocodable_type_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodings_geocodable_type_index ON geocodings USING btree (geocodable_type);


--
-- Name: geocodings_geocode_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX geocodings_geocode_id_index ON geocodings USING btree (geocode_id);


--
-- Name: index_account_credits_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_credits_on_org_id ON account_credits USING btree (organization_id);


--
-- Name: index_appointments_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_appointments_on_job_id ON appointments USING btree (job_id);


--
-- Name: index_appointments_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_appointments_on_org_id ON appointments USING btree (organization_id);


--
-- Name: index_appointments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_appointments_on_user_id ON appointments USING btree (user_id);


--
-- Name: index_communications_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_communications_on_job_id ON communications USING btree (job_id);


--
-- Name: index_communications_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_communications_on_org_id ON communications USING btree (organization_id);


--
-- Name: index_communications_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_communications_on_user_id ON communications USING btree (user_id);


--
-- Name: index_contacts_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_org_id ON contacts USING btree (organization_id);


--
-- Name: index_crews_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_crews_on_org_id ON crews USING btree (organization_id);


--
-- Name: index_crews_users_on_crew_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_crews_users_on_crew_id ON crews_users USING btree (crew_id);


--
-- Name: index_crews_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_crews_users_on_user_id ON crews_users USING btree (user_id);


--
-- Name: index_email_templates_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_email_templates_on_org_id ON email_templates USING btree (organization_id);


--
-- Name: index_events_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_user_id ON events USING btree (user_id);


--
-- Name: index_expenses_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_expenses_on_job_id ON expenses USING btree (job_id);


--
-- Name: index_expenses_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_expenses_on_org_id ON expenses USING btree (organization_id);


--
-- Name: index_google_calendars_on_calendar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_google_calendars_on_calendar_id ON google_calendars USING btree (calendar_id);


--
-- Name: index_google_calendars_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_google_calendars_on_user_id ON google_calendars USING btree (user_id);


--
-- Name: index_google_events_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_google_events_on_event_id ON google_events USING btree (event_id);


--
-- Name: index_google_events_on_google_calendar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_google_events_on_google_calendar_id ON google_events USING btree (google_calendar_id);


--
-- Name: index_google_events_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_google_events_on_user_id ON google_events USING btree (user_id);


--
-- Name: index_job_schedule_entry_users_on_job_schedule_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_job_schedule_entry_users_on_job_schedule_entry_id ON job_schedule_entry_users USING btree (job_schedule_entry_id);


--
-- Name: index_job_schedule_entry_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_job_schedule_entry_users_on_user_id ON job_schedule_entry_users USING btree (user_id);


--
-- Name: index_job_schedule_notifications_on_job_schedule_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_job_schedule_notifications_on_job_schedule_entry_id ON job_schedule_notifications USING btree (job_schedule_entry_id);


--
-- Name: index_job_users_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_job_users_on_job_id ON job_users USING btree (job_id);


--
-- Name: index_job_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_job_users_on_user_id ON job_users USING btree (user_id);


--
-- Name: index_jobs_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_contact_id ON jobs USING btree (contact_id);


--
-- Name: index_jobs_on_crew_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_crew_id ON jobs USING btree (crew_id);


--
-- Name: index_jobs_on_lead_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_lead_source_id ON jobs USING btree (lead_source_id);


--
-- Name: index_jobs_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_org_id ON jobs USING btree (organization_id);


--
-- Name: index_lead_sources_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_lead_sources_on_org_id ON lead_sources USING btree (organization_id);


--
-- Name: index_payments_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_job_id ON payments USING btree (job_id);


--
-- Name: index_payments_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_org_id ON payments USING btree (organization_id);


--
-- Name: index_proposal_item_responses_on_section_response_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposal_item_responses_on_section_response_id ON proposal_item_responses USING btree (proposal_section_response_id);


--
-- Name: index_proposal_item_responses_on_template_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposal_item_responses_on_template_item_id ON proposal_item_responses USING btree (proposal_template_item_id);


--
-- Name: index_proposal_section_responses_on_proposal_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposal_section_responses_on_proposal_id ON proposal_section_responses USING btree (proposal_id);


--
-- Name: index_proposal_section_responses_on_template_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposal_section_responses_on_template_section_id ON proposal_section_responses USING btree (proposal_template_section_id);


--
-- Name: index_proposal_template_items_on_template_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposal_template_items_on_template_section_id ON proposal_template_items USING btree (proposal_template_section_id);


--
-- Name: index_proposal_template_sections_on_template_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposal_template_sections_on_template_id ON proposal_template_sections USING btree (proposal_template_id);


--
-- Name: index_proposal_templates_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposal_templates_on_org_id ON proposal_templates USING btree (organization_id);


--
-- Name: index_proposals_on_contractor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposals_on_contractor_id ON proposals USING btree (contractor_id);


--
-- Name: index_proposals_on_contractor_sig_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposals_on_contractor_sig_user_id ON proposals USING btree (contractor_sig_user_id);


--
-- Name: index_proposals_on_customer_sig_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposals_on_customer_sig_user_id ON proposals USING btree (customer_sig_user_id);


--
-- Name: index_proposals_on_guid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposals_on_guid ON proposals USING btree (guid);


--
-- Name: index_proposals_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposals_on_job_id ON proposals USING btree (job_id);


--
-- Name: index_proposals_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposals_on_org_id ON proposals USING btree (organization_id);


--
-- Name: index_proposals_on_sales_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposals_on_sales_person_id ON proposals USING btree (sales_person_id);


--
-- Name: index_proposals_on_template_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_proposals_on_template_id ON proposals USING btree (proposal_template_id);


--
-- Name: index_quick_books_customers_on_ref; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_quick_books_customers_on_ref ON quick_books_customers USING btree (ref);


--
-- Name: index_quick_books_estimates_on_sub_customer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quick_books_estimates_on_sub_customer_id ON quick_books_estimates USING btree (sub_customer_id);


--
-- Name: index_quick_books_invoices_on_sub_customer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quick_books_invoices_on_sub_customer_id ON quick_books_invoices USING btree (sub_customer_id);


--
-- Name: index_quick_books_payments_on_quick_books_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_quick_books_payments_on_quick_books_id ON quick_books_payments USING btree (quick_books_id);


--
-- Name: index_quick_books_sessions_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_quick_books_sessions_on_organization_id ON quick_books_sessions USING btree (organization_id);


--
-- Name: index_quick_books_sub_customers_on_display_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quick_books_sub_customers_on_display_name ON quick_books_sub_customers USING btree (display_name);


--
-- Name: index_quick_books_sub_customers_on_quick_books_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quick_books_sub_customers_on_quick_books_id ON quick_books_sub_customers USING btree (quick_books_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_on_name ON roles USING btree (name);


--
-- Name: index_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON roles USING btree (name, resource_type, resource_id);


--
-- Name: index_timecards_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_timecards_on_job_id ON timecards USING btree (job_id);


--
-- Name: index_timecards_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_timecards_on_org_id ON timecards USING btree (organization_id);


--
-- Name: index_timecards_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_timecards_on_user_id ON timecards USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_org_id ON users USING btree (organization_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_roles_on_user_id_and_role_id ON users_roles USING btree (user_id, role_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: purchase_line_item_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX purchase_line_item_id_index ON quick_books_expense_line_items USING btree (qb_purchase_id, qb_line_item_id);


--
-- Name: quick_books_accounts_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX quick_books_accounts_id_index ON quick_books_accounts USING btree (organization_id, company_id, type);


--
-- Name: quick_books_customers_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX quick_books_customers_id_index ON quick_books_customers USING btree (organization_id, company_id, contact_id);


--
-- Name: quick_books_items_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX quick_books_items_id_index ON quick_books_items USING btree (organization_id, company_id, name);


--
-- Name: quick_books_qb_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX quick_books_qb_id_index ON quick_books_customers USING btree (organization_id, company_id, quick_books_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20130508183304');

INSERT INTO schema_migrations (version) VALUES ('20130516172153');

INSERT INTO schema_migrations (version) VALUES ('20130516174017');

INSERT INTO schema_migrations (version) VALUES ('20130516202647');

INSERT INTO schema_migrations (version) VALUES ('20130517145515');

INSERT INTO schema_migrations (version) VALUES ('20130517181800');

INSERT INTO schema_migrations (version) VALUES ('20130517191104');

INSERT INTO schema_migrations (version) VALUES ('20130520151513');

INSERT INTO schema_migrations (version) VALUES ('20130520154235');

INSERT INTO schema_migrations (version) VALUES ('20130520161300');

INSERT INTO schema_migrations (version) VALUES ('20130520181641');

INSERT INTO schema_migrations (version) VALUES ('20130520182944');

INSERT INTO schema_migrations (version) VALUES ('20130521142527');

INSERT INTO schema_migrations (version) VALUES ('20130521171932');

INSERT INTO schema_migrations (version) VALUES ('20130521172117');

INSERT INTO schema_migrations (version) VALUES ('20130521190750');

INSERT INTO schema_migrations (version) VALUES ('20130521194909');

INSERT INTO schema_migrations (version) VALUES ('20130521195038');

INSERT INTO schema_migrations (version) VALUES ('20130521195935');

INSERT INTO schema_migrations (version) VALUES ('20130522174838');

INSERT INTO schema_migrations (version) VALUES ('20130522181031');

INSERT INTO schema_migrations (version) VALUES ('20130522195905');

INSERT INTO schema_migrations (version) VALUES ('20130522201124');

INSERT INTO schema_migrations (version) VALUES ('20130523133430');

INSERT INTO schema_migrations (version) VALUES ('20130523142331');

INSERT INTO schema_migrations (version) VALUES ('20130523144440');

INSERT INTO schema_migrations (version) VALUES ('20130523155410');

INSERT INTO schema_migrations (version) VALUES ('20130523164746');

INSERT INTO schema_migrations (version) VALUES ('20130523192652');

INSERT INTO schema_migrations (version) VALUES ('20130524151306');

INSERT INTO schema_migrations (version) VALUES ('20130524155107');

INSERT INTO schema_migrations (version) VALUES ('20130524175606');

INSERT INTO schema_migrations (version) VALUES ('20130528144828');

INSERT INTO schema_migrations (version) VALUES ('20130528145259');

INSERT INTO schema_migrations (version) VALUES ('20130530152700');

INSERT INTO schema_migrations (version) VALUES ('20130530173619');

INSERT INTO schema_migrations (version) VALUES ('20130531142446');

INSERT INTO schema_migrations (version) VALUES ('20130531142551');

INSERT INTO schema_migrations (version) VALUES ('20130531142704');

INSERT INTO schema_migrations (version) VALUES ('20130531142828');

INSERT INTO schema_migrations (version) VALUES ('20130531142907');

INSERT INTO schema_migrations (version) VALUES ('20130531142955');

INSERT INTO schema_migrations (version) VALUES ('20130531151651');

INSERT INTO schema_migrations (version) VALUES ('20130531160048');

INSERT INTO schema_migrations (version) VALUES ('20130531202826');

INSERT INTO schema_migrations (version) VALUES ('20130603150318');

INSERT INTO schema_migrations (version) VALUES ('20130603160259');

INSERT INTO schema_migrations (version) VALUES ('20130603161106');

INSERT INTO schema_migrations (version) VALUES ('20130603161730');

INSERT INTO schema_migrations (version) VALUES ('20130603190512');

INSERT INTO schema_migrations (version) VALUES ('20130603195904');

INSERT INTO schema_migrations (version) VALUES ('20130604141421');

INSERT INTO schema_migrations (version) VALUES ('20130607135005');

INSERT INTO schema_migrations (version) VALUES ('20130607194417');

INSERT INTO schema_migrations (version) VALUES ('20130610134535');

INSERT INTO schema_migrations (version) VALUES ('20130610185122');

INSERT INTO schema_migrations (version) VALUES ('20130610185353');

INSERT INTO schema_migrations (version) VALUES ('20130610185531');

INSERT INTO schema_migrations (version) VALUES ('20130610195236');

INSERT INTO schema_migrations (version) VALUES ('20130611153936');

INSERT INTO schema_migrations (version) VALUES ('20130612174230');

INSERT INTO schema_migrations (version) VALUES ('20130614184008');

INSERT INTO schema_migrations (version) VALUES ('20130617162817');

INSERT INTO schema_migrations (version) VALUES ('20130617195012');

INSERT INTO schema_migrations (version) VALUES ('20130619152911');

INSERT INTO schema_migrations (version) VALUES ('20130620133547');

INSERT INTO schema_migrations (version) VALUES ('20130620180029');

INSERT INTO schema_migrations (version) VALUES ('20130620195842');

INSERT INTO schema_migrations (version) VALUES ('20130621141807');

INSERT INTO schema_migrations (version) VALUES ('20130621181426');

INSERT INTO schema_migrations (version) VALUES ('20130624142942');

INSERT INTO schema_migrations (version) VALUES ('20130624175923');

INSERT INTO schema_migrations (version) VALUES ('20130625143227');

INSERT INTO schema_migrations (version) VALUES ('20130725173435');

INSERT INTO schema_migrations (version) VALUES ('20130726191325');

INSERT INTO schema_migrations (version) VALUES ('20130823171759');

INSERT INTO schema_migrations (version) VALUES ('20130823200832');

INSERT INTO schema_migrations (version) VALUES ('20130823201200');

INSERT INTO schema_migrations (version) VALUES ('20130826133821');

INSERT INTO schema_migrations (version) VALUES ('20130826143953');

INSERT INTO schema_migrations (version) VALUES ('20130826144340');

INSERT INTO schema_migrations (version) VALUES ('20130827151725');

INSERT INTO schema_migrations (version) VALUES ('20130828173748');

INSERT INTO schema_migrations (version) VALUES ('20130913143505');

INSERT INTO schema_migrations (version) VALUES ('20130927175159');

INSERT INTO schema_migrations (version) VALUES ('20131025132639');

INSERT INTO schema_migrations (version) VALUES ('20131025171804');

INSERT INTO schema_migrations (version) VALUES ('20131101131722');

INSERT INTO schema_migrations (version) VALUES ('20131104143029');

INSERT INTO schema_migrations (version) VALUES ('20131115204623');

INSERT INTO schema_migrations (version) VALUES ('20131118140435');

INSERT INTO schema_migrations (version) VALUES ('20140219151004');

INSERT INTO schema_migrations (version) VALUES ('20140310202009');

INSERT INTO schema_migrations (version) VALUES ('20140313152808');

INSERT INTO schema_migrations (version) VALUES ('20140722194955');

INSERT INTO schema_migrations (version) VALUES ('20140725203226');

INSERT INTO schema_migrations (version) VALUES ('20140725203324');

INSERT INTO schema_migrations (version) VALUES ('20140728151329');

INSERT INTO schema_migrations (version) VALUES ('20140728173241');

INSERT INTO schema_migrations (version) VALUES ('20140729181504');

INSERT INTO schema_migrations (version) VALUES ('20140731140333');

INSERT INTO schema_migrations (version) VALUES ('20140731160301');

INSERT INTO schema_migrations (version) VALUES ('20140801192558');

INSERT INTO schema_migrations (version) VALUES ('20140801194201');

INSERT INTO schema_migrations (version) VALUES ('20140805195356');

INSERT INTO schema_migrations (version) VALUES ('20140807150355');

INSERT INTO schema_migrations (version) VALUES ('20140807161429');

INSERT INTO schema_migrations (version) VALUES ('20140829205310');

INSERT INTO schema_migrations (version) VALUES ('20140909145726');

INSERT INTO schema_migrations (version) VALUES ('20141001132602');

INSERT INTO schema_migrations (version) VALUES ('20141003191426');

INSERT INTO schema_migrations (version) VALUES ('20141003192220');

INSERT INTO schema_migrations (version) VALUES ('20141008184439');

INSERT INTO schema_migrations (version) VALUES ('20141008203936');

INSERT INTO schema_migrations (version) VALUES ('20141009143202');

INSERT INTO schema_migrations (version) VALUES ('20141027153450');

INSERT INTO schema_migrations (version) VALUES ('20141119210758');

INSERT INTO schema_migrations (version) VALUES ('20141120143449');

INSERT INTO schema_migrations (version) VALUES ('20141212145643');

INSERT INTO schema_migrations (version) VALUES ('20141212154755');

INSERT INTO schema_migrations (version) VALUES ('20141216201152');

INSERT INTO schema_migrations (version) VALUES ('20150105195747');

INSERT INTO schema_migrations (version) VALUES ('20150128185830');

INSERT INTO schema_migrations (version) VALUES ('20150206144506');

INSERT INTO schema_migrations (version) VALUES ('20150206162938');

INSERT INTO schema_migrations (version) VALUES ('20150210142408');

INSERT INTO schema_migrations (version) VALUES ('20150308163746');

INSERT INTO schema_migrations (version) VALUES ('20150319005627');

INSERT INTO schema_migrations (version) VALUES ('20150319010008');

INSERT INTO schema_migrations (version) VALUES ('20150510165002');

INSERT INTO schema_migrations (version) VALUES ('20150518212832');

INSERT INTO schema_migrations (version) VALUES ('20150614205101');

INSERT INTO schema_migrations (version) VALUES ('20150824125925');

INSERT INTO schema_migrations (version) VALUES ('20151203184829');

INSERT INTO schema_migrations (version) VALUES ('20160125165144');

INSERT INTO schema_migrations (version) VALUES ('20160211012814');

INSERT INTO schema_migrations (version) VALUES ('20160308235110');

INSERT INTO schema_migrations (version) VALUES ('20160406212639');

INSERT INTO schema_migrations (version) VALUES ('20160505205505');

INSERT INTO schema_migrations (version) VALUES ('20160512214429');

INSERT INTO schema_migrations (version) VALUES ('20160513183821');

INSERT INTO schema_migrations (version) VALUES ('20160513184656');

INSERT INTO schema_migrations (version) VALUES ('20160517145921');

INSERT INTO schema_migrations (version) VALUES ('20160517175546');

INSERT INTO schema_migrations (version) VALUES ('20160609095927');

INSERT INTO schema_migrations (version) VALUES ('20160610230347');

INSERT INTO schema_migrations (version) VALUES ('20160611025021');

INSERT INTO schema_migrations (version) VALUES ('20160611050354');

INSERT INTO schema_migrations (version) VALUES ('20160616223701');

INSERT INTO schema_migrations (version) VALUES ('20160617042218');

INSERT INTO schema_migrations (version) VALUES ('20160617050504');

INSERT INTO schema_migrations (version) VALUES ('20160618213450');

INSERT INTO schema_migrations (version) VALUES ('20160621035106');

INSERT INTO schema_migrations (version) VALUES ('20160621035329');

INSERT INTO schema_migrations (version) VALUES ('20160621101931');

INSERT INTO schema_migrations (version) VALUES ('20160621101943');

INSERT INTO schema_migrations (version) VALUES ('20160621101954');

INSERT INTO schema_migrations (version) VALUES ('20160622163352');

INSERT INTO schema_migrations (version) VALUES ('20160624041712');

INSERT INTO schema_migrations (version) VALUES ('20160624043149');

INSERT INTO schema_migrations (version) VALUES ('20160625104221');

INSERT INTO schema_migrations (version) VALUES ('20160625141916');

INSERT INTO schema_migrations (version) VALUES ('20160625165938');

INSERT INTO schema_migrations (version) VALUES ('20160626070123');

INSERT INTO schema_migrations (version) VALUES ('20160627050108');

INSERT INTO schema_migrations (version) VALUES ('20160627050246');

INSERT INTO schema_migrations (version) VALUES ('20160627065932');

INSERT INTO schema_migrations (version) VALUES ('20160627070535');

INSERT INTO schema_migrations (version) VALUES ('20160627072605');

INSERT INTO schema_migrations (version) VALUES ('20160701045355');

INSERT INTO schema_migrations (version) VALUES ('20160704082135');

INSERT INTO schema_migrations (version) VALUES ('20160705131202');

INSERT INTO schema_migrations (version) VALUES ('20160709075833');

INSERT INTO schema_migrations (version) VALUES ('20160710144512');

INSERT INTO schema_migrations (version) VALUES ('20160717183141');

INSERT INTO schema_migrations (version) VALUES ('20160723095529');

INSERT INTO schema_migrations (version) VALUES ('20160723095618');

INSERT INTO schema_migrations (version) VALUES ('20160725082212');

INSERT INTO schema_migrations (version) VALUES ('20160725082608');

INSERT INTO schema_migrations (version) VALUES ('20160802095423');

INSERT INTO schema_migrations (version) VALUES ('20160802124632');

INSERT INTO schema_migrations (version) VALUES ('20160802145738');

INSERT INTO schema_migrations (version) VALUES ('20160802145824');

INSERT INTO schema_migrations (version) VALUES ('20160803021028');

INSERT INTO schema_migrations (version) VALUES ('20160804081520');

INSERT INTO schema_migrations (version) VALUES ('20160807182308');

INSERT INTO schema_migrations (version) VALUES ('20160807182429');

INSERT INTO schema_migrations (version) VALUES ('20160808101957');

INSERT INTO schema_migrations (version) VALUES ('20160809211040');

INSERT INTO schema_migrations (version) VALUES ('20160812142044');

INSERT INTO schema_migrations (version) VALUES ('20160812142258');

INSERT INTO schema_migrations (version) VALUES ('20160812142859');

INSERT INTO schema_migrations (version) VALUES ('20160816170815');

INSERT INTO schema_migrations (version) VALUES ('20160818090847');

INSERT INTO schema_migrations (version) VALUES ('20160818100017');

INSERT INTO schema_migrations (version) VALUES ('20160820083300');

INSERT INTO schema_migrations (version) VALUES ('20160822193715');

INSERT INTO schema_migrations (version) VALUES ('20160824190127');

INSERT INTO schema_migrations (version) VALUES ('20160824191759');

INSERT INTO schema_migrations (version) VALUES ('20160824194448');

INSERT INTO schema_migrations (version) VALUES ('20160824200119');

INSERT INTO schema_migrations (version) VALUES ('20160826132127');

INSERT INTO schema_migrations (version) VALUES ('20160826140125');

INSERT INTO schema_migrations (version) VALUES ('20160826142225');

INSERT INTO schema_migrations (version) VALUES ('20160826143915');

INSERT INTO schema_migrations (version) VALUES ('20160826145316');

INSERT INTO schema_migrations (version) VALUES ('20160826150433');

INSERT INTO schema_migrations (version) VALUES ('20160826215540');

INSERT INTO schema_migrations (version) VALUES ('20160826221850');

INSERT INTO schema_migrations (version) VALUES ('20160906205952');