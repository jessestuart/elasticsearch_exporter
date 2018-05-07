#!/bin/bash
set -euo pipefail

echo "Copying built binary for $GOARCH."
cp .build/linux-${PROMU_ARCH}/elasticsearch_exporter .

if [ $GOARCH == 'amd64' ]; then
  touch qemu-amd64-static
else
  echo "Loading qemu libs for multi-arch support."
  curl -sL https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/qemu-${QEMU_ARCH}-static.tar.gz | tar xz
  docker run --rm --privileged multiarch/qemu-user-static:register
fi

export VERSION_TAG="${REGISTRY}/${IMAGE}:${VERSION}-${TAG}"
export LATEST_TAG="${REGISTRY}/${IMAGE}:latest-${TAG}"

docker build -t $VERSION_TAG \
  --build-arg target=$TARGET \
  --build-arg arch=$QEMU_ARCH \
  .

echo "Logging in to Docker Hub..."
echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
echo "Pushing image with tag: $VERSION_TAG"
docker push $VERSION_TAG

if [ $CIRCLE_BRANCH == 'master' ]; then
  echo "Build is on master branch -- pushing to 'latest' tag."
  docker tag $VERSION_TAG $LATEST_TAG
  docker push $LATEST_TAG
fi
