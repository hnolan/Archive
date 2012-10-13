DELIMITER $$

DROP PROCEDURE IF EXISTS `cdc_rtg`.`cdc_refresh` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdc_refresh` ()
BEGIN

declare pn varchar(50) default 'cdc_refresh';
declare rc int default 0;
declare rc2 int default 0;

call cdc_logit( pn, concat( 'Enter' ) );

/*
--------------------------------------
 Refresh the cdb_interfaces
--------------------------------------
*/

-- Insert any new router interfaces into cdb_interfaces
insert into cdc_interfaces ( rtg_rid, rtg_iid, router_name, interface_name, speed, description )
select r.rid, i.id, r.name, i.name, i.speed, i.description
 from rtg.router r join rtg.interface i on r.rid = i.rid
 where not exists (
  select 1 from cdc_interfaces c where c.router_name = r.name and c.interface_name = i.name
 );

set rc = row_count();
if rc > 0 then
  call cdc_logit( pn, concat( 'Created ',rc,' new router interfaces' ) );
 end if;

-- Re-map entries with different ids
update cdc_interfaces c
  join rtg.router r on c.router_name = r.name
  join rtg.interface i on r.rid = i.rid and c.interface_name = i.name
 set c.rtg_iid = i.id
  where c.rtg_iid <> i.id;

set rc2 = row_count();
if rc2 > 0 then
  call cdc_logit( pn, concat( 'Re-mapped ',rc,' router interface ids' ) );
 end if;

if rc > 0 or rc2 > 0 then
  call rtg_refresh();
 end if;

/*
--------------------------------------
 Refresh the cdb_datasets
--------------------------------------
*/

-- Insert an entry into cdb_datasets for any new datasets found
insert into cdc_datasets ( cdc_iid, cdc_cid, rtg_data_table, import_from, import_before, export_from )
select ci.id as cdc_iid, cc.id as cdc_cid, rs.rtg_data_table,
  rtg_first_sample as import_from,
  date_add( date(rtg_last_sample), interval hour(rtg_last_sample) hour ) as import_before,
  date_add( date(rtg_first_sample), interval hour(rtg_first_sample) hour ) as export_from
 from rtg_data_stats rs
 join cdc_interfaces ci on rs.rtg_iid = ci.rtg_iid
 join cdc_counters cc on rs.rtg_mib_item = cc.mib_item
 where not exists (
  select 1 from cdc_datasets ds where ds.cdc_iid = ci.id and ds.cdc_cid = cc.id
 );

-- Log dataset creation
set rc = row_count();
if rc > 0 then
  call cdc_logit( pn, concat( 'Created ',rc,' new datasets' ) );
 end if;

-- Log exit
call cdc_logit( pn, 'Exit' );

END $$

DELIMITER ;
