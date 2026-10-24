.PHONY: regression lint synthesis

regression:
	./scripts/run_regression.sh

lint:
	./scripts/run_lint.sh

synthesis:
	./scripts/run_synthesis.sh
