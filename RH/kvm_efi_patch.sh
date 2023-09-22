#!/bin/bash

. /etc/rht

function modify_xml {
    # xml modify efi+vdb
    sed -i.bk \
    -e "/<os/a\                <loader readonly='yes' secure='yes' type='pflash'>/usr/share/OVMF/OVMF_CODE.secboot.fd</loader>" \
    -e "/<os/a\                <nvram>/var/lib/libvirt/qemu/nvram/${VM}_VARS.fd</nvram>" \
    -e "/<features/a\                <smm state='on'/>" \
    -e "/<disk/i\                <disk device='disk' type='file'>" \
    -e "/<disk/i\                        <target bus='virtio' dev='vdx'/>" \
    -e "/<disk/i\                        <source file='$IMAGE_EFI'/>" \
    -e "/<disk/i\                        <driver name='qemu' type='qcow2'/>" \
    -e "/<disk/i\                </disk>" $XML_FILE
}
function modify_grub {
    # /boot/grub2
    guestfish -a $IMAGE_FILE -i copy-out /boot/grub2/{grubenv,grub.cfg} /tmp
    \cp /boot/efi/EFI/redhat/grub.cfg /var/tmp
    ROOT_UUID=$(awk '/set=root/{print $NF}' /var/tmp/grub.cfg | uniq)
    BOOT_UUID=$(awk '/set=boot/{print $NF}' /var/tmp/grub.cfg | uniq)
    NEW_UUID=$(awk '/set=root/{print $NF}' /tmp/grub.cfg | uniq)
    sed -i -e "s/$ROOT_UUID/$NEW_UUID/" -e "s/$BOOT_UUID/$NEW_UUID/" /var/tmp/grub.cfg
}
function modify_efi {
    # EFI
    qemu-img create -f qcow2 $IMAGE_EFI 512M >/dev/null
    guestfish -a $IMAGE_EFI <<EOF
        run
        part-disk /dev/sda gpt
        mkfs vfat /dev/sda1
        mount /dev/sda1 /
        copy-in /boot/efi/EFI /
        rm-f /EFI/redhat/{grubenv,grub.cfg,user.cfg}
        copy-in /tmp/grubenv /EFI/redhat/
        copy-in /var/tmp/grub.cfg /EFI/redhat/
        quit
EOF
}

# Main Area
for i in $RHT_VM0 $RHT_VMS; do
    VM=$i
    case $VM in
    classroom)
        IMAGE_FILE=/var/lib/libvirt/images/$RHT_COURSE-$VM-vda.qcow2
        IMAGE_EFI=/var/lib/libvirt/images/$RHT_COURSE-$VM-vdx.qcow2
        XML_FILE=/var/lib/libvirt/images/$RHT_COURSE-$VM.xml
        ;;
    *)
        IMAGE_FILE=/content/$RHT_VMTREE/vms/$RHT_COURSE-$VM-vda.qcow2
        IMAGE_EFI=/var/lib/libvirt/images/$RHT_COURSE-$VM-vdx.qcow2
        XML_FILE=/content/$RHT_VMTREE/vms/$RHT_COURSE-$VM.xml
        ;;
    esac
    modify_xml
    modify_grub
    modify_efi
done
