{%- from "powerdns/map.jinja" import server with context %}
{%- if server.enabled %}

powerdns_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/powerdns/pdns.conf:
  file.managed:
  - source: salt://powerdns/files/pdns.conf
  - template: jinja
  - user: root
  - group: root
  - mode: 600
  - require:
    - pkg: powerdns_packages

{%- if server.backend.engine == 'mysql' %}

powerdns_mysql_packages:
  pkg.installed:
  - names: {{ server.mysql_pkgs }}

/etc/powerdns/pdns.local.gmysql.conf:
  file.managed:
  - source: salt://powerdns/files/pdns.local.gmysql.conf
  - template: jinja
  - user: root
  - group: root
  - mode: 600
  - require:
    - pkg: powerdns_mysql_packages
  - watch_in:
    - service: powerdns_service

{%- endif %}

powerdns_service:
  service.running:
  - enable: true
  - name: {{ server.service }}
  - watch:
    - file: /etc/powerdns/pdns.conf

{%- endif %}
