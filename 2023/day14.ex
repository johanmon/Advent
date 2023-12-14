defmodule Day14  do

  ## First task easy, second task ..... :-0
  ##
  ## In the first task I simply represented the board as a list of
  ## lists. The rows are transposed into columns and one could then
  ## treat each column separately, tilt it and counts the weights.
  ##
  ## There are other, meybe more efficient, ways of representing the
  ## board. One could keep a list of all rocks and their positions:
  ##
  ##    [{:square, 1, 3}, {:round, 1, 8}, {:round, 3, 2} ... ]
  ##
  ## This would be a list of some 30x30 items as compred to the
  ## 100x100 list of lists. There would be no need for transposing the
  ## board since it would be slved by looing at it from different
  ## angles.Tilting could be done by firts extracting the rocks of a
  ## row, sort them and then let them slide. 
  ##
  ## Instead of having them in a list one could of cours put them in a
  ## map which could make it more efficient. ..... update: a map
  ## solution was implemented and it performed worse (aprx half the
  ## spees) than the original solution with lists of lists. The
  ## transpose function is rather efficent and since it will give us
  ## the rows or columns to work with the solution is quite efficient.
  ##
  ## The second task was immediately identified as unsolvable by
  ## brute force. A small test showed that it would take hours just to
  ## spin the sample a billion times so spinning the large board was
  ## of course out of the question.
  ##
  ## Never the less the spin/1 function was implemented that rotated
  ## and tilted the board full circle. The original board is
  ## west-oriented so it is transposed to north-oriented, tilted and
  ## then transposed to be west-oriented. Transforming to south, east
  ## and then back again required some reversing of rows and columns
  ## but it works...... but it will not solve the billion spin
  ## problem.
  ##
  ## One idea was that the rolling rocks after some spins would return
  ## to a position that they had been in before i.e. a loop. If a loop
  ## could be detected och could spin until the beginning of the loop
  ## and then only spin the remaining turns mod the length of the
  ## loop.
  ##
  ## Comparing boards did not sound like good idea but since we're
  ## only interested in the weight it could be that this was enough to
  ## detect the loop.
  ##
  ## At this point I cheated and simply printed the weight of the
  ## board after each spin to manually see if a loop could be
  ## detected. The small sample had a loop of length 7 after 2
  ## turns. The larger task had a loop of length 13 after 105 turns.
  ## 
  ## One would of course like to detect these loops automatically but
  ## hey, it worked :-)
  
  def test_a() do
    String.split(sample(), "\n") |>
      Enum.map(&parse/1)  |>
      transpose() |>
      Enum.map(&tilt/1) |>
      Enum.map(&weight/1) |>
      Enum.sum()
  end

  def task_a() do
    String.split(File.read!("day14.csv"), "\n") |>
      Enum.map(&parse/1)  |>
      transpose() |>
      Enum.map(&tilt/1) |>
      Enum.map(&weight/1) |>
      Enum.sum()
  end

  def test_b() do test_b(2 + rem(1_000_000_000-2, 7)) end

  def test_b(n) do
    String.split(sample(), "\n") |>
      Enum.map(&parse/1)  |>
      spin(n, 1) |>
      transpose() |>
      Enum.map(&weight/1) |>
      Enum.sum()
  end
  
  def task_b() do task_b(105+ rem(1_000_000_000-105,11)) end

  def task_b(n) do
    String.split(File.read!("day14.csv"), "\n") |>
      Enum.map(&parse/1)  |>
      spin(n, 1) |>
      transpose() |>
      Enum.map(&weight/1) |>
      Enum.sum()
  end

  def spin(rows, 0, _) do rows end
  def spin(rows, n, i) do
    north = transpose(rows)

    #:io.format("weight after north transpose in spin ~w: ~w~n", [i, Enum.sum(Enum.map(north, &weight/1))])
    
    north = Enum.map(north, &tilt/1)
    
    west = transpose(north)
    west = Enum.map(west, &tilt/1)

    south = transpose(Enum.reverse(west))
    south = Enum.map(south, &tilt/1)

    east =  transpose(Enum.reverse(south))
    east = Enum.map(east, &tilt/1)

    rows = Enum.map(Enum.reverse(east), fn(r) -> Enum.reverse(r) end)

    spin(rows, n-1, i+1)
  end
  
  def tilt([]) do  [] end
  def tilt([:round|rest]) do
    [:round|tilt(rest)]
  end
  def tilt([:square|rest]) do
    [:square|tilt(rest)]
  end
  def tilt(rest) do
    {tilted, rest} = tilt(rest, [])
    tilted ++ tilt(rest)
  end

  
  def tilt([], tltd) do {tltd, []} end
  def tilt([:empty|rest], tld) do
    tilt(rest, [:empty|tld])
  end  
  def tilt([:square|rest], tld) do
    {tld ++ [:square], rest}
  end
  def tilt([:round|rest], tld) do
    {[:round], tld ++ rest}
  end

  def transpose([[] | _]), do: []
  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end  

  def weight(col) do
    elem(Enum.reduce(col, {length(col),0}, fn(c,{i,s}) ->
      case c do
	:round ->  {i-1, s+i}
	:square -> {i-1, s}
	:empty ->  {i-1, s}
      end
    end), 1)
  end
  
  def parse(row) do
    Enum.map(String.to_charlist(row), fn(char) ->
      case char do
	?O -> :round
	?# -> :square
	?. -> :empty
      end
    end)
  end


  ## This is the version using a map.
  
  def test_map(n) do
    rows = String.split(sample(), "\n")
    {i, j, map} = Enum.reduce(rows, {0,0,%{}}, fn (row, {i,_, map}) -> i = i+1 ; {j, map} = parse_map(row,i,map) ;   {i,j,map}  end)
    spin_map(map, i, j, n)
    weight_map(map, i)
  end

  def task_map(n) do
    rows = String.split(File.read!("day14.csv"), "\n")
    {i, j, map} = Enum.reduce(rows, {0,0,%{}}, fn (row, {i,_, map}) -> i = i+1 ; {j, map} = parse_map(row,i,map) ;   {i,j,map}  end)
    spin_map(map, i, j, n)
    weight_map(map, i)
  end  

  ## Always measure north weight.
  
  def weight_map(map, i) do
    Enum.reduce(map, 0, fn({{k,_}, val}, sum) ->
       case val do
     	:square -> sum
     	:round -> sum + ((i+1) - k)
       end
    end)
  end

  def spin_map(board, _, _, 0) do  board end
  def spin_map(board, i, j, n) do
    spun = tilt_north(board, i, j) |>
      tilt_west(i, j) |>
      tilt_south(i, j) |>
      tilt_east(i, j)
    #:io.format("weight: ~w  ~n", [weight(spun, i)])
    spin_map(spun, i, j, n-1)
  end

  ## All tilt operations are very similar. Implementing them with
  ## higher order functions slowed it down a bit but it does reduce
  ## the code to maintain.
  
  def tilt_north(map, i, j) do
    Enum.reduce(1..j, %{}, fn(j, tilted) ->
      tilt_map(map, i..1, fn(i) -> {i,j} end,  {1,1}, tilted)
    end)
  end

  def tilt_south(map, i, j) do
    Enum.reduce(1..j, %{}, fn(j, tilted) ->
      tilt_map(map, 1..i, fn(i) -> {i,j} end, {i,-1}, tilted)
    end)
  end

  def tilt_west(map, i, j) do
    Enum.reduce(1..i, %{}, fn(i, tilted) ->
      tilt_map(map, j..1, fn(j) -> {i, j} end, {1,1}, tilted)
    end)
  end

  def tilt_east(map, i, j) do
    Enum.reduce(1..i, %{}, fn(i, tilted) ->
      tilt_map(map, 1..j, fn(j) -> {i,j} end, {j,-1}, tilted)
    end)
  end

  def tilt_map(map, range, pos, {n,d}, tilted) do
    col = Enum.reduce(range, [], fn(k, acc) ->
      case Map.get(map, pos.(k)) do
	:nil -> acc
	val -> [{k,val}|acc]
      end
    end)
    col = tilt_col(col, n, d)
    Enum.reduce(col, tilted, fn({k,val}, tilted) -> Map.put(tilted, pos.(k), val) end)    
  end
  
  ## This is the tilting but now we have to know the direction.
  
  def tilt_col([], _, _) do [] end
  def tilt_col([{_, :round}|rest], n, d) do
    [{n, :round} | tilt_col(rest, n + d, d)]
  end
  def tilt_col([{j, :square}|rest], _, d) do
    [{j, :square} | tilt_col(rest, j + d, d)]
  end  

  ## The parser will now add all rocks to the map. 
  
  def parse_map(row, i, map) do
    Enum.reduce(String.to_charlist(row), {0,map}, fn(char, {j,map}) ->
      j = j+1
      case char do
	?O -> {j, Map.put(map, {i,j}, :round)}
	?# -> {j, Map.put(map, {i,j}, :square)}
	?. -> {j, map}
      end
    end)
  end
  

  def sample() do
"O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#...."

  end
  
end
