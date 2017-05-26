{%- from "powerdns/map.jinja" import server with context %}
{%- from "powerdns/server/packages.jinja" import packages with context %}
{%- if server.enabled %}

powerdns_packages:
  pkg.installed:
  - names: {{ packages.pkgs }}

/etc/powerdns/pdns.conf:
  file.managed:
  - source: salt://powerdns/files/pdns.conf
  - template: jinja
  - user: root
  - group: root
  - mode: 600
  - require:
    - pkg: powerdns_packages
  - require_in:
    - service: {{ server.service }}

powerdns_service:
  service.running:
  - enable: true
  - name: {{ server.service }}
  - watch:
    - file: /etc/powerdns/pdns.conf

{%- endif %}
