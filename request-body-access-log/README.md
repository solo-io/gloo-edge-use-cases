# Request Body Access Logging

Users often ask if there is a way to include the bodies for certain requests into the proxy's access logs. This example achieves that by adding a transformation to a virtual service that copies the request body to a request header, then logs that header.

Note that this scheme will fail for message bodies larger than 60 KiB, assuming [default Envoy settings](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/network/http_connection_manager/v3/http_connection_manager.proto) for `max_request_headers_kb`. 

This example was tested with Gloo Edge Enterprise v1.10.5.

## YAML Artifacts
- [httpbin static Upstream](httpbin-us.yaml)
- [VirtualService that copies request body to header](vs-access-log.yaml)
- [Gateway that configures access log with header](gw-access-log.yaml)

## Setup
* Apply Upstream:
`kubectl apply -f httpbin-us.yaml`
* Apply VirtualService:
`kubectl apply -f uuid-path.yaml`
* Apply Gateway changes:
`kubectl apply -f gw-access-log.yaml`

## Example Calls

* httpbin GET with no request body
```
% curl $(glooctl proxy url)/get -i
HTTP/1.1 200 OK
date: Mon, 21 Feb 2022 22:14:55 GMT
content-type: application/json
content-length: 297
server: envoy
access-control-allow-origin: *
access-control-allow-credentials: true
x-envoy-upstream-service-time: 59

{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Host": "localhost",
    "User-Agent": "curl/7.77.0",
    "X-Amzn-Trace-Id": "Root=1-62140edf-7f6a9cf7776cec5606b48d3c",
    "X-Envoy-Expected-Rq-Timeout-Ms": "15000"
  },
  "origin": "71.76.63.164",
  "url": "http://localhost/get"
}
```

* httpbin POST with a request body
```
% curl -X POST -d "my-request-body" $(glooctl proxy url)/post -i
HTTP/1.1 200 OK
date: Mon, 21 Feb 2022 22:15:25 GMT
content-type: application/json
content-length: 519
server: envoy
access-control-allow-origin: *
access-control-allow-credentials: true
x-envoy-upstream-service-time: 52

{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "my-request-body": ""
  },
  "headers": {
    "Accept": "*/*",
    "Content-Length": "15",
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "localhost",
    "User-Agent": "curl/7.77.0",
    "X-Amzn-Trace-Id": "Root=1-62140efd-4018831d54f09c9f376717a0",
    "X-Envoy-Expected-Rq-Timeout-Ms": "15000",
    "X-Request-Body": "my-request-body"
  },
  "json": null,
  "origin": "71.76.63.164",
  "url": "http://localhost/post"
}
```

* httpbin PUT with a request body
```
% curl -X PUT -d "my-request-body" $(glooctl proxy url)/put -i
HTTP/1.1 200 OK
date: Mon, 21 Feb 2022 22:15:44 GMT
content-type: application/json
content-length: 518
server: envoy
access-control-allow-origin: *
access-control-allow-credentials: true
x-envoy-upstream-service-time: 69

{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "my-request-body": ""
  },
  "headers": {
    "Accept": "*/*",
    "Content-Length": "15",
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "localhost",
    "User-Agent": "curl/7.77.0",
    "X-Amzn-Trace-Id": "Root=1-62140f10-75a97ece6e90587a5e887d46",
    "X-Envoy-Expected-Rq-Timeout-Ms": "15000",
    "X-Request-Body": "my-request-body"
  },
  "json": null,
  "origin": "71.76.63.164",
  "url": "http://localhost/put"
}
```

## View Access Logs

Note that the initial request shows a null `requestBody` because the GET request contained no body. Note that the following POST and PUT requests both report the "my-request-body" payload.

```
% kubectl logs -n gloo-system deploy/gateway-proxy | grep ^{ | jq
{
  "requestBody": null,
  "systemTime": "2022-02-21T22:14:55.789Z",
  "upstreamName": "httpbin-us_gloo-system",
  "protocol": "HTTP/1.1",
  "path": "/get",
  "responseCode": 200,
  "httpMethod": "GET",
  "targetDuration": 60,
  "clientDuration": 61,
  "requestId": "5291743a-5a0e-4e55-af71-9101f8b6fe32"
}
{
  "responseCode": 200,
  "path": "/post",
  "systemTime": "2022-02-21T22:15:25.087Z",
  "requestId": "3f7fa059-5691-46f4-9a75-c9429786f105",
  "targetDuration": 53,
  "requestBody": "my-request-body",
  "httpMethod": "POST",
  "clientDuration": 53,
  "upstreamName": "httpbin-us_gloo-system",
  "protocol": "HTTP/1.1"
}
{
  "systemTime": "2022-02-21T22:15:44.812Z",
  "clientDuration": 70,
  "targetDuration": 70,
  "path": "/put",
  "upstreamName": "httpbin-us_gloo-system",
  "protocol": "HTTP/1.1",
  "responseCode": 200,
  "requestBody": "my-request-body",
  "httpMethod": "PUT",
  "requestId": "5891e374-844e-4b6e-8cda-3d187d733d7b"
}
```