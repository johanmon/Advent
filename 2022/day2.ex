defmodule Day2 do

  ## Day 2 Fairly simple and the only tricky part is kepping track of
  ## if A is rock or scissors. I simply started with cretaing a
  ## sequence of tuples {:A, :Y} etc instead of representing them as
  ## {:rock, :scissors}, which would have made life easier. 
  ## Writing uo the rules was fine once the pattern is clear.

  def input() do
    File.stream!("day2.csv") |>
      Stream.map( fn (r) ->
	[one, two] = String.split(r)
	{String.to_atom(one), String.to_atom(two)}
      end)
  end

  def task_a() do
    input() |>
      Enum.reduce(0, fn (turn, n) -> play_a(turn) + n end)
  end

  def task_b() do
    input() |>
      Enum.reduce(0, fn (turn, n) -> play_b(turn) + n end)
  end  

  def play_a(turn) do
    case turn do
      {:A, :X} ->
	1 + 3
      {:A, :Y} ->
	2 + 6
      {:A, :Z} ->
	3 + 0

      {:B, :X} ->
	1 + 0
      {:B, :Y} ->
	2 + 3
      {:B, :Z} ->
	3 + 6

      {:C, :X} ->
	1 + 6 
      {:C, :Y} ->
	2 + 0
      {:C, :Z} ->
	3 + 3
    end
  end

  def play_b(turn) do
    case turn do
      {:A, :X} ->
	3 + 0
      {:A, :Y} ->
	1 + 3
      {:A, :Z} ->
	2 + 6

      {:B, :X} ->
	1 + 0
      {:B, :Y} ->
	2 + 3
      {:B, :Z} ->
	3 + 6

      {:C, :X} ->
	2 + 0 
      {:C, :Y} ->
	3 + 3
      {:C, :Z} ->
	1 + 6
    end
  end
  
  
end
