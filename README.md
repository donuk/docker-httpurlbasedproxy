Also on dockerhub:

https://hub.docker.com/r/donuk/httpurlbasedproxy

Show dockerhub on http://localhost/docker and duckduckgo on http://localhost/duck

```
docker run -p 80:80 -e PROXY_BACKEND_1=/docker:https://hub.docker.com -e PROXY_BACKEND_2=/duck:https://duckduckgo.com --rm donuk/httpurlbasedproxy
```

If your backend proxies change ip frequently (e.g. if they are local services undergoing updates) you can use environment variable `SHORT_DNS_TTL=yes` to reduce dns caching times and prevent 502 errors.
