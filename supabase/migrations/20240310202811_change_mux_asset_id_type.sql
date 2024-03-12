alter table "public"."mux_assets" drop constraint mux_assets_pkey;
alter table "public"."mux_assets" drop column "id";
alter table "public"."mux_assets"
add column "id" uuid default gen_random_uuid() not null primary key;