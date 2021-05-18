defmodule HTML2PDF do
  @typedoc """
  Number with units

  All possible units are:

  * `px` - pixel
  * `in` - inch
  * `cm` - centimeter
  * `mm` - millimeter

  Examples: `"10px"`, `"20in"`

  If number is specified then pixels are used by default.
  """
  @type number_with_units :: number() | String.t()

  @typedoc """
  Format of the document

  One of the following values:
    Letter, Legal, Tabloid, Ledger, A0, A1, A2, A3, A4, A5, A6
  """
  @type format :: String.t()

  @typedoc """
  HTML document
  """
  @type html :: String.t()

  @typedoc """
  PDF options

  Detailed information:
  https://github.com/GoogleChrome/puppeteer/blob/v1.11.0/docs/api.md#pagepdfoptions
  """
  @type option ::
          {:scale, number()}
          | {:display_header_footer, boolean()}
          | {:header_template, html()}
          | {:footer_template, html()}
          | {:print_background, boolean()}
          | {:landscape, boolean()}
          | {:page_ranges, String.t()}
          | {:format, format()}
          | {:width, number_with_units()}
          | {:height, number_with_units()}
          | {:margin,
             %{
               top: number_with_units(),
               left: number_with_units(),
               right: number_with_units(),
               bottom: number_with_units()
             }}
          | {:prefer_css_page_size, boolean()}

  @spec convert(html(), [option]) ::
          {:ok, HTML2PDF.Result.t()} | :error
  def convert(html, opts \\ []) do
    dispatcher().convert(html, opts)
  end

  defp dispatcher do
    Application.get_env(:html2pdf, :dispatcher) || HTML2PDF.Dispatcher.HTTP
  end
end
