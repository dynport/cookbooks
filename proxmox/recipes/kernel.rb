PROXMOX =<<-EOF
deb http://download.proxmox.com/debian squeeze pve
EOF

file "/etc/apt/sources.list.d/proxmox.list" do
  content PROXMOX
  mode "0644"
  notifies :run, "execute[add_proxmox_key]", :immediately
end

execute "add_proxmox_key" do
  command %(wget -O - "http://download.proxmox.com/debian/key.asc" | apt-key add - && apt-get update)
  action :nothing
end

package "pve-firmware"
package "pve-kernel-2.6.32-16-pve"

