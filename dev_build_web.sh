#!/bin/bash

# Download bob.jar like that:
# wget "https://github.com/defold/defold/releases/download/1.6.1/bob.jar" -O bob.jar

# Plus, the script uses https://www.npmjs.com/package/http-server to serve local files.

set -e

PLATFORM=wasm-web

rm -rf build
mkdir -p build/public
java -jar bob.jar --email f@b.com --auth 123 --texture-compression true --bundle-output build/bundle/${PLATFORM} --build-report-html build/public/build_report_latest.html --platform ${PLATFORM} --architectures ${PLATFORM} --archive --liveupdate yes --variant debug resolve build bundle
#java -jar bob.jar --email f@b.com --auth 123 --texture-compression true --bundle-output build/bundle/${PLATFORM} --build-report-html build/public/build_report_latest.html --platform ${PLATFORM} --architectures ${PLATFORM} --archive --liveupdate yes --variant release resolve build bundle
mv build/liveupdate_output/*.zip build/bundle/${PLATFORM}/Wheel_Fortune/resources.zip
# (cd build/bundle/${PLATFORM}/Wheel_Fortune/ && http-server -c-)
--http-server -c-
#openssl genrsa 2048 > key.pem
#openssl req -x509 -days 365 -new -key key.pem -out cert.pem -subj "/C=77/ST=Vladimir/L=Vladimir/O=localhost/OU=localhost/CN=localhost"
#http-server --ssl -c-1 -p 8080 -a 127.0.0.1
#https://yandex.ru/games/app/160801?draft=true&game_url=https://localhost:8080/build/bundle/wasm-web/Wheel_Fortune/