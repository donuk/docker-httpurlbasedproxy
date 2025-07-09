Also on dockerhub:

https://hub.docker.com/r/donuk/httpurlbasedproxy

Show dockerhub on http://localhost/docker and duckduckgo on http://localhost/duck

```
docker run -p 80:80 -e PROXY_BACKEND_1=/docker:https://hub.docker.com -e PROXY_BACKEND_2=/duck:https://duckduckgo.com --rm donuk/httpurlbasedproxy
```
