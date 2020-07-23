# multi-step build
# builds the prod app and then runs it in nginx container

# base image (insall dependencies abd build the app)
#FROM node:alpine as builder
# AWS beanstalk has an issue with named build, the above will produce an error:
# docker pull" requires exactly 1 argument
# using unnabmed build instead (it will be "build 0")
FROM node:alpine

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

# expose port for AWS beanstalk
# this option will only have effect in beanstalk
EXPOSE 80

# copy from "builder" phase
#COPY --from=builder /app/build /usr/share/nginx/html
# using unnamed build to resolve beanstalk issue
COPY --from=0 /app/build /usr/share/nginx/html

# nginx will start automatically when contaner starts