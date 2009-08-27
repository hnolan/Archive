DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_utils`.`weeknos` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `weeknos` (
        d datetime, m int
        )
BEGIN

declare i integer default 0;
declare dt datetime;

create temporary table t1 (
dateval datetime,
dayno   int(10),
weekno  int(10)
);

truncate table t1;

set dt = d;

while i < 14 do
  insert into t1 values ( dt, dayofweek(dt), week(dt,m) );
  set dt = date_add( dt, interval 1 day );
  set i = i + 1;
 end while;

select * from t1;

drop temporary table t1;

END $$

DELIMITER ;
