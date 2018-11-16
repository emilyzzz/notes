#!/bin/bash

# install redis docker
1) get a Dockerfile from: https://hub.docker.com/_/redis/
2) add to docker-compose.xml,   then start it.

# install redis-cli
$ wget http://download.redis.io/releases/redis-4.0.6.tar.gz
$ tar xzf redis-4.0.6.tar.gz
$ cd redis-4.0.6
$ make

# to start server. but i don't use this. i use "docker-compose up -d".
src/redis-server

# to start cli
src/redis-cli

# redis-cli connects to 127.0.0.1 port 6379 by default. but can be configed:
redis-cli -h redis15.localnet.org -p 6390 ping
redis-cli -h localhost -p 6379 ping
redis-cli ping
redis-server /usr/local/etc/redis.conf


# --- api docker to talk to redis docker ---
# inside of api docker,  (no need to have 'link' in 'api' section to 'redis' docker in docker-compose file)
/opt/bin/pip install redis    # redis python client
/opt/bin/python
>>> import redis; r = redis.StrictRedis(host='localhost', port=6379, db=0)
>>> r.set('api_foo', 'api_bar'); r.get('api_foo')
True
'api_bar'

# --- redis python client commands ---
1) most commands are same as direct redis commands
2) 'del' -> 'delete'
3) MULTI/EXEC: handled in 'pipeline' implicitely
4) SUBSCRIBE/LISTEN: tricky
5) connection pooling:  each python-redis client has its own pool by default,  can be changed.
6) doesn't support 'SELECT" due to thread safe issue.


# --- redis direct commands ----
flassaull
set var value
set var value nx          # only succeed if 'var' non existing. otherwise return 'nil'
set var value xx          # only succeed if 'var' is already set, then set to new value
get variable_name
setnx <key> <value>	# Set key value only if key does not exist
mget <key> <key> ...
mset <key> <value> <key> <value> ...
incr <key>
decr <key>
exists var                # return 1 / 0 for variable exists or not
del var                   # return 1 / 0 and delete var, if it exists or not
type var                  # variable type, returns 'none' for non existing var
keys *                    # get all keys,  O(N) as N being No. of keys, assuming no super long key



# ---- hash ----
# doc: https://redis.io/commands#hash
# set good use case:  implementing tags. ex: sadd news:1000:tags 1 2 5 77
HMSET user:1000 username antirez password P1pp0 age 34
HGETALL user:1000
HSET user:1000 password 12345
HGETALL user:1000
keys user*                                           # return all keys start with user*
1) "user:1000"
2) "user:2000"
hmget user:1000 username birthyear no-such-field     # hash multi get.  will return 'nil' if key doesn't exist
hincrby user:1000 birthyear 10                       # increase key 'birthyear' by 10, in hash 'user:1000'



# ---- incr | incrby | decr | decrby ----
> set counter 100
OK
> incr counter
(integer) 101
> incr counter
(integer) 102
> incrby counter 50
(integer) 152


# ---- set ----
sadd myset 1 2 3           # add 3 numbers to myset
smembers myset             # returns all the set members
sismember myset 3          # returns 1/0 if 3 is in myset (or not)

# ---- general operation -----
> mset a 10 b 20 c 30
OK
> mget a b c
1) "10"
2) "20"
3) "30"


# expire
> set key some-value
OK
> expire key 5      # default to 'sec'
(integer) 1
> get key (immediately)
"some-value"
> get key (after some time)
(nil)
> set key 100 ex 10
OK
> ttl key
(integer) 9


# data type
string: max 512M size
list:
  1) implemented with linked list.
  2) max length 2^32 - 1 elements (4294967295, more than 4 billion of elements per list).
  3) O(1) for: adding a new element in the head(LPUSH) or in the tail(RPUSH) of the list is performed in constant time.
  4) Redis Lists can be taken at constant length in constant time. ???? https://redis.io/topics/data-types-intro
  5) access middle elements of the list is slower --- use 'ordered set' instead
Sets: unordered collection of Strings. add, remove, and test for existence of members in O(1), no duplication
hash: Every hash can store up to 2^32 - 1 field-value pairs (more than 4 billion).
bitmap: Bit arrays (or bitmaps): it is possible, using special commands, to handle String values like an array
    of bits: you can set and clear individual bits, count all the bits set to 1, find the first set or unset bit, and so forth.

# key
1, length: keys should not be super long, or super short:  it should be easily readable, max key size: 512M
2, nameing convention: stick to schema: "object-type:id" is a good idea, or "comment:1234:reply-to".
3, type:  keys are strings.


# set
1, 'set' may reset value to an existing variable, even when we change value type.


# SINGLE THREAD

DATA LATENCY?   IF CAN'T TOLERATE LATENCY,  THEN WE NEED REDIS CLUSTER.

Q: HOW DOES THE Current permission consumer update the in memory variables?
