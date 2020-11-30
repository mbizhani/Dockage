#! /bin/bash

source .env

if [ "$1" ]; then

	echo "Token=[${1}], Domain=[${GITLAB_DOMAIN}], VolBaseDir=[${VOL_BASE_DIR}]"

	docker run --rm -it \
	  -v ${VOL_BASE_DIR}/gitlab-runner/config:/etc/gitlab-runner \
	  --network ${EXT_NET} \
	  gitlab/gitlab-runner:${GITLAB_RUNNER_VER} register \
	  --non-interactive \
	  --executor "docker" \
	  --docker-image docker:stable \
	  --url "http://${GITLAB_DOMAIN}/" \
	  --docker-network-mode ${EXT_NET} \
	  --docker-privileged \
	  --registration-token "${1}" \
	  --description "docker-gitlab-runner" \
	  --tag-list "default" \
	  --run-untagged="true" \
	  --locked="false" \
	  --access-level="not_protected" \
	  --docker-volumes /var/run/docker.sock:/var/run/docker.sock
else
	echo "ERROR: $0 TOKEN"
fi
