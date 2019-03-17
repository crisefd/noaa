defmodule Noaa.CLI do
  require Logger
  import Enum, only: [sort: 1]
  alias Noaa.TableFormatter, as: TableFormatter
  alias Noaa.NoaaData, as: Data

  @moduledoc """
    Handle the command line parsing and the dispatch to the various
    functions that end up generating a table of the last
   noaa updates
  """
  def main(argv) do
    argv
    |> parse_args
    |> process
    |> sort_location_data
    |> print_data
  end

  @doc """
    ´argv´ can be -h or --help, which returns :help.

  """
  def parse_args(argv) do
    {parsed, args, _} =
      OptionParser.parse(argv,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    args_to_internal_representation(parsed, args)
  end

  def process(:help) do
    IO.puts("""
      usage: noaa location1 [location2]
    """)

    System.halt(0)
  end

  def process(locations) do
    Data.fetch(locations) |> decode_response
  end

  defp print_data(location_data) do
    location_data |> TableFormatter.print_table(Data.data_columns())
  end

  defp decode_response({:error, _}) do
    IO.puts("Error fetching data")
    System.halt(2)
  end

  defp decode_response(body) do
    body
  end

  defp args_to_internal_representation([help: true], _) do
    :help
  end

  defp args_to_internal_representation(_, []), do: :help

  defp args_to_internal_representation(_, locations) when is_list(locations) do
    locations
  end

  defp args_to_internal_representation(_, locations) do
    IO.inspect(locations)
    [locations]
  end

  def sort_location_data(location_data) do
    sort(location_data)
  end
end
