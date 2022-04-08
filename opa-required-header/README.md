# Use OPA to enforced required request header

This example shows one way to use Open Policy Agent to enforce a required header `x-required` on Gloo Edge inbound requests.

We'll use a static upstream pointing to public [httpbin](http://httpbin.org), plus an OPA policy attached to an Edge virtual service.

## Setup
* Apply httpbin Upstream:

`kubectl apply -f httpbin-us.yaml`

* Apply ConfigMap containing rego rule:

`kubectl apply -f opa-reqd-header-cm.yaml`

* Apply AuthConfig wrapping OPA ConfigMap:

`kubectl apply -f opa-policy-authconfig.yaml`

* Apply VirtualService that uses the OPA AuthConfig:

`kubectl apply -f opa-reqd-header-vs.yaml`

## Example Calls

* Succeeding with `x-required` header
```
% curl $(glooctl proxy url)/get -H "x-required: true" -i
HTTP/1.1 200 OK
date: Fri, 08 Apr 2022 14:47:02 GMT
content-type: application/json
content-length: 334
server: envoy
access-control-allow-origin: *
access-control-allow-credentials: true
x-envoy-upstream-service-time: 39

{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Host": "35.185.51.108",
    "User-Agent": "curl/7.77.0",
    "X-Amzn-Trace-Id": "Root=1-62504ae5-43b6606865d2ffd06d77b765",
    "X-Envoy-Expected-Rq-Timeout-Ms": "15000",
    "X-Required": "true"
  },
  "origin": "35.231.247.214",
  "url": "http://35.185.51.108/get"
}
```

* Failing without `x-required` header
```
% curl $(glooctl proxy url)/get -i
HTTP/1.1 403 Forbidden
date: Fri, 08 Apr 2022 14:47:07 GMT
server: envoy
content-length: 0
```

## Alternative Approaches

* Custom WASM filter

* Virtual Service that matches on the absence of the required header and returns a direct response, like this:
```
kind: VirtualService
metadata:
  name: test-direct-response
  namespace: gloo-system
spec:
  virtualHost:
    routes:
    - matchers:
      - headers: 
        - name: x-required
   value: x-required
   invertMatch: true
      directResponseAction:
        status: 4xx
        body: "Must contain x-required"
```