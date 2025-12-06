defmodule Aoc2025.Day6 do
  def calculate_problem(problem) when is_list(problem) do
    op = hd(problem) 
    acc_init =
      case op do
        "*" -> 1
        "+" -> 0
      end
    problem
      |> Enum.drop(1)
      |> Enum.reduce(acc_init, fn x, acc ->
        case op do
          "*" -> acc * String.to_integer(x)
          "+" -> acc + String.to_integer(x)
        end
      end)
  end

  def part1(input, num_problems, idx \\ 0, acc \\ 0)
  def part1(_input, num_problems, num_problems, acc) do
    acc
  end
  def part1(input, num_problems, idx, acc) do
    res = input 
      |> Enum.drop(idx)
      |> Enum.take_every(num_problems)
      |> Enum.reverse
      |> calculate_problem
    part1(input, num_problems, idx + 1, acc + res)
  end
  
    
  def part2(input) do
    {line_len, _} = :binary.match(input, "\n")

    nums_per_problem = input
      |> String.split("\n")
      |> Enum.filter(& String.length(&1) > 0)
      |> length
    # Subtract one for the line containing the operators
    nums_per_problem = nums_per_problem - 1

    input
      |> String.graphemes
      |> Enum.chunk_every(line_len+1)
      |> Enum.zip
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.chunk_by(fn col -> Enum.all?(col, & &1 == " ") end)
      |> Enum.filter(& length(&1) > 1) # Filter out the separating columns
      |> Enum.map(fn cols ->
          op = cols |> hd |> List.last
          {op_fn, init} = case op do
            "+" -> {&+/2, 0}
            "*" -> {&*/2, 1}
          end
          # Drop the last row that only contains the operator, remove empty columns,
          # then stringify the column list and convert into an integer
          {{op_fn, init}, 
            cols 
              # Filter out last column
              |> Enum.filter(fn rows -> !Enum.any?(rows, & &1 == "\n") end)
              |> Enum.map(fn rows -> 
                rows
                  |> Enum.take(nums_per_problem)
                  |> Enum.filter(& &1 != " ")
                  |> Enum.join 
                  |> String.to_integer 
                end)
            }
        end)
      |> Enum.map(fn {{op_fn, init}, numbers} ->
          Enum.reduce(numbers, init, fn n, acc -> 
            op_fn.(acc, n)
          end)
        end)
      |> Enum.sum
  end
end
  
# input = "123 328  51 64 
#  45 64  387 23 
#   6 98  215 314
# *   +   *   +  "

input = File.read!("input.txt")

num_problems = input
  |> String.split("\n")
  |> Enum.take(1)
  |> hd
  |> String.split
  |> length

sol1 = Aoc2025.Day6.part1(input |> String.split, num_problems)
IO.puts "Part 1: #{sol1}"

sol2 = Aoc2025.Day6.part2(input)
IO.puts "Part 2: #{sol2}"
