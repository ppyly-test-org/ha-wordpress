#!/bin/bash
set e
terraform destroy --target=module.cloud-sql.google_sql_database.wordpress-database  --auto-approve
terraform apply --auto-approve
