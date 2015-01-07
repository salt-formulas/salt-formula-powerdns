{%- from "powerdns/map.jinja" import server with context %}
{%- if server.enabled %}

powerdns_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/powerdns.conf:
  file.managed:
  - source: salt://powerdns/files/powerdns.conf
  - template: jinja
  - user: root
  - group: root
  - mode: 644
  - require:
    - pkg: powerdns_packages

powerdns_service:
  service.running:
  - enable: true
  - name: {{ server.service }}
  - watch:
    - file: /etc/powerdns.conf

{%- endif %}