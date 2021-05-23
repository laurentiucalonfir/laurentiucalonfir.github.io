
(
echo g # Create a new empty DOS partition table
echo n # Add a new partition
echo   # First sector (Accept default: 1)
echo +512M  # Last sector (Accept default: varies) 
echo t
echo 1
echo n # Add a new partition
echo 2 # Partition number
echo   # First sector
echo +4G # Last sector
echo t
echo 2
echo 19
echo n # Add a new partition
echo   # First sector
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | sudo fdisk
