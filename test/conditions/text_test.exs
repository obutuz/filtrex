defmodule FiltrexConditionTextTest do
  use ExUnit.Case
  alias Filtrex.Condition.Text

  @config Filtrex.SampleModel.filtrex_config

  test "parsing errors" do
    assert {:error, "Invalid text value for title"} == Text.parse(@config, %{
      inverse: false,
      column: "title",
      value: %{},
      comparator: "equals"
    })
    assert {:error, "Invalid text comparator 'between'"} == Text.parse(@config, %{
      inverse: false,
      column: "title",
      value: "Buy Milk",
      comparator: "between"
    })
  end

  test "encoding as SQL fragments for ecto" do
    {:ok, condition} = Text.parse(@config, %{inverse: false, column: "title", value: "Buy Milk", comparator: "equals"})
    encoded = Filtrex.Encoder.encode(condition)
    assert encoded.values == ["Buy Milk"]
    assert encoded.expression == "title = ?"

    {:ok, condition} = Text.parse(@config, %{inverse: false, column: "title", value: "Buy Milk", comparator: "does not equal"})
    encoded = Filtrex.Encoder.encode(condition)
    assert encoded.expression == "title != ?"

    {:ok, condition} = Text.parse(@config, %{inverse: false, column: "title", value: "Buy Milk", comparator: "contains"})
    encoded = Filtrex.Encoder.encode(condition)
    assert encoded.expression == "lower(title) LIKE lower(?)"

    {:ok, condition} = Text.parse(@config, %{inverse: false, column: "title", value: "Buy Milk", comparator: "does not contain"})
    encoded = Filtrex.Encoder.encode(condition)
    assert encoded.expression == "lower(title) NOT LIKE lower(?)"
    assert encoded.values == ["%Buy Milk%"]
  end
end
