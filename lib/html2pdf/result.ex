defmodule HTML2PDF.Result do
  @enforce_keys [:content_length, :content]
  defstruct @enforce_keys

  @type t :: %__MODULE__{content_length: non_neg_integer, content: Enumerable.t()}

  @spec new(non_neg_integer(), Enumerable.t()) :: t()
  def new(content_length, content) when content_length >= 0 do
    %__MODULE__{content_length: content_length, content: content}
  end
end
