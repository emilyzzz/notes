### Documentation
http://docs.pgbarman.org/release/2.3/#concurrent-backup-and-backup-from-a-standby
https://github.com/2ndquadrant-it/barman


**Barman** (Backup and Recovery Manager), maintained by 2ndQuadrant, written in Python

#### For 
* disaster recovery or business continuity

####  Can
* remote backup
* multi server backup
* operate remotely from the database server, via the network.
* potentially can reach **zero data loss** (RPO=0)

#### Best Practice
* barman on dedicated server
* do not share barman storage with postgres servers
* integrate barman with monitoring
* use streaming backup for postgres9.4 or newer

#### Requires
* Python 2.6 or 2.7, and some python modules
* Python 3 support on the way, as of now

#### Install
* yum install barman

#### Related PG Params
* hot_standby
* max_wal_senders
* max_replication_slots

#### Commands
* sudo barman list-server (optional: --minimal)
* sudo barman check all
* sudo barman cron
* sudo barman check SERVER_NAME
* sudo barman receive-wal --stop SERVER_NAME
* sudo barman backup SERVER_NAME
* sudo barman diagnose: generate a json of system info
* sudo barman recover **server_name** **backup_id** /path/to/recover/dir
* sudo barman show-backup **server_name** **backup_id**
* sudo barman replication-status qa_api

#### Network
* tablespace_bandwidth_limit = tbname:bwlimit[, tbname:bwlimit, ...]
* network_compression = true|false
