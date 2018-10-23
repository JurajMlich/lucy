ALTER TABLE public.instance_instruction ADD instance_id int NOT NULL;
CREATE INDEX instance_instruction_instance_id_index ON public.instance_instruction (instance_id);
ALTER TABLE public.instance_instruction
  ADD CONSTRAINT instance_instruction_instance_id_instance_id_fk
FOREIGN KEY (instance_id) REFERENCES public.instance (id) ON DELETE CASCADE ON UPDATE CASCADE;