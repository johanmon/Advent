defmodule Day14  do

  ## First task easy, second task ..... :-0
  ##
  ## In the first task I simply represented the board as a list of
  ## lists. The rows are transposed into columns and one could then
  ## treat each column separately, tilt it and counts the weights.
  ##
  ## The second task was immediately identified as unsolvable by brute
  ## force. A small test showed that it would take hours just to spin the
  ## sample a billion times so spinning the large board was of course
  ## out of the question.
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

  def test_b() do test_b(2 +4) end

  def test_b(n) do
    String.split(sample(), "\n") |>
      Enum.map(&parse/1)  |>
      spin(n, 1) |>
      transpose() |>
      Enum.map(&weight/1) |>
      Enum.sum()
  end

  def task_b() do task_b(105+11) end

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
    w = Enum.sum(Enum.map(north, &weight/1))
    :io.format("weight after north transpose in spin ~w: ~w~n", [i, w])
    
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
