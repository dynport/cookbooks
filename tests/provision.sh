export PATH=/var/lib/gems/1.8/bin:$PATH
test -f /usr/bin/gem || sudo apt-get -y install ruby rubygems
test -f /var/lib/gems/1.8/bin/chef-solo || sudo gem install chef --no-ri --no-rdoc

chef-solo -c /vagrant/tests/config.rb -j /vagrant/tests/dna.json