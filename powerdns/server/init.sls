{%- from "powerdns/map.jinja" import server with context %}
{%- if server.backend is defined %}
{%- if not server.backend.engine is defined %}
{{ salt.test.exception('Server backend MUST be configured') }}
{%- endif %}

include:
  - powerdns.server.backends.{{ server.backend.engine }}
  - powerdns.server.zone
{%- endif %}
