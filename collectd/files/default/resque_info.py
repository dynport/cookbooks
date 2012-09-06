import redis_client
import collectd

PLUGIN_NAME = "resque_info"

class ResqueMonitor():
    redis_client = None

    def configure(self, config_object):
        config = {}
        for config_value in config_object.children:
            config[config_value.key] = config_value.values[0]
        self.host = config.get("Host", None)
        self.port = config.get("Port", None)
	print "inside"

        if not self.host: raise RuntimeError("Host must be set")
        if not self.port: raise RuntimeError("Port must be set")

        self.port = int(self.port)

        self.verbose = config.get("Verbose", False)
        self.info("server config: host=%s, port=%s" % (self.host, self.port))
        self.redis_client = redis_client.RedisClient(host=self.host, port=self.port)
        print "set redis client to %s" % (repr(selr.redis_client))

    def read(self, data=None):
        for key in self.queues():
            value = self.queue_size(key)
            type_instance = "queues-%s" % (key)
            val = collectd.Values(plugin=PLUGIN_NAME, type_instance=type_instance, values=[value], type="gauge")
            self.info("Sending value: %s=%s" % (type_instance, value))
            val.dispatch()
            

    def queues(self):
        return self.redis_client.smembers("resque:queues") - set("*",)

    def queue_size(self, key):
        return self.redis_client.llen("resque:queue:%s" % key)

    def info(self, message):
        if self.verbose:
            collectd.info("solr plugin [verbose]: %s" % (message))

monitor = ResqueMonitor()
collectd.register_config(monitor.configure)
collectd.register_read(monitor.read)
