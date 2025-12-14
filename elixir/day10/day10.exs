defmodule Aoc2025.Day10.Machine do
  use Bitwise

  defstruct [:lights, :num_lights, :target_lights, :buttons, :joltages]

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
    %__MODULE__{
      lights: 0,
      num_lights: String.length(lights)-2,
      target_lights: lights_from_string(lights),
      buttons: buttons_from_string(buttons |> String.trim_trailing, String.length(lights)-2)
    }
  end

  def press_button(%__MODULE__{ buttons: buttons, lights: lights, num_lights: num_lights } = machine, idx) do
    button = Enum.at(buttons, idx)
    new_lights = bxor(lights, button)
    # new_lights = Enum.reduce(0..num_lights-1, lights, fn bit_idx, lights_acc ->
    #   bit_pos = num_lights - bit_idx - 1
    #   if (button &&& (1 <<< bit_pos)) == (1 <<< bit_pos) do
    #     # Bit in lights is set, build mask to AND with
    #     if (lights &&& (1 <<< bit_pos)) == (1 <<< bit_pos) do
    #       mask = Enum.reduce(0..num_lights-1, 0, fn idx, acc ->
    #         acc + if idx == bit_idx, do: 0, else: (1 <<< (num_lights - idx - 1))
    #       end)
    #       lights_acc &&& mask
    #     else
    #     # Bit in lights is not set, build mask to OR with
    #       mask = Enum.reduce(0..num_lights-1, 0, fn idx, acc ->
    #         acc + if idx == bit_idx, do: (1 <<< (num_lights - idx - 1)), else: 0
    #       end)
    #       lights_acc ||| mask
    #     end
    #   else
    #     lights_acc
    #   end
    # end)

    %__MODULE__{ machine | lights: new_lights }
  end

  def started?(%__MODULE__{ lights: lights, num_lights: num_lights, target_lights: target_lights }) do
    #(1 <<< num_lights) == lights + 1 
    lights == target_lights
  end
end

defmodule Aoc2025.Day10 do
  alias Aoc2025.Day10.Machine

  def find_sequence(machines, seq_len \\ 1) do
    {found, next_machines} = Enum.reduce_while(machines, {false, []} , fn machine, {_, next_machines} -> 
      new_machines = Enum.map(0..length(machine.buttons)-1, fn btn_idx ->
        Machine.press_button(machine, btn_idx) 
      end)
      case Enum.any?(new_machines, &Machine.started?/1) do
        true -> {:halt, {true, []}}
        false -> {:cont, {false, [new_machines | next_machines]}}
      end
    end)
    if found do
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
      |> IO.inspect
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
