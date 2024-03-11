# ZAP Docker

This respository serves as a deployable instance of a ZAP container specifically tuned to work with the Cytix Portal and ZAP Integration.

Although no warranty or support is offered on this repository, Cytix will endeavour to keep this repository up to date as newer versions of ZAP are relelased by the SSP Team.

## Build/Installation Instructions

For local deployments of the Cytix ZAP container (which we recommend only for testing/development purposes), clone the repository and deploy it into your local docker environment using the commands below:

```bash
# Begin by cloning the zap-docker Github Repo
git clone https://github.com/cytix-software/zap-docker.git && cd zap-docker

# build a local image of the container
docker build -t cytix-zap .

# run a new docker container with the image just built
docker run -d -t -i \
  -e API_KEY='MY_SUPER_SECRET_API_KEY' \
  -p 8080:8080 \
  --name zap cytix-zap
```

Alternatively, if you want to run a container without building first, you can run the following command to get the built image from `ghcr.io`:

```bash
docker run -d -t -i \
  -e API_KEY='MY_SUPER_SECRET_API_KEY'
  -p 8080:8080 \
  --name zap ghcr.io/cytix-software/zap-docker:latest
```

Following a successful build using the steps above, the ZAP server should now be accessible via http://localhost:8080/. The API key used will be as supplied in the `-e API_KEY` flag above. If no `API_KEY` is specified at runtime, the key used will be `MY_SUPER_SECRET_API_KEY`.

## Environmental Variables

### API_KEY
> `-e API_KEY='MY_SUPER_SECRET_API_KEY'`

Use this to specify an API_KEY to communicate with the container. This should be a secure value and
treated as a password/secret. It is **HIGHLY RECOMMENDED** for you to change this value, especially if
you are running this container in a production environment.

### ZAP_PORT
> `-e ZAP_PORT=8080`

Use this to specify a different port to run ZAP with. For local development where you may have additonal
services running on `8080`, we recommended `8180` instead.

## Deployment to the Cloud (AWS Example)

> Coming Soon