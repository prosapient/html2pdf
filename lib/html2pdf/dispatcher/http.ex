defmodule HTML2PDF.Dispatcher.HTTP do
  @behaviour HTML2PDF.Dispatcher
  require Logger

  @timeout :timer.seconds(20)

  @impl true
  def convert(html, options) do
    service_url()
    |> HTTPoison.post(
      %{
        body: html,
        options: map_options(options)
      }
      |> Jason.encode_to_iodata!(),
      [{"Content-Type", "application/json"}],
      recv_timeout: @timeout,
      stream_to: self()
    )
    |> case do
      {:ok, %HTTPoison.AsyncResponse{id: id}} ->
        receive do
          %HTTPoison.AsyncStatus{code: 200, id: ^id} -> {:ok, get_result(id)}
          %HTTPoison.AsyncStatus{code: _, id: ^id} -> :error
        after
          @timeout -> :error
        end

      {_, details} ->
        Logger.error(inspect(details))
        :error
    end
  end

  defp get_result(id) do
    receive do
      %HTTPoison.AsyncHeaders{headers: headers, id: ^id} ->
        HTML2PDF.Result.new(
          get_content_length!(headers),
          Stream.resource(
            fn ->
              id
            end,
            &next_chunk/1,
            fn _id -> :noop end
          )
        )
    end
  end

  defp get_content_length!(headers) do
    {"content-length", raw_content_length} =
      headers
      |> downcase_headers()
      |> List.keyfind("content-length", 0)

    String.to_integer(raw_content_length)
  end

  defp next_chunk(id) do
    receive do
      %HTTPoison.AsyncChunk{chunk: chunk, id: ^id} -> {[chunk], id}
      %HTTPoison.AsyncEnd{id: ^id} -> {:halt, id}
    after
      5000 -> raise "Timeout. Please ensure you don't run the same Stream twice."
    end
  end

  defp downcase_headers(headers) do
    Enum.map(headers, fn {header, value} -> {String.downcase(header), value} end)
  end

  @params_mapping %{
    scale: :scale,
    display_header_footer: :displayHeaderFooter,
    header_template: :headerTemplate,
    footer_template: :footerTemplate,
    print_background: :printBackground,
    landscape: :landscape,
    page_ranges: :pageRanges,
    format: :format,
    width: :width,
    height: :height,
    margin: :margin,
    prefer_css_page_size: :preferCSSPageSize
  }

  defp map_options(options) do
    options
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      case @params_mapping[key] do
        nil ->
          Logger.warn("Unsupported key #{inspect(key)}")
          acc

        new_key ->
          Map.put(acc, new_key, value)
      end
    end)
  end

  defp service_url do
    Application.fetch_env!(:html2pdf, __MODULE__)[:url]
  end
end
