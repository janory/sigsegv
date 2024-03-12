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
CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";
CREATE SCHEMA IF NOT EXISTS "private";
ALTER SCHEMA "private" OWNER TO "postgres";
ALTER SCHEMA "public" OWNER TO "postgres";
CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";
CREATE TYPE "public"."role" AS ENUM ('ticket_manager', 'admin');
ALTER TYPE "public"."role" OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."add_role_to_custom_claim"() RETURNS trigger LANGUAGE "plpgsql" AS $$ BEGIN PERFORM set_claim(
    NEW.user_id::UUID,
    'roles'::TEXT,
    ARRAY_TO_JSON(NEW.roles)::jsonb
  );
RETURN NEW;
END;
$$;
ALTER FUNCTION "public"."add_role_to_custom_claim"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."create_new_ticket"() RETURNS trigger LANGUAGE "plpgsql" AS $$ begin
insert into tickets (event_id, user_id)
values (
    '77a31523-9d68-485f-a10f-4619f8ca9bc9',
    new.user_id
  );
return new;
end;
$$;
ALTER FUNCTION "public"."create_new_ticket"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."delete_claim"(uid uuid, claim text) RETURNS text LANGUAGE "plpgsql" SECURITY DEFINER
SET "search_path" TO 'public' AS $$ BEGIN IF NOT is_claims_admin() THEN RETURN 'error: access denied';
ELSE
update auth.users
set raw_app_meta_data = raw_app_meta_data - claim
where id = uid;
return 'OK';
END IF;
END;
$$;
ALTER FUNCTION "public"."delete_claim"(uid uuid, claim text) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."email_is_registered"(email text) RETURNS boolean LANGUAGE "plpgsql" SECURITY DEFINER
SET "search_path" TO 'public' AS $_$
declare user_id uuid;
begin
select u.id into user_id
from auth.users as u
where lower(u.email) = lower($1);
return user_id is not null;
end;
$_$;
ALTER FUNCTION "public"."email_is_registered"(email text) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."get_claim"(uid uuid, claim text) RETURNS jsonb LANGUAGE "plpgsql" SECURITY DEFINER
SET "search_path" TO 'public' AS $$
DECLARE retval jsonb;
BEGIN IF NOT is_claims_admin() THEN RETURN '{"error":"access denied"}'::jsonb;
ELSE
select coalesce(raw_app_meta_data->claim, null)
from auth.users into retval
where id = uid::uuid;
return retval;
END IF;
END;
$$;
ALTER FUNCTION "public"."get_claim"(uid uuid, claim text) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."get_claims"(uid uuid) RETURNS jsonb LANGUAGE "plpgsql" SECURITY DEFINER
SET "search_path" TO 'public' AS $$
DECLARE retval jsonb;
BEGIN IF NOT is_claims_admin() THEN RETURN '{"error":"access denied"}'::jsonb;
ELSE
select raw_app_meta_data
from auth.users into retval
where id = uid::uuid;
return retval;
END IF;
END;
$$;
ALTER FUNCTION "public"."get_claims"(uid uuid) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."get_my_claim"(claim text) RETURNS jsonb LANGUAGE "sql" STABLE AS $$
select coalesce(
    nullif(current_setting('request.jwt.claims', true), '')::jsonb->'app_metadata'->claim,
    null
  ) $$;
ALTER FUNCTION "public"."get_my_claim"(claim text) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."get_my_claims"() RETURNS jsonb LANGUAGE "sql" STABLE AS $$
select coalesce(
    nullif(current_setting('request.jwt.claims', true), '')::jsonb->'app_metadata',
    '{}'::jsonb
  )::jsonb $$;
ALTER FUNCTION "public"."get_my_claims"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."get_ticket_id_by_phone_number"(phone_input text, event_id_input uuid) RETURNS uuid LANGUAGE "plpgsql" AS $$
declare ticket_id uuid;
declare user_id_var uuid;
begin
select id into user_id_var
from auth.users
where phone = phone_input;
select id into ticket_id
from tickets
where user_id = user_id_var
  and event_id = event_id_input;
