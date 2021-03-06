ALTER TABLE device RENAME TO instance;
ALTER TABLE data_change ALTER COLUMN id TYPE BIGINT USING id::BIGINT;
ALTER TABLE data_change DROP COLUMN resource;
ALTER TABLE data_change DROP COLUMN identifier;
ALTER TABLE data_change ADD data varchar(2000) NULL;
ALTER TABLE data_change RENAME TO instance_instruction;
DROP TABLE  data_change_sent_to_device;
ALTER TABLE public.instance DROP CONSTRAINT device_pkey;
ALTER TABLE public.instance ADD CONSTRAINT instance_pkey PRIMARY KEY (id);
alter sequence data_change_id_seq rename to instance_instruction_id_seq;
alter sequence device_id_seq rename to instance_id_seq;
ALTER TABLE public.instance_instruction DROP CONSTRAINT data_change_pkey;
ALTER TABLE public.instance_instruction ADD CONSTRAINT instance_instruction_pkey PRIMARY KEY (id);
ALTER TABLE public.instance ALTER COLUMN id SET DEFAULT nextval('instance_id_seq'::regclass);
ALTER TABLE public.instance_instruction ALTER COLUMN id SET DEFAULT nextval('instance_instruction_id_seq'::regclass);