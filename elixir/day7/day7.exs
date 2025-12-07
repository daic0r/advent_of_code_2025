defmodule Aoc2025.Day7 do

  def find_start(input) do
    input
      |> Enum.find_value(nil, fn {row_idx, line} ->
        col = Enum.find(line, nil, fn {col_idx, ch} -> ch == "S" end)
        if col do
          {row_idx, elem(col, 0)}
        else
          nil
        end
      end)
  end

  def part1(input, beams \\ [], splits \\ 0)
  def part1(input, [], splits) do
    start = find_start(input)
    part1(input, [start], splits)
  end
  def part1(input, beams, splits) do
    # Current beam positions will be at the head of the list
    {next_beams, splits} = for {row, col} when row+1 < map_size(input) <- beams, reduce: {[], splits} do
      {tmp, sp} ->
        next = Map.get(Map.get(input, row + 1), col)
        case next do
          "." -> {[{row + 1, col} | tmp], sp}
          "^" -> {[{row + 1, col - 1}, {row + 1, col + 1} | tmp], sp + 1}
        end
    end

    next_beams = next_beams
      |> Enum.dedup

    if length(next_beams) > 0 do
      part1(input, next_beams, splits)
    else  
      splits
    end
  end


  def part2(input, start, memo \\ %{})
  def part2(input, {y, x}, memo) when y == map_size(input)-1 do
    {1, Map.put(memo, {y, x}, 1)}
  end
  def part2(input, {y, x}, memo) do
    splits = Map.get(memo, {y, x})

    if splits == nil do
      ch = Map.get(Map.get(input, y), x)
      case ch do
        ch when ch in [".", "S"] -> part2(input, {y + 1, x}, memo)
        "^" -> 
          {splits_left, left} = part2(input, {y + 1, x - 1}, memo)
          {splits_right, right} = part2(input, {y + 1, x + 1}, left)
          sum = splits_left + splits_right
          merged_map = Map.merge(left, right)
          {sum, Map.put(merged_map, {y, x}, sum)}
      end 
    else
      {splits, memo}
    end
  end
  
end

# input = ".......S.......
# ...............
# .......^.......
# ...............
# ......^.^......
# ...............
# .....^.^.^.....
# ...............
# ....^.^...^....
# ...............
# ...^.^...^.^...
# ...............
# ..^...^.....^..
# ...............
# .^.^.^.^.^...^.
# ..............."
input = File.read!("input.txt")
  |> String.split("\n")
  |> Enum.filter(&String.length(&1) > 0)
  |> Enum.map(fn line ->
    line
      |> String.graphemes
      |> Enum.with_index
      |> Enum.map(fn {ch, idx} -> {idx, ch} end)
      |> Enum.into(%{})
  end)
  |> Enum.with_index
  |> Enum.map(fn {line, idx} -> {idx, line} end)
  |> Enum.into(%{})
  |> IO.inspect

sol1 = Aoc2025.Day7.part1(input)
IO.puts "Part 1: #{sol1}"

{sol2, _} = Aoc2025.Day7.part2(input, Aoc2025.Day7.find_start(input))
IO.puts "Part 2: #{sol2}"
