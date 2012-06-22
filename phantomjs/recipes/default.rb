include_recipe "source"

PHANTOM_JS_VERSION = node.phantomjs.version
PHANTOM_JS_PREFIX = "phantomjs-#{PHANTOM_JS_VERSION}-linux-x86_64-dynamic"

download_file "http://phantomjs.googlecode.com/files/#{PHANTOM_JS_PREFIX}.tar.bz2"

execute 'install phantomjs' do
  cwd '/opt'
  command "tar xvfj #{src_dir}/#{PHANTOM_JS_PREFIX}.tar.bz2 && cd /opt/#{PHANTOM_JS_PREFIX}"
  creates "/opt/#{PHANTOM_JS_PREFIX}/bin/phantomjs"
end

link '/opt/phantomjs' do
  to "/opt/#{PHANTOM_JS_PREFIX}"
end
