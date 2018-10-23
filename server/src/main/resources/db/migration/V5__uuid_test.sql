CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
ALTER TABLE public."user" ADD public_key uuid NOT NULL DEFAULT uuid_generate_v4();
CREATE UNIQUE INDEX user_public_key_uindex ON public."user" (public_key);

ALTER TABLE public."deposit" ADD public_key uuid NOT NULL DEFAULT uuid_generate_v4();
CREATE UNIQUE INDEX deposit_public_key_uindex ON public."deposit" (public_key);

ALTER TABLE public."transaction" ADD public_key uuid NOT NULL DEFAULT uuid_generate_v4();
CREATE UNIQUE INDEX transaction_public_key_uindex ON public."transaction" (public_key);

ALTER TABLE public."transaction_category" ADD public_key uuid NOT NULL DEFAULT uuid_generate_v4();
CREATE UNIQUE INDEX transaction_category_public_key_uindex ON public."transaction_category" (public_key);


