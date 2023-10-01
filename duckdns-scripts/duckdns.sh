
#!/bin/sh
curl -s "https://www.duckdns.org/update?domains=${duckdomainraw}&token=${ducktoken}&txt=${CERTBOT_VALIDATION}"
