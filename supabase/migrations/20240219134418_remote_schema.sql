set check_function_bodies = off;

CREATE OR REPLACE FUNCTION private.get_signup_provider_distribution()
 RETURNS TABLE(count integer, provider text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'auth'
AS $function$
select count(*), raw_app_meta_data::json ->> 'provider' as provider from auth.users
group by provider
$function$
;


create type "public"."gender" as enum ('MALE', 'FEMALE');

drop trigger if exists "create_ticket_for_new_user" on "public"."user_profiles";

alter table "public"."output" enable row level security;

alter table "public"."user_profiles" alter column "gender" set data type gender using "gender"::gender;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.country_code_to_name(code text)
 RETURNS text
 LANGUAGE sql
AS $function$
    SELECT value FROM json_each_text('{"AF":"Afghanistan","AX":"Aland Islands","AL":"Albania","DZ":"Algeria","AS":"American Samoa","AD":"Andorra","AO":"Angola","AI":"Anguilla","AQ":"Antarctica","AG":"Antigua And Barbuda","AR":"Argentina","AM":"Armenia","AW":"Aruba","AU":"Australia","AT":"Austria","AZ":"Azerbaijan","BS":"Bahamas","BH":"Bahrain","BD":"Bangladesh","BB":"Barbados","BY":"Belarus","BE":"Belgium","BZ":"Belize","BJ":"Benin","BM":"Bermuda","BT":"Bhutan","BO":"Bolivia","BA":"Bosnia And Herzegovina","BW":"Botswana","BV":"Bouvet Island","BR":"Brazil","IO":"British Indian Ocean Territory","BN":"Brunei Darussalam","BG":"Bulgaria","BF":"Burkina Faso","BI":"Burundi","KH":"Cambodia","CM":"Cameroon","CA":"Canada","CV":"Cape Verde","KY":"Cayman Islands","CF":"Central African Republic","TD":"Chad","CL":"Chile","CN":"China","CX":"Christmas Island","CC":"Cocos (Keeling) Islands","CO":"Colombia","KM":"Comoros","CG":"Congo","CD":"Congo, Democratic Republic","CK":"Cook Islands","CR":"Costa Rica","CI":"Cote D\"Ivoire","HR":"Croatia","CU":"Cuba","CY":"Cyprus","CZ":"Czech Republic","DK":"Denmark","DJ":"Djibouti","DM":"Dominica","DO":"Dominican Republic","EC":"Ecuador","EG":"Egypt","SV":"El Salvador","GQ":"Equatorial Guinea","ER":"Eritrea","EE":"Estonia","ET":"Ethiopia","FK":"Falkland Islands (Malvinas)","FO":"Faroe Islands","FJ":"Fiji","FI":"Finland","FR":"France","GF":"French Guiana","PF":"French Polynesia","TF":"French Southern Territories","GA":"Gabon","GM":"Gambia","GE":"Georgia","DE":"Germany","GH":"Ghana","GI":"Gibraltar","GR":"Greece","GL":"Greenland","GD":"Grenada","GP":"Guadeloupe","GU":"Guam","GT":"Guatemala","GG":"Guernsey","GN":"Guinea","GW":"Guinea-Bissau","GY":"Guyana","HT":"Haiti","HM":"Heard Island & Mcdonald Islands","VA":"Holy See (Vatican City State)","HN":"Honduras","HK":"Hong Kong","HU":"Hungary","IS":"Iceland","IN":"India","ID":"Indonesia","IR":"Iran, Islamic Republic Of","IQ":"Iraq","IE":"Ireland","IM":"Isle Of Man","IL":"Israel","IT":"Italy","JM":"Jamaica","JP":"Japan","JE":"Jersey","JO":"Jordan","KZ":"Kazakhstan","KE":"Kenya","KI":"Kiribati","KR":"Korea","KP":"North Korea","KW":"Kuwait","KG":"Kyrgyzstan","LA":"Lao People\"s Democratic Republic","LV":"Latvia","LB":"Lebanon","LS":"Lesotho","LR":"Liberia","LY":"Libyan Arab Jamahiriya","LI":"Liechtenstein","LT":"Lithuania","LU":"Luxembourg","MO":"Macao","MK":"Macedonia","MG":"Madagascar","MW":"Malawi","MY":"Malaysia","MV":"Maldives","ML":"Mali","MT":"Malta","MH":"Marshall Islands","MQ":"Martinique","MR":"Mauritania","MU":"Mauritius","YT":"Mayotte","MX":"Mexico","FM":"Micronesia, Federated States Of","MD":"Moldova","MC":"Monaco","MN":"Mongolia","ME":"Montenegro","MS":"Montserrat","MA":"Morocco","MZ":"Mozambique","MM":"Myanmar","NA":"Namibia","NR":"Nauru","NP":"Nepal","NL":"Netherlands","AN":"Netherlands Antilles","NC":"New Caledonia","NZ":"New Zealand","NI":"Nicaragua","NE":"Niger","NG":"Nigeria","NU":"Niue","NF":"Norfolk Island","MP":"Northern Mariana Islands","NO":"Norway","OM":"Oman","PK":"Pakistan","PW":"Palau","PS":"Palestinian Territory, Occupied","PA":"Panama","PG":"Papua New Guinea","PY":"Paraguay","PE":"Peru","PH":"Philippines","PN":"Pitcairn","PL":"Poland","PT":"Portugal","PR":"Puerto Rico","QA":"Qatar","RE":"Reunion","RO":"Romania","RU":"Russian Federation","RW":"Rwanda","BL":"Saint Barthelemy","SH":"Saint Helena","KN":"Saint Kitts And Nevis","LC":"Saint Lucia","MF":"Saint Martin","PM":"Saint Pierre And Miquelon","VC":"Saint Vincent And Grenadines","WS":"Samoa","SM":"San Marino","ST":"Sao Tome And Principe","SA":"Saudi Arabia","SN":"Senegal","RS":"Serbia","SC":"Seychelles","SL":"Sierra Leone","SG":"Singapore","SK":"Slovakia","SI":"Slovenia","SB":"Solomon Islands","SO":"Somalia","ZA":"South Africa","GS":"South Georgia And Sandwich Isl.","ES":"Spain","LK":"Sri Lanka","SD":"Sudan","SR":"Suriname","SJ":"Svalbard And Jan Mayen","SZ":"Swaziland","SE":"Sweden","CH":"Switzerland","SY":"Syrian Arab Republic","TW":"Taiwan","TJ":"Tajikistan","TZ":"Tanzania","TH":"Thailand","TL":"Timor-Leste","TG":"Togo","TK":"Tokelau","TO":"Tonga","TT":"Trinidad And Tobago","TN":"Tunisia","TR":"Turkey","TM":"Turkmenistan","TC":"Turks And Caicos Islands","TV":"Tuvalu","UG":"Uganda","UA":"Ukraine","AE":"United Arab Emirates","GB":"United Kingdom","US":"United States","UM":"United States Outlying Islands","UY":"Uruguay","UZ":"Uzbekistan","VU":"Vanuatu","VE":"Venezuela","VN":"Vietnam","VG":"Virgin Islands, British","VI":"Virgin Islands, U.S.","WF":"Wallis And Futuna","EH":"Western Sahara","YE":"Yemen","ZM":"Zambia","ZW":"Zimbabwe"}') WHERE key = UPPER(code);
$function$
;

CREATE OR REPLACE FUNCTION public.get_provider_distribution()
 RETURNS TABLE(count integer, provider text)
 LANGUAGE sql
AS $function$
  select count(*), raw_app_meta_data::json ->> 'provider' as provider from auth.users
group by provider;
$function$
;

CREATE OR REPLACE FUNCTION public.add_role_to_custom_claim()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$  
BEGIN  
  PERFORM set_claim(NEW.user_id::UUID, 'roles'::TEXT, ARRAY_TO_JSON(NEW.roles)::jsonb);  
  RETURN NEW;  
END;  
$function$
;

CREATE OR REPLACE FUNCTION public.create_new_ticket()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
  begin
    insert into tickets (event_id, user_id) values ('77a31523-9d68-485f-a10f-4619f8ca9bc9', new.user_id);
    return new;
    end;
$function$
;

CREATE OR REPLACE FUNCTION public.delete_claim(uid uuid, claim text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN 'error: access denied';
      ELSE        
        update auth.users set raw_app_meta_data = 
          raw_app_meta_data - claim where id = uid;
        return 'OK';
      END IF;
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.email_is_registered(email text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  declare
  user_id uuid;
  begin
    select u.id into user_id from auth.users as u where lower(u.email) = lower($1);
    return user_id is not null;
  end;
$function$
;

CREATE OR REPLACE FUNCTION public.get_claim(uid uuid, claim text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select coalesce(raw_app_meta_data->claim, null) from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_claims(uid uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select raw_app_meta_data from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_claim(claim text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata' -> claim, null)
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_claims()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata', '{}'::jsonb)::jsonb
$function$
;

CREATE OR REPLACE FUNCTION public.get_ticket_id_by_phone_number(phone_input text, event_id_input uuid)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
  declare ticket_id uuid;
  declare user_id_var uuid;

  begin
    select id into user_id_var from auth.users where phone = phone_input;
    select id into ticket_id from tickets where user_id = user_id_var and event_id = event_id_input;

    return ticket_id;

  end;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_id_by_email(email_input text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
  declare user_id uuid;
  begin
    select id into user_id from auth.users where email = email_input;
    return user_id;
  end;
$function$
;

CREATE OR REPLACE FUNCTION public.is_claims_admin()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
  BEGIN
    IF session_user = 'authenticator' THEN
      RETURN FALSE;
    ELSE
      return true;
    END IF;
  END;$function$
;

CREATE OR REPLACE FUNCTION public.phone_is_registered(phone_input text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
  declare
  user_id uuid;
  begin
    select u.id into user_id from auth.users as u where replace(u.phone, '+', '') = replace(phone_input, '+', '');
    return user_id is not null;
  end;
$function$
;

CREATE OR REPLACE FUNCTION public.set_claim(uid uuid, claim text, value jsonb)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN 'error: access denied';
      ELSE        
        update auth.users set raw_app_meta_data = 
          raw_app_meta_data || 
            json_build_object(claim, value)::jsonb where id = uid;
        return 'OK';
      END IF;
    END;
$function$
;

CREATE TRIGGER create_ticket_for_new_user AFTER INSERT ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION create_new_ticket();
ALTER TABLE "public"."user_profiles" DISABLE TRIGGER "create_ticket_for_new_user";


