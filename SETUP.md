# Asclepius — Cloud Setup (Clerk + Supabase)

Takes about 10 minutes, both services have free tiers that are plenty for a demo or a school.

With keys pasted in, accounts and workouts sync to the cloud: log in on any device and your season is there. Without keys, nothing breaks — the app silently stays local (great as a fallback during a live pitch).

---

## 1. Supabase (stores the workouts)

1. Go to [supabase.com](https://supabase.com) → **New project** (free tier is fine). Pick any name, generate a DB password, choose a region near you.
2. When the project is ready, open **SQL Editor** (left sidebar) → **New query**, paste the full contents of `schema.sql` (it's in this repo), click **Run**. You should see `Success. No rows returned`.
3. Go to **Project Settings → API** and copy two values:
   - **Project URL** — looks like `https://abcd1234.supabase.co`
   - **anon / public key** — the long `eyJ...` string labeled `anon` `public`

⚠️ Use the **anon** key, never the `service_role` key. The anon key is safe to ship: Row Level Security (the SQL above) means every user can only ever touch their own rows.

## 2. Clerk (handles login)

1. Go to [clerk.com](https://clerk.com) → **Add application**. Name it (e.g. "Asclepius"). Under sign-in options pick **Email** (and Google if you want one-tap). Create.
2. You land on the API keys page. Copy the **Publishable key** — starts with `pk_test_...` (or `pk_live_...` after going live).

## 3. Connect Clerk → Supabase (two small steps)

**In Clerk — enable Supabase compatibility:**
1. In the Clerk dashboard: **Configure → JWT Templates → New template → Supabase**. Keep the name exactly `supabase`. Leave the prefilled claims (they include `"role": "authenticated"`, which Supabase requires). Save.
2. Clerk docs route (recommended): go to Clerk's **Connect with Supabase** page (Dashboard → Configure → Integrations) and **Activate Supabase integration** — it reveals your Clerk domain, e.g. `thankful-mantis-4029.clerk.accounts.dev`.

**In Supabase — trust your Clerk instance:**
1. Supabase dashboard → **Authentication → Sign In / Up** (Providers) → **Third-Party Auth** → **Add provider** → **Clerk**.
2. Paste your Clerk domain (`thankful-mantis-4029.clerk.accounts.dev`) → Save.

This makes Supabase accept your users' Clerk logins and lets the RLS policies match rows by Clerk user ID (`auth.jwt()->>'sub'`).

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
