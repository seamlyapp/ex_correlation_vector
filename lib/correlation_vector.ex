defmodule CorrelationVector do
  @moduledoc """

  """

  alias CorrelationVector.V2

  @termination_sign "!"

  @versions [V2]

  defstruct(
    immutable: false,
    base_vector: nil,
    extension: 0,
    version: nil
  )

  @type t :: %__MODULE__{
          immutable: boolean(),
          base_vector: String.t(),
          extension: number(),
          version: module()
        }

  def new() do
    new(%{})
  end

  @doc """
  Creates a new CorrelationVector of the given version
  """
  @spec new(map() | keyword()) :: t()
  def new(options) do
    options = options |> Map.new()

    version = options |> Map.get(:version, V2)
    base_vector = options |> Map.get_lazy(:base_vector, fn -> version.seed() end)
    extension = options |> Map.get(:extension, 0)

    immutable =
      options
      |> Map.get_lazy(:immutable, fn ->
        is_oversized?(base_vector, extension, version)
      end)

    %__MODULE__{
      version: version,
      base_vector: base_vector,
      extension: extension,
      immutable: immutable
    }
  end

  @doc """
  Increments the current extension by one. Do this before passing the value to an
  outbound message header.
  """
  @spec increment(t()) :: t()
  def increment(%{immutable: true} = cv) do
    cv
  end

  def increment(%{extension: extension} = cv) do
    next = %{cv | extension: extension + 1}

    if is_oversized?(next) do
      %{next | immutable: true}
    else
      next
    end
  end

  @doc """
  See `extend/1`
  """
  @spec safe_extend(String.t()) :: t()
  def safe_extend(value) do
    case extend(value) do
      {:ok, cv} -> cv
      _ -> new()
    end
  end

  @doc """
  Creates a new correlation vector by extending an existing value. This should be
  done at the entry point of an operation.

  Works on parsed and string CVs

  This function wil return {:ok, cv}  or {:error, reason}. If you just
  want to extend or create a new one use `safe_extend/1`
  """
  @spec extend(String.t()) :: {:ok, t()} | {:error, reason :: String.t()}
  def extend(string) when is_binary(string) do
    case do_parse(string) do
      {:ok, cv} -> extend(cv)
      err -> err
    end
  end

  def extend(%{immutable: true} = cv) do
    {:ok, cv}
  end

  def extend(%{immutable: false, base_vector: base_vector, extension: extension, version: version}) do
    {
      :ok,
      new(
        base_vector: "#{base_vector}.#{extension}",
        version: version
      )
    }
  end

  @doc """
  See `safe_parse/1`
  """
  @spec safe_parse(String.t()) :: t()
  def safe_parse(string) when is_binary(string) do
    case do_parse(string) do
      {:ok, cv} -> cv
      _ -> new()
    end
  end

  def safe_parse(_) do
    new()
  end

  @doc """
  Parses a correlation vector into struct

  This function wil return {:ok, cv}  or {:error, reason}. If you just
  want to parse or create a new one on failure use `safe_parse/1`
  """
  @spec parse(String.t()) :: {:ok, t()}, {:error, reason :: String.t()}
  def parse(string) when is_binary(string) do
    do_parse(string)
  end

  def parse(value) do
    {:error, "Correlation vector must be a string, got #{inspect(value)}."}
  end

  defp do_parse(string) do
    case infer_version(string) do
      {:ok, version} ->
        version.parse(string)

      # On failure try to parse as V2
      :error ->
        V2.parse(string)
    end
  end

  @doc """
  Gets the value of the correlation vector as a string.
  """
  @spec value(t()) :: String.t()
  def value(cv) do
    base = "#{cv.base_vector}.#{cv.extension}"

    if cv.immutable do
      base <> @termination_sign
    else
      base
    end
  end

  @spec infer_version(String.t()) :: {:ok, module()} | :error
  def infer_version(string) when is_binary(string) do
    case string |> String.split(".", parts: 2) do
      [base_vector, _extension] ->
        if version = @versions |> Enum.find(fn version -> version.inferable?(base_vector) end) do
          {:ok, version}
        else
          :error
        end

      _ ->
        :error
    end
  end

  def infer_version(_) do
    :error
  end

  @doc """
  Is the correlation vector immutable? Works on strings and structs.
  """
  @spec is_immutable?(t() | String.t()) :: boolean()
  def is_immutable?(string) when is_binary(string) do
    string |> String.ends_with?(@termination_sign)
  end

  def is_immutable?(%__MODULE__{} = cv) do
    cv.immutable
  end

  def is_immutable?(_) do
    false
  end

  def is_oversized?(%__MODULE__{} = cv) do
    is_oversized?(cv.base_vector, cv.extension, cv.version)
  end

  def is_oversized?(nil, _extension, _version) do
    false
  end

  def is_oversized?(base_vector, extension, version)
      when is_binary(base_vector) and is_number(extension) do
    version.is_oversized?(base_vector, extension)
  end

  def size(base_vector, extension) do
    String.length(base_vector) + 1 + extension_size(extension) + 1
  end

  defp extension_size(extension) when extension > 0 do
    extension
    |> :math.log10()
    |> floor
  end

  defp extension_size(_extension) do
    0
  end
end

defimpl String.Chars, for: CorrelationVector do
  alias CorrelationVector

  def to_string(cv) do
    CorrelationVector.value(cv)
  end
end
