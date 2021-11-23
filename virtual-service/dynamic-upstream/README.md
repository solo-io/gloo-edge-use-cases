# VirtualService Dynamic Upstream Routing

The following examples show how to utilize the `clusterHeader` option of the `routeAction` to connect to the upstream cluster.  Note that this configuration uses the Envoy cluster name which contains the suffix `_gloo-system` by convention.  This may look odd when comparing it to the output of 

```
glooctl get upstream
```

as that command will show the name of the upstream CR as defined by Gloo and not the internal Envoy cluster name.

## Using Extractors to Route to Upstream

The first example here is found in [tenant-cluster-dynamic.yaml](tenant-cluster-dynamic.yaml).  This contains a transformationTemplate with an extractor that uses regex on the path of the URI to get the second subset of the path.  For example, if you had a request incoming for https://team.example.com/api/httpbin/anything this regex would find "httpbin" as the `servicename` variable and use that to build the target cluster for the request.  See the code snippet below.

```
                transformationTemplate:
                  extractors:
                    servicename:
                      header: ':path'
                      regex: '(^\/[^\/]+\/)([^\/]*)'
                      subgroup: 2
                  headers:
                    tenant-upstream:
                      text: "{{ header(\"tenant-id\") }}-{{ servicename }}-8000_gloo-system"
```