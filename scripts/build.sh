#!/bin/bash

echo "Building..."

dir_name=build
mkdir $dir_name

# Create and activate virtual environment...
virtualenv -p python3.8 env_athena_mailer
source ./env_athena_mailer/bin/activate

# Installing python dependencies...
FILE=./lambda/requirements.txt

if [ -f "$FILE" ]; then
  echo "Installing dependencies..."
  pip install -r "$FILE"

else
  echo "Error: requirement.txt does not exist!"
fi

# Deactivate virtual environment...
deactivate

# Create deployment package...
echo "Creating deployment package..."
cp -r ./env_athena_mailer/lib/python3.8/site-packages/. ./$dir_name
cp -r ./lambda/main.py ./$dir_name

## Removing virtual environment folder...
echo "Removing virtual environment folder..."
rm -rf ./env_athena_mailer

echo "Finished script execution!"
