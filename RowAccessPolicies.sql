--Use the appropriate roles for your Snowflake instance - this is just demo purposes
use role accountadmin;

--Create the appropriate objects (role, databases, schema, warehouses)
create or replace role rowaccess1;
create or replace role rowaccess2;
create or replace database row_test;
use schema public;

--Create a warehouse to insert new data rows into
create or replace warehouse compute_wh WITH warehouse_size = 'xsmall' auto_suspend=60 auto_resume=true;

--Create grants so we can use the new objects (roles, databases, schemas, and warehouses)
--Allow our accountadmin to use the newly created roles
grant role rowaccess1 to role accountadmin;
grant role rowaccess2 to role accountadmin;

--Our new roles will need to be able to access the new database 
grant usage on database row_test to role rowaccess1;
grant usage on database row_test to role rowaccess2;

--Our new roles will need to be able to access the public schema
grant usage on schema row_test.public to role rowaccess1;
grant usage on schema row_test.public to role rowaccess2;

--Our new roles will need to be able to read the tables we create
grant select on future tables in schema row_test.public to role rowaccess1;
grant select on future tables in schema row_test.public to role rowaccess2;

--Lastly, our new roles will need to be able to use the compute we created to query the data
grant usage on warehouse compute_wh to role rowaccess1;
grant usage on warehouse compute_wh to role rowaccess2;

--Let's now create a two column table that we can test our row access policies on. 
--Create a table to store the values in
create or replace table row_test.public.sample_table (
  name varchar,
  state varchar,
  id number);
  
--Use warehouse for inserting data
use warehouse compute_wh;
  
--Insert the data into our newly created data. A warehouse is needed for this
insert into row_test.public.sample_table (name, state, id)
  values ('Jesse', 'NC', 1),
         ('Liam', 'VA', 2),
         ('Noah', 'CA', 2),
         ('Oliver','AK',2),
         ('Elijah', 'TX',1),
         ('Olivia','VA',1),
         ('Emma','LA',2),
         ('Charlotte','NC',1),
         ('Amelia','FL',1),
         ('James','GA',1),
         ('Ava','SC',2);

--Now begins the actual part of working with row access policies. Everything else before
--was for setting up our environment. The following table will be a list of mappings that
--state what role can access what rows!


--Create a table of the mappings
create or replace table row_test.public.sample_mappings(
  role varchar,
  role_id number);
  
--Insert the mappings into the data. ROWACCESS1 can access rows with the value '1'
--in ID. Similiary ROWACCESS2 for rows with value '2'
insert into row_test.public.sample_mappings( role, role_id)
  values ('ROWACCESS1', 1),
         ('ROWACCESS2', 2);

--Create a row access policy object on our id. Set the policy based on the role using current_role
--and based on the id mappings.  ACCOUNTADMIN can see all the rows.
create or replace row access policy row_test.public.demo_policy as (id number) returns boolean -> 
  'ACCOUNTADMIN'= current_role() 
    or exists (
      select 1 from row_test.public.sample_mappings
        where role=current_role() and
              role_id=id);

--Apply our row base policies to the table
alter table row_test.public.sample_table add row access policy row_test.public.demo_policy on (id);
  
--Let's simulate all the use cases
--Simulate the row base policy with role accountadmin
use role accountadmin;
select * from row_test.public.sample_table;

--Simulate the row base policy with role rowaccess1
use role rowaccess1;
select * from row_test.public.sample_table;

--Simulate the row base policy with role rowaccess2
use role rowaccess2;
select * from row_test.public.sample_table;
