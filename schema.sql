-- Asclepius — run this whole file in Supabase SQL Editor → New query → Run
-- (Safe to re-run: it drops and recreates the table.)
drop table if exists public.entries;

create table public.entries (
  id         text primary key,
  user_id    text not null default auth.jwt()->>'sub',
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
  using ((select auth.jwt()->>'sub') = user_id);

create policy "own rows insert"
  on public.entries for insert
  with check ((select auth.jwt()->>'sub') = user_id);

create policy "own rows update"
  on public.entries for update
  using ((select auth.jwt()->>'sub') = user_id)
  with check ((select auth.jwt()->>'sub') = user_id);

create policy "own rows delete"
  on public.entries for delete
  using ((select auth.jwt()->>'sub') = user_id);
