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
  

  # Flip columns and rows
  def rotate(input, len, idx \\ 0, columns \\ [])
  def rotate(_input, len, len, columns) do
    # We prepended to the list below, so reverse to get the right order here
    Enum.reverse(columns)
  end
  def rotate(input, len, idx, columns) do
    col = input
      |> Enum.drop(idx)
      |> Enum.chunk_every(1, len+1)
      |> List.flatten

    rotate(input, len, idx + 1, [col | columns])
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
      |> rotate(line_len)
      |> Enum.chunk_by(fn col -> Enum.all?(col, & &1 == " ") end)
      |> Enum.filter(& length(&1) > 1) # Filter out the separating columns
      |> Enum.map(fn cols ->
          op = cols |> hd |> List.last
          {op_fn, init} = case op do
            "+" -> {fn a, b -> a + b end, 0}
            "*" -> {fn a, b -> a * b end, 1}
          end
          # Drop the last row that only contains the operator, remove empty columns,
          # then stringify the column list and convert into an integer
          {{op_fn, init}, 
            cols 
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
