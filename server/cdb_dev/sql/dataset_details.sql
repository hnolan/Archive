select m5.id as dataset_id, m0.name as prefix, m1.name as machine, m2.name as object, m3.name as instance, m4.name as counter
 from m05_datasets m5
 join m04_counters m4 on m4.id = m5.cdb_counter_id
 join m03_instances m3 on m3.id = m5.cdb_instance_id
 join m02_objects m2 on m2.id = m3.cdb_object_id
 join m01_machines m1 on m1.id = m3.cdb_machine_id
 join m00_customers m0 on m0.id = m1.cdb_customer_id;
