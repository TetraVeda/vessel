.PHONY: build bump-version push

GH_REGISTRY  := ghcr.io

# Get the latest git tag
LATEST_TAG   := $(shell git describe --tags --abbrev=0)

IMAGE_NAME   := tetraveda/vessel

CODE_BASEDIR := $TETRAVEDA_HOME

IMAGE_TAG    := $(GH_REGISTRY)/$(IMAGE_NAME):$(LATEST_TAG)

# for incrementing a version
BUMP_LEVEL ?= patch
# Parse the major, minor, and patch parts of the tag
MAJOR := $(shell echo $(LATEST_TAG) | cut -d'.' -f1)
MINOR := $(shell echo $(LATEST_TAG) | cut -d'.' -f2)
PATCH := $(shell echo $(LATEST_TAG) | cut -d'.' -f3)

# Version management
bump-version:
	@echo "Version $(MAJOR).$(MINOR).$(PATCH)"
	@echo "Bumping $(BUMP_LEVEL) version..."
	@if [ "$(BUMP_LEVEL)" = "major" ]; then \
		NEW_TAG="$$(($$((10#$(MAJOR))) + 1)).0.0"; \
	elif [ "$(BUMP_LEVEL)" = "minor" ]; then \
		NEW_TAG="$(MAJOR).$$((10#$(MINOR) + 1)).0"; \
	elif [ "$(BUMP_LEVEL)" = "patch" ]; then \
		NEW_TAG="$(MAJOR).$(MINOR).$$((10#$(PATCH) + 1))"; \
	else \
		echo "Invalid BUMP_LEVEL specified. Choose from 'major', 'minor', or 'patch'."; \
		exit 1; \
	fi; \
	echo "New tag: $$NEW_TAG"; \
	git tag $$NEW_TAG; \
	git push origin $$NEW_TAG

# Build targets for the Credential hosting server called credsvr
build:
	@echo "Latest tag $(LATEST_TAG) and Image name $(IMAGE_NAME)"
	@echo "Image tag $(IMAGE_TAG)"
	@docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--load \
		--tag $(IMAGE_TAG) \
		-f Dockerfile .

push:
	@docker push $(IMAGE_TAG)

run-it-rm:
	@echo "Running $(IMAGE_NAME) as 'vessel' on port 8080 - interactive and temporary with shell prompt - remember to run /startup.sh"
	@docker run --rm -it -p 8080:80 --entrypoint /bin/bash --name vessel $(IMAGE_TAG)

run:
	@echo "Running $(IMAGE_NAME) as 'vessel' on port 8080 - detached"
	@docker run -p 8080:80 --name vessel -d $(IMAGE_TAG)
