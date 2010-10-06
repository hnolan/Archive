#
#	Nagios object types
#
NAG_OBJTYP = %w(
	command
	contact
	contactgroup
	host
	hostdependency
	hostescalation
	hostextinfo
	hostgroup
	service
	servicedependency
	serviceescalation
	serviceextinfo
	servicegroup
	timeperiod
	)

#
#	Nagios configuration file variable declarations
#

NAG_MAINVARS = %w(

	log_file 
	
	cfg_file cfg_dir 
	
	object_cache_file precached_object_file resource_file
	temp_file temp_path status_file status_update_interval 
	
	nagios_user nagios_group

	enable_notifications 
	
	execute_service_checks accept_passive_service_checks execute_host_checks 
	accept_passive_host_checks enable_event_handlers 
	
	log_rotation_method log_archive_path 
	
	check_external_commands command_check_interval command_file
	external_command_buffer_slots lock_file 
	
	retain_state_information state_retention_file retention_update_interval 
	use_retained_program_state use_retained_scheduling_info 
	retained_host_attribute_mask	retained_service_attribute_mask 
	retained_process_host_attribute_mask retained_process_service_attribute_mask
	retained_contact_host_attribute_mask retained_contact_service_attribute_mask 
	
	use_syslog log_notifications log_service_retries log_host_retries log_event_handlers
	log_initial_states log_external_commands log_passive_checks

	global_host_event_handler global_service_event_handler

	sleep_time service_inter_check_delay_method max_service_check_spread
	service_interleave_factor max_concurrent_checks check_result_reaper_frequency
	max_check_result_reaper_time check_result_path max_check_result_file_age
	host_inter_check_delay_method max_host_check_spread interval_length

	auto_reschedule_checks auto_rescheduling_interval auto_rescheduling_window

	use_aggressive_host_checking 
	
	translate_passive_host_checks passive_host_checks_are_soft 
	
	enable_predictive_host_dependency_checks enable_predictive_service_dependency_checks 
	
	cached_host_check_horizon cached_service_check_horizon 
	
	use_large_installation_tweaks 
	
	free_child_process_memory child_processes_fork_twice 
	
	enable_environment_macros 
	
	enable_flap_detection low_service_flap_threshold high_service_flap_threshold
	low_host_flap_threshold high_host_flap_threshold

	soft_state_dependencies service_check_timeout host_check_timeout event_handler_timeout
	notification_timeout 
	
	ocsp_timeout ochp_timeout perfdata_timeout obsess_over_services ocsp_command 
	obsess_over_hosts ochp_command 
	
	process_performance_data host_perfdata_command service_perfdata_command
	host_perfdata_file service_perfdata_file host_perfdata_file_template
	service_perfdata_file_template host_perfdata_file_mode service_perfdata_file_mode
	host_perfdata_file_processing_interval service_perfdata_file_processing_interval
	host_perfdata_file_processing_command service_perfdata_file_processing_command

	check_for_orphaned_services check_for_orphaned_hosts

	check_service_freshness service_freshness_check_interval check_host_freshness
	host_freshness_check_interval additional_freshness_latency

	enable_embedded_perl use_embedded_perl_implicitly p1_file

	date_format use_timezone

	illegal_object_name_chars illegal_macro_output_chars 

	use_regexp_matching use_true_regexp_matching

	admin_email admin_pager

	event_broker_options broker_module

	daemon_dumps_core
	
	debug_file debug_level debug_verbosity max_debug_file_size
	
	)	# End of NAGVARS array (Nagios config variables)


#
#	Nagios object declarations
#

