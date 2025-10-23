#!/bin/bash

helm repo add gloo https://storage.googleapis.com/solo-public-helm
helm repo update

helm install gloo gloo/gloo --namespace gloo-system --create-namespace