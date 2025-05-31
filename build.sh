#!/bin/bash
cd /home/ubuntu/Udemy-section8/
npm install
npm run build
chmod 744 push_docker_image.sh
/home/ubuntu/sagar2/push_docker_image.sh
