all: check install test

check:
	@if ! command -v fzf >/dev/null 2>&1; then \
		echo "You need to install fuzzy finder first!"; \
		echo "https://github.com/junegunn/fzf"; \
		exit 1; \
	@else \
		echo "All checks succeeded!"; \
	fi

install:
	@echo "Installing... (you will need sudo access)"
	@sudo cp ./src/ccg.sh /usr/local/bin/ccg
	@echo "CCG installed successfully!"

test:
	@echo "Testing installation..."
	@ccg
	@exit 0

