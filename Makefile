.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
SHELL = /bin/bash
.SUFFIXES:

export GCLOUD_PROJECT := $(shell gcloud config get-value project 2>/dev/null)

templated = "kustomization.yaml \
            skaffold.yaml"

.PHONY: all
all: kustomize

.PHONY: clean
clean:
	rm -f $(templated)

.PHONY: manifests
manifests: $(templated)
	kustomize build > generate_manifests.yaml

.PHONY: apply
apply: manifests $(templated)
	kubectl apply -f generated_manifests.yaml

.PHONY: skaffold
skaffold: $(templated)
	skaffold run


$(templated): %.yaml: %.yaml.tmpl
	envsubst < $^ > $@
