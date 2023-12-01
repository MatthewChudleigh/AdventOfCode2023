# On each line, the calibration value can be found by combining the
# first digit
# last digit (in that order) to form a single two-digit number.

# In example, the calibration values of the four lines are 12, 38, 15, and 77. Adding these together produces 142.

defmodule FileProcessor do
  def process_file(file_path) do

    result =
      File.stream!(file_path)
      |> Enum.map(fn line -> String.trim(line) end)
      |> Enum.map(&process_line/1)
      |> Enum.reduce(%{total: 0}, fn result, agg ->
        case agg do
          %{total: total} ->
            case sum_total(result) do
              {:ok, result_total} -> %{total: total + result_total}
              other -> other
            end
          other -> other
        end
      end)

    case result do
      %{total: total} -> IO.puts(total)
      other -> IO.inspect(other)
    end

    :ok

  end

  defp sum_total(result) do
    case result do
      {:ok, _, %{head: head, tail: tail}} ->
        {:ok, head*10 + tail}
      {:ok, list, _} ->
        {:error, "Missing numbers in #{list}"}
      other ->
        other
    end
  end

  defp process_line(line) do
    # IO.puts("Line: #{line}")
    list = String.graphemes(line)
    iterate_list(list, 0, length(list) - 1, %{})
  end

  defp iterate_list(list, head, tail, numbers) when head <= tail and Kernel.map_size(numbers) < 2 do
    # list, head)}, Tail: #{Enum.at(list, tail)}")

    {head, numbers} = case try_map_number(list, :head, head, numbers) do
      {:ok, numbers} -> {head, numbers}
      _ -> {head+1, numbers}
    end

    {tail, numbers} = case try_map_number(list, :tail, tail, numbers) do
      {:ok, numbers} -> {tail, numbers}
      _ -> {tail-1, numbers}
    end

    iterate_list(list, head, tail, numbers)
  end

  defp iterate_list(list, head, tail, numbers) when head >= tail and length(numbers) < 2 do
    {:error, "Could not find numbers in #{list}"}
  end

  defp iterate_list(list, _, _, numbers) do
    {:ok, list, numbers}
  end

  defp try_map_number(list, id, index, numbers) do
    case numbers[id] do
      nil ->
        case try_find_number(list, index) do
          {:ok, number} -> {:ok, Map.put(numbers, id, number)}
          other -> other
        end
      _ -> {:ok, numbers}
    end
  end

  defp try_find_number(list, index) do
    case Enum.at(list, index) do
      nil -> {:error, "Invalid Index"}
      element ->
        case Integer.parse(element) do
          {number, ""} -> {:ok, number}
          _ -> {:error, "Not a number"}
        end
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
