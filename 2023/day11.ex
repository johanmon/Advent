defmodule Day11 do

  ## Simpler than at first thought. I did choose the right
  ## representation of the space; simply keeping track of the
  ## positions of the galaxies and not worry in the beginning of the
  ## expanding universe.
  ##
  ## The expansion is a bit quick and dirty. I first collect a list of
  ## all rows and a list of all collumns that have galaxies. I then
  ## run through all galaxies and check how many of the empty rows and
  ## colums have lower indicies. This could have been done more
  ## efficintly but it's complexity wise ok.
  ##
  ## Calculating the shortest distance was of course a trivial task
  ## but the fear was of curse that this would change for the second
  ## task. The second task was a mer increment in the expansion and
  ## this was solved by adding one argument to expand/1 and changing
  ## one line of code:
  ##
  ##         {:glx, (i-ix)+(ix*inc), (j-jx)+(jx*inc)}


  def test_a() do
    String.split(sample(), "\n") |>
      parse() |>
      expand(2) |>
      distances(0)
  end

  def task_a() do
    String.split(File.read!("day11.csv"), "\n") |>
      parse() |>
      expand(2) |>
      distances(0)
  end

  def test_b() do
    String.split(sample(), "\n") |>
      parse() |>
      expand(10) |>
      distances(0)
  end

  def task_b() do
    String.split(File.read!("day11.csv"), "\n") |>
      parse() |>
      expand(1000000) |>
      distances(0)
  end

  ## Is there a function for this in the Enum module. Folding but
  ## always have access to the rest of the list. 
  
  def distances([], n) do n end
  def distances([a | rest], n) do
    d = Enum.reduce(rest, 0, fn(b, acc) -> dist(a,b) + acc end)
    distances(rest, n + d)
  end

  def dist({:glx, r1, c1}, {:glx, r2, c2}) do
    abs(r1-r2) + abs(c1-c2)
  end

  ## This is the (not so) tricky part of expanding the universe. 

  def expand({all, r, c}, inc) do
    glx_rows = Enum.map(all, fn({:glx, i, _}) -> i end)
    glx_cols = Enum.map(all, fn({:glx, _, j}) -> j end)
    free_rows = Enum.filter(1..r, fn(i) -> !Enum.member?(glx_rows, i) end)
    free_cols = Enum.filter(1..c, fn(j) -> !Enum.member?(glx_cols, j) end)
    Enum.map(all, fn({:glx, i, j}) ->
      ix = Enum.reduce(free_rows, 0, fn(r, acc) -> if (r < i) do acc+1 else acc end end)
      jx = Enum.reduce(free_cols, 0, fn(c, acc) -> if (c < j) do acc+1 else acc end end)
      {:glx, (i-ix)+(ix*inc), (j-jx)+(jx*inc)}
    end)
  end

  ## The parsing will collect all galaxies in the map.

  def parse(rows) do
    Enum.reduce(rows, {[],0,0}, fn(row, {all,r,_}) ->
      r = r+1
      Enum.reduce(String.to_charlist(row), {all,r,0}, fn(char, {all, r, c}) ->
	c = c+1
        case char do
	  ?. -> {all, r, c}
	  ?# -> {[{:glx, r, c}|all], r, c}
	end
      end)
    end)
  end



  def sample() do
"...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#....."
  end
  


end
