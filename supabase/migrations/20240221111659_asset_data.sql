alter table "public"."mux_assets" add column "asset_id" text;

alter table "public"."mux_assets" add column "asset_ready" boolean not null default false;

alter table "public"."mux_assets" add column "upload_message" text;

CREATE TRIGGER handle_mux_asset AFTER INSERT OR DELETE ON public.mux_assets FOR EACH ROW EXECUTE FUNCTION supabase_functions.http_request('http://host.docker.internal:54321/functions/v1/handle_mux_asset', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"}', '{}', '1000');



