Pick Helm values snippet in the different directories and merge them together:

```bash
# requires yq v4.x
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' access-logs.yaml data-plane-replicas-antiaffinity.yaml
```

See also: https://docs.solo.io/gloo-edge/latest/operations/production_deployment/

