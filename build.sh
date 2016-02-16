#! /bin/bash

# Load image name from config file
CONFIG_FILE="grafana3.conf"
if [ -f "$CONFIG_FILE" ]
then
    source "$CONFIG_FILE"
    if [ -z "$IMAGE_NAME" ]
    then
        echo "ERROR: 'IMAGE_NAME' not defined in config file '$CONFIG_FILE'"
        exit 1
    fi
else
    echo "ERROR: configuration file '$CONFIG_FILE' couldn't be read"
    exit 1
fi

# Generate Dockerfile from template
sed -e "s#{HTTP_PROXY}#${http_proxy}#g" \
    -e "s#{HTTPS_PROXY}#${https_proxy}#g" \
Dockerfile.in > Dockerfile

# Build image from Dockerfile
echo "Building '$IMAGE_NAME' image"
docker build -t "$IMAGE_NAME" .

# Was image created successfully?
if [ $? -ne 0 ]
then
    echo 'Build failed!'
    exit 1
fi
  
echo -e "Done!\nList available images with 'docker images'"

