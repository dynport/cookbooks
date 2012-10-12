default[:mysql][:datadir]                   = "/data/mysql"
default[:mysql][:buffer_pool_size]          = "2G"
default[:mysql][:expire_logs_days]          = "14"

default[:percona_toolkit][:version]         = "2.1.5"

default[:percona][:download_url]            = "http://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-5.5.27-29.0/binary/linux/x86_64/Percona-Server-5.5.27-rel29.0-315.Linux.x86_64.tar.gz"
default[:percona_xtrabackup][:download_url] = "http://www.percona.com/downloads/XtraBackup/XtraBackup-2.0.3/binary/Linux/x86_64/percona-xtrabackup-2.0.3-470.tar.gz"
