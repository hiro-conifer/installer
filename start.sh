#!/bin/bash
source ./1-value.sh                                               # Type Value
./2-partition.sh $part $part_boot $part_root                      # Create Partitions
./3-pacstrap.sh $part_boot $part_root $ucode                      # Install Base Packages
./4-settings.sh $part_root $hostnm $usernm $userpw $rootpw $ucode # Other Setting
./5-otherpac.sh $usernm $aur                                      # Install Other Packages
./6-setupwm.sh $usernm $aur                                       # Setup SwayWM
