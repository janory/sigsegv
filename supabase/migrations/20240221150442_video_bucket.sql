insert into storage.buckets (id, name)
values ('video_uploads', 'video_uploads') on conflict (name) do nothing;