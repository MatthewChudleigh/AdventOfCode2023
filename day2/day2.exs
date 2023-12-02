# Which games possible if the bag contained only:
# 12 red cubes
# 13 green cubes
# 14 blue cubes

# Fewest number of cubes of each color

defmodule FileProcessor do
  def process_file(file_path) do

    result =
      File.stream!(file_path)
      |> Enum.map(fn line -> String.trim(line) end)
      |> Enum.map(&process_line/1)
      |> Enum.reduce({:total, 0}, fn result, agg ->
        case agg do
          {:total, total} ->
            case max_power(result) do
              {:ok, result_total} -> {:total, total + result_total}
              other -> other
            end
          other -> other
        end
      end)

    case result do
      {:total, total} -> IO.puts(total)
      other -> IO.inspect(other)
    end
  end

  defp max_power({:ok, _, selections}) do
    selections
    |> Enum.reduce(%{green: 0, red: 0, blue: 0}, fn %{green: green, red: red, blue: blue}, %{green: max_green, red: max_red, blue: max_blue} ->
      %{green: max(green, max_green), red: max(red, max_red), blue: max(blue, max_blue)}
    end)
    |> Kernel.then(fn %{green: green, red: red, blue: blue} -> {:ok, green*red*blue} end)
  end

  defp process_line(line) do
    case String.split(line, ":") do
      [game, selections] ->
        ["Game", game] = String.split(game)
        {game, ""} = Integer.parse(game)
        result = Enum.map(String.split(selections, ";"), &process_selection/1)
        {:ok, game, result}
      other ->
        {:error, "Unexpected match", other}
    end
  end

  defp process_selection(selections) do
    String.split(selections, ",")
    |> Enum.reduce(%{blue: 0, red: 0, green: 0}, fn selection, total ->
      case total do
        {:error, error} -> {:error, error}
        total ->
        case String.split(String.trim(selection), " ") do
          [n, "blue"] -> update_map(total, :blue, n)
          [n, "red"] -> update_map(total, :red, n)
          [n, "green"] -> update_map(total, :green, n)
          _ -> total
        end
      end
    end)
  end

  defp update_map(total, key, n) do
    {result, map} = Map.get_and_update(total, key, fn t ->
      case Integer.parse(n) do
        {number, _} -> {n, t + number}
        _ -> {{:error, "Not a number #{n}"}, 0}
      end
    end)

    case result do
      {:error, error} -> {:error, error}
      _ -> map
    end
  end

end

case Enum.at(System.argv(), 0) do
  nil -> :ok
  file_path ->
    if File.exists?(file_path) do
      FileProcessor.process_file(file_path)
    end
  other -> IO.inspect(other)
end
