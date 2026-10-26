.DEFAULT_GOAL := help

CONFIG := {"lineLength":160,"tabWidth":4,"indentation":{"tabs":1}}
SOURCES := ./Felix° ./Felix°Widget ./Felix°Watch\ Watch\ App ./Felix°WatchWidget ./Felix°Tests

.PHONY: help fmt lint

help:
	@printf 'make fmt                 format sources in place\n'
	@printf 'make lint                report style issues\n'

fmt:
	swift format -p -r -i --configuration '$(CONFIG)' $(SOURCES)

lint:
	@findings="$$(swift format lint -p -r --configuration '$(CONFIG)' $(SOURCES) 2>&1)"; \
	if [ -n "$$findings" ]; then \
		printf '%s\n' "$$findings" >&2; \
		printf '\nlint failed (%s findings) - run make fmt\n' "$$(printf '%s\n' "$$findings" | wc -l | tr -d ' ')" >&2; \
		exit 1; \
	fi
	@printf 'lint passed\n'
