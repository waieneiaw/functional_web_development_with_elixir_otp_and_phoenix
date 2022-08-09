.PHONY: serve
serve:
	mix dialyzer
	iex -S mix

.PHONY: test
test:
	mix dialyzer
	mix test
