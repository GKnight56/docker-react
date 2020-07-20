# multi-step build
# builds the prod app and then runs it in nginx container

# base image (insall dependencies abd build the app)
FROM node:alpine as builder

# set working dir (will be created if doesn't exist)
# default is "/"
WORKDIR /app

# copy json file
COPY package.json .

# install dependencies
RUN npm install

# copy files from current dir to CWD inside container
# copying is split in multiple steps so changing cfg files won't cause unnecessary rebuild of previous step
COPY . .

# build the app (will be located in /app/build)
RUN npm run build

# start new block - "run phase"
FROM nginx

# copy from "builder" phase
COPY --from=builder /app/build /usr/share/nginx/html

# nginx will start automatically when contaner starts