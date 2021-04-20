#cloud-config

write_files:
- path: /etc/systemd/system/echo.service
  permissions: 0644
  owner: root
  content: |
    [Unit]
    Description=Start a simple http echo docker container
    After=network-online.target
    Wants=network-online.target

    [Service]
    ExecStart=/usr/bin/docker run --rm \
      -p 3000:80 \
      --name=%n \
      ealen/echo-server
    ExecStop=/usr/bin/docker stop %n
    ExecStopPost=/usr/bin/docker rm %n
    Restart=always
    RestartSec=15s
    TimeoutStartSec=30s
    
    [Install]
    WantedBy=multi-user.target    

runcmd:
- systemctl daemon-reload
- systemctl start echo.service

# Optional once-per-boot setup. For example: mounting a PD.
bootcmd:
- fsck.ext4 -tvy /dev/[DEVICE_ID]
- mkdir -p /mnt/disks/[MNT_DIR]
- mount -t ext4 -O ... /dev/[DEVICE_ID] /mnt/disks/[MNT_DIR]