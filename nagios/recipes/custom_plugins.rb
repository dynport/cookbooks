include_recipe "source"

icinga = Icinga.new(self)

user icinga.username

path = "/opt/nagios-custom-plugins"
libexec_path = "#{path}/libexec"

[path, libexec_path].each do |dir|
  directory dir do
    owner icinga.username
    recursive true
    mode "0755"
  end
end

Dir.glob(File.expand_path("../../files/default/custom-plugins/*", __FILE__)).each do |path|
  file = File.basename(path)
  cookbook_file "#{libexec_path}/#{file}" do
    owner icinga.username
    mode "0755"
    source "custom-plugins/#{file}"
  end
end
