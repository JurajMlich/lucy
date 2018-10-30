create table if not exists deposit_owner
(
  deposit_id integer not null
  constraint "FKg33cbyas4j4hs2k7hy6gl7bo2"
  references deposit
  on update cascade on delete cascade,
  user_id    integer not null
  constraint "FKq6vrhhoyf98d4v7hfewmtmnw4"
  references "user"
  on update cascade on delete cascade,
  constraint deposit_owner_pkey
  primary key (deposit_id, user_id)
);

ALTER TABLE public.deposit DROP CONSTRAINT "FKips0rhqn9k84045nivxf81akb";
ALTER TABLE public.deposit DROP owner_id;