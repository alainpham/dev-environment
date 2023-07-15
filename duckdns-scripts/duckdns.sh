
#!/bin/sh
curl -s "https://www.duckdns.org/update?domains=${duckdomain}&token=${ducktoken}&txt=${CERTBOT_VALIDATION}"