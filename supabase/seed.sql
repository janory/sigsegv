CREATE OR REPLACE FUNCTION public.create_user(email text, password text) RETURNS uuid AS $$
declare user_id uuid;
encrypted_pw text;
BEGIN user_id := gen_random_uuid();
encrypted_pw := crypt(password, gen_salt('bf'));
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token,
    phone
  )
VALUES (
    '00000000-0000-0000-0000-000000000000',
    user_id,
    'authenticated',
    'authenticated',
    email,
    encrypted_pw,
    '2023-05-03 19:41:43.585805+00',
    '2023-04-22 13:10:03.275387+00',
    '2023-04-22 13:10:31.458239+00',
    '{"provider":"email","providers":["email"]}',
    '{}',
    '2023-05-03 19:41:43.580424+00',
    '2023-05-03 19:41:43.585948+00',
    '',
    '',
    '',
    '',
    '4711223344'
  );
INSERT INTO auth.identities (
    id,
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  )
VALUES (
    gen_random_uuid(),
    user_id,
    user_id,
    format(
      '{"sub":"%s","email":"%s"}',
      user_id::text,
      email
    )::jsonb,
    'email',
    '2023-05-03 19:41:43.582456+00',
    '2023-05-03 19:41:43.582497+00',
    '2023-05-03 19:41:43.582497+00'
  );
return user_id;
END;
$$ LANGUAGE plpgsql;
select user_id
from public.create_user('test@example.com', 'test123!');
insert into user_profiles (user_id, name, country, date_of_birth, gender)
values (
    user_id,
    'Test User',
    'NO',
    '1990-01-01'::date,
    gender
  ) on conflict (user_id) do nothing;