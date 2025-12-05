defmodule Aoc2025.Day5 do
  def part1(fresh, available) do
    available
      |> Enum.count(fn id ->
        Enum.any?(fresh, fn {min,max} -> id in min..max end) 
      end)
  end

  def merge_ranges({min1, max1}, {min2, max2}) do
    cond do
      min1 < min2 and max1 < min2 -> [{min1, max1}, {min2, max2}]
      min1 > max2 and max1 > max2 -> [{min2, max2}, {min1, max1}]
      min1 <= min2 and max1 >= max2 -> [{min1, max1}]
      min1 <= max2 and min1 >= min2 -> [{min2, max(max1, max2)}]
      max1 <= max2 and max1 >= min2 -> [{min(min1, min2), max2}]
    end
  end

  def part2(fresh, drop \\ 0)
  def part2(fresh, drop) when drop == length(fresh) do
    fresh 
      |> Enum.map(fn {min, max} -> Range.size(min..max) end)
      |> Enum.sum
  end
  def part2(fresh, drop) when drop == length(fresh)-1 do
    part2(fresh, drop + 1)
  end
  def part2(fresh, drop) do
    head = fresh |> Enum.take(drop)
    tail = fresh |> Enum.drop(drop)
    [rng1, rng2] = tail |> Enum.take(2)
    suffix = Enum.drop(tail, 2)
    merged = merge_ranges(rng1, rng2)
    if length(merged) == 2 do
      part2(head ++ merged ++ suffix, drop + 1)
    else
      part2(head ++ merged ++ suffix, drop)
    end
  end
  
end

# [fresh, available] = "3-5
# 10-14
# 16-20
# 12-18
#
# 1
# 5
# 8
# 11
# 17
# 32"
[fresh, available] = File.read!("input.txt")
  |> String.split("\n\n")

fresh = fresh
  |> String.split("\n")
  |> Enum.map(fn rng ->
    [[min, max]] = Regex.scan(~r/(\d+)-(\d+)/, rng, capture: :all_but_first)
    {String.to_integer(min), String.to_integer(max)}
  end)
  |> Enum.sort_by(& elem(&1, 0))
  |> IO.inspect

available = available
  |> String.split("\n")
  |> Enum.filter(& String.length(&1) > 0)
  |> Enum.map(&String.to_integer/1)


sol1 = Aoc2025.Day5.part1(fresh, available)
sol2 = Aoc2025.Day5.part2(fresh)
IO.puts "Part 1: #{sol1}"
IO.puts "Part 2: #{sol2}"
