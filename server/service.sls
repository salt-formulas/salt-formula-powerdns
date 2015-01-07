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

powerdns_service:
  service.running:
  - enable: true
  - name: {{ server.service }}
  - watch:
    - file: /etc/powerdns/pdns.conf

{%- endif %}
