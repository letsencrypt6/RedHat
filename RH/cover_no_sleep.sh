#!/bin/bash

# 笔记本合盖不休眠

sed -i '/HandleLidSwitch=/aHandleLidSwitch=lock' /etc/systemd/logind.conf

systemctl restart systemd-logind