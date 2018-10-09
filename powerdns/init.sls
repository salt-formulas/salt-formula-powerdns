{%- if pillar.powerdns is defined %}
include:
{%- if pillar.powerdns.server is defined %}
- powerdns.server
{%- endif %}
{%- endif %}
