if package = ARGV.first
  puts "running tests for #{package}"
  ENV["PATH"] = "/var/lib/gems/1.8/bin:#{ENV["PATH"]}"
  system %(test -f /usr/bin/gem || sudo apt-get -y install ruby rubygems)
  system %(test -f /var/lib/gems/1.8/bin/chef-solo || sudo gem install chef --no-ri --no-rdoc)
  
  exec "chef-solo -c /vagrant/config.rb -j /vagrant/tests/#{package}.json"
end
