defmodule CorrelationVector.V2 do
  alias CorrelationVector

  @termination_sign "!"
  @max_vector_length 127
  @base_length 22
  @base64_char_set ~C(ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/)

  # In order to reliably convert a V2 vector base to a guid, the four least significant bits of the last base64
  # content-bearing 6-bit block must be zeros.

  # Base64 characters with four least significant bits of zero are:
  # A - 00 0000
  # Q - 01 0000
  # g - 10 0000
  # w - 11 0000
  @base64_last_char_set ~C(AQgw)

  def parse(<<base_vector::binary-size(@base_length), ".", rest::binary>> = string) do
    if String.length(string) > @max_vector_length do
      {:error,
       "The #{__MODULE__} correlation vector can not be bigger than #{@max_vector_length} characters"}
    else
      immutable = rest |> String.ends_with?(@termination_sign)

      [rest_base, extension_string] =
        rest
        |> String.replace(~r/!$/, "")
        |> String.reverse()
        |> String.split(".", parts: 2)
        |> Enum.map(&String.reverse/1)
        |> Enum.reverse()
        |> then(fn
          [rest_base, extension_string] -> ["." <> rest_base, extension_string]
          [extension_string] -> ["", extension_string]
        end)

      case Integer.parse(extension_string) do
        {extension, _} when extension >= 0 ->
          {
            :ok,
            CorrelationVector.new(
              base_vector: base_vector <> rest_base,
              extension: extension,
              version: __MODULE__,
              immutable: immutable
            )
          }

        _ ->
          {:error,
           "Invalid correlation vector #{inspect(string)}. Invalid extension value #{extension_string}"}
      end
    end
  end

  def parse(string) when is_binary(string) do
    {:error, "Invalid correlation vector #{inspect(string)}."}
  end

  def parse(value) do
    {:error, "Correlation vector must be a string, got #{inspect(value)}."}
  end

  def seed() do
    seed_char(<<>>) |> to_string
  end

  defp seed_char(result) when byte_size(result) < @base_length - 1 do
    next_char = @base64_char_set |> Enum.random() |> List.wrap() |> to_string
    seed_char(result <> next_char)
  end

  defp seed_char(result) when byte_size(result) == @base_length - 1 do
    next_char = @base64_last_char_set |> Enum.random() |> List.wrap() |> to_string
    result <> next_char
  end

  def is_oversized?(base_vector, extension) do
    CorrelationVector.size(base_vector, extension) > @max_vector_length
  end

  def inferable?(base_vector) do
    String.length(base_vector) == @base_length
  end
end

defimpl String.Chars, for: CorrelationVector.V2 do
  def to_string(v2) do
    CorrelationVector.value(v2)
  end
end
