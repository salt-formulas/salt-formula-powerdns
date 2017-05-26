{%- from "powerdns/map.jinja" import server with context %}
{%- from "powerdns/server/packages.jinja" import packages with context %}
include:
  - powerdns.server.service

powerdns_sqlite_packages:
  pkg.installed:
    - names: {{ packages.backends.sqlite }}

/etc/powerdns/dbtemplate.sql:
  file.managed:
    - source: salt://powerdns/files/sqlite.sql
    - require:
      - pkg: powerdns_sqlite_packages

{{ server.backend.dbpath }}:
  file.directory:
    - user: pdns
    - group: pdns
    - mode: 750
    - makedirs: true

init_sqlite_db:
  cmd.run:
    - name: sqlite3 {{ server.backend.dbpath }}/{{ server.backend.dbname }} < /etc/powerdns/dbtemplate.sql
    - runas: pdns
    - umask: 027
    - require:
      - file: /etc/powerdns/dbtemplate.sql
      - file: {{ server.backend.dbpath }}
    - creates: {{ server.backend.dbpath }}/{{ server.backend.dbname }}

/etc/powerdns/pdns.d/pdns.local.gsqlite3.conf:
  file.managed:
  - source: salt://powerdns/files/backends/sqlite.conf
  - template: jinja
  - user: root
  - group: root
  - mode: 640
  - require:
    - pkg: powerdns_sqlite_packages
  - watch_in:
    - service: powerdns_service

