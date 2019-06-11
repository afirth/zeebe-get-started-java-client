.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
SHELL = /bin/bash
.SUFFIXES:

export GCLOUD_PROJECT := $(shell gcloud config get-value project 2>/dev/null)

templated = kustomization.yaml \
            skaffold.yaml
manifest = kustomize_generated_manifest.yaml

.PHONY: all
all: kustomize

.PHONY: clean
clean:
	rm -f $(templated) $(manifest)

#runs kustomize to make one big yaml manifest
.PHONY: manifests
manifests: $(templated)
	kustomize build > $(manifest)

#runs kubectl apply on the generated manifest
.PHONY: apply
apply: manifests $(templated)
	kubectl apply -f $(manifest)

#runs skaffold
.PHONY: skaffold
skaffold: $(templated)
	skaffold run

#calls envsubst to replace things like GCLOUD_PROJECT
$(templated): %.yaml: %.yaml.tmpl
	envsubst < $^ > $@
