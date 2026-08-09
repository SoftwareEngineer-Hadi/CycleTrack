-- CycleTrack encrypted backup table.
-- Paste into the Supabase SQL editor after creating a project.
-- Enable Google provider under Authentication → Providers.

create table if not exists public.encrypted_backups (
  user_id uuid primary key references auth.users (id) on delete cascade,
  ciphertext text not null,
  -- AES-GCM wrapped data-encryption key (enables cross-device restore).
  wrapped_key text,
  updated_at timestamptz not null default now()
);

alter table public.encrypted_backups enable row level security;

create policy "Users manage own backup"
  on public.encrypted_backups
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- If you already created the table without wrapped_key, run:
-- alter table public.encrypted_backups add column if not exists wrapped_key text;
