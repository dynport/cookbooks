def create_database(db_name, user = nil)
  cmd = "CREATE DATABASE #{db_name} CHARACTER SET UTF8"
  cmd << "; GRANT ALL ON #{db_name}.* TO #{user}@localhost" if user
  execute "create database #{db_name}" do
    command %(mysql -u root -e "#{cmd}")
    not_if %(mysql -u root -e "show databases" | grep "^#{db_name}$")
  end
end