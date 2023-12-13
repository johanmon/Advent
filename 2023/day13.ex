defmodule Day13 do


  ## Ok, how problematic can it be to handle bit operations? The first
  ## task was quite ok. I parsed the rows and turned them into an
  ## integer each by interpretating the row as a bit sequence. This
  ## was done in order to compare rows much easier.
  ##
  ## To find a reflection it was now easy to traverse the list looking
  ## for a double row and then checking that the traversed part was a
  ## reflection of the remaining part. 
  ##
  ## The second task turned out to be quite simple but took to long
  ## time to debu. Instead of having used the Bitwise module I did the
  ## tranformation by hand wich of course then required a lot of
  ## debugging.
  ##
  ## To solve the second task we simply expand a description of a map
  ## to all its possible versions. The number of versions is only n*m
  ## so it does not explode.
  ##
  ## If I would have read the instructions more carefully I would have
  ## seen that the original solution should be igored. This was when
  ## realized a small fix to the find/3 function that was given an
  ## extra argument of a mirror to ignore.
  ##
  ## 
  
  def test_a() do
    [one, two] = String.split(sample(), "\n\n")
    one = String.split(one, "\n") |>  
      Enum.map(&String.to_charlist/1) |>
      mirror()
    two = String.split(two, "\n") |>
      Enum.map(fn(row) -> String.to_charlist(row) end) |>
      mirror()
    {one,two}
  end

  def task_a() do
    String.split(File.read!("day13.csv"), "\n\n") |>
      Enum.map(fn(map) -> 
	String.split(map, "\n") |>  
	  Enum.map(&String.to_charlist/1) |>
	  mirror()
      end) |>
      Enum.sum()
  end

  def test_b() do
    [one, two] = String.split(sample(), "\n\n")
    one = String.split(one, "\n") |>  
      Enum.map(&String.to_charlist/1) |>
      search()
    two = String.split(two, "\n") |>
      Enum.map(fn(row) -> String.to_charlist(row) end) |>
      search()
    {one, two}
  end

  def task_b() do
    String.split(File.read!("day13.csv"), "\n\n") |>
      Enum.map(fn(map) -> 
	String.split(map, "\n") |>  
	 Enum.map(&String.to_charlist/1) |>
	 search()
      end) |>
      Enum.sum()
  end

  ## Searching a map in the second task is as before done by first
  ## looking for a horizontal mirror and if not found looking for a
  ## vertical. The difference is that we now have to check all smudged
  ## versions.

  def search(map) do
    case smudge(map) do
      :nil ->
	{:ok, n} = smudge(transform(map))
	n
      {:ok, n} ->
	n*100
    end
  end

  ## This is where we check the all smudged versions of a map but
  ## ignoring the original mirror. Smudging requires b that is the
  ## number of bits in a row decription. This is collected by
  ## parser since it is part of the parsing anyway. 
  
  def smudge(map) do 
    rows = Enum.map(map, fn(row) -> parse(row) end)
    b = elem(hd(rows),1)

    rows = Enum.map(rows, fn({r,_}) -> r end)

    ## find the original in order to avoid it
    o = case find(rows, [], 1, 0) do
	  {:ok, n} -> n
	  :nil -> 0
	end

    smudged = smudged(rows, b, [])    

    Enum.find_value(smudged, fn(rows) -> find(rows, [], 1, o) end)
  end

  def bits(0) do 0 end
  def bits(n) do
    1 + bits(Bitwise.bsr(n,1))
  end
  
  
  ## This is where we expand a map to all possible maps by smudging
  ## one position.
  
  def smudged([], _, _) do [] end
  def smudged([r|rest], b, sofar) do
    smudge(r, rest, b, sofar) ++ smudged(rest, b, [r|sofar])
  end

  def smudge(nr, rest, b, sofar) do
    Enum.map(alter(nr, b), fn(alt) ->
      Enum.reduce(sofar, [alt|rest], fn(s, acc) -> [s|acc] end)
    end)
  end

  def alter(nr, b) do
    Enum.map(0..(b-1), fn(i) -> Bitwise.bxor(nr,Bitwise.bsl(1,i)) end)
  end

  ## This is the first solution. Look for a mirror image first looking
  ## at the rows and then doing a tranformation to examine the
  ## columns. 

  def mirror(map) do 
    case find(map) do
      :nil  ->
	{:ok, n} = find(transform(map))
	n
      {:ok, n} ->
	n*100
    end
  end

  def find(map) do
    rows = Enum.map(map, fn(r) -> elem(parse(r),0) end)
    find(rows, [], 1, 0)
  end

  ## The find(row, sofar, n, x) finds a mirror from position n while
  ## ignoring any mirror at position x. The ignore part was needed for
  ## part two.

  
  def find([], _, _,_) do :nil end
  def find([i|[i|refl]=rest], image, n, n) do
    if (reflection(image, refl) ) do
      find(rest, [i|image], n+1, n)      
    else
      find(rest, [i|image], n+1, n)
    end
  end
  def find([i|[i|refl]=rest], image, n, x) do
    if (reflection(image, refl) ) do
      {:ok, n}
    else
      find(rest, [i|image], n+1, x)
    end
  end
  def find([i|rest], image, n, x) do
    find(rest, [i|image], n+1, x)
  end

    
  def reflection([], _) do true end
  def reflection(_, []) do true end  
  def reflection([x|img], [x|ref]) do
    reflection(img, ref)
  end
  def reflection(_, _) do false end    


  def transform([[]|_]) do [] end
  def transform(rows) do
    {layer, rest} = skim(rows)
    [layer | transform(rest)]
  end

  def skim([]) do {[],[]} end
  def skim([[frst|row]|rows]) do
    {layer, rest} = skim(rows)
    {[frst|layer], [row|rest]}
  end
  

  def parse(row) do
    Enum.reduce(row, {0,1}, fn(char, {n,k}) ->
      case char do
	?# -> {n+trunc(:math.pow(2,k)), k+1}
	?. -> {n,k+1}
      end
    end)
  end


  def sample() do
"#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#"
end


  def larger() do
".......#.####
.......#.####
#..##........
.#...###.##.#
##.#.##.#####
#.#####...#.#
.#.###.####.#
..###....#..#
#.#.####..##.
#.#.####..##.
..###....#..#
.#.###.####.#
#.#####..##.#
##.#.##.#####
.#...###.##.#
#..##........
.......#.####"
  end

  

end
