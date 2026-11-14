# Linux Basics — Hands-On: entry points. Run `make help`.
SHELL := /bin/bash
COURSE := ./bin/course
COMPOSE := docker compose -f runtime/docker/compose.yaml --profile '*'
VM_TOOL ?= vagrant
ID ?=
SEED ?=
export SEED
TASK ?=
# images to build in `make setup` (rocky needs access to the Rocky mirrors)
IMAGES ?= ubuntu rocky dns systemd

.DEFAULT_GOAL := help
.PHONY: help setup build up down vm-up vm-down vm-ssh lab check hint reset quiz read progress \
        list syllabus test test-unit test-labs lint need-id

help: ## show this help
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[1m%-12s\033[0m %s\n", $$1, $$2}'
	@echo; echo "  Examples: make lab ID=working-with-the-shell   make check ID=iptables   make hint ID=iptables TASK=t2"

setup: ## check prerequisites and build the Docker images
	@command -v python3 >/dev/null || { echo "python3 is required"; exit 1; }
	@command -v docker >/dev/null || { echo "docker is required (https://docs.docker.com/get-docker/)"; exit 1; }
	@docker compose version >/dev/null 2>&1 || { echo "Docker Compose v2 is required"; exit 1; }
	@command -v vagrant >/dev/null || command -v multipass >/dev/null || command -v incus >/dev/null || \
	  echo "note: no VM tool found (vagrant, multipass or incus); modules 02, 07 and 08 need one"
	$(COMPOSE) build $(IMAGES)
	docker pull -q postgres:16

build: setup ## alias for setup

up: ## start every Docker lab machine (usually not needed: `make lab` starts what it needs)
	$(COMPOSE) up -d --no-build

down: ## stop and remove all course containers, networks and volumes
	$(COMPOSE) down -v --remove-orphans

vm-up: ## start the course VM (VM_TOOL=vagrant|multipass|incus)
ifeq ($(VM_TOOL),vagrant)
	cd runtime/vm && vagrant up
else ifeq ($(VM_TOOL),multipass)
	multipass launch 24.04 --name bob-vm --cpus 2 --memory 2G --disk 12G --cloud-init runtime/vm/multipass-cloud-init.yaml
	multipass mount . bob-vm:/course
	multipass exec bob-vm -- sudo COURSE_ROLE=bob-vm bash /course/runtime/vm/provision.sh
else ifeq ($(VM_TOOL),incus)
	@echo "See runtime/vm/incus-profile.yaml for the incus commands (they need your storage pool name)."
else
	@echo "unknown VM_TOOL=$(VM_TOOL)"; exit 1
endif

vm-down: ## destroy the course VM
ifeq ($(VM_TOOL),vagrant)
	cd runtime/vm && vagrant destroy -f
else ifeq ($(VM_TOOL),multipass)
	multipass delete --purge bob-vm
else ifeq ($(VM_TOOL),incus)
	incus delete -f bob-vm
endif

vm-ssh: ## open a shell on the VM as bob
	cd runtime/vm && vagrant ssh bob-vm -c 'sudo -iu bob'

need-id:
	@[ -n "$(ID)" ] || { echo "usage: make $(MAKECMDGOALS) ID=<lab-or-quiz-id>"; exit 2; }

lab: need-id ## start a lab and open a shell: make lab ID=iptables
	$(COURSE) start $(ID)

check: need-id ## grade a lab: make check ID=iptables
	$(COURSE) check $(ID)

hint: need-id ## next hint: make hint ID=iptables TASK=t2
	$(COURSE) hint $(ID) $(TASK)

reset: need-id ## reset a lab: make reset ID=iptables
	$(COURSE) reset $(ID)

quiz: need-id ## take a quiz: make quiz ID=01-introduction-to-shell
	$(COURSE) quiz $(ID)

read: need-id ## read a lesson: make read ID=02-basic-linux-commands
	$(COURSE) read $(ID)

list: ## list everything in the course
	$(COURSE) list

progress: ## show your progress
	$(COURSE) progress

syllabus: ## regenerate SYLLABUS.md
	$(COURSE) syllabus > SYLLABUS.md

test: test-unit lint ## repository self-tests (no containers)

test-unit: ## python unit tests
	python3 -m unittest discover -s tests -p 'test_*.py' -v

test-labs: ## end-to-end lab tests: make test-labs MODULE=01 (or ID=<lab>)
	bash tests/test_labs.sh $(if $(ID),--lab $(ID),$(MODULE))

lint: ## shellcheck + markdownlint (if installed)
	@if command -v shellcheck >/dev/null; then \
	  git ls-files '*.sh' 'runtime/docker/webctl' | xargs shellcheck -x -S warning && echo "shellcheck OK"; \
	else echo "shellcheck not installed; skipping"; fi
	@if command -v markdownlint-cli2 >/dev/null; then markdownlint-cli2 "**/*.md" "#node_modules"; \
	else echo "markdownlint-cli2 not installed; skipping"; fi
