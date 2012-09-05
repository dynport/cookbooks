import socket
import re

class RedisClient(object):
    socket = None
    host = None
    port = None
    connected = False
    file_handle = None

    def __init__(self, host="127.0.0.1", port=6379):
        self.host = host
        self.port = port

    def get(self, key):                     return self.__write_and_read__("GET %s" % key)
    def set(self, key, value):              return self.__write_and_read__("SET %s %s" % (key, value))
    def hset(self, hash_key, key, value):   return self.__write_and_read__("HSET %s %s %s" % (hash_key, key, value))
    def hget(self, hash_key, key):          return self.__write_and_read__("HGET %s %s" % (hash_key, key))
    def sadd(self, set_key, member):        return self.__write_and_read__("SADD %s %s" % (set_key, member))
    def smembers(self, set_key):            return self.__write_and_read__("SMEMBERS %s" % set_key)
    def lpush(self, list_key, value):       return self.__write_and_read__("LPUSH %s %s" % (list_key, value))
    def llen(self, list_key):               return self.__write_and_read__("LLEN %s" % list_key)
    def info(self):                         return self.__write_and_read__("INFO")

    def __write_and_read__(self, command):
        self.__write__(command)
        return self.__read_raw__()

    def __read_raw__(self):
        line = self.file_handle.readline()
        first_char = line[0]
        if first_char == "+":
            return line[1:-2] == "OK"
        elif first_char == ":":
            return int(line[1:-2])
        elif first_char == "$":
            to_read = int(line[1:-2])
            if to_read > 0:
                return self.file_handle.read(to_read + 2)[0:-2]
        elif first_char == "*":
            to_read = int(line[1:-2])
            return tuple([self.__read_raw__().strip() for i in range(to_read)])
        elif line.startswith("-ERR "):
            raise RuntimeError(line)
        else:
            return line

    def __connect_when_not_connected__(self):
        if not self.connected:
            self.socket = socket.socket()
            self.socket.connect((self.host, self.port))
            self.file_handle = self.socket.makefile()
            self.connected = True

    def __write__(self, message):
        self.__connect_when_not_connected__()
        self.socket.sendall("%s\r\n" % message)

    def __parseInfo__(self, info):
        ret = { "keys": {} }
        for line in info.split("\n"):
            match = re.match(r"(.*?):(.*)", line)
            if match:
                value = match.group(2)
                if value.isdigit():
                    value = int(value)
                ret[match.group(1).strip()] = value
        for key, value in ret.iteritems():
            if key.startswith("db"):
                match = re.search(r"keys=(\d+)", value)
                if match:
                    ret["keys"][key] = int(match.group(1))
        return ret

if __name__ == "__main__":
    import unittest

    def __connect_when_not_connected__(self):
        if not self.connected:
            self.socket = socket.socket()
            self.socket.connect((self.host, self.port))
            self.file_handle = self.socket.makefile()
            self.connected = True

    class IntegerArithmenticTestCase(unittest.TestCase):
        def setUp(self):
            self.client = RedisClient()
            self.client.__write__("FLUSHDB")
            self.client.file_handle.readline()
            self.info = """
                total_commands_processed:35
                used_memory_human:12GB
                used_memory:16142272

                # Keyspace
                db0:keys=1,expires=0
                db1:keys=4,expires=0
            """

        def test__parseInfo__(self):
            parsed_info = self.client.__parseInfo__(self.info)
            self.assertEqual(16142272, parsed_info["used_memory"])
            self.assertEqual("12GB", parsed_info["used_memory_human"])
            self.assertEqual(35, parsed_info["total_commands_processed"])
            self.assertEqual({ "db0": 1, "db1": 4 }, parsed_info["keys"])

        def testSetAndGet(self):
            self.client.set("a", 88)
            self.assertEqual(self.client.get("n"), None)
            self.assertEqual(self.client.get("a"), "88")
            self.assertEqual(self.client.get("n"), None)
            self.assertEqual(self.client.get("a"), "88")
            self.assertEqual(self.client.get("a"), "88")

        def testSets(self):
            self.assertEqual(self.client.sadd("set", "a"), 1)
            self.assertEqual(self.client.sadd("set", "a"), 0)
            self.assertEqual(self.client.sadd("set", "b"), 1)
            self.assertEqual(("a", "b"), self.client.smembers("set"))

        def testHashes(self):
            self.assertEqual(self.client.hset("hash", "a", "b"), 1)
            self.assertEqual(self.client.hget("hash", "a"), "b")

        def testLists(self):
            self.assertEqual(self.client.lpush("list", "a"), 1)
            self.assertEqual(self.client.lpush("list", "b"), 2)
            self.assertEqual(self.client.llen("list"), 2)

        def testRaiseErrors(self):
            with self.assertRaises(RuntimeError):
                self.client.__write_and_read__("HSET a b")

    unittest.main()
