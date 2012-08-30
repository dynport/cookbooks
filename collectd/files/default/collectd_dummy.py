class Config():
    children = []
    values = []
    key = None

    def __init__(self, children=[], values=[], key=None):
        self.children = children
        self.values = values
        self.key = key


def register_config(fun):
    host = Config(key="Host", values=[("1.2.3.4")])
    port = Config(key="Port", values=[("1234")])
    config = Config(children=(host, port))
    fun(config)

def register_read(fun):
    fun()

def info(message):
    print "INFO", message

def warning(message):
    print "WARNING", message

def error(message):
    print "ERROR", message

class Values():
    values = []
    type = None
    plugin = None
    type_instance = None

    def __init__(self, type=None, plugin=None, type_instance=None, values=[]):
        self.type = type
        self.plugin = plugin
        self.type_instance = type_instance
        self.values = values

    def dispatch(self, values=None):
        if values:
            print "overwriting"
            self.values = values
        info("SENDING %s=%s" % (self.type_instance, self.values))
