DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_test`.`cdb_create_datasets` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdb_create_datasets` ()
BEGIN

/*

This procedure creates new datasets by updating the underlying metadata tables.

It expects a temporary table called temp_datasets to exist containing the following columns :
	cdc_prefix        [varchar] (20) NOT NULL
	cdc_machine       [varchar] (200) NOT NULL
	cdc_object        [varchar] (50) NOT NULL
	cdc_instance      [varchar] (50) NULL
	cdc_counter       [varchar] (50) NOT NULL
	cdc_path          [varchar] (512) NOT NULL
If the table contains additional fields they will be ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdb_create_datasets';
declare rc integer default 0;

declare rcout integer default 0;

declare done int default 0;

-- Log entry
call cdb_logit( pn, concat( 'Enter' ) );

-- Create and populate temporary table to hold dataset details
create temporary table tt10 DEFAULT CHARSET=utf8
 select distinct c.id AS p_id, 0 AS m_id, 0 AS o_id, 0 AS i_id, 0 AS c_id,
	t.cdc_machine, t.cdc_object, t.cdc_instance, t.cdc_counter, t.cdc_prefix, t.cdc_path
 from temp_datasets t
  join cdb_customers c on c.prefix = t.cdc_prefix
 where t.cdc_path not in (
	SELECT d.cdb_path FROM cdb_datasets AS d where d.cdb_prefix = t.cdc_prefix
  );

-- Check for entries in tt10
select count(*) from tt10 into rc;

-- describe tt10;

-- Exit here if no data was found
if rc <= 0 then
  call cdb_logit( pn, concat( 'Exit - no new (valid) datasets found' ) );

  drop temporary table tt10;

  leave main;
 end if;

-- select * from tt10;

-- Log info message
call cdb_logit( pn, concat( 'Found ', rc, ' new (valid) datasets' ) );

-- ============
--   Machines
-- ============

-- Create entries for all new Machines
insert into cdb_machines ( cdb_customer_id, machine_name )
 select distinct t.p_id, t.cdc_machine from tt10 t
  where t.cdc_machine not in (
 select m.machine_name from cdb_machines m where m.cdb_customer_id = t.p_id );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new machines created' ) );
 end if;

 -- Update temp table with Machine IDs
update tt10 t join cdb_machines m
 on t.p_id = m.cdb_customer_id and t.cdc_machine = m.machine_name
 SET t.m_id = m.id;

-- ============
--   Objects
-- ============

-- create entries for all new objects
insert into cdb_objects ( object_name )
 select distinct t.cdc_object from tt10 t
 where t.cdc_object not in ( select distinct object_name from cdb_objects );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new objects created' ) );
 end if;

-- update temp table with object ids
update tt10 t join cdb_objects o on t.cdc_object = o.object_name
 set t.o_id = o.id;

-- ============
--   Instances
-- ============

-- Create entries for all new Instances
insert into cdb_instances ( cdb_machine_id, cdb_object_id, instance_name )
 select distinct t.m_id, t.o_id, t.cdc_instance
 from tt10 t where t.cdc_instance not in (
	select instance_name from cdb_instances where cdb_machine_id = t.m_id and cdb_object_id = t.o_id );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new instances created' ) );
 end if;

-- Update temp table with Instance IDs
update tt10 t join cdb_instances i on
 t.cdc_instance = i.instance_name and t.m_id = i.cdb_machine_id and t.o_id = i.cdb_object_id
 set t.i_id = i.id;

-- ============
--   Counters
-- ============

-- Create entries for all new Counters
insert into cdb_counters ( cdb_object_id, counter_name )
 select distinct t.o_id, t.cdc_counter from tt10 t
 where t.cdc_counter not in (
	select c.counter_name from cdb_counters c where c.cdb_object_id = t.o_id );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new counters created' ) );
 end if;

-- Update temp table with Counter IDs
update tt10 t join cdb_counters c
 on t.cdc_counter = c.counter_name and t.o_id = c.cdb_object_id
 set t.c_id = c.id;


-- ====================
-- ... and finally, Datasets
-- ====================

-- Create entries for all the new DataSets
insert into cdb_datasets (
 cdb_instance_id, cdb_counter_id, created_at, cdb_prefix, cdb_path )
 select t.i_id, t.c_id, now(), t.cdc_prefix, t.cdc_path
 from tt10 as t;

set rc = row_count();

-- Log results on exit
call cdb_logit( pn, concat( 'Exit - ', rc, ' new datasets created' ) );

select concat( 'cdb_create_datasets: ', rc, ' new datasets created' ) as msg;

-- Finally drop the temporary table
drop temporary table tt10;

END main;

END $$

DELIMITER ;
