DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`nag_check_instances` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `nag_check_instances` (
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

/*

This procedure scans the raw events in the input table and produces
an output table which maps the host, service and reason (event type)
fields on to instances ids which are subsequently used to store the
event data.

The procedure creates new machine and instance records as required.

Input table: tempev

The table is expected to exist with at least the following columns:

  `host` varchar(100) NOT NULL,
  `service` varchar(100) default NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime default '0000-00-00 00:00:00',
  `reason` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,

Any other columns are ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'nag_check_instances';
declare rc integer default 0;
declare mrc integer default 0;
declare irc integer default 0;
declare dsrcid integer default 0;
declare custid integer default 0;

-- ---------------------------------------
-- Check that a unique datasource exists
-- ---------------------------------------
select count(*) from m06_datasources ds
 join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.cdb_customer_id from m06_datasources ds
   join m00_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid, custid;
 else
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  call cdb_logit( pn, concat( 'Exit. *** Error - ', rc, ' datasources found ***' ) );
  leave main;
 end if;

-- ---------------------------------------
--  Create machines from any new hosts
-- ---------------------------------------
insert into m01_machines ( cdb_customer_id, name )
 select custid, t.host
  from ( select distinct host from tempev ) t
 where t.host not in ( select name from m01_machines m where m.cdb_customer_id = custid );

set mrc = row_count();

-- Report machine creation, if any were found
if mrc > 0 then
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  call cdb_logit( pn, concat( mrc, ' new machines created' ) );
 end if;

-- ---------------------------------------
-- Populate temporary table to hold
--  instance details for lookup
-- ---------------------------------------
insert into temp_instances ( i_id, m_id, o_id, cdb_machine, cdb_object, cdb_instance, nag_event_type, latest_event )
select i.id as i_id, m.id as m_id, o.id as o_id, ni.* from (
 select host as cdb_machine,
  case
   when reason like '%HOST%' then _latin1 'NagiosHostEvent'
   when reason like '%SERVICE%' then _latin1 'NagiosServiceEvent'
   else _latin1 'NagiosOtherEvent'
   end as cdb_object,
  service as cdb_instance, reason as nag_event_type, IFNULL( max(end_time), max(start_time) ) as latest_event
  from tempev group by host, service order by host, service
 ) ni
  join m01_machines m on m.name = ni.cdb_machine
  join m02_objects o on o.name = ni.cdb_object
  left join m03_instances i on i.cdb_machine_id = m.id and i.cdb_object_id = o.id and i.name = ni.cdb_instance
 where m.cdb_customer_id = custid;

-- ---------------------------------------
--  Create any new instances
-- ---------------------------------------
insert into m03_instances ( cdb_machine_id, cdb_object_id, name, latest_event )
 select m_id, o_id, cdb_instance, latest_event from temp_instances
  where i_id IS NULL;

set irc = row_count();

-- Handle instance creation, if any were found
if irc > 0 then

  if mrc = 0 then
    call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
    call cdb_logit( pn, concat( mrc, ' new machines created' ) );
   end if;

  call cdb_logit( pn, concat( irc, ' new instances created' ) );

  -- Update temp table with new instance ids
  update temp_instances ti join m03_instances i
    on ti.m_id = i.cdb_machine_id and ti.o_id = i.cdb_object_id and ti.cdb_instance = i.name
   set ti.i_id = i.id;

  end if;

-- select * from temp_instances;

if mrc > 0 or irc > 0 then
  call cdb_logit( pn, concat( 'Exit' ) );
 end if;

END main;

END $$

DELIMITER ;
