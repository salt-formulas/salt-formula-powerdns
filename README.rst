
========
PowerDNS
========

Sample pillar:

PowerDNS server with MySQL backend

.. code-block:: yaml
  powedns:
    server:
      enabled: true
      backend:
        engine: mysql
        host: localhost
        port: 3306
        name: pdns
        user: pdns
        password: password
      bind:
        address: 0.0.0.0
        port: 53
      axfr_ips:
        - 10.11.0.0/16
        - 127.0.0.1
      api:
        enabled: true
        key: SecurePass
      webserver:
        enabled: true
        password: SuperSecurePass
        address: 0.0.0.0
        port: 8081


PowerDNS server with sqlite backend

.. code-block:: yaml
  powerdns:
    server:
      enabled: true
      backend:
        engine: sqlite
        dbname: pdns.sqlite
        dbpath: /var/lib/powerdns
      bind:
        address: 127.0.0.1
        port: 55
      default-soa-name: ns1.domain.tld
      soa-minimum-ttl: 3600
      api:
        enabled: true
        key: SecurePass
      webserver:
        enabled: true
        password: SuperSecurePass
        address: 0.0.0.0
        port: 8081


Read more
=========
