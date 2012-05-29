def unicorn_start_stop_script(attributes)
  include_recipe "unicorn"
  include_recipe "source"

  name = attributes[:name]
  attributes[:syslog_flag] ||= "unicorn"
  attributes[:environment] ||= "production"
  daemon_args = "unicorn -E #{attributes[:environment]}"
  daemon_args << " -c #{attributes[:unicorn_config]}" if attributes[:unicorn_config]
  attributes[:start_stop_env] = "environment_id=#{attributes[:rvm_env]}"
  start_stop_script(attributes.merge(:pidfile => "/tmp/unicorn_#{name}.pid", :daemon => "#{node.source.install_dir}/bundle_wrapper", :daemon_args => daemon_args))
end