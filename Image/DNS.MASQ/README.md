# DNS Service with dnsmasq

## Create Image

```
docker build -t dnsmasq:01 .
```

## Run

```
docker run --rm -it \
  -v $(pwd)/dnsmasq.d:/etc/dnsmasq.d \
  --net=host \
  dnsmasq:01
```