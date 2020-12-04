# docker-geoip
https://hub.docker.com/r/extremeshok/geoip

# Features
Automatically fetch and update various geoip databases

View **docker-compose-sample.yml** in the source repository for usage

nginx-countries by gypthecat
DB-IP GeoIPv2 Databases
Legacy GeoIP Databases (updated) provided by https://www.miyuru.lk/geoiplegacy
IPv6/IPv4 databases, IPv4 address are mapped as IPv6 address.
Emulate maxmind will replace maxmind database files with db-ip database and will use the default maxmind filenames

# DEFAULTS
* EMULATE_MAXMIND=${EMULATE_MAXMIND:-yes}
* DISABLE_ASN=${DISABLE_ASN:-no}
* DISABLE_DBIP=${DISABLE_DBIP:-no}
* DISABLE_LEGACY=${DISABLE_LEGACY:-yes}
* DISABLE_COUNTRY_CIDR=${DISABLE_COUNTRY_CIDR:-no}
