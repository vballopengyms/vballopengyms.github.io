create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 150),
  city text not null check (char_length(city) between 1 and 100),
  address text not null check (char_length(address) between 1 and 200),
  cost text not null check (char_length(cost) between 1 and 100),
  rating smallint not null check (rating between 1 and 5),
  review text not null check (char_length(review) between 20 and 1200),
  helpful_links jsonb not null default '[]'::jsonb,
  place_id text not null default '',
  latitude double precision,
  longitude double precision,
  photos jsonb not null default '[]'::jsonb,
  author_id uuid not null references auth.users(id) on delete cascade,
  author_mask text not null default 'Community member',
  created_at timestamptz not null default now()
);

create table if not exists public.votes (
  review_id uuid not null references public.reviews(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  value smallint not null check (value in (-1, 1)),
  created_at timestamptz not null default now(),
  primary key (review_id, user_id)
);

create index if not exists reviews_created_at_idx on public.reviews (created_at desc);
create index if not exists reviews_author_id_idx on public.reviews (author_id);
create index if not exists votes_user_id_idx on public.votes (user_id);

alter table public.reviews enable row level security;
alter table public.votes enable row level security;

drop policy if exists "Reviews are public" on public.reviews;
create policy "Reviews are public" on public.reviews for select using (true);

drop policy if exists "Signed-in users create their reviews" on public.reviews;
create policy "Signed-in users create their reviews"
on public.reviews for insert to authenticated
with check ((select auth.uid()) = author_id);

drop policy if exists "Authors update their reviews" on public.reviews;
create policy "Authors update their reviews"
on public.reviews for update to authenticated
using ((select auth.uid()) = author_id)
with check ((select auth.uid()) = author_id);

drop policy if exists "Authors and admin delete reviews" on public.reviews;
create policy "Authors and admin delete reviews"
on public.reviews for delete to authenticated
using (
  (select auth.uid()) = author_id
  or lower(coalesce((select auth.jwt() ->> 'email'), '')) = 'sanny.do@gmail.com'
);

drop policy if exists "Votes are public" on public.votes;
create policy "Votes are public" on public.votes for select using (true);

drop policy if exists "Signed-in users create their votes" on public.votes;
create policy "Signed-in users create their votes"
on public.votes for insert to authenticated
with check (
  (select auth.uid()) = user_id
  and not exists (
    select 1 from public.reviews
    where reviews.id = review_id
      and reviews.author_id = (select auth.uid())
  )
);

drop policy if exists "Users update their votes" on public.votes;
create policy "Users update their votes"
on public.votes for update to authenticated
using ((select auth.uid()) = user_id)
with check (
  (select auth.uid()) = user_id
  and not exists (
    select 1 from public.reviews
    where reviews.id = review_id
      and reviews.author_id = (select auth.uid())
  )
);

drop policy if exists "Users delete their votes" on public.votes;
create policy "Users delete their votes"
on public.votes for delete to authenticated
using ((select auth.uid()) = user_id);

grant usage on schema public to anon, authenticated;
grant select on public.reviews, public.votes to anon;
grant select, insert, update, delete on public.reviews to authenticated;
grant select, insert, update, delete on public.votes to authenticated;
