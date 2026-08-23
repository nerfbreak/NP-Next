create extension if not exists pgcrypto;

create type public.app_role as enum ('SUPERUSER','OPERATOR');
create type public.run_status as enum ('QUEUED','RUNNING','SUCCEEDED','FAILED','CANCELLED');
create type public.worker_status as enum ('STARTING','STANDBY','BUSY','STOPPING','OFFLINE','ERROR');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  role public.app_role not null default 'OPERATOR',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.distributors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique,
  login_url text not null default 'https://rb-id.np.accenture.com/RB_ID/Logon.aspx',
  username text not null,
  encrypted_password text not null,
  warehouse text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.system_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

create table public.sku_leading_zero_rules (
  sku text primary key,
  formatted_sku text not null,
  created_at timestamptz not null default now()
);

create table public.distributor_sku_multipliers (
  id uuid primary key default gen_random_uuid(),
  distributor_id uuid not null references public.distributors(id) on delete cascade,
  sku text not null,
  multiplier numeric not null,
  unique(distributor_id, sku)
);

create table public.workers (
  id uuid primary key default gen_random_uuid(),
  worker_name text not null unique,
  status public.worker_status not null default 'OFFLINE',
  current_run_id uuid,
  last_heartbeat_at timestamptz,
  updated_at timestamptz not null default now()
);

create table public.automation_runs (
  id uuid primary key default gen_random_uuid(),
  distributor_id uuid not null references public.distributors(id),
  workflow text not null,
  status public.run_status not null default 'QUEUED',
  requested_by uuid references public.profiles(id),
  worker_id uuid references public.workers(id),
  started_at timestamptz,
  finished_at timestamptz,
  cancelled_at timestamptz,
  error_message text,
  created_at timestamptz not null default now()
);

create unique index one_active_run_per_distributor
on public.automation_runs(distributor_id)
where status in ('QUEUED','RUNNING');

create table public.automation_run_items (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.automation_runs(id) on delete cascade,
  sku text not null,
  newspage_qty numeric,
  distributor_qty numeric,
  multiplier numeric not null default 1,
  difference numeric,
  adjustment_qty numeric,
  created_at timestamptz not null default now()
);

create table public.automation_run_events (
  id bigserial primary key,
  run_id uuid not null references public.automation_runs(id) on delete cascade,
  event_type text not null,
  message text,
  payload jsonb,
  created_at timestamptz not null default now()
);

create table public.audit_logs (
  id bigserial primary key,
  actor_id uuid references public.profiles(id),
  action text not null,
  entity_type text,
  entity_id uuid,
  metadata jsonb,
  created_at timestamptz not null default now()
);

insert into public.system_settings(key, value) values
('login_url', '"https://rb-id.np.accenture.com/RB_ID/Logon.aspx"'::jsonb),
('navigation_timeout_ms', '120000'::jsonb),
('action_timeout_ms', '30000'::jsonb),
('job_timeout_ms', '3600000'::jsonb)
on conflict (key) do nothing;

insert into public.sku_leading_zero_rules(sku, formatted_sku) values
('135428','0135428'),('137118','0137118'),('137120','0137120'),('167209','0167209'),
('172130','0172130'),('172131','0172131'),('205901','0205901'),('22583','022583'),
('22595','022595'),('260656','0260656'),('260659','0260659'),('304095','0304095'),
('304100','0304100'),('304102','0304102'),('304157','0304157'),('304161','0304161'),
('304164','0304164'),('323044','0323044'),('372264','0372264'),('373100','0373100'),
('373103','0373103'),('373104','0373104'),('373105','0373105'),('373106','0373106'),
('373108','0373108'),('373110','0373110'),('373112','0373112')
on conflict (sku) do nothing;
