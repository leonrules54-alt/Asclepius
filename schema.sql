-- Asclepius — run this whole file in Supabase SQL Editor → New query → Run
create table if not exists public.entries (
  id         text primary key,
  user_id    uuid not null default auth.uid(),
  kind       text not null check (kind in ('w','r')),
  entry_date date not null,
  payload    jsonb not null default '{}'::jsonb,
  created    bigint not null default 0,
  deleted    boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.entries enable row level security;

create policy "own rows read"
  on public.entries for select
  using (auth.uid() = user_id);

create policy "own rows insert"
  on public.entries for insert
  with check (auth.uid() = user_id);

create policy "own rows update"
  on public.entries for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own rows delete"
  on public.entries for delete
  using (auth.uid() = user_id);
