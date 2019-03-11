defmodule Noaa.TableFormatter do
  require Logger
  import Enum, only: [ max_by: 2, each: 2 ]
  import String, only: [ pad_leading: 2]
  import Map, only: [ get: 2]

  def print_table(location_data, columns) do
    Logger.info("printing table")
    location_data
    |> each(fn {location, data} ->
          format_data({location, data}, columns)
         end)
  end

  defp format_data({ location, :error }, _) do
    IO.puts("Error formatting data for location #{location}")
  end

  defp format_data({ location, body }, columns) do
    { _, label } = columns |> max_by(fn {_, label} -> String.length(label)  end)
    max_width = String.length(label)
    IO.puts separator(max_width)
    IO.puts "Weather of #{location} from NOAA"
    each(columns,
         fn {field, label} ->
          IO.puts "#{pad_leading(label, max_width)} #{printable(get(body, field))}"
         end)
  end

  defp printable(str) when is_binary(str), do: str
  defp printable(str), do: to_string(str)

  defp separator(width) do
    List.duplicate("-", width)
  end

end
