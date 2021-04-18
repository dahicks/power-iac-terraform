#cloud-config

users:
- name: envoy
  uid: 2000

write_files:
- path: /etc/envoy/envoy_demo.yaml
  permissions: 0644
  owner: envoy
  content: |
    ${ envoy_config }

- path: /etc/systemd/system/envoy.service
  permissions: 0644
  owner: root
  content: |
    [Unit]
    Description=Start a simple docker container

    [Service]
    ExecStart=/usr/bin/docker run --rm -u 2000 \
      -p 10000:10000 \
      --name=%n \
      -v /etc/envoy:/etc/envoy \
      envoyproxy/envoy:v1.18.2 -c /etc/envoy/envoy_demo.yaml
    ExecStop=/usr/bin/docker stop %n
    ExecStopPost=/usr/bin/docker rm %n

runcmd:
- systemctl daemon-reload
- systemctl start envoy.service

# Optional once-per-boot setup. For example: mounting a PD.
bootcmd:
- fsck.ext4 -tvy /dev/[DEVICE_ID]
- mkdir -p /mnt/disks/[MNT_DIR]
- mount -t ext4 -O ... /dev/[DEVICE_ID] /mnt/disks/[MNT_DIR]