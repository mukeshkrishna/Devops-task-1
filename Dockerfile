FROM node:16.13.2 AS Build

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .

RUN useradd --system --create-home --home-dir /home/node-user --shell /bin/bash --gid root --groups sudo --uid 1001 node-user
RUN chown -R node-user:node-user /usr/src

USER node-user

EXPOSE 8090
CMD node app.js

