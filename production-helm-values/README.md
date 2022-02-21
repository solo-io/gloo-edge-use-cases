# Helm values samples for production

_The main documentation is here: https://docs.solo.io/gloo-edge/latest/operations/production_deployment/_

Compose your own Helm values file from the samples in this directory.


## Merging Yaml chunks

Commands shown below require [`yq`](https://github.com/mikefarah/yq/#install) version 1.4.x

```bash
yq eval-all '. as $item ireduce ({}; . * $item )' *.yaml
# - OR -
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' access-logs.yaml data-plane-replicas-antiaffinity.yaml
```

**Sources:**
- https://mikefarah.gitbook.io/yq/operators/reduce#merge-all-yaml-files-together
- https://mikefarah.gitbook.io/yq/operators/multiply-merge#merging-files


## Full example

This example gathers most of the samples from this directory:

```bash
yq eval-all '. as $item ireduce ({}; . * $item )' access-logs.yaml control-plane-perf.yaml control-plane-validation-rules.yaml data-plane-replicas-antiaffinity.yaml disable-discovery.yaml hcm-tuning.yaml | tee values.yaml
```


## Discussion on existing tools to merge files

[Kustomize](https://kustomize.io/) doesn’t work with plain yaml files, without the `metadata:` and `kind:` attributes. 

Other options include: 
* [Kustomize Components](https://kubectl.docs.kubernetes.io/guides/config_management/components/), but that won’t help either
* [Kustomize Controller](https://fluxcd.io/docs/components/kustomize/) would not help for the same reasons
* [Helm Controller](https://fluxcd.io/docs/components/helm/), but it looks like a big machinery in order to merge yaml chunks

## Samples included here

- [Access Log Configuration](access-logs.yaml)
- [AWS NLB TLS Offloading](aws-nlb-tls-offloading.yaml)
- [Control Plane Performance Tuning](control-plane-perf.yaml)
- [Control Plane Validation Rules](control-plane-validation-rules.yaml)
- [Data Plane Anti-Affinity](data-plane-replicas-antiaffinity.yaml)
- [Disabling Discovery](disable-discovery.yaml)
- [Envoy Health Checks](envoy-health-check-filter.yaml)
- [HCM Tuning](hcm-tuning.yaml)
- [Listener Tuning](listener-tuning.yaml)
- [XDS Relay](xds-relay.yaml)
- [Disable Prometheus](no-prometheus.yaml)