#!/bin/bash

set -e

function install-docker {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  echo "    step 1/4: Installing Docker    "
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  sudo apt-get update
  sudo apt-get install apt-transport-https ca-certificates
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  sudo touch /etc/apt/sources.list.d/docker.list
  echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt-get update
  sudo apt-get install -y docker-engine
  sudo service docker restart
  echo "Done with installing docker"
}

function create-docker-group {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  echo "    step 2/4: Creating Docker Group     "
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  sudo usermod -aG docker ubuntu
  echo "Done with creating docker group"
}

function wait-for-some-time {
  echo "Waiting for service to start ..."
  sleep 30
  echo "Done with waiting"
}

function generate-docker-unique-id {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  echo "    step 3/4: Generating unique ID     "
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  sudo rm /etc/docker/key.json
  echo "Done with generating unique ID"
}

function activate-remote-api {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  echo "    step 4/4: Activating remote API    "
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  sudo sed -i 's/DOCKER_OPTS=/DOCKER_OPTS='\''-H tcp:\/\/0.0.0.0:4243 -H unix:\/\/\/var\/run\/docker.sock'\''/g' /etc/init/docker.conf
  echo "Done with activating remote API"
}

function restart-docker {
  sudo service docker restart
}

install-docker
create-docker-group
wait-for-some-time
generate-docker-unique-id
activate-remote-api
restart-docker
