defmodule Day8a do

  ## The first part of the puzzle was quit simple. A map is used to
  ## lookup the state of each node. The parser will transform the
  ## strings to atoms to make things easier to read and probably more
  ## efficient.


  def test() do
    {:puzzle, dir, nodes} = parse(sample())
    nodes = Map.new(nodes)
    search(dir, :AAA, nodes, dir, 0)
  end

  def task() do
    {:puzzle, dir, nodes} = parse(String.trim(File.read!("day8.csv")))
    nodes = Map.new(nodes)
    search(dir, :AAA, nodes, dir, 0)
  end  
  

  def search([], :ZZZ, _, _, n) do n end
  def search([], pos, nodes, dir, n) do
    search(dir, pos, nodes, dir, n)
  end
  def search([d|rest], pos, nodes, dir, n) do
    {left,right} = nodes[pos]
    case d do
      :left -> search(rest, left, nodes, dir, n+1)
      :right -> search(rest, right, nodes, dir, n+1)
    end
  end
  



  def parse(input) do
    [dir, _ | rows] =  String.split(input, "\n")
    dir = Enum.map(String.to_charlist(dir), fn(char) -> case char do
						          ?L -> :left
						          ?R -> :right
					                end
    end)
    rows = Enum.map(rows, fn(row) ->
      <<org::binary-size(3), " ", "=", " ", "(", left::binary-size(3), ","," ", right::binary-size(3), ")">> = row
      {String.to_atom(org),  {String.to_atom(left), String.to_atom(right)}}
    end)
    {:puzzle, dir, rows}
  end
  
      
  def sample() do
"LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)"
  end
  


end
