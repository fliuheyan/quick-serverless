FROM node:4.6
RUN npm install -g yarn
ENV PATH "$PATH:/app/node_modules/.bin/"

RUN api-get update

mkdir -p /app
COPY . /app
yarn install
