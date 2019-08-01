# docker-geoip
https://hub.docker.com/r/extremeshok/geoip

# Features
Automatically fetch and update various geoip databases

View **docker-compose-sample.yml** in the source repository for usage

nginx-countries by gypthecat
Maxmind GeoIPv2 Databases
Maxmind GeoIP Legacy Databases (last available version is included)

# Disable
* DISABLE_MAXMIND=${DISABLE_MAXMIND:-no}
* DISABLE_MAXMIND_LEGACY=${DISABLE_MAXMIND_LEGACY:-no}
* DISABLE_COUNTRY_CIDR=${DISABLE_COUNTRY_CIDR:-no}
