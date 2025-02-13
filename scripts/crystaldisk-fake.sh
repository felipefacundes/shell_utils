#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script performs a series of disk performance tests on a Linux system. 
It begins by clearing the filesystem cache to ensure accurate measurements. 
The script then conducts two writing tests using different methods: one with synchronous writes and another with direct I/O. 
Following the write tests, it performs a copy test to measure the time taken to copy the created file. 
Finally, it executes a read test to assess read performance and prompts the user 
to run an additional test using the 'hdparm' utility for further disk performance analysis.
DOCUMENTATION

test_disk_file=.test_disk_file_$(date +"%Y-%m-%d_%H-%M-%S")

bash -c "sync && echo 3 | sudo tee /proc/sys/vm/drop_caches" > /dev/null
echo
tput setaf 2; echo "Writing Test (Method 01):"
tput sgr0
echo
dd if=/dev/zero of="${test_disk_file}" bs=64M count=16 oflag=dsync status=progress
echo
tput setaf 2; echo "Writing Test (Method 02):"
tput sgr0
echo
rm "${test_disk_file}"
dd if=/dev/zero of="${test_disk_file}" bs=64M count=16 oflag=direct status=progress
echo
tput setaf 2; echo "Copy Test:"
tput sgr0
echo
time cp "${test_disk_file}" .test_disk_file_copy
rm .test_disk_file_copy
echo
bash -c "sync && echo 3 | sudo tee /proc/sys/vm/drop_caches" > /dev/null
tput setaf 2; echo "Read Test:"
tput sgr0
echo
dd if="${test_disk_file}" of=/dev/null bs=8k oflag=dsync status=progress
rm "${test_disk_file}"
echo
tput setaf 2
echo "now test with hdparm"
echo "run:"
tput setaf 3
echo "sudo hdparm -Tt /dev/sda"
tput sgr0
