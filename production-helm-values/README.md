# Helm values samples for production

The main documentation is here: https://docs.solo.io/gloo-edge/latest/operations/production_deployment/

Pick Helm values snippets in the different files and merge them together.

Commands shown below require `yq` version 1.4.x

## Merging two or more files
https://mikefarah.gitbook.io/yq/operators/multiply-merge#merging-files

```bash
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' access-logs.yaml data-plane-replicas-antiaffinity.yaml
```


## Merging all the files
https://mikefarah.gitbook.io/yq/operators/reduce#merge-all-yaml-files-together

```bash
yq eval-all '. as $item ireduce ({}; . * $item )' *.yaml
```

