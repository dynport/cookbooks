package "php5-cli"

if node[:php] && node[:php][:packages]
  node[:php][:packages].each { |pkg| package "php5-#{pkg}" }
end