defmodule Day1 do

  ## Day 1 A simple task to sum sequences ... if you only read the instructions :-) 
  ## 

  def task_a() do
    File.stream!("day1.csv") |>
      Stream.map( fn (r) -> decode(r)  end ) |>
      Enum.sum()
  end

  def task_b() do
    File.stream!("day1.csv") |>    
      Stream.map(fn(r) -> filter(r) end) |>
      Enum.map(fn(r) -> decode(r) end) |>
      Enum.sum()
  end


  def test_a() do
    str = ["1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet"]
    Enum.map( str, fn(r) -> decode(r) end)
  end

  def test_b() do
    str = ["two1nine", "eightwothree", "abcone2threexyz", "xtwone3four", "4nineeightseven2", "oneight234", "7pqrstsixteen"]
    Enum.map( str, fn(r) -> filter(r) end) |>
      Enum.map(fn(r) -> decode(r) end)
  end  
  

  def decode(row) do
    	case List.foldl(String.to_charlist(row), :none, 
   	   fn (chr, acc) ->
	     if ((chr >= 48) && (chr <= 57)) do
	       case acc do	   
 		 :none ->	   
		   {:one, chr - 48}
		 {:one, i} ->
		   {:two, i, (chr - 48)}
		 {:two, i, _} ->
		   {:two, i, (chr - 48)}
	       end
	     else
	       acc
	     end
	      end) do
	  {:one, i} ->
	    i*10 + i
	  {:two, i, j} ->
	    i*10 + j
	end
  end

  ##  Running through the string nine times can not be the most
  ##  efficient way of solving this but it works.

  def filter(r) do
      r |>
      String.replace("one",   "o1e") |>
      String.replace("two",   "t2o") |>    
      String.replace("three", "t3e") |>
      String.replace("four",  "4") |>
      String.replace("five",  "5e") |>
      String.replace("six",   "6") |>    
      String.replace("seven", "7n") |>
      String.replace("eight", "e8t") |>
      String.replace("nine",  "9e")
  end
  
  
    

  
end
