drop trigger if exists "create_ticket_for_new_user" on "public"."user_profiles";

drop function if exists "public"."create_new_ticket"();

drop function if exists "public"."email_is_registered"(email text);

drop function if exists "public"."get_provider_distribution"();

drop function if exists "public"."get_ticket_id_by_phone_number"(phone_input text, event_id_input uuid);

drop function if exists "public"."get_user_id_by_email"(email_input text);

drop function if exists "public"."phone_is_registered"(phone_input text);



