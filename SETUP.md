# Asclepius — Cloud Setup (Clerk + Supabase)

Takes about 10 minutes, both services have free tiers that are plenty for a demo or a school.

With keys pasted in, accounts and workouts sync to the cloud: log in on any device and your season is there. Without keys, nothing breaks — the app silently stays local (great as a fallback during a live pitch).

---

## 1. Supabase (stores the workouts)

1. Go to [supabase.com](https://supabase.com) → **New project** (free tier is fine). Pick any name, generate a DB password, choose a region near you.
2. When the project is ready, open **SQL Editor** (left sidebar) → **New query**, paste this, click **Run**:

```sql
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
```

3. Go to **Project Settings → API** and copy two values:
   - **Project URL** — looks like `https://abcd1234.supabase.co`
   - **anon / public key** — the long `eyJ...` string labeled `anon` `public`

⚠️ Use the **anon** key, never the `service_role` key. The anon key is safe to ship: Row Level Security (the SQL above) means every user can only ever touch their own rows.

## 2. Clerk (handles login)

1. Go to [clerk.com](https://clerk.com) → **Add application**. Name it (e.g. "Asclepius"). Under sign-in options pick **Email** (and Google if you want one-tap). Create.
2. You land on the API keys page. Copy the **Publishable key** — starts with `pk_test_...` (or `pk_live_...` after going live).

## 3. Connect Clerk → Supabase (the JWT template)

This makes every request to Supabase carry the signed-in user's identity:

1. In Clerk dashboard: **Configure → JWT Templates → New template**, choose **Supabase**.
2. It prefills the claims — leave them. In the **Signing key** dropdown pick your instance's key (the default one is fine).
3. Save. Note the template name is exactly **`supabase`** (the app requests it by that name — if Clerk names it differently, rename it to `supabase`).

## 4. Paste the three keys into the app

Open `index.html`, find the `CLOUD_CONFIG` block near the top of the `<script>` (search for `CLOUD_CONFIG`) and fill it in:

```js
const CLOUD_CONFIG={
  clerkPublishableKey:'pk_test_...your key...',
  supabaseUrl:'https://abcd1234.supabase.co',
  supabaseAnonKey:'eyJ...your anon key...'
};
```

Save, commit, push. Reload the site — done. The **Sign up / Log in** button now opens Clerk's real login, and every workout/rest-day change syncs to your Supabase table (the little ☁ pill in the nav shows live status).

---

## How it behaves

- **Log in on a new device** → your whole history pulls down and the app recalculates everything (score, chart, streaks) from the synced workouts.
- **Offline or Supabase down** → you keep logging locally; it syncs on the next save once back online. If the cloud libraries fail to load entirely, the app falls back to the built-in local accounts so the demo never dies on stage.
- **Clear All Data** clears both local and cloud rows (cloud delete retries on next sync if offline at the time).
- **Demo mode never syncs** — sample data exists only in memory and vanishes on Exit, your real data untouched.

## Test checklist (2 min)

1. Open the site in an incognito window → Sign up with an email → verify code → log a workout → ☁ pill shows "synced".
2. Check Supabase → Table Editor → `entries` → the row is there with your `user_id`.
3. Open the site on your phone (or another browser) → log in with the same email → the workout appears within a second.
4. Delete the entry on the phone → refresh the desktop → it's gone there too.
