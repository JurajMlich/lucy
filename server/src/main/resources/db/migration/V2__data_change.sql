create table if not exists "data_change"
(
  id                serial       not null
    constraint data_change_pkey
    primary key,
  resource          varchar(255) not null,
  type              varchar(255) not null,
  identifier        varchar(255) not null,
  creation_datetime timestamp    not null
);

ALTER TABLE public.transaction_transaction_category
  DROP CONSTRAINT "FKbgksc56rb6gk8nv7sy9j84dw3";
ALTER TABLE public.transaction_transaction_category
  ADD CONSTRAINT "FKbgksc56rb6gk8nv7sy9j84dw3"
FOREIGN KEY (transaction_id) REFERENCES public.transaction (id) ON DELETE CASCADE ON UPDATE CASCADE;

create table if not exists "device"
(
  id                serial       not null
    constraint device_pkey
    primary key,
  auth_token        varchar(255) not null,
  creation_datetime timestamp    not null
);

create table if not exists data_change_sent_to_device
(
  data_change_id integer not null
    constraint "FKbgksc56rb6gk8nv7sy9j84dw3"
    references data_change
    on update cascade on delete cascade,
  device_id      integer not null
    constraint "FK1uyqqb82ghrawoi40f0p6whgo"
    references device
    on update cascade on delete cascade,
  constraint data_change_sent_to_device_pkey
  primary key (data_change_id, device_id)
);

ALTER TABLE public.transaction ALTER COLUMN execution_datetime DROP NOT NULL;