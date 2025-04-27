# wxrdle

Worlde but on Steroid

## Note
All the word is pulled from https://word.tips.
All the definition is pulled from https://yourdictionary.com.

## Description
Has ability to change the length of the wordle, for you that want some extreme challenge.

## Looks and Feel
<img src="https://user-images.githubusercontent.com/20193342/158436115-cecb231b-589a-4126-b59c-ad3c56db6b8e.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/158436115-cecb231b-589a-4126-b59c-ad3c56db6b8e.png" width="450" />

<img src="https://user-images.githubusercontent.com/20193342/158436491-99e15e53-a0a7-4051-a3e7-7316255facd7.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/158436491-99e15e53-a0a7-4051-a3e7-7316255facd7.png" width="450" />

## Game Mode
There are few costumizations that you can perform for your game:
1. Length of the word (minimum 5, maximum 10)
2. Length of the answer available (minimum 4, maximum 7)
3. The Game Type:
- <strong>Easy Mode</strong>: The point will keep stacked there are no penalty for skipped/wrong answer.
- <strong>Continues</strong>: In case you skipped/got wrong answer there will be penalty for your current point (it can be minus).
- <strong>Survival</strong>: In case you skipper/got wrong answer your current point will be reset back to 0.
4. Word Check (to perform dictionary check when player input the guess)

## Wxrdle Server
As some API is protected using CORS, but allowed using localhost, you will need to run you own server and change the URL accordingly.
Server can be found on the `/server` folder.

To run server do:
1. cd server
2. npm install
3. pm2 start ecosystem.config.js

Then you can setup your reverse proxy and change the URL on your ENV to point to your API.

## How to Run
1. clone the project
2. flutter run!

## Docker Image
https://hub.docker.com/repository/docker/adimartha/wxrdle

docker pull adimartha/wxrdle:latest

### Docker Compose Example
I am using this docker compose on portainer (stack)

```
version: '3.3'
services:
    wxrdle:
        container_name: wxrdle
        image: adimartha/wxrdle
        ports:
            - 4011:80
        restart: unless-stopped
```

With this you can access the application from your browser using:

```
your-docker-IP:4111
````

You can change the IP address on the docker compose to fit your need.

## Test it out
You can test it on the github hosted pages below

https://billyinferno.github.io/wxrdle/