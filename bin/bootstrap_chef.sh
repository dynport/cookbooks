export PATH=/var/lib/gems/1.8/bin:$PATH

test -f /usr/bin/git || apt-get -y install git-core
test -f /usr/bin/gem || apt-get -y install ruby rubygems
test -f /var/lib/gems/1.8/bin/chef-solo || gem install chef --no-ri --no-rdoc
test -d /root/cookbooks || git clone https://github.com/dynport/cookbooks.git /root/cookbooks
cd /root/cookbooks && git pull --rebase origin
cd /root
