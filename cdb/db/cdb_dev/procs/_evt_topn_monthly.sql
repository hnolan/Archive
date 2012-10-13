DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`_evt_topn_monthly` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `_evt_topn_monthly` (
        p_prefix varchar(20),
        p_year   int,
        p_month  int,
        p_topn   int,
        p_grade  varchar(20)
        )
BEGIN

declare grade_sql varchar(50);

-- Parameter validation
if upper(p_grade) = 'HARD' then
  set grade_sql = ' and event_grade = ''HARD'' ';
 elseif upper(p_grade) = 'SOFT' then
  set grade_sql = ' and event_grade = ''SOFT'' ';
 else
  set grade_sql = '';
 end if;

/*
----------------------------------------------------
This routine expects the calling routine to have
created a temp table with the following layout.
This routine populates that table.
----------------------------------------------------
create temporary table temp_evt_topn (
        toptype varchar(50),
        topval int,
        i_id integer,
--        event_state enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
--        event_grade enum('HARD','SOFT') NOT NULL,
        event_count int,
        event_duration int
        );
----------------------------------------------------
*/

-- Top N Host Event Duration
set @sql = 'insert into temp_evt_topn ( toptype, topval, i_id, event_count, event_duration ) ';
set @sql = concat( @sql, ' select ''Top ', p_topn, ' Hosts by Event Duration'', sum(event_duration), ' );
set @sql = concat( @sql, '     cdb_instance_id, sum(event_count), sum(event_duration) ' );
set @sql = concat( @sql, '   from evt_stats_monthly e join event_instances i on e.cdb_instance_id = i.i_id ' );
set @sql = concat( @sql, '   where cdb_prefix = ''', p_prefix, ''' and sample_year = ', p_year, ' and sample_month = ', p_month );
set @sql = concat( @sql, '      and service_type = ''AVAIL'' and cdb_instance = '''' ', grade_sql );
set @sql = concat( @sql, '    group by i_id order by sum(event_duration) desc limit ', p_topn );

prepare stmt from @sql;
execute stmt;

-- Top 10 Service Event Duration
set @sql = 'insert into temp_evt_topn ( toptype, topval, i_id, event_count, event_duration ) ';
set @sql = concat( @sql, ' select ''Top ', p_topn, ' Services by Event Duration'', sum(event_duration), ' );
set @sql = concat( @sql, '     cdb_instance_id, sum(event_count), sum(event_duration) ' );
set @sql = concat( @sql, '   from evt_stats_monthly e join event_instances i on e.cdb_instance_id = i.i_id ' );
set @sql = concat( @sql, '   where cdb_prefix = ''', p_prefix, ''' and sample_year = ', p_year, ' and sample_month = ', p_month );
set @sql = concat( @sql, '      and service_type = ''AVAIL'' and cdb_instance <> '''' ', grade_sql );
set @sql = concat( @sql, '    group by i_id order by sum(event_duration) desc limit ', p_topn );

prepare stmt from @sql;
execute stmt;

END $$

DELIMITER ;
