defmodule Aoc2025.Day9 do

  def area({x1, y1}, {x2, y2}) do
    (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
  end

  def determine_areas(input, out \\ :ets.new(:areas, [:ordered_set]))
  def determine_areas([], out) do
    out
  end
  def determine_areas(input, out) do
    [{x,y} | tail] = input
    Enum.each(tail, fn {x2, y2} ->
      area = area({x,y},{x2,y2})
      :ets.insert(out, {area, {{x, y}, {x2,y2}}})
    end)
    determine_areas(tail, out)
  end

  def part1(input) do
    areas = input |> determine_areas
    [{area, _}] = :ets.take(areas, :ets.last(areas))
    area
  end
  
end

# input = "7,1
# 11,1
# 11,7
# 9,7
# 9,5
# 2,5
# 2,3
# 7,3"
input = File.read!("input.txt")
  |> String.split("\n")
  |> Enum.filter(&String.length(&1) > 0)
  |> Enum.map(fn str ->
    [x,y] = String.split(str, ",")
    {String.to_integer(x), String.to_integer(y)} 
  end)
  |> IO.inspect

sol1 = Aoc2025.Day9.part1(input)
IO.puts "Part 1: #{sol1}"
