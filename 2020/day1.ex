defmodule Day1 do

  def task_a() do
    sorted = File.stream!("day1.csv") |>
      Enum.map(fn(row) -> {nr,_} = Integer.parse(row); nr end) |>
      Enum.sort()
    {a, b} = find_two(sorted, 2020)
    a * b
  end

  def task_b() do
    sorted = File.stream!("day1.csv") |>
      Enum.map(fn(row) -> {nr,_} = Integer.parse(row); nr end) |>
      Enum.sort()
    {a, b, c} = find_three(sorted, 2020)
    a * b * c
  end  

  def find_three([a|rest], n) do
    case find_two(rest, n - a) do
      nil ->
	find_three(rest, n)
      {b,c} -> {a, b, c}
    end
  end

  def find_two([], _) do nil end
  def find_two([x|_], n) when x > n do nil end  
  def find_two([a|rest], n) do
    case find_one(rest, n - a) do
      nil ->
	find_two(rest, n)
      b ->
	{a,b}
    end
  end
  
  def find_one([], _) do nil end
  def find_one([b|_], b) do b end
  def find_one([x|_], b) when x > b do nil end  
  def find_one([_|rest], b) do find_one(rest,b) end  
    

end
