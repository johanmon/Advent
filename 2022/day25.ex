defmodule Day25 do


  def task_a() do
    res = File.stream!("day25.csv") |>
      Enum.map(fn(row) -> parse(String.trim(row)) end) |>
      Enum.reduce( 0, fn(snafu, acc) -> decode(snafu) + acc end) 
    :io.format("res = ~w\n", [res])
    encode(res)
  end
  

  def encode(nr) do
    snafu = case encode(nr, {0,[]}) do
	      {0, snafu} ->
		snafu
	      {n, snafu} ->
		[n |snafu]
	    end
    code(snafu)
  end

  def encode(0, {0,snafu}) do {0,[0|snafu]} end
  def encode(0, {1,snafu}) do {0,[1|snafu]} end

  def encode(1, {0,snafu}) do {0,[1|snafu]} end  
  def encode(1, {1,snafu}) do {0,[2|snafu]} end  

  def encode(2, {0,snafu}) do {0,[2|snafu]} end  
  def encode(2, {1,snafu}) do {1,[-2|snafu]} end

  def encode(3, {0,snafu}) do {1,[-2|snafu]} end						    
  def encode(3, {1,snafu}) do {1,[-1|snafu]} end  

  def encode(4, {0,snafu}) do {1,[-1|snafu]} end						    
  def encode(4, {1,snafu}) do {1,[0|snafu]} end  
  
  def encode(n, snafu) do
    r = rem(n, 5)
    k = div(n, 5)
    encode(k, encode(r, snafu))
  end

  def decode(snafu) do
      decode(snafu, 0)
  end

  def decode([], sum) do  sum end
  def decode([n|rest], sum) do
    decode(rest, 5*sum + n)
  end

  def parse(snafu) do
    parse(String.to_charlist(snafu), [])
  end

  def parse([], nr) do Enum.reverse(nr) end
  def parse([char|rest], nr) do
    n = case char do
	  ?2 -> 2
	  ?1 -> 1
	  ?0 -> 0
	  ?\- -> -1
	  ?\= -> -2
	end
    parse(rest, [n|nr])
  end

  def code(snafu) do code(snafu,[]) end
  
  def code([], code) do List.to_string(Enum.reverse(code)) end
  def code([n|snafu], code) do
    char = case n do
	  2 -> ?2
	  1 -> ?1
	  0 -> ?0
	  -1 -> ?\-
	  -2 -> ?\=
	end
    code(snafu, [char|code])
  end
  
  

  def sample() do 
    [
      {"1=-0-2"   , 1747},
      {"12111"   , 906},
      {"2=0="   , 198},
      {"21"   , 11},
      {"2=01"   , 201},
      {"111"   , 31},
      {"20012"   , 1257},
      {"112"   , 32},
      {"1=-1="   , 353},
      {"1-12"   , 107},
      {"12   "   , 7},
      {"1="   , 3},
      {"122",     37}
    ]
  end
















  

end

 
