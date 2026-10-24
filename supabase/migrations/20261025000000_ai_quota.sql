-- ─────────────────────────────────────────────
-- ZahnChallenge – Tageslimit für KI-Anfragen (Dr. Lukas, Foto-Auswertung)
-- Schützt vor hohen Kosten durch Missbrauch. Wird von der Edge Function "dr-lukas" genutzt.
-- Ausführen: Supabase Dashboard → SQL Editor → einfügen → Run
-- ─────────────────────────────────────────────

create table public.ai_usage (
    user_id uuid not null references auth.users (id) on delete cascade,
    day     date not null default current_date,
    count   integer not null default 0 check (count >= 0),
    primary key (user_id, day)
);

comment on table public.ai_usage is 'Anzahl KI-Anfragen je Nutzer:in und Tag.';

-- Kein direkter Zugriff über die API, nur über consume_ai_quota()
alter table public.ai_usage enable row level security;

-- Zählt eine Anfrage und gibt zurück, ob sie noch im Tageslimit liegt.
create function public.consume_ai_quota(daily_limit integer default 100)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
    used integer;
begin
    if auth.uid() is null then
        return false;
    end if;

    insert into public.ai_usage (user_id, day, count)
    values (auth.uid(), current_date, 1)
    on conflict (user_id, day) do update set count = public.ai_usage.count + 1
    returning count into used;

    return used <= daily_limit;
end;
$$;

revoke all on function public.consume_ai_quota(integer) from public, anon;
grant execute on function public.consume_ai_quota(integer) to authenticated;
