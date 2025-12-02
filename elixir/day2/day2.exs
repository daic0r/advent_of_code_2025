defmodule Aoc2025.Day2 do

  def has_only_repeating_pattern(str_id, cur_pat \\ [], cur_comparison \\ [], in_pattern \\ false)
  def has_only_repeating_pattern("", cur_pat, cur_pat, _in_pattern) do
    true
  end
  def has_only_repeating_pattern("", cur_pat, cur_comp, _in_pattern) do
    false
  end
  def has_only_repeating_pattern(str_id, cur_pat, cur_comparison, in_pattern) do
    IO.inspect(cur_pat, label: "cur_pat")
    IO.inspect(cur_comparison, label: "cur_comparison")

    head = String.at(str_id, 0)
    tail = String.slice(str_id, 1..String.length(str_id))
    new_comparison = cur_comparison ++ [head]
    starts_with = List.starts_with?(cur_pat, new_comparison)
    if starts_with do
      has_only_repeating_pattern(tail, cur_pat, new_comparison, true) 
    else 
      if not in_pattern do
        IO.inspect(new_comparison, label: "THIS")
        has_only_repeating_pattern(tail, cur_pat ++ [head], [])
      else
        has_only_repeating_pattern(tail, cur_pat ++ [head], [head], true)
      end
    end
  end


  def check_range_for_invalid_ids(min_id, max_id, cur_id, out_invalid \\ [])
  def check_range_for_invalid_ids(min_id, max_id, cur_id, out_invalid) when cur_id == max_id + 1 do
    out_invalid
  end
  def check_range_for_invalid_ids(min_id, max_id, cur_id, out_invalid) do
    res =
      if has_only_repeating_pattern(Integer.to_string(cur_id)) do
        [cur_id | out_invalid]
      else
        out_invalid
      end
    check_range_for_invalid_ids(min_id, max_id, cur_id + 1, res)
  end

  def check_range_simple(min_id, max_id, cur_id, out_invalid \\ [])
  def check_range_simple(min_id, max_id, cur_id, out_invalid) when cur_id == max_id + 1 do
    out_invalid
  end
  def check_range_simple(min_id, max_id, cur_id, out_invalid) do
    cur_id_str = Integer.to_string(cur_id)
    str_len = String.length(cur_id_str)
    if Integer.mod(str_len, 2) != 0 do
      check_range_simple(min_id, max_id, cur_id + 1, out_invalid)
    end
    {a, b} = String.split_at(cur_id_str, div(str_len, 2))
    if a == b do
      check_range_simple(min_id, max_id, cur_id + 1, [cur_id | out_invalid])
    else
      check_range_simple(min_id, max_id, cur_id + 1, out_invalid)
    end
  end


  def part1(input) do
    input  
    |> Enum.filter(fn {min, max} ->
      Integer.mod(String.length(min), 2) == 0 or Integer.mod(String.length(max), 2) == 0
    end)
    |> Enum.map(fn {min, max} ->
      min_int = String.to_integer(min)
      max_int = String.to_integer(max)
      diff = String.to_integer(String.slice(max, 1..String.length(max)))
      lower_bound = 
        if Integer.mod(String.length(min), 2) == 1 do
          max_int - diff
        else
          min_int 
        end
      upper_bound =
        if Integer.mod(String.length(max), 2) == 1 do
          max_int - diff - 1
        else
          max_int
        end
      {lower_bound, upper_bound}
    end)
    |> IO.inspect
    |> Enum.flat_map(fn {min_id, max_id} ->
      check_range_simple(min_id, max_id, min_id)
    end)
    |> Enum.sum
  end

  def part2(input) do
    input
    |> Enum.map(fn {min, max} ->
      {String.to_integer(min), String.to_integer(max)}
    end)
    |> Enum.flat_map(fn {min, max} ->
      check_range_for_invalid_ids(min, max, min) 
    end)
    |> IO.inspect
    |> Enum.sum
  end
  
end


input="11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
#input = File.read!("input.txt")
  |> String.trim_trailing("\n")
  |> String.split(",")
  |> Enum.map(fn rng ->
    [min, max] = String.split(rng, "-")
    {min, max}
  end)

sol1 = Aoc2025.Day2.part1(input)
sol2 = Aoc2025.Day2.part2(input)

IO.puts "Part 1: #{sol1}"
IO.puts "Part 2: #{sol2}"
