def install_ruby(version, attributes = {})
  include_recipe "source"
  name = "ruby-#{version}"

  download_file "http://ftp.ruby-lang.org/pub/ruby/1.9/#{name}.tar.gz"
  %w(build-essential libyaml-dev libxml2-dev libxslt1-dev libreadline-dev libssl-dev zlib1g-dev).each do |pkg|
    package pkg
  end

  compile_env = {}
  compile_env["CFLAGS"] = attributes[:cflags] if attributes[:cflags]

  build_commands = []
  build_commands << "tar xvfz #{name}.tar.gz && cd #{name}"

  prefix = "/opt/#{name}"

  # taken from https://gist.github.com/4136373
  if attributes[:falcon_patch]
    package "autoconf"
    log "applying falcon patch"
    file "/opt/src/falcon.diff" do
      content File.read(File.expand_path("../../files/default/falcon.diff", __FILE__))
    end
    build_commands << "patch -p1</opt/src/falcon.diff"
    prefix += "-falcon"
  end
  build_commands << "./configure --prefix=#{prefix} && make && make install"

  execute "install ruby-#{version}" do
    env compile_env
    cwd "/opt/src"
    command build_commands.join(" && ")
    not_if "test -e #{prefix}/bin/ruby"
  end

  if attributes[:symlink]
    link "/opt/ruby" do
      to "/opt/#{name}"
    end
  end
end
