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

    IO.puts("Result:")
    case result do
      %{total: total} -> IO.puts(total)
      other -> IO.inspect(other)
    end

    :ok

  end

  defp sum_total(result) do
    # IO.inspect(result)
    case result do
      {:ok, %{head: head, tail: tail}} ->
        {:ok, head*10 + tail}
      other ->
        other
    end
  end

  defp process_line(line) do
    # IO.puts("Line: #{line}")
    list = String.graphemes(line)
    iterate_list(list, 0, length(list) - 1, %{head_part: "", tail_part: ""})
  end

  defp iterate_list(_, _, _, %{head: head, tail: tail}) do
    {:ok, %{head: head, tail: tail}}
  end

  defp iterate_list(list, head, tail, numbers) when tail >= 0 and head < length(list) do
    #  IO.puts("Head: #{Enum.at(list, head)}, Tail: #{Enum.at(list, tail)}")

    # IO.puts("Head:")
    {head, numbers} = case try_map_number(list, :head, numbers[:head_part], head, numbers) do
      {:ok, numbers} -> {head, numbers}
      {:partial, part} -> {head+1, Map.put(numbers, :head_part, part)}
      _ -> {head+1, numbers}
    end

    # IO.puts("Tail:")
    {tail, numbers} = case try_map_number(list, :tail, numbers[:tail_part], tail, numbers) do
      {:ok, numbers} -> {tail, numbers}
      {:partial, part} -> {tail-1, Map.put(numbers, :tail_part, part)}
      _ -> {tail-1, numbers}
    end

    iterate_list(list, head, tail, numbers)
  end

  defp iterate_list(list, _, _, numbers) do
    {:error, "Could not find numbers in #{list}", numbers}
  end

  defp try_map_number(list, id, part, index, numbers) do
    case numbers[id] do
      nil ->
        case try_find_number(list, part, index) do
          {:ok, number} -> {:ok, Map.put(numbers, id, number)}
          {:partial, part} -> {:partial, part}
          {:error, error} -> {:error, error}
        end
      _ -> {:ok, numbers}
    end
  end

  defp try_find_number(list, part, index) do
    with {:ok, element} <- safe_element_at(list, index),
         {:ok, number} <- parse_number_or_concat(part, element) do
      {:ok, number}
    else
      :error -> {:error, "Invalid Index"}
      {:partial, partial} -> {:partial, partial}
    end
  end

  defp safe_element_at(list, index), do: Enum.fetch(list, index)

  defp parse_number_or_concat(part, element) do
    case Integer.parse(element) do
      {number, ""} -> {:ok, number}
      _ -> try_find_number_word(part, element)
    end
  end

  # Placeholder for the try_find_number_word function
  defp try_find_number_word(part, element) do
    case try_find_number_word(part <> element) do
      {:ok, number} -> {:ok, number}
      {:partial, word} -> {:partial, word}
      :no_match -> {:partial, element}
    end
  end

  defp try_find_number_word(word) do
    # IO.puts("\t#{word}")

    number_words = [
      "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
      "eno", "owt", "eerht", "ruof", "evif", "xis", "neves", "thgie", "enin"
    ]

    case word do
      "one" -> {:ok, 1}
      "two" -> {:ok, 2}
      "three" -> {:ok, 3}
      "four" -> {:ok, 4}
      "five" -> {:ok, 5}
      "six" -> {:ok, 6}
      "seven" -> {:ok, 7}
      "eight" -> {:ok, 8}
      "nine" -> {:ok, 9}
      "eno" -> {:ok, 1}
      "owt" -> {:ok, 2}
      "eerht" -> {:ok, 3}
      "ruof" -> {:ok, 4}
      "evif" -> {:ok, 5}
      "xis" -> {:ok, 6}
      "neves" -> {:ok, 7}
      "thgie" -> {:ok, 8}
      "enin" -> {:ok, 9}
      _ ->
        if Enum.any?(number_words, fn number_word -> String.starts_with?(number_word, word) end) do
          {:partial, word}
        else
          case String.length(word) do
            1 -> :no_match
            length -> try_find_number_word(String.slice(word, 1, length - 1))
          end
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
