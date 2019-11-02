.DEFAULT_GOAL  := help
AWK            := awk
DOCKER         := /usr/local/bin/docker
VPATH          := dockerfile
BUILD          := .build
CONTAINER      := go-http-post-get
IMAGE          := richardpct/$(CONTAINER)
CONTAINER_PORT := 8080
HOST_PORT      := 8080

# If DOCKER does not exist then looks for in the PATH variable
ifeq "$(wildcard $(DOCKER))" ""
  DOCKER_FOUND := $(shell which docker)
  DOCKER = $(if $(DOCKER_FOUND),$(DOCKER_FOUND),$(error docker is not found))
endif

# Check if Docker is running
ifneq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS), help)"
  ifneq "$(shell $(DOCKER) version > /dev/null && echo running)" "running"
    $(error Docker is not running)
  endif
endif

# $(call docker-image-rm)
define docker-image-rm
  if $(DOCKER) image inspect $(IMAGE) > /dev/null 2>&1; then \
    $(DOCKER) image rm $(IMAGE); \
    rm -f $(BUILD); \
  fi
endef

# $(call docker-container-stop)
define docker-container-stop
  if $(DOCKER) container inspect $(CONTAINER) > /dev/null 2>&1; then \
    $(DOCKER) container stop $(CONTAINER); \
  fi
endef

.PHONY: help
help: ## Show help
	@echo "Usage: make TARGET\n"
	@echo "Targets:"
	@$(AWK) -F ":.* ##" '/^[^#].*:.*##/{printf "%-13s%s\n", $$1, $$2}' \
	$(MAKEFILE_LIST) \
	| grep -v AWK

.PHONY: shell
shell: run ## Get a shell into the container
	$(DOCKER) container exec -it $(CONTAINER) /bin/sh

.PHONY: push
push: $(BUILD) ## Push the image to DockerHub
	$(DOCKER) push $(IMAGE)

.PHONY: run
run: $(BUILD) ## Run the container
	if ! $(DOCKER) container inspect $(CONTAINER) > /dev/null 2>&1; then \
	  $(DOCKER) container run --rm -d \
	  -p $(HOST_PORT):$(CONTAINER_PORT) \
	  --name $(CONTAINER) \
	  $(IMAGE); \
	fi

.PHONY: build
build: $(BUILD) ## Build the image from the Dockerfile

$(BUILD): Dockerfile
	$(call docker-container-stop)
	$(call docker-image-rm)

	cd dockerfile && \
	$(DOCKER) build -t $(IMAGE) .
	@touch $@

.PHONY: clean
clean: stop ## Delete the image
	$(call docker-image-rm)

.PHONY: stop
stop: ## Stop the container
	$(call docker-container-stop)
