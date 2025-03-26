all: check_shell check install test

check_shell:
	@if ! command -v bash >/dev/null 2>&1; then \
		echo "You need to install bash shell to run this program."; \
		exit 1; \
	fi
	@echo "Shell is configured correctly!"

SHELL := /bin/bash

check:
	@if ! command -v fzf >/dev/null 2>&1; then \
		echo "You need to install fuzzy finder first."; \
		echo "https://github.com/junegunn/fzf"; \
		exit 1; \
	fi
	@echo "All checks succeeded!"

install:
	@echo "Installing... (you will need sudo access)"
	@sudo cp ./src/ccg.sh /usr/local/bin/ccg
	@echo "CCG installed successfully!"

test:
	@echo "Testing installation..."
	@ccg
	@exit 0

