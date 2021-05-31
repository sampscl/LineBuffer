defmodule LineBuffer do
  @moduledoc """
  Buffer lines like a boss.
  """

  defmodule State do
    @typedoc """
    `%State{}`'s type
    """
    @type t :: %__MODULE__{}
    @doc false
    defstruct [
      splitter: "\n",
      buf: "",
    ]
  end

  @spec new(String.t()) :: State.t()
  @doc ~S"""
  Create a new line buffer

  ## Parameters
  - splitter: A string to use to split input into lines. Pass nil to use the default "\n"

  ## Returns
  `%State{}` that is the first parameter to all other module functions.

  ## Examples
  ```elixir
    # Default construction
    iex> LineBuffer.new()
    %LineBuffer.State{buf: "", splitter: "\n"}

    # Specific splitter
    iex> LineBuffer.new("\r\n")
    %LineBuffer.State{buf: "", splitter: "\r\n"}
  ```
  """
  def new(splitter \\ "\n"), do: %State{splitter: splitter}

  @spec add_data(State.t(), String.t()) :: {State.t(), [String.t()]}
  @doc ~S"""
  Add data to a line buffer

  ## Parameters
  - state: An initialized `%State{}`
  - new_data: A `String.t()` to use to split input into lines, defaults to `"\n"`

  ## Returns
  `{updated_state, [line_without_delimiter]}`

  ## Examples
  ```elixir
  iex> lb = LineBuffer.new()
  %LineBuffer.State{buf: "", splitter: "\n"}
  iex> LineBuffer.add_data(lb, "foo\n")
  {%LineBuffer.State{buf: "", splitter: "\n"}, ["foo"]}

  iex> lb = LineBuffer.new()
  %LineBuffer.State{buf: "", splitter: "\n"}
  iex> LineBuffer.add_data(lb, "foo\nbar")
  {%LineBuffer.State{buf: "bar", splitter: "\n"}, ["foo"]}

  iex> lb = LineBuffer.new()
  %LineBuffer.State{buf: "", splitter: "\n"}
  iex> LineBuffer.add_data(lb, "foo\nbar\n")
  {%LineBuffer.State{buf: "", splitter: "\n"}, ["foo", "bar"]}
  ```
  """
  def add_data(state, new_data) do
    working_buf = state.buf <> new_data
    #IO.puts("working_buf: #{inspect working_buf}")
    split_result = String.split(working_buf, state.splitter, trim: false)
    #IO.puts("split_result: #{inspect split_result}")
    {new_buf, lines} = List.pop_at(split_result, -1)
    #IO.puts("{new_buf, lines}: #{inspect {new_buf, lines}}")
    case {new_buf, lines} do
      {"" = _buf, [] = lines} -> {state, lines}              # had no data, added no data
      {"" = buf, lines}       -> {%{state| buf: buf}, lines} # ended up with one or more complete lines
      {buf, [] = lines}       -> {%{state| buf: buf}, lines} # ended up with more data but no complete lines
      {buf, lines}            -> {%{state| buf: buf}, lines} # ended up with more data and one or more complete lines
    end
  end

  @spec peek(State.t()) :: String.t()
  @doc ~S"""
  Get the current string being buffered.

  ## Parameters
  - state: An initialized `%State{}`

  ## Returns
  `String.t()`

  ## Examples
  ```elixir
    iex> lb = LineBuffer.new()
    %LineBuffer.State{buf: "", splitter: "\n"}
    iex> {updated_lb, _} = LineBuffer.add_data(lb, "foo\nbar")
    {%LineBuffer.State{buf: "bar", splitter: "\n"}, ["foo"]}
    iex> LineBuffer.peek(updated_lb)
    "bar"
  ```
  """
  def peek(state), do: state.buf

  @spec flush(State.t()) :: {State.t(), String.t()}
  @doc ~S"""
  Flush (empty) the buffer.

  ## Parameters
  - state: An initialized `%State{}`

  ## Returns
  New and emptied state and the old buffered data: `{%State{}, String.t}`

  ## Examples
  ```elixir
    iex> lb = LineBuffer.new()
    %LineBuffer.State{buf: "", splitter: "\n"}
    iex> {updated_lb, _} = LineBuffer.add_data(lb, "foo\nbar")
    {%LineBuffer.State{buf: "bar", splitter: "\n"}, ["foo"]}
    iex> LineBuffer.flush(updated_lb)
    {%LineBuffer.State{buf: "", splitter: "\n"}, "bar"}
  ```
  """
  def flush(state), do: {%{state| buf: ""}, state.buf}

  @spec get_splitter(State.t()) :: String.t()
  @doc ~S"""
  Get the splitter from state

  ## Parameters
  - state: An initialized `%State{}`

  ## Returns
  The splitter from state (a `String.t()`)

  ## Examples
  ```elixir
    iex> lb = LineBuffer.new()
    %LineBuffer.State{buf: "", splitter: "\n"}
    iex> LineBuffer.get_splitter(lb)
    "\n"
  ```
  """
  def get_splitter(state), do: state.splitter

  @spec set_splitter(State.t(), String.t()) :: {State.t(), [String.t()]}
  @doc ~S"""
  Set the splitter.

  Changing the splitter may cause new lines to be returned
  that were not considered lines before. Therefore this function is roughly
  equivalent to creating a new LineBuffer and adding the old line buffer's
  data to it.

  ## Parameters
  - state: An initialized `%State{}`
  - splitter: A string to use as the new splitter/delimiter

  ## Returns
  `{state, [line_without_delimiter]}`

  ## Examples
  ```elixir
    iex> lb = LineBuffer.new("\r\n")
    %LineBuffer.State{buf: "", splitter: "\r\n"}
    iex> {updated_lb, _} = LineBuffer.add_data(lb, "foo\nbar\n")
    {%LineBuffer.State{buf: "foo\nbar\n", splitter: "\r\n"}, []}
    iex> LineBuffer.set_splitter(updated_lb, "\n")
    {%LineBuffer.State{buf: "", splitter: "\n"}, ["foo", "bar"]}
  ```
  """
  def set_splitter(state, splitter) do
    splitter
    |> new()
    |> add_data(state.buf)
  end
end
