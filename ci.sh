#!/bin/bash

if [ "$TRAVIS_PULL_REQUEST" = "true" ]; then
  docker buildx build  \
    --progress plain \
    --platform=linux/amd64 \
    .
  exit $?
fi
echo $DOCKER_PASSWORD | docker login -u qmcgaw --password-stdin &> /dev/null
if [ "$TRAVIS_TAG" = "" ]; then
  LATEST_TAG=latest
  ALPINE_TAG=alpine
else
  LATEST_TAG = "$TRAVIS_TAG"
  ALPINE_TAG=alpine-$TRAVIS_TAG
fi
echo "Building Docker images for \"$DOCKER_REPO:$ALPINE_TAG\" and \"$DOCKER_REPO:$LATEST_TAG\""
docker buildx build \
    -f alpine.Dockerfile \
    --progress plain \
    --platform=linux/amd64 \
    --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
    --build-arg VCS_REF=`git rev-parse --short HEAD` \
    --build-arg VERSION=$ALPINE_TAG \
    -t $DOCKER_REPO:$LATEST_TAG \
    -t $DOCKER_REPO:$ALPINE_TAG \
    --push \
    .
