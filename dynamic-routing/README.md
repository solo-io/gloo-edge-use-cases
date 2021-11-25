# VirtualService Dynamic Upstream Routing

The following examples shows how to utilize the `clusterHeader` option of the `routeAction` to connect to the upstream cluster.  Note that this configuration uses the Envoy cluster name which contains the suffix `_gloo-system` by convention.  This may look odd when comparing it to the output of 

```
glooctl get upstream
```

as that command will show the name of the upstream CR as defined by Gloo and not the internal Envoy cluster name.

## Using Extractors to Route to Upstream

The first example here is found in [tenant-cluster-dynamic.yaml](tenant-cluster-dynamic.yaml).  This contains a transformationTemplate with an extractor that uses regex on the path of the URI to get the second subset of the path.  For example, if you had a request incoming for https://team.example.com/api/httpbin/anything this regex would find "httpbin" as the `x-service-name` variable and use that to build the target cluster for the request. See the code snippet below:

```yaml
                transformationTemplate:
                  extractors:
                    x-service-name: # pick the 2nd segment from the path
                      header: ':path'
                      regex: '/api/([a-zA-Z0-9]+)/.*'
                      subgroup: 1
                  headers:
                        tenant-upstream: # build an "upstream cluster" name with the convention: "<upstream name>_<upstream namespace>""
                          text: "{{ x-tenant-id }}-{{ x-service-name }}service_{{ x-tenant-id }}" # the Upstream CR lives in the tenant's namespace
                  clearRouteCache: true
```

More information can be found in this blog post: https://www.solo.io/blog/dynamic-routing-with-gloo-edge/
