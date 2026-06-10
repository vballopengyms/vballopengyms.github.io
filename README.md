# VBall Open Gyms

A free community open-gym tracker and parent safety vetting hub for youth volleyball.

## Shared database setup

The site stays on GitHub Pages. Supabase Free provides the shared Postgres database
and user authentication.

1. Create a free project at https://database.new.
2. Open **SQL Editor**, paste `supabase-schema.sql`, and run it.
3. Open **Project Settings > API**.
4. Put the project URL and publishable key in `config.js`.
5. In **Authentication > URL Configuration**, set the site URL to
   `https://www.vballopengyms.com`.
6. In **Authentication > Providers > Email**, disable email confirmation for the
   simplest launch flow, or leave it enabled if confirmation emails are preferred.
7. Commit and push `index.html`, `config.js`, and `supabase-schema.sql`.

The publishable key in `config.js` is safe to expose in a browser. Never put the
Supabase secret key or service-role key in this repository.

When an existing local user signs into the Supabase-backed version, reviews still
stored in that browser are imported once into the shared database.
