.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
SHELL = /bin/bash
.SUFFIXES:

export GCLOUD_PROJECT := $(shell gcloud config get-value project 2>/dev/null)

templates = kustomization.yaml \
            skaffold.yaml
manifest = kustomize_generated_manifest.yaml

.PHONY: all
all: kustomize

.PHONY: clean
clean:
	rm $(templates) $(manifest)

#runs kustomize to make one big yaml manifest
.PHONY: manifest
manifest: $(templates)
	kustomize build > $(manifest)

#runs kubectl apply on the generated manifest
.PHONY: apply
apply: manifests $(templates)
	kubectl apply -f $(manifest)

#runs skaffold
.PHONY: skaffold
skaffold: $(templates)
	skaffold run

#calls envsubst to replace things like GCLOUD_PROJECT
$(templates): %.yaml: %.yaml.tmpl
	envsubst < $^ > $@
