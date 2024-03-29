#!/bin/sh

# Set variables
build_number=$1
logs_path=s3://blazingsql-colab/blazingsql-logs/endtoend_test_blazingsql

# Copy from docker container to tmp directory
sudo mkdir /tmp/$build_number

echo "Copying logs into local machine jenkins"
sudo docker cp bzsqlcontainer:/var/log/supervisor  /tmp/$build_number
sudo chmod  777  -R /tmp/$build_number
#  Uploading logs to s3 public bucket
echo "Copying logs to s3"
aws s3 cp  /tmp/$build_number/ $logs_path/$build_number --recursive

# Print logs
#echo "=========== Listing Logs ======================"
#aws s3 ls $logs_path/$build_number/supervisor/

# Pruebas

echo "================ Execute this command to check the logs from S3 ============================"

for f in $(aws s3 ls $logs_path/$build_number/supervisor/ | awk '{print $NF}'); 
do       
    echo  "wget https://blazingsql-colab.s3.amazonaws.com/blazingsql-logs/endtoend_test_blazingsql/$build_number/supervisor/$f";
done