
defmodule Day7a do


  def test() do
    Enum.map(String.split(sample(), "\n"), fn(row) -> parse(row) end) |>
      Enum.map(fn({:hand, hand, bid}) -> {:hand, type(hand), hand, bid} end) |>
      Enum.sort(fn(x,y) -> less(x,y) end) |>
      List.foldl( {1,0}, fn({:hand, _,_,bid}, {n,acc}) -> {n+1,bid*n+acc} end)
  end

  def task() do
    File.stream!("day7.csv") |>
      Stream.map(fn(row) -> parse(row) end) |>
      Stream.map(fn({:hand, hand, bid}) -> {:hand, type(hand), hand, bid} end) |>
      Enum.sort(fn(x,y) -> less(x,y) end) |>
      List.foldl( {1,0}, fn({:hand, _,_,bid}, {n,acc}) -> {n+1,bid*n+acc} end)
  end
  
  

  def less({:hand, t1, h1, _}, {:hand, t2, h2, _}) do
    cond do 
      t1 < t2 -> true
      t1 == t2 -> (h1 < h2)
      true -> false
    end
  end
  

  

  def type(hand) do
    case Enum.sort(hand) do
      [x,x,x,x,x] -> 7 ## :five
      [x,x,x,x,_] -> 6 ## :four
      [_,x,x,x,x] -> 6 ## :four
      [x,x,x,y,y] -> 5 ## :house
      [x,x,y,y,y] -> 5 ## :house      
      [x,x,x,_,_] -> 4 ## :three            
      [_,x,x,x,_] -> 4 ## :three            
      [_,_,x,x,x] -> 4 ## :three            
      [x,x,y,y,_] -> 3 ## :two            
      [x,x,_,y,y] -> 3 ## :two            
      [_,x,x,y,y] -> 3 ## :two            
      [x,x,_,_,_] -> 2 ## :one
      [_,x,x,_,_] -> 2 ## :one
      [_,_,x,x,_] -> 2 ## :one
      [_,_,_,x,x] -> 2 ## :one      
      [a,b,c,d,e] when (a != b) and (b != c) and (c != d) and (d != e) -> 1 ## high
      _ -> 0 ## :nada
    end
  end


  

  
  def parse(row) do
    [hand, bid] = String.split(String.trim(row))
    {bid,_} = Integer.parse(bid)
    hand =  Enum.map(String.to_charlist(hand), fn(x) -> label(x) end)
    {:hand ,hand, bid}
  end

  def label(char) do
    case char do
      ?A -> 14
      ?K -> 13
      ?Q -> 12
      ?J -> 11
      ?T -> 10
      nr -> nr - ?0
    end
  end
  
  
  def sample() do
"32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"
  end

end
