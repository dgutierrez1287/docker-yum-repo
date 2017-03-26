#!/bin/bash

docker build -t dgutierrez1287/yum-repo .

if [[ $? -ne 0 ]]; then
    echo "ERROR: error building contatiner"
    exit 1
fi

exit 0