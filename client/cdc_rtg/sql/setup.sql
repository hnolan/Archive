create database cdc_rtg;
create user 'cdc'@'localhost' identified by 'roc';
grant ALL on rtg.* TO 'cdc'@'localhost';
grant ALL on cdc_rtg.* TO 'cdc'@'localhost';
grant FILE on *.* TO 'cdc'@'localhost';

insert into cdc_config values ( 'LAHC', 'lancsman', '/var/cdc/export' );

