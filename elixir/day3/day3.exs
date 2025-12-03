defmodule Aoc2025.Day3 do

  def part1(input) do
    input
      |> Enum.map(fn bank ->
        digits = Enum.map(bank, fn digit -> 
          String.to_integer(digit)
        end)
          |> Enum.with_index()

        max_1 = digits
          |> Enum.take(length(digits) - 1)
          |> Enum.max_by(& elem(&1, 0))
        max_2 = digits
          |> Enum.drop(elem(max_1, 1) + 1)
          |> Enum.max_by(& elem(&1, 0))

        (10 * elem(max_1, 0)) + elem(max_2, 0)
      end)
      |> Enum.sum
  end

  def part2(input) do
    input
      |> Enum.map(fn bank ->
        digits = Enum.map(bank, fn digit -> 
          String.to_integer(digit)
        end)
          |> Enum.with_index()

        {_, _, _, number} = 
          Enum.reduce(digits, {0, length(digits)-11, 11, 0}, fn {digit, idx}, {from, to, exponent, number} ->
            if idx >= from do
              max = Enum.max_by(digits |> Enum.drop(from) |> Enum.take(to-from), & elem(&1, 0))
              {elem(max, 1) + 1, to + 1, exponent - 1, number + trunc(:math.pow(10, exponent)) * elem(max, 0) }
            else
              {from, to, exponent, number}
            end
          end)

        number
      end)
      |> Enum.sum
  end
  
end

# input = "987654321111111
# 811111111111119
# 234234234234278
# 818181911112111"
input = File.read!("input.txt")
  |> String.split("\n")
  |> Enum.filter(& String.length(&1) > 0)
  |> Enum.map(& String.graphemes/1)

sol1 = Aoc2025.Day3.part1(input)
sol2 = Aoc2025.Day3.part2(input)

IO.puts "Part 1: #{sol1}"
IO.puts "Part 2: #{sol2}"
