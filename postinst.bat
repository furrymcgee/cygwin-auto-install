REM start ssh server
%1/bin/bash -l -c "sed -i /etc/fstab -e /^none/s/posix=0/posix=1/ -e '$a//samba/share /mnt smbfs noacl 0 0'"
%1/bin/bash -l -c "ssh-host-config --yes && cygrunsrv -S sshd"
%1/bin/bash -l -c "make -C /mnt -n"
exit /b
