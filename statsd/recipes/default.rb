include_recipe "source"
include_recipe "node"

package "git-core"

VERSION = node.statsd.version

DIR = "/opt/statsd-#{VERSION}"
PATH = "#{src_dir}/node-v#{VERSION}.tgz"


remote_file PATH do
  source "https://github.com/etsy/statsd/tarball/v#{VERSION}"
end

execute "unpack node" do
  command "tar xvfz #{PATH} && mv etsy-statsd-11049a2/ #{DIR}"
  cwd "/tmp"
  creates "#{DIR}/stats.js"
end

template "#{DIR}/statsdConfig.js" do
  variables(
    :graphite_port => node.statsd.graphite_port,
    :graphite_host => node.statsd.graphite_host,
    :port => node.statsd.port,
    :address => node.statsd.address,
    :mgmt_address => node.statsd[:mgmt_address],
    :mgmt_port => node.statsd[:mgmt_port]
  )
end
