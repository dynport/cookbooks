include_recipe "php"

package "php5-cgi"
package "psmisc"

template "/etc/init.d/php-cgi" do
  source "php-cgi.init.erb"
  mode "0755"
end