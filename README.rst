
========
PowerDNS
========

Sample pillar:

PowerDNS server with MySQL backend

	powedns:
	  server:
	    enabled: true
	    backend:
	      engine: mysql
	      host: localhost
	      port: 3306
	      name: pdns
	      user: pdn
	      password: password

Read more
=========