default[:www_user]              = "nginx"
default[:nginx][:version]       = "1.2.0"
default[:nginx][:install_root]  = "/opt"
default[:nginx][:dir]           = "#{default[:nginx][:install_root]}/nginx"
default[:nginx][:processes]     = 1