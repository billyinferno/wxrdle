#!/bin/sh

# perform flutter clean to clean all the current build
flutter clean

# perform the flutter pub get
flutter pub get

# rebuild the flutter web apps
flutter build web --release -t lib/main.dart

# build the docker based on the build
docker build -t adimartha/wxrdle .
