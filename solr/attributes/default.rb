default["solr"]["version"]                 = "3.6.0"
default["solr"]["java_heap_size"]          = "64M"
default["solr"]["java_new_size"]           = "16M"
default["solr"]["java_survivor_ratio"]     = "3"
default["solr"]["filter_cache"]            = "5120"
default["solr"]["query_result_cache"]      = "3072"
default["solr"]["document_cache"]          = "512"
default["solr"]["port"]                    = "4001"
default["solr"]["master_port"]             = "4002"
default["solr"]["slave_port"]              = "4003"
default["solr"]["home"]                    = "/data/solr"
default["solr"]["initial_core"]            = "default"
default["solr"]["master_url"]              = "http://127.0.0.1:#{default["solr"]["master_port"]}/solr/#{default["solr"]["initial_core"]}/replication"
