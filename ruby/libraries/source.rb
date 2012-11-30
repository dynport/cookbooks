def install_ruby(version, symlink = true)
  include_recipe "source"
  name = "ruby-#{version}"

  download_file "http://ftp.ruby-lang.org/pub/ruby/1.9/#{name}.tar.gz"
  %w(build-essential libyaml-dev libxml2-dev libxslt-dev libreadline-dev libssl-dev zlib1g-dev).each do |pkg|
    package pkg
  end

  execute "install ruby-#{version}" do
    cwd "/opt/src"
    command "tar xvfz #{name}.tar.gz && cd #{name} && ./configure --prefix=/opt/#{name} && make && make install"
    not_if "test -e /opt/#{name}/bin/ruby"
  end
  
  if symlink
    link "/opt/ruby" do
      to "/opt/#{name}"
    end
  end
end
