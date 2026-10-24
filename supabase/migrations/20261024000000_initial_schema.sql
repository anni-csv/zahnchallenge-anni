-- ─────────────────────────────────────────────
-- ZahnChallenge – erstes Datenbank-Schema
-- Profile, Fall-Durchläufe, Ergebnisse pro Schritt, Ranking, Konto löschen
-- Ausführen: Supabase Dashboard → SQL Editor → einfügen → Run
-- ─────────────────────────────────────────────


-- ─────────────────────────────────────────────
-- PROFILE
-- Ein Profil pro Nutzer:in, wird beim Registrieren automatisch angelegt
-- ─────────────────────────────────────────────
create table public.profiles (
    id              uuid primary key references auth.users (id) on delete cascade,
    nickname        text unique
                    check (nickname ~ '^[A-Za-z0-9_.-]{3,20}$'),
    display_name    text check (char_length(display_name) <= 60),
    university      text check (char_length(university) <= 80),
    semester        smallint check (semester between 1 and 20),
    show_in_ranking boolean not null default true,
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now()
);

comment on table public.profiles is 'Öffentliche Profildaten je Nutzer:in (1:1 zu auth.users).';
comment on column public.profiles.nickname is 'Name im Ranking, 3–20 Zeichen: Buchstaben, Zahlen, _ . -';


-- ─────────────────────────────────────────────
-- FALL-DURCHLÄUFE
-- Jeder Start eines Falls ist ein Versuch; abgeschlossen, wenn completed_at gesetzt ist
-- ─────────────────────────────────────────────
create table public.case_attempts (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
    case_id      text not null,                      -- z. B. 'fall1' (id aus der Fall-JSON)
    started_at   timestamptz not null default now(),
    completed_at timestamptz,
    score        integer not null default 0 check (score >= 0),
    max_score    integer not null default 0 check (max_score >= 0),
    check (score <= max_score)
);

create index case_attempts_user_case_idx on public.case_attempts (user_id, case_id);

comment on table public.case_attempts is 'Ein Durchlauf eines Patientenfalls durch eine:n Nutzer:in.';


-- ─────────────────────────────────────────────
-- ERGEBNISSE PRO SCHRITT
-- Antwort und Punkte je Schritt (Grundlage für Statistiken und Expertenbewertung)
-- ─────────────────────────────────────────────
create table public.step_results (
    attempt_id  uuid not null references public.case_attempts (id) on delete cascade,
    step_id     text not null,                       -- z. B. 'f1-konsil'
    score       integer not null default 0 check (score >= 0),
    max_score   integer not null default 0 check (max_score >= 0),
    answer      jsonb,                               -- z. B. {"selected": [0, 1]} oder {"text": "..."}
    answered_at timestamptz not null default now(),
    primary key (attempt_id, step_id)
);

comment on table public.step_results is 'Antwort und Punkte je Schritt eines Durchlaufs.';


-- ─────────────────────────────────────────────
-- AUTOMATIK
-- ─────────────────────────────────────────────

-- Profil beim Registrieren anlegen
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.profiles (id) values (new.id);
    return new;
end;
$$;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- updated_at bei Profiländerungen pflegen
create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger profiles_set_updated_at
    before update on public.profiles
    for each row execute function public.set_updated_at();


-- ─────────────────────────────────────────────
-- ZUGRIFFSREGELN (Row Level Security)
-- Grundsatz: Jede:r sieht und ändert nur die eigenen Daten.
-- ─────────────────────────────────────────────
alter table public.profiles      enable row level security;
alter table public.case_attempts enable row level security;
alter table public.step_results  enable row level security;

-- Profile
create policy "Eigenes Profil lesen"
    on public.profiles for select to authenticated
    using ((select auth.uid()) = id);

create policy "Eigenes Profil ändern"
    on public.profiles for update to authenticated
    using ((select auth.uid()) = id)
    with check ((select auth.uid()) = id);

-- Fall-Durchläufe
create policy "Eigene Durchläufe lesen"
    on public.case_attempts for select to authenticated
    using ((select auth.uid()) = user_id);

create policy "Eigene Durchläufe anlegen"
    on public.case_attempts for insert to authenticated
    with check ((select auth.uid()) = user_id);

create policy "Eigene Durchläufe ändern"
    on public.case_attempts for update to authenticated
    using ((select auth.uid()) = user_id)
    with check ((select auth.uid()) = user_id);

-- Ergebnisse pro Schritt (Zugriff über den zugehörigen Durchlauf)
create policy "Eigene Ergebnisse lesen"
    on public.step_results for select to authenticated
    using (exists (
        select 1 from public.case_attempts a
        where a.id = attempt_id and a.user_id = (select auth.uid())
    ));

create policy "Eigene Ergebnisse anlegen"
    on public.step_results for insert to authenticated
    with check (exists (
        select 1 from public.case_attempts a
        where a.id = attempt_id and a.user_id = (select auth.uid())
    ));

create policy "Eigene Ergebnisse ändern"
    on public.step_results for update to authenticated
    using (exists (
        select 1 from public.case_attempts a
        where a.id = attempt_id and a.user_id = (select auth.uid())
    ))
    with check (exists (
        select 1 from public.case_attempts a
        where a.id = attempt_id and a.user_id = (select auth.uid())
    ));


-- ─────────────────────────────────────────────
-- RANKING
-- Punkte = Summe der jeweils besten abgeschlossenen Durchläufe je Fall.
-- Gibt nur Nickname und Punkte preis, nie E-Mail oder andere Profildaten.
-- ─────────────────────────────────────────────
create function public.get_leaderboard(max_entries integer default 50)
returns table (rank bigint, nickname text, points bigint, completed_cases bigint)
language sql
stable
security definer
set search_path = ''
as $$
    with best as (
        select a.user_id, a.case_id, max(a.score) as best_score
        from public.case_attempts a
        where a.completed_at is not null
        group by a.user_id, a.case_id
    )
    select
        rank() over (order by sum(b.best_score) desc) as rank,
        p.nickname,
        sum(b.best_score)  as points,
        count(*)           as completed_cases
    from best b
    join public.profiles p on p.id = b.user_id
    where p.show_in_ranking and p.nickname is not null
    group by p.id, p.nickname
    order by points desc, p.nickname
    limit least(greatest(max_entries, 1), 200);
$$;

revoke all on function public.get_leaderboard(integer) from public, anon;
grant execute on function public.get_leaderboard(integer) to authenticated;


-- ─────────────────────────────────────────────
-- KONTO LÖSCHEN (Pflicht für App Store & DSGVO)
-- Löscht den Login; Profil, Durchläufe und Ergebnisse folgen per "on delete cascade".
-- ─────────────────────────────────────────────
create function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    if auth.uid() is null then
        raise exception 'Nicht angemeldet';
    end if;
    delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- Interne Trigger-Funktionen nicht über die API aufrufbar machen
revoke all on function public.handle_new_user() from public, anon, authenticated;
revoke all on function public.set_updated_at() from public, anon, authenticated;
