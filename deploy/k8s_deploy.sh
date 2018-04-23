#!/bin/bash

export PYTHONIOENCODING=utf8

if [ "$DEPLOYMENT_GROUP_NAME" == "Test" ]
then
  mysql_password=$(aws ssm get-parameter --name /CodeBuild/WP-CICD/Test/mysql_pw --with-decryption --region eu-west-1 | python -c "import sys, json; print json.load(sys.stdin)['Parameter']['Value']")  
  mysql_host=$(aws ssm get-parameter --name /CodeBuild/WP-CICD/Test/mysql_host --with-decryption --region eu-west-1 | python -c "import sys, json; print json.load(sys.stdin)['Parameter']['Value']")  
  memcached_host=$(aws ssm get-parameter --name /CodeBuild/WP-CICD/Test/memcached_host --with-decryption --region eu-west-1 | python -c "import sys, json; print json.load(sys.stdin)['Parameter']['Value']")  
  
elif [ "$DEPLOYMENT_GROUP_NAME" == "Production" ]
then
  mysql_password=$(aws ssm get-parameter --name /CodeBuild/WP-CICD/Production/mysql_pw --with-decryption --region eu-west-1 | python -c "import sys, json; print json.load(sys.stdin)['Parameter']['Value']")  
  mysql_host=$(aws ssm get-parameter --name /CodeBuild/WP-CICD/Production/mysql_host --with-decryption --region eu-west-1 | python -c "import sys, json; print json.load(sys.stdin)['Parameter']['Value']")  
  memcached_host=$(aws ssm get-parameter --name /CodeBuild/WP-CICD/Production/memcached_host --with-decryption --region eu-west-1 | python -c "import sys, json; print json.load(sys.stdin)['Parameter']['Value']")  
else
  mysql_password=$(aws ssm get-parameter --name /CodeBuild/WP-CICD/Test/mysql_pw --with-decryption --region eu-west-1 | python -c "import sys, json; print json.load(sys.stdin)['Parameter']['Value']")  
  mysql_host=$(aws ssm get-parameter --name /CodeBuild/WP-CICD/Test/mysql_host --with-decryption --region eu-west-1 | python -c "import sys, json; print json.load(sys.stdin)['Parameter']['Value']")  
  memcached_host=$(aws ssm get-parameter --name /CodeBuild/WP-CICD/Test/memcached_host --with-decryption --region eu-west-1 | python -c "import sys, json; print json.load(sys.stdin)['Parameter']['Value']")  
fi


sed -i -e "s/<WORDPRESS_DB_PASSWORD>/$mysql_password/g" deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive/wordpress-service-deploy.yml
sed -i -e "s/<WORDPRESS_DB_HOST>/$mysql_host/g" deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive/wordpress-service-deploy.yml
sed -i -e "s/<MEMCACHED_HOST>/$memcached_host/g" deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive/wordpress-service-deploy.yml

su ubuntu -c "kubectl apply -f deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive/wordpress-service-deploy.yml"
