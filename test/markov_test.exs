defmodule MarkovTest do
  use ExUnit.Case
  doctest Markov

  test "Simple string" do
      assert %{"this" => %{"is" => 1}, "is" => %{"a" => 1}, "a" => %{"test" => 1}, "test" => %{:end => 1}}
            == Markov.build_markov_map("this is a test")
  end

  test "Simple string with duplicates" do
      assert %{"this" => %{"is" => 1}, "is" => %{"a" => 2}, "a" => %{"is" => 1, "test" => 1}, "test" => %{:end => 1}}
            == Markov.build_markov_map("this is a is a test")
  end

  test "Simple string with case insensitive" do
      assert %{"this" => %{"is" => 1}, "is" => %{"a" => 1}, "a" => %{"Is" => 1}, "Is" => %{"A" => 1}, "A" => %{"test" => 1},
                "test" => %{:end => 1}}
              == Markov.build_markov_map("this is a Is A test")
  end

  test "List of simple strings" do
      messages = ["this is a test", "this is not a test"]
      assert %{"this" => %{"is" => 2}, "is" => %{"a" => 1, "not" => 1}, "not" => %{"a" => 1}, "a" => %{"test" => 2},
                 "test" => %{:end => 2}}
              == Markov.build_markov_map(messages)
  end

  test "Large list of strings" do
      n = 100000
      messages = List.duplicate("this is a test", n)
      assert %{"this" => %{"is" => n}, "is" => %{"a" => n}, "a" => %{"test" => n}, "test" => %{:end => n}}
              == Markov.build_markov_map(messages)
  end

  test "Get the only next word " do
        map = %{"this" => %{"is" => 1}}
        assert "is" == Markov.get_next_for_seed(map, "this")
  end

  test "Get the next word of an end signal" do
        map = %{"this" => %{:end => 1}}
        assert nil == Markov.get_next_for_seed(map, "this")
  end

  test "Get one of the next words " do
        possibles = ["is", "a", "test"]
        map = %{"this" => %{"is" => 1, "a" => 1, "test" => 1}}
        assert Enum.member?(possibles, Markov.get_next_for_seed(map, "this"))
  end

  test "Get one of the next words (large population)" do
        possibles = ["is", "a", "test"]
        map = %{"this" => %{"is" => 100000, "a" => 200000, "test" => 3000}}
        assert Enum.member?(possibles, Markov.get_next_for_seed(map, "this"))
  end

  test "Seed has no next possibilities" do
        map = %{"this" => %{"is" => 1}}
        assert nil == Markov.get_next_for_seed(map, "is")
  end

  test "Get test string" do
        map = %{"this" => %{"is" => 1}, "is" => %{"a" => 1}, "a" => %{"test" => 1}}
        assert "this is a test" == Markov.generate_text_chain(map, "this", 4)
  end

  test "Get test string that runs out" do
        map = %{"this" => %{"is" => 1}, "is" => %{"a" => 1}, "a" => %{"test" => 1}}
        assert "this is a test" == Markov.generate_text_chain(map, "this", 10)
  end

  test "Get test string that finds an end before the max limit" do
        map = %{"this" => %{"is" => 1}, "is" => %{:end => 1}, "a" => %{"test" => 1}}
        assert "this is" == Markov.generate_text_chain(map, "this", 10)
  end

  test "Get large test string" do
        map = %{"this" => %{"is" => 100, "a" => 200, "test" => 300},
                "is" => %{"this" => 100, "a" => 200, "test" => 300},
                "a" => %{"is" => 100, "this" => 200, "test" => 300},
                "test" => %{"is" => 100, "a" => 200, "this" => 300}}
        assert Markov.generate_text_chain(map, "this", 1000)
  end

end
