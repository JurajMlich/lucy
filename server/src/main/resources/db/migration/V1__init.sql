create table if not exists "user"
(
  id         serial       not null
    constraint user_pkey
    primary key,
  email      varchar(255) not null,
  first_name varchar(255) not null,
  last_name  varchar(255) not null,
  password   varchar(255) not null
);

create unique index if not exists user_email_uindex
  on "user" (email);

create table if not exists deposit
(
  id       serial           not null
    constraint deposit_pkey
    primary key,
  balance  double precision not null,
  disabled boolean          not null,
  name     varchar(255)     not null,
  type     varchar(255)     not null,
  owner_id integer          not null
    constraint "FKips0rhqn9k84045nivxf81akb"
    references "user"
    on update cascade on delete cascade
);

create table if not exists deposit_user
(
  deposit_id integer not null
    constraint "FKg33cbyas4j4hs2k7hy6gl7bod"
    references deposit
    on update cascade on delete cascade,
  user_id    integer not null
    constraint "FKq6vrhhoyf98d4v7hfewmtmnwm"
    references "user"
    on update cascade on delete cascade,
  constraint deposit_user_pkey
  primary key (deposit_id, user_id)
);

create table if not exists transaction
(
  id                 serial           not null
    constraint transaction_pkey
    primary key,
  execution_datetime timestamp        not null,
  name               varchar(255),
  note               varchar(255),
  state              varchar(255)     not null,
  value              double precision not null,
  creator_id         integer          not null
    constraint "FK1qwmre5i52848sksjlq0gnku2"
    references "user"
    on update cascade,
  source_deposit_id  integer
    constraint "FKi8k1vr1wid0qs5yyc3gn54lti"
    references deposit
    on update cascade on delete set null,
  target_deposit_id  integer          not null
    constraint "FKpkvawd1gv1cappxqc1qub96yi"
    references deposit
    on update cascade on delete cascade
);

create table if not exists transaction_category
(
  id       serial       not null
    constraint transaction_category_pkey
    primary key,
  color    varchar(255),
  disabled boolean      not null,
  name     varchar(255) not null,
  negative boolean      not null
);

create table if not exists transaction_transaction_category
(
  transaction_id          integer not null
    constraint "FKbgksc56rb6gk8nv7sy9j84dw3"
    references transaction,
  transaction_category_id integer not null
    constraint "FK1uyqqb82ghrawoi40f0p6whgo"
    references transaction_category
    on update cascade on delete cascade,
  constraint transaction_transaction_category_pkey
  primary key (transaction_id, transaction_category_id)
);
