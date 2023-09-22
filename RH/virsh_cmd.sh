#!/bin/bash

# kvm开机自启动
virsh autostart node2

# kvm开机不启动
virsh autostart --disable node2