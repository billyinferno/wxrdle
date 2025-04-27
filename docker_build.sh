#!/bin/sh

# perform flutter clean to clean all the current build
flutter clean

# perform the flutter pub get
flutter pub get

# rebuild the flutter web apps
flutter build web --release -t lib/main.dart

# build the docker based on the build
docker build -t adimartha/wxrdle .

# then tag the latest docker image to the current tag
docker image tag adimartha/wxrdle:latest adimartha/wxrdle:20250427

# push both of the image to the docker repo
docker image push adimartha/wxrdle:latest
docker image push adimartha/my_expense:20250427