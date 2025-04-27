#!/bin/sh

# perform flutter clean to clean all the current build
flutter clean

# perform the flutter pub get
flutter pub get

# rebuild the flutter web apps
flutter build web --release -t lib/main.prod.dart --verbose

# build the docker based on the build
docker build -t adimartha/wxrdle .

# push both of the image to the docker repo
docker image push adimartha/wxrdle:latest