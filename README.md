# Purpose
Run a web server in a container which displays the hostname  
If a POST request is performed then it writes the data in /tmp/post.txt file  
If a GET request is performed then it displays the /tmp/post.txt file

# Requirement
* Docker

# Usage
I wrote a Makefile to handle the life cycle of images and containers, the
syntax is as follows:

## Getting Help
    $ make help

## Building the image
    $ make build

## Running the container
    $ make run

## Getting a shell access into the running container
    $ make shell

## Pushing the image to DockerHub
    $ make push

## Stopping the container
    $ make stop

## Removing the image
    $ make clean
