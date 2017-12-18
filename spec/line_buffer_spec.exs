defmodule LineBufferSpec do
  use ESpec
  it "splits simple one liners" do
    lb = LineBuffer.new("\n")
    {new_lb, lines} = LineBuffer.add_data(lb, "foo\n")
    lines |> should(eq(["foo"]))
    LineBuffer.peek(new_lb) |> should(eq(""))
  end

  it "splits line from partial line" do
    lb = LineBuffer.new("\n")
    {new_lb, lines} = LineBuffer.add_data(lb, "foo\nbar")
    lines |> should(eq(["foo"]))
    LineBuffer.peek(new_lb) |> should(eq("bar"))
  end

  it "splits multiple lines" do
    lb = LineBuffer.new("\n")
    {new_lb, lines} = LineBuffer.add_data(lb, "foo\nbar\n")
    lines |> should(eq(["foo", "bar"]))
    LineBuffer.peek(new_lb) |> should(eq(""))
  end

  it "accumulates lines" do
    lb = LineBuffer.new("\n")
    {new_lb_a, lines_a} = LineBuffer.add_data(lb, "foo\nbar")
    lines_a |> should(eq(["foo"]))
    {new_lb, lines} = LineBuffer.add_data(new_lb_a, "\n")
    lines |> should(eq(["bar"]))
    LineBuffer.peek(new_lb) |> should(eq(""))
  end

  it "handles multiple delimiters" do
    lb = LineBuffer.new("\n")
    {new_lb, lines} = LineBuffer.add_data(lb, "\nfoo\n\nbar\nbaz\n")
    LineBuffer.peek(new_lb) |> should(eq(""))
    lines |> should(eq(["", "foo", "", "bar", "baz"]))
  end
end
