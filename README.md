# Correlation Vector

CorrelationVector provides the Elixir implementation of the [Microsoft CorrelationVector protocol](https://github.com/microsoft/CorrelationVector) for tracing and correlation of events through a distributed system.

This is a (partial) port of the [JavaScript library provided by Microsoft](https://github.com/microsoft/CorrelationVector-JavaScript).

# Caveats

* Only V2 is implemented
* The Spin operation has not been implemented

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_correlation_vector` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_correlation_vector, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_correlation_vector>.

