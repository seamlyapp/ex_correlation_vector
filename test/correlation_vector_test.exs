defmodule CorrelationVectorTest do
  use ExUnit.Case
  doctest CorrelationVector

  alias CorrelationVector

  describe "to_string" do
    test "should create a string from the vector" do
      {:ok, cv} = CorrelationVector.parse("Y58xO9ov0kmpPvkiuzMUVA.3.4.5")
      assert "Y58xO9ov0kmpPvkiuzMUVA.3.4.5" == to_string(cv)
    end
  end

  describe "safe_parse/1" do
    test "it should be able to Parse v2 vector" do
      cv = CorrelationVector.safe_parse("Y58xO9ov0kmpPvkiuzMUVA.3.4.5")
      assert cv.base_vector == "Y58xO9ov0kmpPvkiuzMUVA.3.4"
      assert cv.extension == 5
      assert cv.immutable == false

      cv = CorrelationVector.safe_parse("Y58xO9ov0kmpPvkiuzMUVA.1!")
      assert cv.base_vector == "Y58xO9ov0kmpPvkiuzMUVA"
      assert cv.extension == 1
      assert cv.immutable == true
    end

    test "it should create a new vector if string can't be parsed" do
      cv = CorrelationVector.safe_parse("Y58xO9ov0kmpPvkiuzMU.1")
      assert cv.base_vector != "Y58xO9ov0kmpPvkiuzMU"
      assert cv.extension == 0
      assert cv.immutable == false
    end
  end

  describe "parse/1" do
    test "it should be able to Parse v2 vector" do
      {:ok, cv} = CorrelationVector.parse("Y58xO9ov0kmpPvkiuzMUVA.3.4.5")
      assert cv.base_vector == "Y58xO9ov0kmpPvkiuzMUVA.3.4"
      assert cv.extension == 5
      assert cv.immutable == false

      {:ok, cv} = CorrelationVector.parse("Y58xO9ov0kmpPvkiuzMUVA.1!")
      assert cv.base_vector == "Y58xO9ov0kmpPvkiuzMUVA"
      assert cv.extension == 1
      assert cv.immutable == true
    end

    test "it should not extend from empty cV" do
      assert {:error, "Invalid correlation vector \"\"."} = CorrelationVector.parse("")
    end

    test "it should error with insufficient chars" do
      assert {:error, "Invalid correlation vector \"tul4NUsfs9Cl7mO.1\"."} =
               CorrelationVector.parse("tul4NUsfs9Cl7mO.1")
    end

    test "it should error with too many chars" do
      assert {:error, "Invalid correlation vector \"Y58xO9ov0kmpPvkiuzMUVAextra.1\"."} =
               CorrelationVector.parse("Y58xO9ov0kmpPvkiuzMUVAextra.1")
    end

    test "it should error with too big value" do
      assert {:error,
              "The Elixir.CorrelationVector.V2 correlation vector can not be bigger than 127 characters"} =
               CorrelationVector.parse(
                 "KZY+dsX2jEaZesgCPjJ2Ng.2147483647.2147483647.2147483647.2147483647.2147483647.2147483647.2147483647.2147483647.2147483647.2147483647"
               )
    end

    test "it should error with negative extension value" do
      assert {:error,
              "Invalid correlation vector \"Y58xO9ov0kmpPvkiuzMUVA.-10\". Invalid extension value -10"} =
               CorrelationVector.parse("Y58xO9ov0kmpPvkiuzMUVA.-10")
    end
  end

  describe "increment/1" do
    test "it should be able to increment cV" do
      cv = CorrelationVector.new()
      incremented_cv = CorrelationVector.increment(cv)

      assert cv.extension == 0
      assert incremented_cv.extension == 1
    end
  end

  describe "safe_extend/1" do
    test "it should be able to extend cV" do
      cv = CorrelationVector.new()
      extended_cv = CorrelationVector.safe_extend(cv)

      assert extended_cv.base_vector == "#{cv.base_vector}.#{cv.extension}"
      assert extended_cv.extension == 0
      assert extended_cv.immutable == false
    end

    test "it should be able to extend cV from string" do
      vector = "Y58xO9ov0kmpPvkiuzMUVA.3"
      extended_cv = CorrelationVector.safe_extend(vector)

      assert extended_cv.base_vector == vector
      assert extended_cv.extension == 0
      assert extended_cv.immutable == false
    end

    test "it should not extend from empty cV" do
      extended_cv = CorrelationVector.safe_extend("")

      assert %CorrelationVector{} = extended_cv
    end
  end

  describe "extend/1" do
    test "it should be able to extend cV" do
      cv = CorrelationVector.new()
      assert {:ok, extended_cv} = CorrelationVector.extend(cv)

      assert extended_cv.base_vector == "#{cv.base_vector}.#{cv.extension}"
      assert extended_cv.extension == 0
      assert extended_cv.immutable == false
    end

    test "it should be able to extend cV from string" do
      vector = "Y58xO9ov0kmpPvkiuzMUVA.3"
      assert {:ok, extended_cv} = CorrelationVector.extend(vector)

      assert extended_cv.base_vector == vector
      assert extended_cv.extension == 0
      assert extended_cv.immutable == false
    end
  end

  # it("should be immutable when increment past max for v2 version", () => {
  #     CorrelationVector.validateCorrelationVectorDuringCreation = false;
  #     const base: string = "KZY+dsX2jEaZesgCPjJ2Ng.2147483647.2147483647.2147483647" +
  #         ".2147483647.2147483647.2147483647.2147483647.2147483647.2147483647.214";
  #     const vector: CorrelationVector =
  #         CorrelationVector.extend(base);
  #     vector.increment();
  #     if (`${base}.1` !== vector.value) {
  #         fail("Expect 1 on increment");
  #     }
  #     for (let i: number = 0; i < 20; i++) {
  #         vector.increment();
  #     }
  #     expect(vector.value).toBe(`${base}.9!`);
  # });
  # end
end
