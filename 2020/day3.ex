defmodule Day3 do

  # No complications - map parsed and tress stored in a map. The
  # simple traversal is O(r*lg(w)) in the number of rows and number of
  # trees (since only these are stored).
  #
  # The runtime could be improved if we kept one map per row since we
  # know which row we are looking at. This would reduce the
  # complexity to O(r * lg(w')) where w' is the number of trees in a
  # row (which is max c).
  #
  # Now since the map, once constructed, is only use to lookup trees,
  # we could implement it as a matrix (tuple of tuples). This would
  # then bring us down to O(r) for traversal.
  #
  # Does it make a difference?   
  
  def task_a() do
    {r, c, map} = sample()
    traverse(0, 0, 1, 3, r, c, map, 0)
  end

  def task_b() do
    {r, c, map} = input()
    t1 = traverse(0, 0, 1, 1, r, c, map, 0)
    t2 = traverse(0, 0, 1, 3, r, c, map, 0)
    t3 = traverse(0, 0, 1, 5, r, c, map, 0)
    t4 = traverse(0, 0, 1, 7, r, c, map, 0)
    t5 = traverse(0, 0, 2, 1, r, c, map, 0)
    {{t1,t2,t3,t4,t5}, t1*t2*t3*t4*t5}
  end
  
  def traverse(i, j, ii, jj, r, c, map, sofar) do
    i = i + ii
    if( i < r) do
      j = rem(j+jj, c)
      sofar = if lookup(map, {i,j}) do
	sofar + 1
      else
	sofar
      end
      traverse(i, j, ii, jj, r, c, map, sofar)
    else
      sofar
    end
  end


  def input() do
    File.stream!("day3.csv") |>
      ## parse()
      matrix()  
  end
	  
  def sample() do
    rows = [
      "..##.......",
      "#...#...#..",
      ".#....#..#.",
      "..#.#...#.#",
      ".#...##..#.",
      "..#.##.....",
      ".#.#.#....#",
      ".#........#",
      "#.##...#...",
      "#...##....#",
      ".#..#...#.#"]
    ## parse(rows)
    matrix(rows)
  end

  ## lookup in a MapSet or matrix
  
  def lookup(map = %MapSet{}, pos)  do
    MapSet.member?(map, pos)
  end

  def lookup(matrix, {i,j}) when is_tuple(matrix) do
    elem(elem(matrix, i), j)
  end  
  

  ## saving the trees in a matrix 

  def matrix(rows) do
    {r, c, map} = Enum.reduce(rows, {0, 0, []}, fn(row, {r, _, map}) ->
	{c, row} = collumns(row)
	{r+1, c, [row|map]}
    end)
    {r, c, List.to_tuple(Enum.reverse(map))}
  end
  
  def collumns(row) do
    {c, row} = Enum.reduce(String.to_charlist(String.trim(row)), {0, []}, fn(char, {c, map}) ->
      if char == ?\# do
	{c+1, [true|map]}
      else
	{c+1, [false|map]}
      end
    end)
    {c, List.to_tuple(Enum.reverse(row))}
  end
  
  
  ## saving the trees in a MapSet

  def parse(rows) do
    Enum.reduce(rows, {0, 0, MapSet.new()}, fn(row, {r, _, map}) ->
	{c, map} = parse(row, r, map)
	{r+1, c, map}
    end)
  end
  
  def parse(row, r, map) do
    Enum.reduce(String.to_charlist(String.trim(row)), {0,map}, fn(char, {c,map}) ->
      if char == ?\# do
	{c+1, MapSet.put(map, {r,c})}
      else
	{c+1, map}
      end
    end)
  end

  
end
