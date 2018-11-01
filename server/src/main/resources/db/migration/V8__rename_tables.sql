alter sequence deposit_id_seq rename to finance_deposit_id_seq;
ALTER TABLE deposit ALTER COLUMN id SET DEFAULT nextval('finance_deposit_id_seq'::regclass);
ALTER TABLE deposit RENAME TO finance_deposit;

ALTER TABLE deposit_owner RENAME TO finance_deposit_owner;
ALTER TABLE deposit_user RENAME TO finance_deposit_accessible_by;

alter sequence transaction_id_seq rename to finance_transaction_id_seq ;
ALTER TABLE transaction ALTER COLUMN id SET DEFAULT nextval('finance_transaction_id_seq'::regclass);
ALTER TABLE transaction RENAME TO finance_transaction;

alter sequence transaction_category_id_seq rename to finance_transaction_category_id_seq;
ALTER TABLE transaction_category ALTER COLUMN id SET DEFAULT nextval('finance_transaction_category_id_seq'::regclass);
ALTER TABLE transaction_category RENAME TO finance_transaction_category;

ALTER TABLE transaction_transaction_category RENAME TO finance_transaction_transaction_category;