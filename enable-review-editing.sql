drop policy if exists "Authors update their reviews" on public.reviews;

create policy "Authors update their reviews"
on public.reviews
for update
to authenticated
using ((select auth.uid()) = author_id)
with check ((select auth.uid()) = author_id);

grant update on public.reviews to authenticated;
