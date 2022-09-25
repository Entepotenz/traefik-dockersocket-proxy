# traefik-dockersocket-proxy
Template to avoid exposing your dockersocket to an internet facing [traefik reverse proxy] (https://github.com/traefik/traefik) (can be used as a template to create custom configuration for different services)

The haproxy configuration limits access to the docker socket to:
- **read-only**
- minimum API calls for traefik

If you are looking for more full fledged solution you should checkout this project: https://github.com/Tecnativa/docker-socket-proxy

# HowTo
1. execute `build-env.sh` to generate the `.env`
    - this is necessary to get the valid user GROUPID for haproxy (checkout this section [Why are you overwriting the user group of haproxy?](#Why-are-you-overwriting-the-user-group-of-haproxy))
2. execute `docker-compose up`
3. send HTTP GET request fo `whoami.localhost`
    - if you do not get a HTTP 404 then everything is working :-)

## HowTo debug
For each request haproxy writes a log line.

You can get the log by issuing this command: `docker-compose logs dockerproxy`

# My reasons why I prefer this solution over [tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy) (depending on your use case you might come to a different perfectly valid conclusion)
- simple solution -> less code -> less complexity -> less things to break
- use most recent lts version of haproxy (less maintenance)
    - At the time of writing `tecnativa/docker-socket-proxy` uses `haproxy:2.2-alpine`

# Technical description
## What is the dockersocket?
quote:
> Docker socket /var/run/docker.sock is the UNIX socket that Docker is listening to. This is the primary entry point for the Docker API.

link: https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html#rule-1-do-not-expose-the-docker-daemon-socket-even-to-the-containers

## Why is it necessary to secure access to the dockersocket?
quote:
> The owner of this socket is root. Giving someone access to it is equivalent to giving unrestricted root access to your host.

link: https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html#rule-1-do-not-expose-the-docker-daemon-socket-even-to-the-containers

## Why is mounting `/var/run/docker.sock` as read-only **not sufficient**?
quote:
> mounting the socket read-only is not a solution but only makes it harder to exploit.

link: https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html#rule-1-do-not-expose-the-docker-daemon-socket-even-to-the-containers

## Why are you overwriting the user group of haproxy?
Starting with 2.4 haproxy uses `haproxy` as user and **not** root (for security reasons).
If you mount the docker socket into the haproxy container the access permissions to the docker socket still require root permissions.

Configuring `user: "haproxy:${PGID_DOCKER_SOCKET}"` in `docket-compose.yml` overwrites the groupid of the haproxy process.


# Kudos and sources
I recommend you to read through those sites if you want to customize the configuration:
- https://chriswiegman.com/2019/11/protecting-your-docker-socket-with-traefik-2/
- https://github.com/Tecnativa/docker-socket-proxy
- https://github.com/traefik/traefik/issues/4174
- https://hub.docker.com/_/haproxy?tab=description&page=1&name=lts