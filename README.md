# docker-geoip
https://hub.docker.com/r/extremeshok/geoip

# Features
Automatically fetch and update various geoip databases

View **docker-compose-sample.yml** in the source repository for usage

nginx-countries by gypthecat
DB-IP GeoIPv2 Databases
Legacy GeoIP Databases (updated) provided by https://www.miyuru.lk/geoiplegacy
IPv6/IPv4 databases, IPv4 address are mapped as IPv6 address.
Replace maxmind with db-ip databases, but will still use default maxmind filenames

# Disable
* DISABLE_MAXMIND=${DISABLE_MAXMIND:-no}
* DISABLE_LEGACY=${DISABLE_LEGACY:-no}
* DISABLE_COUNTRY_CIDR=${DISABLE_COUNTRY_CIDR:-no}
