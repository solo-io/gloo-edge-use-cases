# Handling Large Payloads

 A customer was struggling with another API gateway for a use case that had two basic requirements:
* Upload large files, up to 100 MB.
* Add some custom headers from the gateway to the upstream request.

This example shows how to manage requests with large payloads in Gloo Edge.

We'll deploy an upstream service in our kube cluster that corresponds to the public [httpbin](http://httpbin.org) service. We'll use the httpbin [/post](https://httpbin.org/#/HTTP_Methods/post_post) endpoint to demonstrate handling of large payloads and show us any problems along the way. In addition, we'll evolve an Edge virtual service to show how to fully satisfy this use case.

## Prerequisites
* Any standards-compliant kube cluster should work with this example. We tested this example with GKE version v1.21.10-gke.2000.
* Any recent version of Gloo Edge will work with this. We tested this example with Gloo Edge Enterprise version 1.11.0, although Open Source Gloo Edge should work too.

## Setup
* Apply httpbin Service and Deployment:

`kubectl apply -f httpbin-svc-dpl.yaml`

* Apply the initial version of the VirtualService. It's a simple VS that forwards requests for any domain with any path to the httpbin service. It also uses a transformation to inject the custom header `x-my-custom-header` with value `my-custom-value`. More sophisticated transformation templates are described in the Gloo Edge [docs](https://docs.solo.io/gloo-edge/latest/guides/traffic_management/request_processing/transformations/).

`kubectl apply -f large-payload-vs-original.yaml`

* Generate some large local sample payload files
- 1MB: `base64 /dev/urandom | head -c 10000000 > 1m-payload.txt`
- 10MB: `base64 /dev/urandom | head -c 100000000 > 10m-payload.txt`
- 100MB: `base64 /dev/urandom | head -c 1000000000 > 100m-payload.txt`


## Example Calls

* Succeeding with a small 100-byte request payload. Note the `X-My-Custom-Header` value that appears in the request headers that httpbin echoes back to the caller.
```
% curl -i -s -w "@curl-format.txt" -X POST -d "@100b-payload.txt" $(glooctl proxy url)/post
HTTP/1.1 200 OK
server: envoy
date: Thu, 05 May 2022 20:14:41 GMT
content-type: application/json
content-length: 550
access-control-allow-origin: *
access-control-allow-credentials: true
x-envoy-upstream-service-time: 2

{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "{\"text\":\"tqwypfzxzlkdhbeokohdignyslcelvuuivuprthlejxtzowhnisamykeyillwpiwocbrwmkaknehpvw0123456789\"}": ""
  },
  "headers": {
    "Accept": "*/*",
    "Content-Length": "100",
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "35.185.51.108",
    "User-Agent": "curl/7.77.0",
    "X-Envoy-Expected-Rq-Timeout-Ms": "15000",
    "X-My-Custom-Header": "my-custom-value"
  },
  "json": null,
  "origin": "10.72.2.5",
  "url": "http://35.185.51.108/post"
}
          time_total:  0.090021s
       response_code:  200
        payload_size:  100
```

* Failing with a 1MB payload. For this and all subsequent examples, we'll suppress the native httpbin output because of its extreme verbosity in echoing back all of the original request payload. Instead, we'll rely on curl facilities to show just the response bits we care about: the total processing time, HTTP response code, and confirming the size of the request payload.
```
% curl -s -i -w "@curl-format.txt" -X POST -d "@1m-payload.txt" $(glooctl proxy url)/post
HTTP/1.1 100 Continue

HTTP/1.1 413 Payload Too Large
content-length: 17
content-type: text/plain
date: Thu, 05 May 2022 20:16:28 GMT
server: envoy
connection: close

payload too large          
       time_total:  0.931177s
       response_code:  413
       payload_size:  1048582
```

An HTTP 413 response indicates that we have overflowed Envoy's default buffer size for a given request. Learn more about Envoy buffering and flow control [here](https://www.envoyproxy.io/docs/envoy/latest/faq/debugging/why_is_envoy_sending_413s) and [here](https://www.envoyproxy.io/docs/envoy/latest/faq/configuration/flow_control#faq-flow-control). It is possible to increase the Envoy buffer size, but this must be considered very carefully since multiple large requests with excessive buffer sizes could result in memory consumption issues for the proxy.

The good news is that for this use case we don't require buffering of the request payload at all, since we are not contemplating transformations on the payload. We're simply delivering a large file to a service endpoint. The only transformation we require of the Envoy proxy is to add `X-My-Custom-Header`to the input, which we showed in the previous example.

So now we'll apply a one-line change to our VirtualService that sets the optional Gloo Edge [passthrough](https://docs.solo.io/gloo-edge/latest/guides/traffic_management/request_processing/transformations/#transformation-templates) flag. It is commonly used in use cases like this to instruct the proxy NOT to buffer the payload at all, but simply to pass it through unchanged to the upstream service.

* Apply the "passthrough" version of the VirtualService. 

`kubectl apply -f large-payload-vs-passthrough.yaml`

* Retry the 1MB payload with the modified VirtualService. Now it works!

```
curl -s -w "@curl-format.txt" -X POST -d "@1m-payload.txt" $(glooctl proxy url)/post -o /dev/null
          time_total:  1.434748s
       response_code:  200
        payload_size:  1048582
```

* Note also the smooth, linear scaling when we increase the payload size up to 10MB:

```
curl -s -w "@curl-format.txt" -X POST -d "@10m-payload.txt" $(glooctl proxy url)/post -o /dev/null
          time_total:  10.715770s
       response_code:  200
        payload_size:  10485820
```

* Finally, we achieve our goal of handling a 100MB payload:

```
curl -s -w "@curl-format.txt" -X POST -d "@100m-payload.txt" $(glooctl proxy url)/post -o /dev/null
          time_total:  89.372558s
       response_code:  200
        payload_size:  104858200
```

Note that in a couple of cases, the 100MB test failed due to curl running out of memory. This has nothing to do with Gloo Edge; we're simply bumping up against the memory limits of the curl client.