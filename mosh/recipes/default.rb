%w(protobuf-compiler libprotobuf-dev pkg-config libncurses5-dev zlib1g-dev libutempter-dev libio-pty-perl).each { |pkg| package pkg }

MOSH_VERSION = node.mosh.version

download_file "https://github.com/downloads/keithw/mosh/mosh-#{MOSH_VERSION}.tar.gz"

execute "install mosh" do
  command "
    cd /opt/src
    tar xvfz mosh-#{MOSH_VERSION}.tar.gz
    cd mosh-#{MOSH_VERSION}
    ./configure --prefix=/opt/mosh-#{MOSH_VERSION}
    make
    make install
  "
  creates "/opt/mosh-#{VERSION}/bin/mosh"
end

link "/opt/mosh" do
  to "/opt/mosh-#{MOSH_VERSION}"
end
