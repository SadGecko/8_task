#!/bin/bash

docker build -t sadgecko/wp:last ./app
docker push sadgecko/wp:last