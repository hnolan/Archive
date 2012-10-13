DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_test`.`nag_check_instances` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `nag_check_instances` (
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

/*

The procedure creates new machine and instance records as required.

Input table: tempin

The table is expected to exist with at least the following columns:

  `svc_id` varchar(100) NOT NULL,
  `host` varchar(100) NOT NULL,
  `service` varchar(100) default NULL,
  `first_status_time` datetime NOT NULL,
  `latest_status_time` datetime  NOT NULL

Any other columns are ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'nag_check_instances';
declare msg varchar(250) default '';
declare rc integer default 0;
declare mrc integer default 0;
declare irc integer default 0;
declare dsrcid integer default 0;
declare custid integer default 0;

-- ---------------------------------------
-- Check that a unique datasource exists
-- ---------------------------------------
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.cdb_customer_id from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid, custid;
 else
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  set msg = concat( '*** Error - ', rc, ' datasources found ***' );
  call cdb_logit( pn, concat( 'Exit. ', msg ) );
  select msg;
  leave main;
 end if;

-- ---------------------------------------
--  Create machines from any new hosts
-- ---------------------------------------
insert into cdb_machines ( cdb_customer_id, machine_name )
 select custid, t.host
  from ( select distinct host from tempin ) t
 where t.host not in ( select machine_name from cdb_machines m where m.cdb_customer_id = custid );

set mrc = row_count();

-- Report machine creation, if any were found
if mrc > 0 then
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  set msg = concat( mrc, ' new machines created, ' );
 end if;

-- Populate tempin with machine IDs
update tempin t join cdb_machines m
 on m.machine_name = t.host and m.cdb_customer_id = custid
 set t.m_id = m.id;

-- ---------------------------------------
-- Populate tempin with object IDs
-- ---------------------------------------
update tempin t join cdb_objects o
 on o.object_name = IF(service= _utf8 '', _utf8 'NagiosHostEvent', _utf8 'NagiosServiceEvent')
 set t.o_id = o.id;

-- ---------------------------------------
 -- Create entries for all new Instances
-- ---------------------------------------
insert into cdb_instances ( cdb_machine_id, cdb_object_id, instance_name, first_status_time, latest_status_time )
 select t.m_id, t.o_id, t.service, t.first_status_time, t.latest_status_time
 from tempin t where t.service not in (
  select instance_name from cdb_instances where cdb_machine_id = t.m_id and cdb_object_id = t.o_id
  );

set irc = row_count();

-- Handle instance creation, if any were found
if irc > 0 then

  if mrc = 0 then
    call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
   end if;

  set msg = concat( msg, irc, ' new instances created.' );

  end if;

-- Populate tempin with instance IDs
update tempin t join cdb_instances i
  on t.m_id = i.cdb_machine_id and t.o_id = i.cdb_object_id and t.service = i.instance_name
 set t.i_id = i.id;

-- Update tempev with Instance IDs
update tempev e join tempin i on e.svc_id = i.svc_id
 set e.i_id = i.i_id;

-- Update instance table with latest times
update cdb_instances i join tempin t on t.i_id = i.id
 set i.latest_status_time = t.latest_status_time;

if msg <> '' then
  call cdb_logit( pn, concat( 'Exit. ', msg ) );
  select msg;
 end if;

END main;

END $$

DELIMITER ;
