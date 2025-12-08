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

  def gen_distances(input, idx \\ 0, out \\ %{})
  def gen_distances(input, idx, out) when idx == length(input) do
    out 
  end
  def gen_distances(input, idx, out) do
    [head | tail] = input |> Enum.drop(idx)
    distances = for vec <- tail, into: %{}, do: {vec, dist(head, vec)}
    gen_distances(input, idx + 1, Map.put(out, head, distances))
  end

  def gen_distances2(input, limit, out \\ :orddict.new())
  def gen_distances2([], _limit, out) do
    out
  end
  def gen_distances2(input, limit, out) do
    [head | tail] = input
    new_out = Enum.reduce(tail, out, fn vec, stor ->
      d = dist(head, vec)
      :orddict.store(d, {head, vec}, stor)
    end)
    new_out = case limit do
      :infinity -> new_out
      n -> new_out |> Enum.take(limit)
    end
    gen_distances2(tail, limit, new_out)
  end

  def get_distance(distances, a, b) do
    dist = Map.get(Map.get(distances, a), b) 
    if dist do
      dist   
    else
      Map.get(Map.get(distances, b), a)
    end
  end

  def part1(distances, out_circuits, num_merges, idx \\ 0)
  def part1(distances, out_circuits, num_merges, num_merges) do
    out_circuits
      |> Enum.sort_by(& length(&1), :desc)
      |> Enum.take(3)
      |> IO.inspect(limit: :infinity)
      |> Enum.product_by(& length(&1))
  end
  def part1(distances, out_circuits, num_merges, idx) do
    {{vec_a, vec_b}, distances} = :orddict.take(elem(hd(distances), 0), distances)
    circ_a = Enum.find(out_circuits, fn circuit -> vec_a in circuit and vec_b not in circuit end)
    circ_b = Enum.find(out_circuits, fn circuit -> vec_b in circuit and vec_a not in circuit end)

    # Merge the two circuits if the two points aren't already part of the same
    # circuit
    out_circuits = if circ_a != nil and circ_b != nil do
      merged = circ_a ++ circ_b

      out_circuits = out_circuits |> Enum.reject(& &1 == circ_b or &1 == circ_a)

      [merged | out_circuits]
    else
      out_circuits
    end

    # out_circuits = out_circuits
    #   |> Enum.map(fn circuit ->
    #     circuit = if vec_a in circuit and vec_b not in circuit do
    #       [vec_b | circuit]
    #     else
    #       circuit
    #     end
    #     circuit = if vec_b in circuit and vec_a not in circuit do
    #       [vec_a | circuit]
    #     else
    #       circuit
    #     end
    #     circuit
    #   end)
    # |> Enum.map(fn circuit ->
    #   circuit
    #     |> Enum.sort_by(& &1, fn %Vector{ x: x1, y: y1, z: z1 }, %Vector{ x: x2, y: y2, z: z2 } ->
    #       x1 < x2 or (x1 == x2 and y1 < y2) or (x1 == x2 and y1 == y2 and z1 < z2) 
    #     end)
    #   end)
    # |> Enum.uniq
    # #|> IO.inspect(label: "PASS")
    # IO.puts "=========="

    part1(distances, out_circuits, num_merges, idx + 1)
  end

  
  def part2(distances, out_circuits)
  # def part2(distances, out_circuits) when length(out_circuits) == 1 do
  #   out_circuits
  #     |> Enum.sort_by(& length(&1), :desc)
  #     |> Enum.take(3)
  #     |> IO.inspect(limit: :infinity)
  #     |> Enum.product_by(& length(&1))
  # end
  def part2(distances, out_circuits) do
    {{vec_a, vec_b}, distances} = :orddict.take(elem(hd(distances), 0), distances)
    circ_a = Enum.find(out_circuits, fn circuit -> vec_a in circuit and vec_b not in circuit end)
    circ_b = Enum.find(out_circuits, fn circuit -> vec_b in circuit and vec_a not in circuit end)

    # Merge the two circuits if the two points aren't already part of the same
    # circuit
    out_circuits = if circ_a != nil and circ_b != nil do
      merged = circ_a ++ circ_b

      out_circuits = out_circuits |> Enum.reject(& &1 == circ_b or &1 == circ_a)

      out_circuits = [merged | out_circuits]

      if length(out_circuits) == 1 do
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
  |> Enum.map(fn vec -> [vec] end)

distances = Aoc2025.Day8.gen_distances2(input, 1000) |> IO.inspect(limit: :infinity)

sol1 = Aoc2025.Day8.part1(distances, circuits, 1000)
IO.puts "Part 1: #{sol1}"

distances = Aoc2025.Day8.gen_distances2(input, 8000)
sol2 = Aoc2025.Day8.part2(distances, circuits)
IO.puts "Part 2: #{sol2}"
