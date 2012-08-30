if __name__ == "__main__":
    print "DEBUG: using collectd_dummy"
    import collectd_dummy as collectd
else:
    import collectd
import optparse
import json
import httplib

PLUGIN_NAME = "solr_info"

class SolrServer():
    keys = ( "fieldValueCache", "filterCache", "documentCache", "queryResultCache" )
    field_value_mapping = {
        "fieldValueCache": "field_value_cache",
        "filterCache": "filter_cache", 
        "documentCache": "document_cache", 
        "queryResultCache": "query_result_cache" 
    }
    cached_response = None
    verbose = False
    keys_to_track = ( "cumulative_evictions", "cumulative_hits", "cumulative_inserts", "cumulative_lookups", "evictions", "hits", "inserts", "lookups" )

    def configure(self, config_object):
        config = {}
        for config_value in config_object.children:
            config[config_value.key] = config_value.values[0]
        self.host = config.get("Host", None)
        self.port = config.get("Port", None)
        self.path = config.get("URI", None)
        
        if not self.host: raise RuntimeError("Host must be set")
        if not self.port: raise RuntimeError("Port must be set")
        if not self.path: raise RuntimeError("URI must be set")

        self.port = int(self.port)

        self.verbose = config.get("Verbose", False)
        self.info("server config: host=%s, port=%s, path=%s" % (self.host, self.port, self.path))
    
    def read(self, data=None):
        all_stats = self.all_stats()
        for metric in all_stats:
            stats = all_stats[metric]
            for key in stats:
                type_instance = "%s.%s" % (metric, key)
                value = stats[key]
                val = collectd.Values(plugin=PLUGIN_NAME, type_instance=type_instance, values=[value], type="gauge")
                self.info("Sending value: %s=%s" % (type_instance, value))
                val.dispatch()
    
    def response(self):
        if not self.cached_response:
            self.cached_response = self.fetch_response()
        return self.cached_response

    def fetch_response(self):
        con = httplib.HTTPConnection(self.host, self.port)
        self.info("Fetching host=%s port=%s path=%s" % (self.host, self.port, self.path))
        con.request("get", "%s?stats=true&wt=json&cat=CACHE" % (self.path))
        body = con.getresponse().read()
        return json.loads(body)

    def cache(self):
        return self.response()["solr-mbeans"][1]

    def stats_for(self, key):
        stats = self.cache()[key]["stats"]
        ret = {}
        for key in self.keys_to_track:
            ret[key] = stats.get(key, None)
        return ret

    def all_stats(self):
        ret = {}
        for key in self.keys:
            lowered_key = self.field_value_mapping[key]
            ret[lowered_key] = self.stats_for(key)
        return ret

    def info(self, message):
        if self.verbose:
            collectd.info("solr plugin [verbose]: %s" % (message))

server = SolrServer()
collectd.register_config(server.configure)
collectd.register_read(server.read)
