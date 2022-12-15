defmodule Day15 do


  ## Day 15 - fun! This was the first puzzle were you had to think
  ## twice before finding a suitable algorithm.
  ##
  ## Either I'm getting better at parsing the input or it was simple but
  ## today the parsing was actually done in fifteen minutes. Only
  ## later did I realize that the beacon it self was not important and
  ## that one only needed the distance.
  ##
  ## To solve the first task I simply used a MapSet and added each x
  ## position that was covered by any of the sensors. This does of
  ## course mean that any x position is added multiple times because
  ## it is probably covered by more than one sensor. It also requires
  ## multiple put operations for each sensor. This was ok for the
  ## first puzzle but the execution time was a couple of seconds.
  ##
  ## When starting on the second puzzle one immediately realized that
  ## something had to be done. A naive solution was implemented for
  ## the small test sample and that worked ok. The solution scanned
  ## all {x,y} positions in teh range {1..20,1..20} and determined if
  ## it was covered by any sensor. As soon as a position was found
  ## that was not covered you knew you had found the position we're
  ## looking for.
  ##
  ## The naive solytion did of course not work for the range
  ## 1..4000000 so something had to be done. The trick was to replace
  ## the MapSet with a sequence of covered ranges. When a sensor is
  ## considered the range covered by the sensor could be added to the
  ## sequence and in this operation the sequnce was of course reduced
  ## if possible (rtfc - range/3).
  ##
  ## With the range operations working one could scan each row
  ## 1..4000000 and compute the range covered in as many steps as we
  ## have sensors. In the end if the range extended across 1..4000000
  ## then the free position was not at the given row.
  ##
  ## Finding the answer to the second puzzle is done in less than four
  ## seconds. I clocked in at position 4915 for the second task and I
  ## didn't even start at six o'clock :-)
  ##
  
  
  def task_a() do
    ty = 2_000_000
    input = parse(input())
    input = Enum.map(input, fn ({sensor, beacon}) ->  {sensor, distance(sensor, beacon)} end)
    map = range()
    map = Enum.reduce(input, map, fn ({{sx,sy}, d}, map) ->
      if d >= abs(sy-ty) do
	{x0,x1} = cover(sx, sy, d, ty)
	range(map, x0, x1)
      else
	map
      end	
    end)
    [{x0,x1}] = map
    abs(x1 - x0)    
  end

  def task_b() do
    input = parse(input())
    input = Enum.map(input, fn ({sensor, beacon}) ->  {sensor, distance(sensor, beacon)} end)
    ly = 4_000_000
    {ty,tx} = Enum.reduce_while(0..ly, 0, fn(ty, _a) ->
      map = range()
      
      ## if ( rem(ty, 100_000) == 0 ) do
      ##   :io.format("tt = ~w\n", [ty])
      ## end

      map = Enum.reduce(input, map, fn({{sx,sy}, d}, map) ->
	if d >= abs(sy - ty) do
	  {x0,x1} = cover(sx, sy, d, ty)
	  range(map, x0, x1)
	else
	  map
	end
      end)
      case map do
	[{x0,x1}] when x0 <= 0 and x1 >= ly ->
	  {:cont, 0}
	[{_,tx}|_] ->
	  {:halt, {ty,tx+1}}
      end
    end)
    tx*ly + ty
  end

  def cover(sx, sy, d, ty) do
    h = abs(sy-ty)
    m = (d-h)
    {(sx-m), (sx+m)}
  end

  def distance({sx,sy}, {bx, by}) do
     abs(sx - bx) +  abs(sy - by)
  end
    


  def range() do [] end

  def range([], x0, x1) do [{x0,x1}] end
  
  def range([{xn, _} = rng|rest], x0, x1) when x1 < xn do
    [{x0,x1}, rng | rest]
  end
  def range([{xn, xm}|rest], x0, x1) when x0 <= xm do
    range(rest, min(xn,x0), max(xm,x1))
  end
  def range([rng|rest], x0, x1) do
    [rng | range(rest, x0, x1)]
  end
  

  def parse(input) do
    Enum.map(input, fn (r) ->
      [sensor, beacon] = String.split(r, [":"])
      [_, sx, sy] = String.split(sensor, ["="])
      {sx,_} = Integer.parse(sx)
      {sy,_} = Integer.parse(sy)
      
      [_, bx, by] = String.split(beacon, ["="])
      {bx,_} = Integer.parse(bx)
      {by,_} = Integer.parse(by)
      {{sx,sy}, {bx,by}}
      end)
  end
  
  
  def input() do
    File.stream!("day15.csv")
  end


  def test() do
    ["Sensor at x=2, y=18: closest beacon is at x=-2, y=15",
     "Sensor at x=9, y=16: closest beacon is at x=10, y=16",
     "Sensor at x=13, y=2: closest beacon is at x=15, y=3",
     "Sensor at x=12, y=14: closest beacon is at x=10, y=16",
     "Sensor at x=10, y=20: closest beacon is at x=10, y=16",
     "Sensor at x=14, y=17: closest beacon is at x=10, y=16",
     "Sensor at x=8, y=7: closest beacon is at x=2, y=10",
     "Sensor at x=2, y=0: closest beacon is at x=2, y=10",
     "Sensor at x=0, y=11: closest beacon is at x=2, y=10",
     "Sensor at x=20, y=14: closest beacon is at x=25, y=17",
     "Sensor at x=17, y=20: closest beacon is at x=21, y=22",
     "Sensor at x=16, y=7: closest beacon is at x=15, y=3",
     "Sensor at x=14, y=3: closest beacon is at x=15, y=3",
     "Sensor at x=20, y=1: closest beacon is at x=15, y=3"]
  end

end
