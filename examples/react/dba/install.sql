rem  Copyright (c) 2019 By AsterionDB Inc.
rem
rem  install.sql 	AsterionDB DbTwig Middle Tier Framework
rem
rem  Written By:  Steve Guilford
rem
rem  This SQL script drives the creation of all required objects for the DbTwig Middle Tier Framework
rem  suite of tutorials.
rem
rem  Invocation: sqlplus /nolog @install

whenever sqlerror exit failure;

set verify off
spool install.log

PROMPT To proceed, you will have to connect to the database as a DBA.
PROMPT

accept dba_user prompt "Enter a user name that can connect to the database as a DBA: "
accept dba_pass prompt "Enter the DBA password: " hide

connect &&dba_user/&&dba_pass;

prompt
accept dbtwig_user prompt "Enter the name of the user that owns the DbTwig schema [dbtwig]: " default dbtwig
prompt

prompt
prompt We need to create a user to own the DbTwig Examples schema
accept dbtwig_examples_user prompt "Enter the name of the DbTwig Examples schema owner [dbtwig_examples]: " default dbtwig_examples
prompt

prompt
accept dbtwig_examples_password prompt "Enter the DbTwig Examples user's password: " hide
prompt

prompt
accept vault_user prompt "Enter the name of the user that owns the AsterionDB schema [asteriondb_objvault]: " default asteriondb_objvault
prompt

set echo on

declare

    l_sql_text                        clob;
    l_default_tablespace              database_properties.property_value%type;

begin

    select  property_value
      into  l_default_tablespace
      from  database_properties 
     where  property_name = 'DEFAULT_PERMANENT_TABLESPACE';

    l_sql_text := 'create user &&dbtwig_examples_user identified by "&&dbtwig_examples_password"';
    execute immediate l_sql_text;

    l_sql_text := 'grant create session, create table, create procedure to &&dbtwig_examples_user';
    execute immediate l_sql_text;

    l_sql_text := 'alter user &&dbtwig_examples_user quota 50M on '||l_default_tablespace;
    execute immediate l_sql_text;

end;
.
/

grant execute on &&dbtwig_user..db_twig to &&dbtwig_examples_user;

create synonym &&dbtwig_examples_user..db_twig for &&dbtwig_user..db_twig;

alter session set current_schema = &&dbtwig_user;

insert into db_twig_services values ('reactExample', '&&dbtwig_examples_user');

alter session set current_schema = &&dbtwig_examples_user;

create table insurance_claims     
(claim_id 			                number(6) primary key,
 insured_party 		                varchar2(60),
 accident_date 		                date,
 deductible_amount 		            number(8,2),
 accident_location       	        varchar2(128),
 claims_adjuster_report 	        varchar2(128));

create table insurance_claim_photos
(claim_id 		                    number(6)
   references insurance_claims(claim_id),
 filename 		                    varchar2(128));

create sequence tutorials_seq minvalue 1 maxvalue 999999 cycle start with 1;

begin

  insert into insurance_claims
    (claim_id, insured_party, accident_location, accident_date, deductible_amount, claims_adjuster_report)
  values
    (tutorials_seq.nextval, 'Vincent Van Gogh', 'Auvers-sur-Oise, France', '27-JUL-1890', 9239.29, 'assets/pdfs/vanGogh.pdf');

  insert into insurance_claims
    (claim_id, insured_party, accident_location, accident_date, deductible_amount, claims_adjuster_report)
  values
    (tutorials_seq.nextval, 'James Dean', 'Cholame, California', '30-SEP-1955', 5553.12, 'assets/pdfs/jamesDean.pdf');

  insert into insurance_claim_photos
    select  claim_id, 'assets/images/vincentVanGogh_1.jpg'
      from  insurance_claims
     where  insured_party = 'Vincent Van Gogh';

  insert into insurance_claim_photos
    select  claim_id, 'assets/images/vincentVanGogh_2.jpg'
      from  insurance_claims
     where  insured_party = 'Vincent Van Gogh';

  insert into insurance_claim_photos
    select  claim_id, 'assets/images/jamesDean_1.jpg'
      from  insurance_claims
     where  insured_party = 'James Dean';

  insert into insurance_claim_photos
    select  claim_id, 'assets/images/jamesDean_2.jpg'
      from  insurance_claims
     where  insured_party = 'James Dean';

end;
.
/

commit;

@@react_example
@@react_example.pls

@@../../../dba/middleTierMap

insert into middle_tier_map values ('getInsuranceClaims', 'function', 'react_example.get_insurance_claims');
insert into middle_tier_map values ('getInsuranceClaimDetail', 'function', 'react_example.get_insurance_claim_detail');
insert into middle_tier_map values ('restApiError', 'function', 'react_example.error_handler');

commit;

spool off;
exit;
