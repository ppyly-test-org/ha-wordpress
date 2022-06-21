#!/bin/bash
sudo -u pashkadez gcsfuse --implicit-dirs -o allow_other terraform-wordpress-bucket-123456789 /mnt/wordpress/
sudo ln -s /mnt/wordpress /var/www/
sudo systemctl reload apache2