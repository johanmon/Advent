defmodule Day5 do

  ## The first part was a bit too easy, the seond part not so. The
  ## simple solution does of course not work sin ce the numbers are in
  ## the hundres of millions. The solution is of course to represent
  ## the values as ranges and tehn see how they overlap. Elixir Ranges
  ## library does not work since it does not provide intersection
  ## etc. Did it by hand but one could of course work out something
  ## more general.
  

  def test_a() do
    {seeds, maps} = parse(sample())
    locations = Enum.map(seeds, fn(seed) -> location(seed, maps) end)
    Enum.min(locations)
  end

  def task_a() do
    {seeds, maps} = parse(File.read!("day5.csv"))
    locations = Enum.map(seeds, fn(seed) -> location(seed, maps) end)
    Enum.min(locations)
  end


  ## The dummy solutiuon of simply expanding the seed values works for
  ## the small sample but not for the real thing.

  def test_x() do 
    {seeds, maps} = parse(sample())
    seeds = expand(seeds)
    locations = Enum.map(seeds, fn(seed) -> location(seed, maps) end)
    Enum.min(locations)
  end

  def test_b() do 
    {seeds, maps} = parse(sample())
    ranges  = Enum.chunk_every(seeds ,2)    
    locations = locations(ranges, maps)
    Enum.min(locations)
  end  

  def task_b() do
    {seeds, maps} = parse(File.read!("day5.csv"))
    ranges  = Enum.chunk_every(seeds ,2)
    locations = locations(ranges, maps)
    Enum.min(locations)
  end  


  ## This is the dummy solution that simply expands the seed values.
  
  def expand([]) do [] end
  def expand([s, r | rest]) do
    Enum.to_list(s..(s+r)) ++ expand(rest)
  end

  ## Solution to the first puzzle.

  def location(src, []) do  src end
  def location(src, [map|maps]) do
    src = dest(src, map) 
    location(src, maps)
  end


  def dest(src, []) do src end
  def dest(src, [[d,s,r] | rest]) do
    if ( src >= s and src <= (s+r-1)) do
      d + (src-s)
    else
      dest(src, rest)
    end
  end


  ## Solution to the second puzzle.

  def locations(ranges, maps) do
    List.foldl(maps, ranges, fn(map, rngs) -> dests(rngs, map) end)
  end

  def dests(ranges, map) do
    Enum.flat_map(ranges, fn([src,rng]) -> range(src,rng, map) end)
  end

  ## This is the part where we go from one source range (src,rng) to a
  ## list of destination ranges [[d1,r1],....]. The problem is to
  ## determine how a source range overlap with a map range and do the
  ## right thing.

  def range(src, rng, []) do [[src,rng]] end
  def range(src, rng, [[d,s,r]|rest]) do
    if ( (src+rng-1) < s or  src > (s+r-1) ) do
      ## outside of descr range 
      range(src, rng, rest)
    else
      if ( src >= s ) do
	## start inside
	if ((src+rng-1) <= (s+r-1)) do
	  ## completly covered by 
	  [[(src-s+d), rng]]
	else
	  ## start inside finish outside
	  r1 = r - (src-s)
	  r2 = (src-s)
	  [[(d + r2), r1] | range((src+r1), (rng-r1), rest)]
	end
      else
	## start outside
	if ( (src+rng-1) <= (s+r) ) do
	  ## finish inside
	  r1 = (src+rng-1 - s)
	  r2 = rng - r1
	  [[d, r2] | range(src, (rng-r1), rest)]
	else
	  ## completly covering
	  r1 = s - src
	  r2 = (src+rng) - (s+r)
	  [[d, r] | range(src, r1, rest) ++ range(s+r-1, r2, rest) ]
	end
      end
    end
  end


  ## Parsing did not cause any problems.

  
  def parse(descr) do
    [seeds | maps] = String.split(String.trim(descr), "\n\n")
    [_ | seeds] = String.split(seeds, " ")
    seeds = Enum.map(seeds, fn(str) -> {nr, _} = Integer.parse(String.trim(str)); nr end)
    {seeds, []}
    maps = Enum.map(maps, fn(map) ->
      [_| rows] = String.split(map, "\n")
      Enum.map(rows, fn(row) ->
	Enum.map(String.split(row, " "), fn(str) -> {nr, _} = Integer.parse(String.trim(str)); nr end)
      end)
    end)
    {seeds, maps} 
  end
  


  def sample() do
"seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"
  end
    

end

