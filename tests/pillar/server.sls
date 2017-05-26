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