NAG_OBJVARS = {

 "command" =>
	%w( 
		command_name 
		command_line 
		name register use
		), 

 "contact" => 
	%w(
		contact_name
		alias
		contactgroups
		host_notifications_enabled
		service_notifications_enabled
		host_notification_period
		service_notification_period
		host_notification_options
		service_notification_options
		host_notification_commands
		service_notification_commands
		email
		pager
		addressx
		can_submit_commands
		retain_status_information
		retain_nonstatus_information
		name register use
		),

 "contactgroup" =>
	%w(	
		contactgroup_name
		alias
		members
		contactgroup_members
		name register use
		),

 "host" =>
	%w(	
		host_name
		alias
		display_name
		address
		parents
		hostgroups
		check_command
		initial_state
		max_check_attempts
		check_interval
		normal_check_interval
		retry_interval
		retry_check_interval
		active_checks_enabled
		passive_checks_enabled
		check_period
		obsess_over_host
		check_freshness
		freshness_threshold
		event_handler
		event_handler_enabled
		low_flap_threshold
		high_flap_threshold
		flap_detection_enabled
		flap_detection_options
		process_perf_data
		retain_status_information
		retain_nonstatus_information
		contacts
		contact_groups
		notification_interval
		first_notification_delay
		notification_period
		notification_options
		notifications_enabled
		stalking_options
		notes
		notes_url
		action_url
		icon_image
		icon_image_alt
		vrml_image
		statusmap_image
		2d_coords
		3d_coords
		name register use
		),

 "hostdependency" =>
	%w(	
		dependent_host_name
		dependent_hostgroup_name
		host_name
		hostgroup_name
		inherits_parent
		execution_failure_criteria
		notification_failure_criteria
		dependency_period
		name register use
		),

 "hostescalation" =>
	%w( 
		host_name
		hostgroup_name
		contacts
		contact_groups
		first_notification
		last_notification
		notification_interval
		escalation_period
		escalation_options
		name register use
		),

 "hostextinfo" => 
	%w( 
		host_name
		notes
		notes_url
		action_url
		icon_image
		icon_image_alt
		vrml_image
		statusmap_image
		2d_coords
		3d_coords
		name register use
		),

 "hostgroup" =>
	%w( 
		hostgroup_name
		alias
		members
		hostgroup_members
		notes
		notes_url
		action_url
		name register use
		),

 "service" =>
	%w( 
		host_name
		hostgroup_name
		hostgroup
		service_description
		display_name
		servicegroups
		is_volatile
		check_command
		initial_state
		max_check_attempts
		check_interval
		normal_check_interval
		retry_interval
		retry_check_interval
		active_checks_enabled
		passive_checks_enabled
		check_period
		obsess_over_service
		check_freshness
		freshness_threshold
		event_handler
		event_handler_enabled
		low_flap_threshold
		high_flap_threshold
		flap_detection_enabled
		flap_detection_options
		process_perf_data
		retain_status_information
		retain_nonstatus_information
		notification_interval
		first_notification_delay
		notification_period
		notification_options
		notifications_enabled
		contacts
		contact_groups
		stalking_options
		notes
		notes_url
		action_url
		icon_image
		icon_image_alt
		parallelize_check
		name register use
		),

 "servicedependency" =>
	%w( 
		dependent_host_name
		dependent_hostgroup_name
		dependent_service_description
		host_name
		hostgroup_name
		service_description
		inherits_parent
		execution_failure_criteria
		notification_failure_criteria
		dependency_period
		name register use
		),

 "serviceescalation" =>
	%w( 
		host_name
		hostgroup_name
		service_description
		contacts
		contact_groups
		first_notification
		last_notification
		notification_interval
		escalation_period
		escalation_options
		name register use
		),

 "serviceextinfo" =>
	%w( 
		host_name
		service_description
		notes
		notes_url
		action_url
		icon_image
		icon_image_alt
		name register use
		),

 "servicegroup" =>
	%w( 
		servicegroup_name
		alias
		members
		servicegroup_members
		notes
		notes_url
		action_url
		name register use
		),

 "timeperiod" =>
	%w( 
		timeperiod_name
		alias
		sunday monday tuesday wednesday thursday friday saturday 
		exception
		exclude
		name register use
		)
	
}	# End of OBJVARS hash (Nagios Object Variables)
	

# Nagios attributes that can contain multiple references	
NAG_ATTR_MULTI = {

 "contact" => 
	%w(
		contactgroups 
		host_notification_commands 
		service_notification_commands 
		use
		),

 "contactgroup" =>
	%w( 
		contactgroup_members
		members
		use
		), 

 "host" =>
	%w( 
		contact_groups
		contacts
		hostgroups
		parents
		use
		), 

 "hostescalation" =>
	%w( 
		contact_groups
		contacts
		use
		), 

 "hostgroup" =>
	%w( 
		hostgroup_members
		members
		use
		), 

 "service" =>
	%w( 
		contact_groups
		contacts
		servicegroups
		use
		), 

 "serviceescalation" =>
	%w( 
		contacts
		use
		), 

 "servicegroup" =>
	%w( 
		members
		servicegroup_members
		use
		), 

 "timeperiod" =>
	%w( 
		exclude 
		use
		)

}	# End of NAG_ATTR_MULTI hash
	

