defmodule Day15 do

  ## Friday fun and rather quickly solved. The trucy part was more
  ## reading the instructions and realizing in what order the lenses
  ## were added.
  ##
  ## A map structure is used to keep track of the boxes and it works
  ## fine. Some care is taken not to add or keep boxes that have no
  ## lenses.

  def test_a() do
    sample() |>
      parse() |>
      Enum.map( &String.to_charlist/1) |>
      Enum.map( &hash/1)
  end

  def task_a() do
    File.read!("day15.csv") |>
      parse() |>
      Enum.map( &String.to_charlist/1) |>
      Enum.map( &hash/1) |>
      Enum.sum()
  end  


  def test_b() do
    sample() |>
      parse() |>
      Enum.map( &decode/1) |>
      Enum.reduce(%{}, &initialize/2) |>
      Enum.map(&focusing_power/1) |>
      Enum.sum()
  end

  def task_b() do
    File.read!("day15.csv") |>
      parse() |>
      Enum.map( &decode/1) |>
      Enum.reduce(%{}, &initialize/2) |>
      ## number_of_boxes() |>
      Enum.map(&focusing_power/1) |>
      Enum.sum()
  end


  def number_of_boxes(map) do
    :io.format("number of boxes: ~w~n", [ length(Enum.to_list(map))])
    map
  end

  
  ## The initailization becomes trivial ones we have the supporting
  ## functions to add and remoev a lens. In the second clause we can
  ## not use Map.update/4 sice we would then add an entry box => [] if
  ## we removed a lens in a box that did not exist. No worries but why
  ## add boxes if they are not needed. We also remove boxes from the
  ## map if they are empty. Might not mean very much but we keep the
  ## number of boxes down to 168 in the assignment.

  def initialize({:add, box, label, f}, boxes) do
    Map.update(boxes, box, [{:lens, label, f}], fn(lenses) -> 
      add_lens(lenses, label, f)
    end)
  end
  
  def initialize({:rem, box, label}, boxes) do
    case Map.get(boxes, box) do
      :nil ->
        ## :io.format("no empty box added\n")
	boxes
      lenses ->
	case rem_lens(lenses, label) do
	  [] ->
	    ## :io.format("deleting box\n")
	    Map.delete(boxes, box)
	  lenses ->
	    Map.put(boxes, box, lenses)
	end
    end
  end  

  ## The order of the lenses is of course important. In this solution
  ## they are represented aina list [slot 1, slot 2 .... ]  This makes
  ## the focusing power ealser to calculate and also makes it easy to
  ## add a new lens in a new slot i.e. as the last position, if no
  ## matching label is found.
  

  def add_lens([], label, f) do  [{:lens, label, f}] end
  def add_lens([{:lens, label, _}|rest], label, f) do
    [{:lens, label, f}| rest]
  end
  def add_lens([first|rest], label, f) do
    [first|add_lens(rest, label, f)]
  end
  
  def rem_lens(lenses, label) do
    List.keydelete(lenses, label, 1)
  end

    
  def focusing_power({nr, lenses}) do
    elem(Enum.reduce(lenses, {0,1}, fn({:lens, _, f}, {s,i}) ->
      {s + ((nr+1)*i*f), i+1}
    end),0)
  end

  

  ## For the first task the parser did the conversion to char_lists
  ## but this is now better done in the decode phase since it allows
  ## us to use the strings as labels (more efficient to compare).

  def decode(instr) do
    case String.split(instr,["=","-"]) do
      [label, ""] ->
	{:rem, hash(String.to_charlist(label)), label}
      [label, nr] ->
	{:add, hash(String.to_charlist(label)), label, elem(Integer.parse(nr),0)}
    end
  end

  ##    Determine the ASCII code for the current character of the string.
  ##    Increase the current value by the ASCII code you just determined.
  ##    Set the current value to itself multiplied by 17.
  ##    Set the current value to the remainder of dividing itself by 256.

  def hash(str) do 
    Enum.reduce(str, 0, fn(c, s) -> rem( (s+c)*17, 256) end)
  end

  ## The parser only splits the whole input string into instrcutions
  ## but does not interpret them. 
  
  def parse(str) do
    String.split(str, ",")
  end


  def sample() do "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7" end


end
