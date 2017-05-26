{%- from "powerdns/map.jinja" import server with context %}
{%- from "powerdns/server/packages.jinja" import packages with context %}
include:
  - powerdns.server.service

powerdns_mysql_packages:
  pkg.installed:
    - names: {{ packages.backends.mysql }}

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
