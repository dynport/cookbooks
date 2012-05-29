# name           : name of the daemon
# user           : user to be used to run daemon as
# cwd            : used to chdir before starting daemon
# pidfile        : path to pidfile used by start-stop-daemon
# daemon         : pass to script used to run daemon
# daemon_args    : arguments passed after -- 
# create_pidfile : tells start-stop-daemon to create the pidfile (using -m)
# syslog_flag    : pipes output of daemon to | logger -t <syslog_flag> when set

def start_stop_script(attributes)
  [:user, :cwd, :name, :pidfile, :daemon].each do |key|
    raise "#{key} not set" if !attributes.has_key?(key)
  end

  template "/etc/init.d/#{attributes[:name]}" do
    source "start_stop_script.erb"
    cookbook "base"
    variables(attributes)
    mode "755"
  end
end