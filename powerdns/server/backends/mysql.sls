{%- from "powerdns/map.jinja" import server with context %}
{%- from "powerdns/server/packages.jinja" import packages with context %}
include:
  - powerdns.server.service

{%- if server.backend.get('use_socket', False) == True %}
    {%- set mysql_connection_args = {
        'use_socket': True,
        'connection_charset': server.backend.get('dbcharset', 'utf8'),
        'connection_db': server.backend.dbname,
        'connection_default_file': server.backend.get('dbdefault_file', ''),
        'connection_unix_socket': server.backend.socket,
        'connection_user': server.backend.user,
        'connection_pass': server.backend.password,
        } %}
{%- else %}
    {%- set mysql_connection_args = {
        'use_socket': False,
        'connection_charset': server.backend.get('dbcharset', 'utf8'),
        'connection_db': server.backend.dbname,
        'connection_default_file': server.backend.get('dbdefault_file', ''),
        'connection_host': server.backend.host,
        'connection_port': server.backend.port,
        'connection_user': server.backend.user,
        'connection_pass': server.backend.password,
        } %}
{%- endif %}

powerdns_mysql_packages:
  pkg.installed:
    - names: {{ packages.backends.mysql }}

/etc/powerdns/dbtemplate.sql:
  file.managed:
    - source: salt://powerdns/files/mysql.sql
    - require:
      - pkg: powerdns_mysql_packages

{%- set powerdns_db_tables = salt['mysql.db_tables'](server.backend.dbname, **mysql_connection_args) %}
{%- if not powerdns_db_tables %}
powerdns_init_mysql_db:
  mysql_query.run_file:
    - database: {{ server.backend.dbname }}
    - query_file: /etc/powerdns/dbtemplate.sql
    - connection_charset: {{ mysql_connection_args.connection_charset }}
{%- if mysql_connection_args.connection_default_file %}
    - connection_default_file: {{ mysql_connection_args.connection_default_file }}
{%- endif %}
{%- if mysql_connection_args.use_socket == True %}
    - connection_unix_socket: {{ mysql_connection_args.connection_unix_socket }}
{%- else %}
    - connection_host: {{ mysql_connection_args.connection_host }}
    - connection_port: {{ mysql_connection_args.connection_port }}
{%- endif %}
    - connection_user: {{ mysql_connection_args.connection_user }}
    - connection_pass: {{ mysql_connection_args.connection_pass }}
    - require:
      - file: /etc/powerdns/dbtemplate.sql
{%- endif %}
{%- if server.supermasters is defined %}
{% for supermaster in server.supermasters %}
use_supermaster_{{ supermaster.ip }}:
  powerdns_mysql.row_present:
    - table: supermasters
    - where_sql: ip="{{ supermaster.ip }}"
    - database: {{ server.backend.dbname }}
    - data:
        ip: {{ supermaster.ip }}
        nameserver: {{ supermaster.nameserver }}
        account: {{supermaster.account }}
    {%- if server.overwrite_supermasters is defined %}
    - update: {{ server.overwrite_supermasters }}
    {%- endif %}
    - connection_charset: {{ mysql_connection_args.connection_charset }}
{%- if mysql_connection_args.connection_default_file %}
    - connection_default_file: {{ mysql_connection_args.connection_default_file }}
{%- endif %}
{%- if mysql_connection_args.use_socket == True %}
    - connection_unix_socket: {{ mysql_connection_args.connection_unix_socket }}
{%- else %}
    - connection_host: {{ mysql_connection_args.connection_host }}
    - connection_port: {{ mysql_connection_args.connection_port }}
{%- endif %}
    - connection_user: {{ mysql_connection_args.connection_user }}
    - connection_pass: {{ mysql_connection_args.connection_pass }}
{%- if not powerdns_db_tables %}
    - require:
      - powerdns_init_mysql_db
{%- endif %}
    - watch_in:
      - service: powerdns_service
{% endfor %}
{%- endif %}
/etc/powerdns/pdns.d/pdns.local.gmysql.conf:
  file.managed:
  - source: salt://powerdns/files/backends/mysql.conf
  - template: jinja
  - user: root
  - group: root
  - mode: 640
  - require:
    - pkg: powerdns_mysql_packages
  - watch_in:
    - service: powerdns_service
