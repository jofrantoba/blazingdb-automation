#!/bin/bash

nvidia-docker run --rm -v $PWD:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ -ti blazingdb/ral
