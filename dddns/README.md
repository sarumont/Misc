# DNSimple Dynamic DNS

Implements dynamic DNS via `systemd-timers` and DNSimple's API

## Configuration

Create `/etc/dddns.env` containing:

    DNSIMPLE_TOKEN=...
    DNSIMPLE_ACCOUNT=...
    ZONE_ID=...
    RECORD_ID=...

## Installation

Clone/copy/symlink this directory to `/opt/dddns`.
    
    sudo ln -s /opt/dddns/dddns.timer /etc/systemd/system/dddns.timer
    sudo ln -s /opt/dddns/dddns.service /etc/systemd/system/dddns.service
    systemctl enable --now ddns.timer
