#!/bin/bash

set -e

# Clean up previous builds
rm -rf lambda_pg_init_deploy
rm -f lambda_pg_init_deploy.zip

mkdir lambda_pg_init_deploy

# Install pg8000
pip install pg8000 -t lambda_pg_init_deploy

# Copy the lambda handler
cp pg_init.py lambda_pg_init_deploy/

# Create the deployment zip
cd lambda_pg_init_deploy
zip -r9 ../lambda_pg_init_deploy.zip .
cd ..

# Clean up current build directory 
rm -rf lambda_pg_init_deploy