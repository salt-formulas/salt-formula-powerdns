powerdns:
  server:
    enabled: true
    backend:
      engine: sqlite
      dbname: pdns.sqlite3
      dbpath: /var/lib/powerdns
    bind:
      address: 127.0.0.1
      port: 53
    api:
      enabled: true
      key: ChanGEMe
    webserver:
      enabled: true
      address: 127.0.0.1
      password: ChangeMeToo
    axfr_ips:
      - 172.16.10.103
      - 172.16.10.104
      - 172.16.10.102
      - 127.0.0.1
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
