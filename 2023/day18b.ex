defmodule Day18b do

  ## The second task first looked like a nightmare but turned out to
  ## be a walk in a park once you looked at it as polygon shape. I did
  ## not think about the rim of the polygon i.e. the ditch they are
  ## digging. This is of course 1 meter wide and the part facing
  ## towards the center is of course included in the area. Adding half
  ## a rim was close but no cigar since we have turned around in a
  ## circle and thereby fall one square meter short.
  
  def test() do
    sample() |>
      String.split("\n") |>
      Enum.map(&parse/1) |>
      dig() |>
      area()
  end

  def task() do
    File.read!("day18.csv") |>
      String.split("\n") |>
      Enum.map(&parse/1) |>
      dig() |>
      area()
  end

  ## The rim of the lava pool is also part of the pool... or rather,
  ## the general calculation of the area of a polygon will include
  ## half of the rim so we add the other half. Now since we have
  ## gone a circle we loose one square meter so we add one.
  
  def area(line) do
    area(line,0) + div(rim(line,0),2) + 1
  end

  def rim([{x1,y1} | [{x2,y1}|_]=rest], sum) do
    rim(rest, sum+abs(x2-x1))
  end
  def rim([{x1,y1} | [{x1,y2}|_]=rest], sum) do
    rim(rest, sum+abs(y2-y1))
  end  
  def rim([_], sum) do sum end

  ## Calculating the area of a rectangular polygon is easy. A line
  ## going up or down can be ignored but the rectangualr area under a
  ## horizontal line is added to the total. The area is then the
  ## absolut value.
  
  def area([{_,y1} | [{_,y1}|_]=rest], sum) do
    area(rest, sum)
  end
  def area([{x1,y1} | [{x1,y2}|_]=rest], sum) do
    area(rest, (y2-y1)*x1 + sum)
  end
  def area([_], sum) do abs(sum) end


  def dig(plan) do
    Enum.reduce(plan, [{0,0}], fn({:dig, dir, mtr}, [pos|_]=map) ->
      [move(pos, dir, mtr)|map]
    end)
  end

  def move({i,j}, dir, m) do
    case dir do
      :up -> {i-m, j}
      :down -> {i+m, j}
      :right -> {i, j+m}
      :left -> {i, j-m}
    end
  end

  def parse(row) do
    [_dir, _nr, code] = String.split(row," ")
    <<?(, ?\#, dist::binary-size(5), dir, ?)>> = code
    dir = case (dir-48) do
	    0 -> :right
	    1 -> :down
	    2 -> :left	    
	    3 -> :up
	  end
    {nr,_} = Integer.parse(dist, 16)
    {:dig, dir, nr}
  end


  def sample() do 
"R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)"
  end
  

  
end

