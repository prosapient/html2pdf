defmodule HTML2PDF.Dispatcher do
  @callback convert(HTML2PDF.html(), [HTML2PDF.option()]) :: {:ok, HTML2PDF.Result.t()} | :error
end
