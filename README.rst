=====
Usage
=====

PowerDNS, founded in the late 1990s, is a premier supplier
of open source DNS software, services and support. Deployed
throughout the world with some of the most demanding users
of DNS, we pride ourselves on providing quality software
and the very best support available.

Sample Pillars
==============

PowerDNS server with MySQL backend

.. code-block:: yaml

    powerdns:
      server:
        api:
          enabled: True
          key: VxK9cMlFL5Ae
        axfr_ips:
          - 172.16.10.103
          - 172.16.10.104
          - 172.16.10.102
          - 127.0.0.1
        backend:
          engine : mysql
          host : localhost
          port : 3306
          dbname : powerdns
          user : powerdns
          password : powerdns
          timeout': 10
          dnssec : on
        bind:
          address: 172.16.10.103
        overwrite_supermasters: True
        supermasters:
          - account: master
            ip: 172.16.10.103
            nameserver: ns1.example.org
          - account: master
            ip: 172.16.10.104
            nameserver: ns2.example.org
          - account: master
            ip: 172.16.10.102
            nameserver: ns3.example.org
        webserver:
          address: 172.16.10.103
          enabled: True
          password: gJ6n3gVaYP8eS
          port: 8081

.. note:: If you use one MySQL database across several
   PowerDNS instances, be sure to pass *-b1* parameter
   to *salt* command to avoid race condition.

PowerDNS server with SQLite backend

.. code-block:: yaml

    powerdns:
      server:
        api:
          enabled: True
          key: VxK9cMlFL5Ae
        axfr_ips:
          - 172.16.10.103
          - 172.16.10.104
          - 172.16.10.102
          - 127.0.0.1
        backend:
          engine: sqlite
          dbname: pdns.sqlite
          dbpath: /var/lib/powerdns
        bind:
          address: 172.16.10.103
        overwrite_supermasters: True
        supermasters:
          - account: master
            ip: 172.16.10.103
            nameserver: ns1.example.org
          - account: master
            ip: 172.16.10.104
            nameserver: ns2.example.org
          - account: master
            ip: 172.16.10.102
            nameserver: ns3.example.org
        webserver:
          address: 172.16.10.103
          enabled: True
          password: gJ6n3gVaYP8eS
          port: 8081


Documentation
=============

* https://doc.powerdns.com/

