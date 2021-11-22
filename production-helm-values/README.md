Pick Helm values snippets in the different files and merge them together:

```bash
# requires yq v4.x

# merge two or more files (https://mikefarah.gitbook.io/yq/operators/multiply-merge#merging-files):
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' access-logs.yaml data-plane-replicas-antiaffinity.yaml

# - OR -

# merge all files (https://mikefarah.gitbook.io/yq/operators/reduce#merge-all-yaml-files-together):
yq eval-all '. as $item ireduce ({}; . * $item )' *.yaml
```

See also: https://docs.solo.io/gloo-edge/latest/operations/production_deployment/

