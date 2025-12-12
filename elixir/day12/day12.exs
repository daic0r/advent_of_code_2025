defmodule Aoc2025.Day12 do

  def part1(pieces, areas) do
    areas 
      |> Enum.map(fn {area, pieces_to_fit} ->
        required_area = Enum.reduce(pieces_to_fit |> Enum.with_index(), 0, fn {piece_count, piece_idx}, acc ->
          acc + Map.get(pieces, piece_idx) * piece_count
        end)
        required_area <= area
      end)
      |> Enum.count(& &1 == true)
  end
  
end

# input = "0:
# ###
# ##.
# ##.
#
# 1:
# ###
# ##.
# .##
#
# 2:
# .##
# ###
# ##.
#
# 3:
# ##.
# ###
# ##.
#
# 4:
# ###
# #..
# ###
#
# 5:
# ###
# .#.
# ###
# ----
# 4x4: 0 0 0 0 2 0
# 12x5: 1 0 1 0 2 2
# 12x5: 1 0 1 0 3 2"

input = File.read!("input.txt")
# Inserted seperator ---- to facilitate parsing
[pieces, areas] = String.split(input, "----\n")
pieces = pieces
  |> String.split("\n\n")
  |> Enum.with_index()
  |> Enum.map(fn {piece_str, idx} ->
    {idx, piece_str
      |> String.split("\n")
      |> Enum.drop(1)
      |> Enum.map(fn row ->
        row
          |> String.graphemes()
          |> Enum.count(& &1 == "#")
      end)
      |> Enum.sum}
  end)
  |> Enum.into(%{})

areas = areas
  |> String.split("\n")
  |> Enum.filter(& String.length(&1) > 0)
  |> Enum.map(fn area_str ->
    [area, pieces] = String.split(area_str, ":")
    [width, height] = String.split(area, "x")
    {String.to_integer(width)*String.to_integer(height), pieces
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    }
  end)

sol1 = Aoc2025.Day12.part1(pieces, areas)
IO.puts "Part 1: #{sol1}"
