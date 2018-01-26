#!/bin/bash
set -eu

if [ ! -f sharedkey ]; then
	echo "No shared key file: sharedkey" >&2
	exit 1
fi

scripts/makebuildenv.sh

rm -rf .out
mkdir .out

TINI_VERSION="0.16.1-r0"
EXITD_VERSION="1.1.0"
SPIPED_COMMIT="9c0857b643ff8649aa0a1ab4f9fbf20b0c8e533a" # 1.6.0

curl -sL -o .out/exitd https://github.com/romabysen/exitd/releases/download/${EXITD_VERSION}/exitd-linux-amd64-upx
chmod +x .out/exitd

docker run \
	--rm -it \
	-v $(pwd)/.out:/out \
	-v $(pwd)/parchment:/go/src/github.com/mendsley/parchment \
	parchment/buildenv sh -c "set -eux \
		&& go test -v github.com/mendsley/... \
		&& GGO_ENABLED=0 go install \
			-tags netgo \
			-ldflags '-w -extldflags \"-static\"' \
			-v \
			github.com/mendsley/parchment/cmd/parchmentcat \
			github.com/mendsley/parchment/cmd/parchment-journald \
		&& go install -v github.com/mendsley/parchment \
		&& cp /go/bin/* /out/ \
		&& apk add --no-cache tini=${TINI_VERSION} \
		&& cp /sbin/tini /out/ \
		&& git clone git://github.com/Tarsnap/spiped /spiped \
		&& cd /spiped \
		&& git reset --hard ${SPIPED_COMMIT} \
		&& CC='gcc -static' make \
		&& cp ./spiped/spiped /out/ \
		&& chown -R $(id -u) /out/* \
		;
	" \
	;

##
# Build containers
cp scripts/Dockerfile-* .out/
cp scripts/run-* .out/
cp scripts/conf-* .out/
cp sharedkey .out/
docker build --squash -t parchment/cat --file .out/Dockerfile-cat .out
docker build --squash -t parchment/journald --file .out/Dockerfile-journald .out
docker build --squash -t parchment/client --file .out/Dockerfile-client .out
docker build --squash -t parchment/server --file .out/Dockerfile-server .out
