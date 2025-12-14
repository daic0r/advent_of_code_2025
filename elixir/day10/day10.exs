defmodule Aoc2025.Day10.Machine do
  use Bitwise

  defstruct [:lights, :num_lights, :target_lights, :buttons, :num_buttons, :joltages]

  def lights_from_string(str) do
    num_lights = String.length(str) - 2
    str  
      |> String.slice(1, num_lights)
      |> String.graphemes
      |> Enum.with_index
      |> Enum.reduce(0, fn {light, idx}, acc ->
        acc + case light do
          "#" -> :math.pow(2, num_lights - idx - 1)
          "." -> 0
        end
      end)
      |> trunc
  end

  def buttons_from_string(str, num_lights) do
    str
      |> String.split 
      |> Enum.map(fn button ->
        button
          |> String.slice(1, String.length(button)-2)
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)
          |> Enum.reduce(0, fn idx, acc ->
            acc + :math.pow(2, num_lights - idx - 1)
          end)
          |> trunc
      end)
  end

  def from_string(str) do
    # [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    rex = ~r/(\[[\.#]+\]) ((?:\((?:\d+,?)+\) ?)+)(\{(?:\d+,?)+\})/
    [[lights, buttons, joltages]]  = Regex.scan(rex, str, capture: :all_but_first) 
    buttons = buttons_from_string(buttons |> String.trim_trailing, String.length(lights)-2)
    %__MODULE__{
      lights: 0,
      num_lights: String.length(lights)-2,
      target_lights: lights_from_string(lights),
      buttons: buttons,
      num_buttons: length(buttons)
    }
  end

  def press_button(%__MODULE__{ buttons: buttons, lights: lights, num_lights: num_lights } = machine, idx) do
    button = Enum.at(buttons, idx)
    new_lights = bxor(lights, button)

    %__MODULE__{ machine | lights: new_lights }
  end

  def started?(%__MODULE__{ lights: lights, num_lights: num_lights, target_lights: target_lights }) do
    lights == target_lights
  end
end

defmodule Aoc2025.Day10 do
  alias Aoc2025.Day10.Machine

  # Each button press will result in a different machine state, therefore after
  # each iteration of N buttons we will also have N new machine states to
  # continue with for each button (BFS).
  def find_sequence(machines, seq_len \\ 1) do
    # Each machine produces a list of new machine states after each individual
    # button press
    {found?, next_machines} = Enum.reduce_while(machines, {false, []} , fn machine, {_, next_machines} ->
      # For each machine, every button can be pressed again
      {found?, next_machines_for_button} = Enum.reduce_while(0..machine.num_buttons-1, {false, []}, fn btn_idx, {_, next_machines} ->
        next_machine = Machine.press_button(machine, btn_idx)
        case Machine.started?(next_machine) do
          true -> {:halt, {true, [next_machine | next_machines]}}
          false -> {:cont, {false, [next_machine | next_machines]}}
        end
      end)
      case found? do
        true -> {:halt, {true, []}}
        false -> {:cont, {false, [next_machines_for_button | next_machines]}}
      end
    end)
    # Here we have a list of lists of machines, therefore we flatten it down
    # below
    if found? do
      seq_len
    else
      find_sequence(next_machines |> List.flatten, seq_len + 1)
    end
  end
  def part1(machines) do
    machines
      |> Enum.map(fn machine ->
        find_sequence([machine]) 
      end)
      |> IO.inspect(limit: :infinity)
      |> Enum.sum()
  end
end

# input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
# [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
# [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"
input = File.read!("input.txt")
  |> String.split("\n")
  |> Enum.filter(&String.length(&1) > 0)
  |> Enum.map(&Aoc2025.Day10.Machine.from_string(&1))

sol1 = Aoc2025.Day10.part1(input)
IO.puts "Part 1: #{sol1}"
