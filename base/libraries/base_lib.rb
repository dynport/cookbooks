def start_stop_script(attributes)
  [:user, :cwd, :name, :pidfile, :daemon].each do |key|
    raise "#{key} not set" if !attributes.has_key?(key)
  end

  template "/etc/init.d/#{attributes[:name]}" do
    source "start_stop_script.erb"
    cookbook "base"
    variables(attributes)
    mode "755"
  end
end