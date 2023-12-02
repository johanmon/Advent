defmodule Day2 do


  ## A day with a lot of parsing only to get the data in some
  ## seinsible form. Once in something that one can work with the
  ## summing up was not too problematic. Took some easy ways out and
  ## checked each color separately. 
  

  def test_a() do
    Enum.map( String.split(sample(), "\n"),  fn(row) -> parse(row) end) |>
      Enum.filter( fn({:game, _, draws}) -> check(draws) end) |>
      List.foldl( 0, fn({:game, id, _}, acc) -> id + acc end)
  end

  def test_b() do
    Enum.map( String.split(sample(), "\n"),  fn(row) -> parse(row) end) |>
      Enum.map( fn({:game, _, draws}) -> List.foldl(draws, {0,0,0}, fn(draw, acc) -> minimum(draw, acc) end) end) |>
      Enum.map( fn({r,g,b}) -> r*g*b end) |>
      Enum.sum()
  end

  
  def task_a() do
    File.stream!("day2.csv") |>
      Stream.map( fn(row) -> parse(row) end) |>
      Stream.filter( fn({:game, _, draws}) -> check(draws) end) |>
      Enum.reduce( 0, fn({:game, id, _}, acc) -> id + acc end)
  end

  def task_b() do
    File.stream!("day2.csv") |> 
      Stream.map(fn(row) -> parse(row) end) |>
      Stream.map( fn({:game, _, draws}) -> List.foldl(draws, {0,0,0}, fn(draw, acc) -> minimum(draw, acc) end) end) |>
      Stream.map( fn({r,g,b}) -> r*g*b end) |>
      Enum.sum()
  end  

  def minimum(draw,{red,green,blue}) do minimum(draw, red, green, blue) end

  def minimum([], red, green, blue) do {red, green, blue} end
  def minimum([{:red, c}|rest],  red, green, blue) do
    minimum(rest, max(red,c), green , blue)
  end
  def minimum([{:green, c}|rest], red, green, blue) do
    minimum(rest, red, max(green,c) , blue)
  end
  def minimum([{:blue, c}|rest], red, green, blue) do
    minimum(rest, red, green , max(c, blue))
  end  
  
  ## "only 12 red cubes, 13 green cubes, and 14 blue cubes?"

  def check([]) do true end
  def check([draw | rest]) do
    if check(draw, :red, 12) && check(draw, :green, 13) && check(draw, :blue, 14) do
      check(rest)
    else
      false
    end
  end
  
  
  def check([], _, _) do true end
  def check([{color, c}|rest], color, k) do
    if ( c <= k ) do
      check(rest, color, k - c)
    else
      false
    end
  end
  def check([_|rest], color, k) do
    check(rest, color, k)
  end  
  

  ## "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue"

  def parse(row)  do
    trimed = String.trim(row)
    [game , rest] =  String.split(trimed, ":")
    ["Game", id] = String.split(game, " ")
    draws = Enum.map(String.split(rest, ";"), fn (dr) ->
      Enum.map(String.split(dr, ","), 
        fn(desc) ->
	  pair(String.split(desc, " "))
        end)
    end)
    {:game, String.to_integer(id), draws}
  end

  def pair([_, nr, color]) do
    case color do
      "red" ->
	{:red, String.to_integer(nr)}
      "blue" ->
	{:blue, String.to_integer(nr)}
      "green" ->
	{:green, String.to_integer(nr)} 
    end
  end
    



    
  def sample() do
"Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
  end
  

end
