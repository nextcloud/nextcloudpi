#!/usr/bin/python3

"""
Automatic DB tunning for NextCloudPi

Very much inspired by

https://github.com/major/MySQLTuner-perl/blob/a146c81b7c37aebaa5c2084c843bf65e8465b5bf/mysqltuner.pl

Copyleft 2021 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
GPL licensed (see LICENSE file in repository root).
Use at your own risk!

More at https://ownyourbits.com
"""

# NOTE: apt install -y python3-pymysql python3-psutil python3-tabulate

import pymysql
import pymysql.cursors
import math
import psutil
import tabulate

class DB:
    """ DB session abstraction """
    def __init__(self):
        """ connect to the database """
        self.con = pymysql.connect(
                unix_socket='/run/mysqld/mysqld.sock',
                user='root',
                read_default_file='/root/.my.cnf',
                db='nextcloud')

    def get_status_var(self, var: str) -> int:
        """ get status variable """
        with self.con.cursor() as cur:
            cur.execute(f"SELECT Variable_value from  information_schema.GLOBAL_STATUS where Variable_name='{var}'")
            return int(cur.fetchone()[0])

    def get_data_usage(self) -> int:
        """ get current data usage """
        with self.con.cursor() as cur:
            cur.execute("SELECT SUM(DATA_LENGTH+INDEX_LENGTH)"
                    "FROM information_schema.TABLES "
                    "WHERE TABLE_SCHEMA NOT IN ('information_schema', 'performance_schema', 'mysql') "
                    "AND ENGINE IS NOT NULL")
            return int(cur.fetchone()[0])

    def get_var(self, var: str) -> int:
        """ get variable """
        with self.con.cursor() as cur:
            cur.execute(f"SHOW variables where variable_name = '{var}'")
            return int(cur.fetchone()[1])

    def __del__(self):
        """ close connection """
        self.con.close()

def human_units(val: int) -> str:
    """ human readable formatting """
    if val >= 1024**3:
        return f'{val/(1024**3):.2f}G'
    elif val >= 1024**2:
        return f'{val/(1024**2):.2f}M'
    elif val >= 1024:
        return f'{val/(1024**1):.2f}K'
    else:
        return f'{val/(1024**0):.2f}B'

""""""""""""""""""

db = DB()

# data usage
data_usage = db.get_data_usage()

# max_heap_table_size | max_tmp_table_size
pct_temp_disk = 100 * db.get_status_var('Created_tmp_disk_tables') / db.get_status_var('Created_tmp_tables')
max_heap_table_size = db.get_var('max_heap_table_size')
max_tmp_table_size = max(max_heap_table_size, db.get_var('tmp_table_size'))
if pct_temp_disk > 25 and max_tmp_table_size < 256 * 1024 * 1024:
    new_max_heap_table_size = max_heap_table_size * 2
else:
    new_max_heap_table_size = max_heap_table_size
new_tmp_table_size = new_max_heap_table_size

# RAM
RAM_total = psutil.virtual_memory().total
RAM_size = RAM_total / 4; # dedicated to DB

# innodb_buffer_pool_size (preliminary estimation)
RAM_size_G = RAM_size / (1024**3) # in GiB
if RAM_size_G > 1:
    cold_estimate_innodb_buffer_pool_size = 256 + 256 * math.log2(RAM_size_G) # in MiB
else:
    cold_estimate_innodb_buffer_pool_size = 128 # in MiB
cold_estimate_innodb_buffer_pool_size = cold_estimate_innodb_buffer_pool_size * (1024**2)

# innodb_buffer_pool_size (based on actual data usage)
new_innodb_buffer_pool_size = data_usage

# innodb_buffer_pool_size
innodb_buffer_pool_size = db.get_var('innodb_buffer_pool_size')

# innodb_log_file_size
innodb_log_files_in_group = db.get_var('innodb_log_files_in_group')
innodb_log_file_size = db.get_var('innodb_log_file_size')
new_innodb_log_file_size = innodb_buffer_pool_size / innodb_log_files_in_group / 4

# Max base usage. This is all buffers combined without taking into account any connections
key_buffer_size = db.get_var('key_buffer_size')
innodb_log_buffer_size = db.get_var('innodb_log_buffer_size')
query_cache_size = db.get_var('query_cache_size')
aria_pagecache_buffer_size = db.get_var('aria_pagecache_buffer_size')
max_base_usage = key_buffer_size + max_tmp_table_size + innodb_buffer_pool_size + innodb_log_buffer_size + query_cache_size + aria_pagecache_buffer_size

# Memory usage taking into account connections
read_buffer_size = db.get_var('read_buffer_size')
read_rnd_buffer_size = db.get_var('read_rnd_buffer_size')
sort_buffer_size = db.get_var('sort_buffer_size')
thread_stack = db.get_var('thread_stack')
max_allowed_packet = db.get_var('max_allowed_packet')
join_buffer_size = db.get_var('join_buffer_size')
per_thread_buffers = read_buffer_size + read_rnd_buffer_size + sort_buffer_size + thread_stack + max_allowed_packet + join_buffer_size

# Total possible memory is memory needed by MySQL based on max_connections
# This is the max memory MySQL can theoretically used if all connections allowed has opened by mysql
max_connections = db.get_var('max_connections')
total_per_thread_buffers = per_thread_buffers * max_connections

# Max used memory is memory used by MySQL based on Max_used_connections
# This is the max memory used theoretically calculated with the max concurrent connection number reached by mysql
max_used_connections = db.get_status_var('Max_used_connections')
max_total_per_thread_buffers = per_thread_buffers * max_used_connections

max_used_memory = max_base_usage + max_total_per_thread_buffers
max_peak_memory = max_base_usage + total_per_thread_buffers

# pct_max_physical_memory = 100 * max_peak_memory / RAM_size
pct_max_physical_memory = 100 * max_used_memory / RAM_size
if pct_max_physical_memory > 90:
    # new_RAM_size = max_peak_memory * 100 / 80 # target 80% of RAM
    new_RAM_size = max_used_memory * 100 / 80 # target 80% of RAM
else:
    new_RAM_size = RAM_size

# PLOT
print(tabulate.tabulate(
        [
            ['System RAM'              , human_units(RAM_total)                   ],
            ['DB dedicated RAM'        , f"{human_units(RAM_size)} -> {human_units(new_RAM_size)}" ],
            ['Current Data Usage'      , human_units(data_usage)                  ],
            ['Memory usage %'          , f"{pct_max_physical_memory:.2f}%"        ],
            ['Temp tables in RAM %'    , f"{pct_temp_disk:.2f}% -> 25%"           ],
            ['Innodb buffer pool size' , f"{human_units(innodb_buffer_pool_size)} -> {human_units(new_innodb_buffer_pool_size)}"],
            ['Innodb log file size'    , f"{human_units(innodb_log_file_size)} -> {human_units(new_innodb_log_file_size)}"],
            ['Max heap/tmp table size' , f'{human_units(max_heap_table_size)} -> {human_units(new_max_heap_table_size)}'],
            ['Max memory usage'        , human_units(max_used_memory) ],
            ['Max possible memory usage' , human_units(max_peak_memory) ],
        ],
        headers=['Parameter', 'Value -> Recommended'],
        tablefmt='fancy_grid'
        ))
