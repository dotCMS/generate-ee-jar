#!/bin/bash

set -e

repo_username=$1
repo_password=$2
ee_build_id=$3
build_id=$4
rsa_key=$5

echo "Repo username: ${repo_username}"
echo "Repo password: ${repo_password}"
echo "EE Build id: ${ee_build_id}"
echo "Core Build id: ${build_id}"

if [[ ${ee_build_id} =~ ^release-.* ]]; then
  is_release='true'
else
  is_release='false'
fi

mkdir /root/.ssh
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
echo "${rsa_key}" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

mkdir -p /build/src \
  && echo "Pulling dotCMS src" \
  && cd /build/src && git clone git@github.com:dotCMS/core.git core \
  && cd /build/src/core && git submodule update --init --recursive \
  && git clean -f -d && git pull

echo "Checking out core commit/tag/branch: ${build_id}"
git checkout ${build_id}
git pull origin ${build_id}
git submodule update --init --recursive
cd dotCMS && ./gradlew java -PuseGradleNode=false

dev_push=false
if [[ "${is_release}" == 'true' ]]; then
  releaseParam='-Prelease=true'
else
  releaseParam=''
  if [[ "${ee_build_id}" != 'master' ]]; then
    dev_push=true
    cp ./gradle.properties ./gradle.properties.bak
    release_version=${GITHUB_SHA::8}
    sed -i "s,^dotcmsReleaseVersion=.*$,dotcmsReleaseVersion=${release_version},g" ./gradle.properties
    echo "Overriding dotcmsReleaseVersion to: ${release_version}"
    cat ./gradle.properties | grep dotcmsReleaseVersion
  fi
fi

echo 'Uploading enterprise jar'
echo "./gradlew -b deploy.gradle uploadEnterprise ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password}"
./gradlew -b deploy.gradle uploadEnterprise ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password}
