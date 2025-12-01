defmodule Aoc2025.Day1 do

  def part1(input) do
    input
    |> Enum.map(fn movement ->
      {dir, amount} = String.split_at(movement, 1)
      case dir do
        "L" -> -1 * String.to_integer(amount)
        "R" -> String.to_integer(amount)
      end
    end)
    |> Enum.reduce({50, []}, fn amount, {cur_pos, history} ->
      new_pos = Integer.mod(cur_pos + amount, 100)
      {new_pos, [new_pos | history]}
    end)
    |> elem(1)
    |> Enum.count(& &1 == 0)
  end

  def part2(input) do
    input
    |> Enum.map(fn movement ->
      {dir, amount} = String.split_at(movement, 1)
      case dir do
        "L" -> -1 * String.to_integer(amount)
        "R" -> String.to_integer(amount)
      end
    end)
    |> Enum.reduce({50, []}, fn amount, {cur_pos, history} ->
      new_pos = cur_pos + amount
      zero_crossings = abs(div(new_pos, 100))
      zero_crossings = if new_pos <= 0 and cur_pos != 0 do
        zero_crossings + 1
      else
        zero_crossings
      end
      {Integer.mod(new_pos, 100), [zero_crossings | history]}
    end)
    |> elem(1)
    |> Enum.sum
  end

end


# input = "L68
# L30
# R48
# L5
# R60
# L55
# L1
# L99
# R14
# L82"
#   |> String.split("\n")
#   |> Enum.filter(& String.length(&1) > 0)

input = File.read!("input.txt") 
  |> String.split("\n")
  |> Enum.filter(& String.length(&1) > 0)

sol1 = Aoc2025.Day1.part1(input)
sol2 = Aoc2025.Day1.part2(input)

IO.puts "Part 1: #{sol1}"
IO.puts "Part 2: #{sol2}"
