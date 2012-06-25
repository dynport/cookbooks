file '/etc/apt/sources.list.d/newrelic.list' do
  content 'deb http://apt.newrelic.com/debian/ newrelic non-free'
end

execute 'add newrelic key' do
  command <<-EOF
    wget -O - http://download.newrelic.com/548C16BF.gpg | apt-key add -
    apt-get update
    apt-get install newrelic-sysmond
  EOF
  creates '/etc/init.d/newrelic-sysmond'
end

execute 'add newrelic license key' do
  command <<-EOF
    nrsysmond-config --set license_key=#{node.newrelic.license_key}
  EOF
  only_if "cat /etc/newrelic/nrsysmond.cfg | grep REPLACE_WITH"
end
