set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.email_is_registered(email text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  declare
  user_id uuid;
  begin
    if session_user = 'authenticator' then
      raise exception 'Unauthorized';
    end if;
    select u.id into user_id from auth.users as u where lower(u.email) = lower($1);
    return user_id is not null;
  end;
$function$
;



