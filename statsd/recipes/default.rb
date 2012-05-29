include_recipe "node"

package "git-core"

VERSION = node.statsd.version

DST = node.source.install_dir

VERSION_DIR = "#{DST}/statsd-#{VERSION}"
DIR = "#{DST}/statsd"

PATH = "#{src_dir}/node-v#{VERSION}.tgz"


remote_file PATH do
  source "https://github.com/etsy/statsd/tarball/v#{VERSION}"
end

execute "unpack node" do
  command "tar xvfz #{PATH} && mv etsy-statsd-11049a2/ #{VERSION_DIR}"
  cwd "/tmp"
  creates "#{VERSION_DIR}/stats.js"
end

link DIR do
  to "#{VERSION_DIR}"
end

template "#{VERSION_DIR}/statsdConfig.js" do
  variables(
    :graphite_port => node.statsd.graphite_port,
    :graphite_host => node.statsd.graphite_host,
    :port => node.statsd.port,
    :address => node.statsd.address,
    :mgmt_address => node.statsd[:mgmt_address],
    :mgmt_port => node.statsd[:mgmt_port]
  )
  mode "0644"
end

user "statsd"

start_stop_script(
  :name => "statsd", 
  :pidfile => "/tmp/statsd.pid", :daemon => "#{DIR}/bin/node", :daemon_args => "stats.js statsdConfig.js", :cwd => DIR,
  :user => "statsd", :syslog_flag => "statsd", :create_pidfile => true
)