return ticket_id;
end;
$$;
ALTER FUNCTION "public"."get_ticket_id_by_phone_number"(phone_input text, event_id_input uuid) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."get_user_id_by_email"(email_input text) RETURNS uuid LANGUAGE "plpgsql" AS $$
declare user_id uuid;
begin
select id into user_id
from auth.users
where email = email_input;
return user_id;
end;
$$;
ALTER FUNCTION "public"."get_user_id_by_email"(email_input text) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."is_claims_admin"() RETURNS boolean LANGUAGE "plpgsql" AS $$ BEGIN IF session_user = 'authenticator' THEN RETURN FALSE;
ELSE return true;
END IF;
END;
$$;
ALTER FUNCTION "public"."is_claims_admin"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."phone_is_registered"(phone_input text) RETURNS boolean LANGUAGE "plpgsql" AS $$
declare user_id uuid;
begin
select u.id into user_id
from auth.users as u
where replace(u.phone, '+', '') = replace(phone_input, '+', '');
return user_id is not null;
end;
$$;
ALTER FUNCTION "public"."phone_is_registered"(phone_input text) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."set_claim"(uid uuid, claim text, value jsonb) RETURNS text LANGUAGE "plpgsql" SECURITY DEFINER
SET "search_path" TO 'public' AS $$ BEGIN IF NOT is_claims_admin() THEN RETURN 'error: access denied';
ELSE
update auth.users
set raw_app_meta_data = raw_app_meta_data || json_build_object(claim, value)::jsonb
where id = uid;
return 'OK';
END IF;
END;
$$;
ALTER FUNCTION "public"."set_claim"(uid uuid, claim text, value jsonb) OWNER TO "postgres";
SET default_tablespace = '';
SET default_table_access_method = "heap";
CREATE TABLE IF NOT EXISTS "public"."events" (
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "name" character varying NOT NULL,
  "venue_id" uuid NOT NULL,
  "starts_at" timestamp with time zone NOT NULL,
  "id" uuid DEFAULT gen_random_uuid() NOT NULL
);
ALTER TABLE "public"."events" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."output" ("id" uuid);
ALTER TABLE "public"."output" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."roles" (
  "user_id" uuid NOT NULL,
  "roles" public.role [] NOT NULL,
  "id" uuid DEFAULT gen_random_uuid() NOT NULL
);
ALTER TABLE "public"."roles" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."tickets" (
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "user_id" uuid NOT NULL,
  "redeemed_at" timestamp without time zone,
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "event_id" uuid NOT NULL,
  "sent_at" timestamp with time zone
);
ALTER TABLE "public"."tickets" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."user_profiles" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "user_id" uuid NOT NULL,
  "name" character varying NOT NULL,
  "gender" character varying NOT NULL,
  "country" character varying NOT NULL,
  "date_of_birth" date NOT NULL
);
ALTER TABLE "public"."user_profiles" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."venues" (
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "name" character varying NOT NULL,
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "capcity" integer NOT NULL
);
ALTER TABLE "public"."venues" OWNER TO "postgres";
ALTER TABLE ONLY "public"."tickets"
ADD CONSTRAINT "event_user" UNIQUE ("event_id", "user_id");
ALTER TABLE ONLY "public"."events"
ADD CONSTRAINT "events_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."user_profiles"
ADD CONSTRAINT "profile_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."roles"
ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."tickets"
ADD CONSTRAINT "tickets_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."venues"
ADD CONSTRAINT "venues_name_key" UNIQUE ("name");
ALTER TABLE ONLY "public"."venues"
ADD CONSTRAINT "venues_pkey" PRIMARY KEY ("id");
CREATE TRIGGER create_ticket_for_new_user
AFTER
INSERT ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.create_new_ticket();
CREATE TRIGGER on_role_update_add_role_to_custom_claim
AFTER
INSERT
  OR
UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.add_role_to_custom_claim();
ALTER TABLE ONLY "public"."events"
ADD CONSTRAINT "events_venue_id_fkey" FOREIGN KEY (venue_id) REFERENCES public.venues(id);
ALTER TABLE ONLY "public"."roles"
ADD CONSTRAINT "roles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE ONLY "public"."tickets"
ADD CONSTRAINT "tickets_event_id_fkey" FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;
ALTER TABLE ONLY "public"."tickets"
ADD CONSTRAINT "tickets_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY "public"."user_profiles"
ADD CONSTRAINT "user_profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE "public"."events" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."tickets" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."user_profiles" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."venues" ENABLE ROW LEVEL SECURITY;
REVOKE USAGE ON SCHEMA "public"
FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT USAGE ON SCHEMA "public" TO "grafana_user";
GRANT ALL ON FUNCTION "public"."add_role_to_custom_claim"() TO "anon";
GRANT ALL ON FUNCTION "public"."add_role_to_custom_claim"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_role_to_custom_claim"() TO "service_role";
GRANT ALL ON FUNCTION "public"."create_new_ticket"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_new_ticket"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_new_ticket"() TO "service_role";
GRANT ALL ON FUNCTION "public"."delete_claim"(uid uuid, claim text) TO "anon";
GRANT ALL ON FUNCTION "public"."delete_claim"(uid uuid, claim text) TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_claim"(uid uuid, claim text) TO "service_role";
GRANT ALL ON FUNCTION "public"."email_is_registered"(email text) TO "anon";
GRANT ALL ON FUNCTION "public"."email_is_registered"(email text) TO "authenticated";
GRANT ALL ON FUNCTION "public"."email_is_registered"(email text) TO "service_role";
GRANT ALL ON FUNCTION "public"."get_claim"(uid uuid, claim text) TO "anon";
GRANT ALL ON FUNCTION "public"."get_claim"(uid uuid, claim text) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_claim"(uid uuid, claim text) TO "service_role";
GRANT ALL ON FUNCTION "public"."get_claims"(uid uuid) TO "anon";
GRANT ALL ON FUNCTION "public"."get_claims"(uid uuid) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_claims"(uid uuid) TO "service_role";
GRANT ALL ON FUNCTION "public"."get_my_claim"(claim text) TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_claim"(claim text) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_claim"(claim text) TO "service_role";
GRANT ALL ON FUNCTION "public"."get_my_claims"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_claims"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_claims"() TO "service_role";
GRANT ALL ON FUNCTION "public"."get_ticket_id_by_phone_number"(phone_input text, event_id_input uuid) TO "anon";
GRANT ALL ON FUNCTION "public"."get_ticket_id_by_phone_number"(phone_input text, event_id_input uuid) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_ticket_id_by_phone_number"(phone_input text, event_id_input uuid) TO "service_role";
GRANT ALL ON FUNCTION "public"."get_user_id_by_email"(email_input text) TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_id_by_email"(email_input text) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_id_by_email"(email_input text) TO "service_role";
GRANT ALL ON FUNCTION "public"."is_claims_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_claims_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_claims_admin"() TO "service_role";
GRANT ALL ON FUNCTION "public"."phone_is_registered"(phone_input text) TO "anon";
GRANT ALL ON FUNCTION "public"."phone_is_registered"(phone_input text) TO "authenticated";
GRANT ALL ON FUNCTION "public"."phone_is_registered"(phone_input text) TO "service_role";
GRANT ALL ON FUNCTION "public"."set_claim"(uid uuid, claim text, value jsonb) TO "anon";
GRANT ALL ON FUNCTION "public"."set_claim"(uid uuid, claim text, value jsonb) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_claim"(uid uuid, claim text, value jsonb) TO "service_role";
GRANT ALL ON TABLE "public"."events" TO "anon";
GRANT ALL ON TABLE "public"."events" TO "authenticated";
GRANT ALL ON TABLE "public"."events" TO "service_role";
GRANT ALL ON TABLE "public"."output" TO "anon";
GRANT ALL ON TABLE "public"."output" TO "authenticated";
GRANT ALL ON TABLE "public"."output" TO "service_role";
GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";
GRANT ALL ON TABLE "public"."tickets" TO "anon";
GRANT ALL ON TABLE "public"."tickets" TO "authenticated";
GRANT ALL ON TABLE "public"."tickets" TO "service_role";
GRANT ALL ON TABLE "public"."user_profiles" TO "anon";
GRANT ALL ON TABLE "public"."user_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profiles" TO "service_role";
GRANT SELECT ON TABLE "public"."user_profiles" TO "grafana_user";
GRANT ALL ON TABLE "public"."venues" TO "anon";
GRANT ALL ON TABLE "public"."venues" TO "authenticated";
GRANT ALL ON TABLE "public"."venues" TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON SEQUENCES TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON FUNCTIONS TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON TABLES TO "service_role";
RESET ALL;