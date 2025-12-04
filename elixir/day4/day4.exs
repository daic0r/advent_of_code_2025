defmodule Aoc2025.Day4 do
  @adj [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  def part1(input) do
    input
      |> Enum.map(fn {row_idx, row} ->
        row
          |> Enum.filter(fn {_idx, tile} -> tile == "@" end)
          |> Enum.map(fn {col_idx, _tile} ->
            @adj
              |> Enum.map(fn {dy, dx} ->
                adj_row = Map.get(input, row_idx + dy)
                if adj_row do
                  if Map.get(adj_row, col_idx + dx) == "@" do
                    1
                  else
                    0
                  end
                else
                  0
                end
              end)
              |> Enum.sum
          end)
          |> Enum.filter(& &1 < 4)
          |> length
      end)
      |> Enum.sum
  end

  def part2(input, input, original_input) do
    Enum.zip(input, original_input)
      |> Enum.map(fn {{_row_idx, row}, {_orig_row_idx, orig_row}} ->
        Enum.zip(row, orig_row)
          |> Enum.count(fn {{_col_idx, tile}, {_orig_col_idx, orig_tile}} ->
            tile != orig_tile
          end)
      end)
      |> Enum.sum
  end
  def part2(input, _prev_input, original_input) do
    transformed = input
      |> Enum.map(fn {row_idx, row} ->
        ret = row
          |> Enum.map(fn {col_idx, tile} ->
            num_adj = @adj
              |> Enum.map(fn {dy, dx} ->
                adj_row = Map.get(input, row_idx + dy)
                if adj_row do
                  if Map.get(adj_row, col_idx + dx) == "@" do
                    1
                  else
                    0
                  end
                else
                  0
                end
              end)
              |> Enum.sum

            if num_adj < 4 do
              {col_idx, "."} 
            else
              {col_idx, tile}
            end
          end)
          |> Enum.into(%{})
        {row_idx, ret}
      end)
      |> Enum.into(%{})

    part2(transformed, input, original_input)
  end
end

# input = "..@@.@@@@.
# @@@.@.@.@@
# @@@@@.@.@@
# @.@@@@..@.
# @@.@@@@.@@
# .@@@@@@@.@
# .@.@.@.@@@
# @.@@@.@@@@
# .@@@@@@@@.
# @.@.@@@.@."
input = File.read!("input.txt")
  |> String.split("\n")
  |> Stream.filter(&String.length(&1) > 0)
  |> Stream.map(&String.graphemes/1)
  |> Stream.with_index
  |> Stream.map(fn {row, idx} ->
    {Stream.with_index(row), idx}
  end)

map = for {row, row_idx} <- input, into: %{} do
  {row_idx, (for {tile, col_idx} <- row, into: %{}, do: {col_idx, tile})}
end

sol1 = Aoc2025.Day4.part1(map)
sol2 = Aoc2025.Day4.part2(map, nil, map)

IO.puts "Part 1: #{sol1}"
IO.puts "Part 2: #{sol2}"
