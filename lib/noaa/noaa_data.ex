defmodule Noaa.NoaaData do
  require Logger
  import Enum, only: [reduce: 3, at: 2, map: 2]
  import Map, only: [put: 3, merge: 2]
  import String, only: [split: 2, upcase: 1]

  @noaa_url Application.get_env(:noaa, :noaa_url)

  @columns_names Application.get_env(:noaa, :noaa_columns)

  @user_agent [{"User-agent", "crisefd"}]

  def fetch(locations) do
    Logger.info(fn -> "Fetching data for locations: #{inspect(locations)}" end)

    locations
    |> reduce(%{}, fn location, acc ->
      data =
        location
        |> data_url
        |> HTTPoison.get(@user_agent)
        |> handle_response

      upcased_location = upcase(location)
      put(acc, upcased_location, data)
    end)
  end

  def data_columns(), do: @columns_names

  defp data_url(location), do: "#{@noaa_url}#{location}.xml"

  defp handle_response({_, %{status_code: status_code, body: body}}) do
    Logger.info("Got response: status code=#{status_code}")
    check_for_errors(status_code, body)
  end

  defp check_for_errors(200, body), do: body |> parse_data

  defp check_for_errors(_, body) do
    Logger.error(fn -> "Error response: #{inspect(body)}" end)
    {:error, body}
  end

  def parse_data(data) do
    parsed_col_data = map(@columns_names, fn {c, _} -> c end)

    data
    |> parse_columns_data(parsed_col_data)
  end

  def parse_columns_data(data, field_names) do
    field_names
    |> reduce(
      %{},
      fn field_name, acc ->
        extracted_field = data |> extract_field(field_name)
        merge(acc, extracted_field)
      end
    )
  end

  def extract_field(data, field_name) do
    opening_tag_exp = "<#{field_name}>"
    ending_tag_exp = "</#{field_name}>"

    field_value =
      data
      |> split(opening_tag_exp)
      |> at(1)
      |> split(ending_tag_exp)
      |> at(0)

    put(%{}, field_name, field_value)
  end
end
