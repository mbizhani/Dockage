# DevOps

By downloading these files and using following steps, a DevOps env with CI/CD is setup with 
`GitLab`, `GitLab Runner`, and `Sonatype Nexus3`.

## Exec Steps
- Check out all of files
- Modify `.env` and set `VOL_BASE_DIR` and `DOMAIN_BASE` variables due to your settings
- `chmod +x init.sh && sudo ./init.sh`
- `docker-compose up -d`
- Base on `.env`, assert `${GITLAB_DOMAIN}` and `${NEXUS_DOMAIN}` names are configured in your DNS server 
  - For local test, add entries in your `/etc/hosts`
- For Gitlab, go to `http://${GITLAB_DOMAIN}` and configure it
  - `chmod +x register-runner.sh && ./register-runner.sh TOKEN` to register the Runner in your Gitlab 
- For Nexus, go to `http://${NEXUS_DOMAIN}` and configure it

For more information, refer to [Docker to the Point - Part 3](https://www.devocative.org/article/tech/docker03)