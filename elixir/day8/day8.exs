defmodule Aoc2025.Day8.Vector do
  defstruct x: 0, y: 0, z: 0

  def new_vector(x, y, z) do
    %__MODULE__{ x: x, y: y, z: z }
  end

  def from_string(str) when is_binary(str) do
    [x, y, z] = str
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    new_vector(x, y, z)
  end

  def dist(%__MODULE__{ x: x1, y: y1, z: z1 }, %__MODULE__{ x: x2, y: y2, z: z2 }) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2) + :math.pow(z2 - z1, 2))
  end
end

defmodule Aoc2025.Day8 do
  import Aoc2025.Day8.Vector

  def gen_distances(input, out \\ :ets.new(:day, [:ordered_set]))
  def gen_distances([], out) do
    out
  end
  def gen_distances(input, out) do
    [head | tail] = input

    Enum.each(tail, fn vec ->
      d = dist(head, vec)
      :ets.insert(out, {d, {head, vec}})
    end)

    gen_distances(tail, out)
  end

  def part1(distances, out_circuits, num_merges, idx \\ 0)
  def part1(_distances, out_circuits, num_merges, num_merges) do
    out_circuits
      |> MapSet.to_list
      |> Enum.sort_by(& MapSet.size(&1), :desc)
      |> Enum.take(3)
      |> Enum.product_by(& MapSet.size(&1))
  end
  def part1(distances, out_circuits, num_merges, idx) do
    [{_, {vec_a, vec_b}}] = :ets.take(distances, :ets.first(distances))
    circ_a = Enum.find(out_circuits, fn circuit -> vec_a in circuit and vec_b not in circuit end)
    circ_b = Enum.find(out_circuits, fn circuit -> vec_b in circuit and vec_a not in circuit end)

    # Merge the two circuits if the two points aren't already part of the same
    # circuit
    out_circuits = if circ_a != nil and circ_b != nil do
      out_circuits = MapSet.delete(out_circuits, circ_a)
      out_circuits = MapSet.delete(out_circuits, circ_b)

      merged = MapSet.union(circ_a, circ_b)
      MapSet.put(out_circuits, merged)
    else
      out_circuits
    end

    part1(distances, out_circuits, num_merges, idx + 1)
  end

  
  def part2(distances, out_circuits) do
    [{_, {vec_a, vec_b}}] = :ets.take(distances, :ets.first(distances))
    circ_a = Enum.find(out_circuits, fn circuit -> vec_a in circuit and vec_b not in circuit end)
    circ_b = Enum.find(out_circuits, fn circuit -> vec_b in circuit and vec_a not in circuit end)

    # Merge the two circuits if the two points aren't already part of the same
    # circuit
    if circ_a != nil and circ_b != nil do

      out_circuits = MapSet.delete(out_circuits, circ_a)
      out_circuits = MapSet.delete(out_circuits, circ_b)

      merged = MapSet.union(circ_a, circ_b)
      out_circuits = MapSet.put(out_circuits, merged)

      if MapSet.size(out_circuits) == 1 do
        vec_a.x * vec_b.x
      else
        part2(distances, out_circuits)
      end
    else
        part2(distances, out_circuits)
    end
  end
end

# input = "162,817,812
# 57,618,57
# 906,360,560
# 592,479,940
# 352,342,300
# 466,668,158
# 542,29,236
# 431,825,988
# 739,650,466
# 52,470,668
# 216,146,977
# 819,987,18
# 117,168,530
# 805,96,715
# 346,949,466
# 970,615,88
# 941,993,340
# 862,61,35
# 984,92,344
# 425,690,689"
#
#
input = File.read!("input.txt")

input = input
  |> String.split("\n")
  |> Enum.filter(&String.length(&1) > 0)
  |> Enum.map(&Aoc2025.Day8.Vector.from_string/1)

# Every vector is in its own circuit in the beginning
circuits = input
  |> Enum.map(fn vec -> MapSet.new()|> MapSet.put(vec) end)
  |> Enum.into(MapSet.new())

distances = Aoc2025.Day8.gen_distances(input)

sol1 = Aoc2025.Day8.part1(distances, circuits, 1000)
IO.puts "Part 1: #{sol1}"

distances = Aoc2025.Day8.gen_distances(input)

sol2 = Aoc2025.Day8.part2(distances, circuits)
IO.puts "Part 2: #{sol2}"
