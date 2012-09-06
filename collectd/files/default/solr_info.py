import collectd
import optparse
import json
import httplib
import datetime

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
    keys_to_track = ( "evictions", "hits", "inserts", "lookups" )
    cached_stats = None

    def configure(self, config_object):
        config = {}
        for config_value in config_object.children:
            config[config_value.key] = config_value.values[0]
        self.host = config.get("Host", None)
        self.port = config.get("Port", None)
        self.path = config.get("Path", None)
        
        if not self.host: raise RuntimeError("Host must be set")
        if not self.port: raise RuntimeError("Port must be set")
        if not self.path: raise RuntimeError("Path must be set")

        self.port = int(self.port)

        self.verbose = config.get("Verbose", False)
        self.info("server config: host=%s, port=%s, path=%s" % (self.host, self.port, self.path))
    
    def read(self, data=None):
        self.reset_cache()
        self.handle_cache_stats()
        self.handle_avg_stats()

    def reset_cache(self):
        self.cached_response = None
        self.cached_stats = None
    
    def handle_avg_stats(self):
        self.dispatch_metric("avg_time_per_request", value=self.search_stats()["avgTimePerRequest"])
        self.dispatch_metric("avg_requests_per_second", value=self.search_stats()["avgRequestsPerSecond"])
        
    def handle_cache_stats(self):
        all_stats = self.all_stats()
        for metric in all_stats:
            for key, value in all_stats[metric].iteritems():
                self.dispatch_metric("%s.%s" % (metric, key), value=value)

    def dispatch_metric(self, type_instance, value, the_type="gauge"):
        val = collectd.Values(plugin=PLUGIN_NAME, type_instance=type_instance, values=[value], type=the_type)
        self.info("Sending value: %s=%s" % (type_instance, value))
        val.dispatch()
    
    def response(self):
        if not self.cached_response:
            self.cached_response = self.fetch_response()
        return self.cached_response

    def fetch_response(self):
        started = datetime.datetime.now()
        con = httplib.HTTPConnection(self.host, self.port)
        self.info("Fetching host=%s port=%s path=%s" % (self.host, self.port, self.path))
        con.request("get", "%s?stats=true&wt=json&key=fieldValueCache&key=filterCache&key=documentCache&key=queryResultCache&key=search" % (self.path))
        body = con.getresponse().read()
        self.info("fetched response in %.4f" % (self.diff_from(started)))
        return json.loads(body)

    def stats(self):
        if self.cached_stats: return self.cached_stats
        stats = {}
        current_key = None
        for key_or_value in self.response()["solr-mbeans"]:
            if not current_key:
                current_key = key_or_value
            else:
                stats[current_key] = key_or_value
                current_key = None
        self.cached_stats = stats
        return self.cached_stats

    def search_stats(self):
        return self.stats()["QUERYHANDLER"]["search"]["stats"]

    def cache(self):
        return self.stats()["CACHE"]

    def diff_from(self, old_time):
        delta = datetime.datetime.now() - old_time
        return (delta.seconds + (delta.microseconds / 1000000.0))

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
