.PHONY: iex
iex:
	mix dialyzer
	iex -S mix

.PHONY: test
test:
	mix dialyzer
	mix test

.PHONY: serve
serve:
	mix dialyzer
	cd apps/islands_interface && mix phx.server
