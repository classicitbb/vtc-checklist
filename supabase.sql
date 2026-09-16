-- VTC shared checklist board
create table if not exists public.vtc_checks (
  board text    not null,
  item  text    not null,
  v     smallint not null,
  t     bigint  not null,
  primary key (board, item)
);

alter table public.vtc_checks enable row level security;

-- Anyone holding the publishable key may read the board; writes go only
-- through the functions below, so the key cannot be used to write freely.
drop policy if exists vtc_read on public.vtc_checks;
create policy vtc_read on public.vtc_checks for select to anon, authenticated using (true);

-- One tick. The newest timestamp wins, so a late write can never undo a newer one.
create or replace function public.vtc_set(p_board text, p_item text, p_v smallint, p_t bigint)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_board !~ '^[A-Za-z0-9_-]{3,64}$' then raise exception 'bad board name'; end if;
  if p_item  !~ '^[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/[0-9]{1,4}$' then raise exception 'bad item'; end if;
  insert into public.vtc_checks (board, item, v, t)
  values (p_board, p_item, least(greatest(p_v,0),1)::smallint, p_t)
  on conflict (board, item) do update
    set v = excluded.v, t = excluded.t
    where vtc_checks.t < excluded.t;
end $$;

-- Many ticks at once, used when a day is reset.
create or replace function public.vtc_set_many(p_board text, p_rows jsonb)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_board !~ '^[A-Za-z0-9_-]{3,64}$' then raise exception 'bad board name'; end if;
  if jsonb_array_length(p_rows) > 500 then raise exception 'too many rows'; end if;
  insert into public.vtc_checks (board, item, v, t)
  select p_board, r->>'item', least(greatest((r->>'v')::int,0),1)::smallint, (r->>'t')::bigint
  from jsonb_array_elements(p_rows) r
  on conflict (board, item) do update
    set v = excluded.v, t = excluded.t
    where vtc_checks.t < excluded.t;
end $$;

grant select on public.vtc_checks to anon, authenticated;
grant execute on function public.vtc_set(text,text,smallint,bigint) to anon, authenticated;
grant execute on function public.vtc_set_many(text,jsonb) to anon, authenticated;
