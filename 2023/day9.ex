defmodule Day9 do


  def test_a() do
    String.split(sample(), "\n") |>
      Enum.map(fn(row) -> parse(row) end) |>
      Enum.map(fn(row) -> down(row) end) |>
      Enum.map(fn(seq) -> nxt(seq) end) |>
      Enum.sum()
  end

  def task_a() do
    File.stream!("day9.csv") |>
      Enum.map(fn(row) -> parse(row) end) |>
      Enum.map(fn(row) -> down(row) end) |>
      Enum.map(fn(seq) -> nxt(seq) end) |>
      Enum.sum()
  end

  def test_b() do
    String.split(sample(), "\n") |>
      Enum.map(fn(row) -> parse(row) end) |>
      Enum.map(fn(row) -> Enum.reverse(row) end) |>
      Enum.map(fn(row) -> prev(row) end) |>
      Enum.map(fn(seq) -> back(seq) end) |>
      Enum.sum()
  end

  def task_b() do
    File.stream!("day9.csv") |>
      Enum.map(fn(row) -> parse(row) end) |>
      Enum.map(fn(row) -> Enum.reverse(row) end) |>
      Enum.map(fn(row) -> prev(row) end) |>
      Enum.map(fn(seq) -> back(seq) end) |>
      Enum.sum()
  end


  def nxt([0]) do 0 end
  def nxt([x|rest]) do
    x + nxt(rest)
  end

  def back([0]) do 0 end
  def back([x|rest]) do
    x - back(rest)
  end  

  def prev(row) do
    ## :io.format(" down : ~w~n", [row])    
    case daff(row) do
      {_, 0, 0} ->
	[0]
      {row, last, _} ->
	[last | prev(row)]
    end
  end

  def down(row) do
    ## :io.format(" down : ~w~n", [row])
    case diff(row) do
      {_, 0, 0} ->
	[0]
      {row, last, _} ->
	[last | down(row)]
    end
  end
  

  def diff([a1,a2]) do
    {[a2-a1], a2, a2-a1}
  end 
  def diff([a1,a2|rest]) do
    {rest, last, mx} = diff([a2|rest])
    {[a2-a1|rest], last, max(a2-a1, mx)}
  end
			   

  def daff([a1,a2]) do
    {[a1-a2], a2, a1-a2}
  end 
  def daff([a1,a2|rest]) do
    {rest, last, mx} = daff([a2|rest])
    {[a1-a2|rest], last, max(a1-a2, mx)}
  end
			   
  

  def parse(row) do
    String.split(row, " ") |>
      Enum.map(fn(nr) ->
	{nr, _} = Integer.parse(nr)
	nr
      end)
  end
 

    

  def sample() do
"0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"
  end
  

    

  

end
