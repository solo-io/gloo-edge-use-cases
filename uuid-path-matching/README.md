# UUID Path Matching

This example shows some examples of how to match path requests in Gloo Edge that contain an 8-4-4-4-12 formatted UUID. The user had a requirement to match on paths that contained a UUID, like this:
* `/api/v1/<uuid>/good-path`
* `/api/v1/<uuid>`

Using `prefix` matchers wasn't a good option because of other requirements, so we developed some `regex` matchers instead.

## VirtualService
- [UUID path-matching VirtualService](uuid-path.yaml)

## Setup
* Apply VirtualService:
* `kubectl apply -f uuid-path.yaml`

## Example Calls

* Matching full UUID path
```
% curl $(glooctl proxy url)/api/v1/123e4567-e89b-12d3-a456-426614174000/good-path -i
HTTP/1.1 200 OK
content-length: 21
content-type: text/plain
date: Tue, 08 Feb 2022 22:12:22 GMT
server: envoy

api v1 uuid good-path
```

* Matching shorter UUID path
```
% curl $(glooctl proxy url)/api/v1/123e4567-e89b-12d3-a456-426614174000 -i
HTTP/1.1 200 OK
content-length: 11
content-type: text/plain
date: Tue, 08 Feb 2022 22:13:41 GMT
server: envoy

api v1 uuid
```

* Mismatching on malformed UUID
```
% curl $(glooctl proxy url)/api/v1/123e4567-e89b-12d3-a456-42661417/good-path -i
HTTP/1.1 404 Not Found
date: Tue, 08 Feb 2022 22:13:22 GMT
server: envoy
content-length: 0
```

* Mismatching on invalid path request
```
% curl $(glooctl proxy url)/api/v1/123e4567-e89b-12d3-a456-426614174000/bad-path -i
HTTP/1.1 404 Not Found
date: Tue, 08 Feb 2022 22:13:34 GMT
server: envoy
content-length: 0
```