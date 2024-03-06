gcloud compute instances create alain-demo \
    --project=solutions-engineering-248511 \
    --zone=us-east1-d \
    --machine-type=n2-custom-16-32768 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=72723261885-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-20240306-155938,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240213,mode=rw,size=40,type=projects/solutions-engineering-248511/zones/us-east1-d/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any


ssh alain_pham_grafana_com@demovm.duckdns.org