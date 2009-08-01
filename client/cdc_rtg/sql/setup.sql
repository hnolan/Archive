create database cdc_rtg;
create user 'cdc'@'localhost' identified by 'artichoke';
grant ALL on rtg.* TO 'cdc'@'localhost';
grant ALL on cdc_rtg.* TO 'cdc'@'localhost';
