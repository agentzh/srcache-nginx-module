# vi:filetype=

use lib 'lib';
use Test::Nginx::Socket;

#repeat_each(2);

plan tests => repeat_each() * 2 * blocks();

$ENV{TEST_NGINX_MEMCACHED_PORT} ||= 11211;

no_shuffle();

run_tests();

__DATA__

=== TEST 1: flush all
--- config
    location /flush {
        set $memc_cmd 'flush_all';
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
GET /flush
--- response_body eval: "OK\r\n"



=== TEST 2: skip is false
--- config
    location /foo {
        default_type text/css;
        srcache_store PUT /memc $uri;
        set $skip '';
        srcache_store_skip $skip;

        echo hello;
    }

    location /memc {
        internal;

        set $memc_cmd set;
        set $memc_key key;
        set $memc_exptime 300;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
    GET /foo
--- response_body
hello



=== TEST 3: check if /memc was invoked (just equal)
--- config
     location /memc {
        set $memc_cmd get;
        set $memc_key key;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
    GET /memc
--- response_body
hello



=== TEST 4: flush all
--- config
    location /flush {
        set $memc_cmd 'flush_all';
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
GET /flush
--- response_body eval: "OK\r\n"



=== TEST 5: store_skip is literally false
--- config
    location /foo {
        default_type text/css;
        srcache_store PUT /memc $uri;
        srcache_store_skip 0;

        echo hello;
    }

    location /memc {
        internal;

        set $memc_cmd set;
        set $memc_key key;
        set $memc_exptime 300;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
    GET /foo
--- response_body
hello



=== TEST 6: check if /memc was invoked (less than)
--- config
     location /memc {
        set $memc_cmd get;
        set $memc_key key;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
    GET /memc
--- response_body
hello



=== TEST 7: flush all
--- config
    location /flush {
        set $memc_cmd 'flush_all';
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
GET /flush
--- response_body eval: "OK\r\n"



=== TEST 8: store_skip is true
--- config
    location /foo {
        default_type text/css;
        srcache_store PUT /memc $uri;
        srcache_store_skip 1;

        echo hello;
    }

    location /memc {
        internal;

        set $memc_cmd set;
        set $memc_key key;
        set $memc_exptime 300;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
    GET /foo
--- response_body
hello



=== TEST 9: check if /memc was invoked (more than)
--- config
     location /memc {
        set $memc_cmd get;
        set $memc_key key;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
    GET /memc
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 10: flush all
--- config
    location /flush {
        set $memc_cmd 'flush_all';
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
GET /flush
--- response_body eval: "OK\r\n"



=== TEST 11: explicit "true" string
--- config
    location /foo.txt {
        default_type text/css;
        srcache_store PUT /memc $uri;
        srcache_store_skip true;
    }

    location /memc {
        internal;

        set $memc_cmd set;
        set $memc_key key;
        set $memc_exptime 300;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- user_files
>>> foo.txt
hello
--- request
    GET /foo.txt
--- response_body
hello



=== TEST 12: check if /memc was invoked (explicit "true" string)
--- config
     location /memc {
        set $memc_cmd get;
        set $memc_key key;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
    GET /memc
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 13: flush all
--- config
    location /flush {
        set $memc_cmd 'flush_all';
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
GET /flush
--- response_body eval: "OK\r\n"



=== TEST 14: server-side config
--- config
    srcache_store_skip 1;
    location /foo.txt {
        default_type text/css;
        srcache_store PUT /memc $uri;
    }

    location /memc {
        internal;

        set $memc_cmd set;
        set $memc_key key;
        set $memc_exptime 300;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- user_files
>>> foo.txt
abc
--- request
    GET /foo.txt
--- response_body
abc



=== TEST 15: check if /memc was invoked (server-level config)
--- config
     location /memc {
        set $memc_cmd get;
        set $memc_key key;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
    GET /memc
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 16: flush all
--- config
    location /flush {
        set $memc_cmd 'flush_all';
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
GET /flush
--- response_body eval: "OK\r\n"



=== TEST 17: overriding server-side config
--- config
    srcache_store_skip 1;
    location /foo.txt {
        default_type text/css;
        srcache_store PUT /memc $uri;
        srcache_store_skip 0;
    }

    location /memc {
        internal;

        set $memc_cmd set;
        set $memc_key key;
        set $memc_exptime 300;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- user_files
>>> foo.txt
hello, world
--- request
    GET /foo.txt
--- response_body
hello, world



=== TEST 18: check if /memc was invoked (overriding server config)
--- config
     location /memc {
        set $memc_cmd get;
        set $memc_key key;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }
--- request
    GET /memc
--- response_body
hello, world

