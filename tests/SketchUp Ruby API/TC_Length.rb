# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen


require "testup/testcase"


# class Length
# http://www.sketchup.com/intl/developer/docs/ourdoc/length
class TC_Length < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  # http://stackoverflow.com/a/736313/486990
  FIXNUM_MAX = (2**(0.size * 8 -2) -1)
  FIXNUM_MIN = -(2**(0.size * 8 -2))

  BIGNUM = (FIXNUM_MAX * 2) + 10


  # ========================================================================== #
  # class Math
  # The Math class also fails under SU2015 64bit because it performs some low
  # level type checks.

  def test_Math_sqrt_with_Length
    assert_equal(3.0, Math.sqrt(9.to_l))
  end


  # ========================================================================== #
  # module Marshal

  def test_Marshal_dump_and_load
    length = 10.to_l
    data = Marshal.dump(length)
    restored = Marshal.load(data)
    assert_equal(length, restored)
    # Cannot test class here because in SU2014 and older a marshalled Length
    # would be restored as Float, which should be considered a bug.
    # We just test that the restored data is equal to the dumped data.
  end


  # ========================================================================== #
  # Interoperability Operator Plus

  def test_Length_plus_Fixnum
    assert_equal(12.0, 10.to_l + 2)
  end

  def test_Length_plus_Bignum
    result = 10.to_l + BIGNUM
    expected = 10.0 + BIGNUM
    assert_kind_of(Float, result)
    assert_equal(expected, result)
  end

  def test_Length_plus_Float
    assert_equal(12.0, 10.to_l + 2.0)
  end

  def test_Fixnum_plus_Length
    assert_equal(12.0, 2 + 10.to_l)
  end

  def test_Bignum_plus_Length
    result = BIGNUM + 10.to_l
    expected = BIGNUM + 10.0
    assert_kind_of(Float, result)
    assert_equal(expected, result)
  end

  def test_Float_plus_Length
    assert_equal(12.0, 2.0 + 10.to_l)
  end


  # ========================================================================== #
  # Interoperability Operator Minus

  def test_Length_minus_Fixnum
    assert_equal(8.0, 10.to_l - 2)
  end

  def test_Length_minus_Bignum
    result = -10.to_l - BIGNUM
    expected = -10.0 - BIGNUM
    assert_kind_of(Float, result)
    assert_equal(expected, result)
  end

  def test_Length_minus_Float
    assert_equal(8.0, 10.to_l - 2.0)
  end

  def test_Fixnum_minus_Length
    assert_equal(-8.0, 2 - 10.to_l)
  end

  def test_Bignum_minus_Length
    result = BIGNUM - 10.to_l
    expected = BIGNUM - 10.0
    assert_kind_of(Float, result)
    assert_equal(expected, result)
  end

  def test_Float_minus_Length
    assert_equal(-8.0, 2.0 - 10.to_l)
  end


  # ========================================================================== #
  # Interoperability Operator Multiply

  def test_Length_multiply_Fixnum
    assert_equal(20.0, 10.to_l * 2)
  end

  def test_Length_multiply_Bignum
    result = 2.to_l * BIGNUM
    expected = 2.0 * BIGNUM
    assert_kind_of(Float, result)
    assert_equal(expected, result)
  end

  def test_Length_multiply_Float
    assert_equal(20.0, 10.to_l * 2.0)
  end

  def test_Fixnum_multiply_Length
    assert_equal(20.0, 2 * 10.to_l)
  end

  def test_Bignum_multiply_Length
    result = BIGNUM * 2.to_l
    expected = BIGNUM * 2.0
    assert_kind_of(Float, result)
    assert_equal(expected, result)
  end

  def test_Float_multiply_Length
    assert_equal(20.0, 2.0 * 10.to_l)
  end


  # ========================================================================== #
  # Interoperability Operator Plus

  def test_Length_plus_Fixnum
    assert_equal(12.0, 10.to_l + 2)
  end

  def test_Length_plus_Bignum
    result = 10.to_l + BIGNUM
    expected = 10.0 + BIGNUM
    assert_kind_of(Float, result)
    assert_equal(expected, result)
  end

  def test_Length_plus_Float
    assert_equal(12.0, 10.to_l + 2.0)
  end

  def test_Fixnum_plus_Length
    assert_equal(12.0, 2 + 10.to_l)
  end

  def test_Bignum_plus_Length
    result = BIGNUM + 10.to_l
    expected = BIGNUM + 10.0
    assert_kind_of(Float, result)
    assert_equal(expected, result)
  end

  def test_Float_plus_Length
    assert_equal(12.0, 2.0 + 10.to_l)
  end


  # ========================================================================== #
  # Interoperability Operator Modulo

  def test_Length_modulo_Fixnum
    assert_equal(2.5, 5.5.to_l % 3)
  end

  def test_Length_modulo_Float
    assert_equal(2.5, 5.5.to_l % 3.0)
  end

  def test_Fixnum_modulo_Length
    assert_equal(2.0, 5 % 3.to_l)
  end

  def test_Float_modulo_Length
    assert_equal(2.5, 5.5 % 3.to_l)
  end


  # ========================================================================== #
  # Interoperability Operator Pow

  def test_Length_pow_Fixnum
    assert_equal(25.0, 5.0.to_l ** 2)
  end

  def test_Length_pow_Float
    assert_equal(25.0, 5.0.to_l ** 2.0)
  end

  def test_Fixnum_pow_Length
    assert_equal(25.0, 5 ** 2.to_l)
  end

  def test_Float_pow_Length
    assert_equal(25.0, 5.0 ** 2.to_l)
  end


  # ========================================================================== #
  # method Length.==
  # http://www.sketchup.com/intl/developer/docs/ourdoc/length#==

  def test_Operator_Equal_api_example
    length1 = 20.to_l
    length2 = 30.to_l
    is_equal = length1 == length2
  end

  def test_Operator_Equal_Length_is_greater_than_Length
    length1 = 12.to_l
    length2 = 11.to_l
    result = length1 == length2
    assert_equal(false, result)
  end

  def test_Operator_Equal_Length_is_equal_Length_with_tolerance
    length1 = 11.to_l
    length2 = (11.0 + SKETCHUP_FLOAT_TOLERANCE).to_l
    result = length1 == length2
    assert_equal(true, result)
  end

  def test_Operator_Equal_Length_is_equal_Length
    length1 = 12.to_l
    length2 = 12.to_l
    result = length1 == length2
    assert_equal(true, result)
  end

  def test_Operator_Equal_Length_is_less_than_Length
    length1 = 11.to_l
    length2 = 12.to_l
    result = length1 == length2
    assert_equal(false, result)
  end

  def test_Operator_Equal_Length_is_greater_than_Float
    length1 = 12.to_l
    length2 = 11.to_l.to_f
    result = length1 == length2
    assert_equal(false, result)
  end

  def test_Operator_Equal_Length_is_equal_Float
    length1 = 12.to_l
    length2 = 12.to_l.to_f
    result = length1 == length2
    assert_equal(true, result)
  end

  def test_Operator_Equal_Length_is_less_than_Float
    length1 = 11.to_l
    length2 = 12.to_l.to_f
    result = length1 == length2
    assert_equal(false, result)
  end

  def test_Operator_Equal_Float_is_greater_than_Length
    length1 = 12.to_l.to_f
    length2 = 11.to_l
    result = length1 == length2
    assert_equal(false, result)
  end

  def test_Operator_Equal_Float_is_equal_Length
    length1 = 12.to_l.to_f
    length2 = 12.to_l
    result = length1 == length2
    assert_equal(true, result)
  end

  def test_Operator_Equal_Float_is_less_than_Length
    length1 = 11.to_l.to_f
    length2 = 12.to_l
    result = length1 == length2
    assert_equal(false, result)
  end

  def test_Operator_Equal_invalid_argument_string
    length1 = 12.to_l
    length2 = "I am not a Length!"
    assert_raises ArgumentError do
      result = length1 == length2
    end
  end

  def test_Operator_Equal_invalid_argument_numeric_string
    length1 = 12.to_l
    length2 = "11"
    assert_raises ArgumentError do
      result = length1 == length2
    end
  end

  def test_Operator_Equal_invalid_argument_point
    length1 = 12.to_l
    length2 = ORIGIN
    assert_raises ArgumentError do
      result = length1 == length2
    end
  end


  # ========================================================================== #
  # method Length.>
  # http://www.sketchup.com/intl/developer/docs/ourdoc/length#>

  def test_Operator_GreaterThan_api_example
    length1 = 11.to_l
    length2 = 12.to_l
    if length1 > length2
      puts "length1 is greater than length2"
    else
      puts "length1 is not greater than length2"
    end
  end

  def test_Operator_GreaterThan_Length_is_greater_than_Length
    length1 = 12.to_l
    length2 = 11.to_l
    result = length1 > length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThan_Length_is_equal_Length_with_tolerance
    length1 = 11.to_l
    length2 = (11.0 + SKETCHUP_FLOAT_TOLERANCE).to_l
    result = length1 > length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThan_Length_is_equal_Length
    length1 = 12.to_l
    length2 = 12.to_l
    result = length1 > length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThan_Length_is_less_than_Length
    length1 = 11.to_l
    length2 = 12.to_l
    result = length1 > length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThan_Length_is_greater_than_Float
    length1 = 12.to_l
    length2 = 11.to_l.to_f
    result = length1 > length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThan_Length_is_equal_Float
    length1 = 12.to_l
    length2 = 12.to_l.to_f
    result = length1 > length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThan_Length_is_less_than_Float
    length1 = 11.to_l
    length2 = 12.to_l.to_f
    result = length1 > length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThan_Float_is_greater_than_Length
    length1 = 12.to_l.to_f
    length2 = 11.to_l
    result = length1 > length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThan_Float_is_equal_Length
    length1 = 12.to_l.to_f
    length2 = 12.to_l
    result = length1 > length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThan_Float_is_less_than_Length
    length1 = 11.to_l.to_f
    length2 = 12.to_l
    result = length1 > length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThan_invalid_argument_string
    length1 = 12.to_l
    length2 = "I am not a Length!"
    assert_raises ArgumentError do
      result = length1 > length2
    end
  end

  def test_Operator_GreaterThan_invalid_argument_numeric_string
    length1 = 12.to_l
    length2 = "11"
    assert_raises ArgumentError do
      result = length1 > length2
    end
  end

  def test_Operator_GreaterThan_invalid_argument_point
    length1 = 12.to_l
    length2 = ORIGIN
    assert_raises ArgumentError do
      result = length1 > length2
    end
  end


  # ========================================================================== #
  # method Length.>=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/length#>=

  def test_Operator_GreaterThanOrEqual_api_example
    length1 = 11.to_l
    length2 = 12.to_l
    if length1 >= length2
      puts "length1 is greater than or equal length2"
    else
      puts "length1 is less than length2"
    end
  end

  def test_Operator_GreaterThanOrEqual_Length_is_greater_than_Length
    length1 = 12.to_l
    length2 = 11.to_l
    result = length1 >= length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThanOrEqual_Length_is_equal_Length_with_tolerance
    length1 = 11.to_l
    length2 = (11.0 + SKETCHUP_FLOAT_TOLERANCE).to_l
    result = length1 >= length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThanOrEqual_Length_is_equal_Length
    length1 = 12.to_l
    length2 = 12.to_l
    result = length1 >= length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThanOrEqual_Length_is_less_than_Length
    length1 = 11.to_l
    length2 = 12.to_l
    result = length1 >= length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThanOrEqual_Length_is_greater_than_Float
    length1 = 12.to_l
    length2 = 11.to_l.to_f
    result = length1 >= length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThanOrEqual_Length_is_equal_Float
    length1 = 12.to_l
    length2 = 12.to_l.to_f
    result = length1 >= length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThanOrEqual_Length_is_less_than_Float
    length1 = 11.to_l
    length2 = 12.to_l.to_f
    result = length1 >= length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThanOrEqual_Float_is_greater_than_Length
    length1 = 12.to_l.to_f
    length2 = 11.to_l
    result = length1 >= length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThanOrEqual_Float_is_equal_Length
    length1 = 12.to_l.to_f
    length2 = 12.to_l
    result = length1 >= length2
    assert_equal(true, result)
  end

  def test_Operator_GreaterThanOrEqual_Float_is_less_than_Length
    length1 = 11.to_l.to_f
    length2 = 12.to_l
    result = length1 >= length2
    assert_equal(false, result)
  end

  def test_Operator_GreaterThanOrEqual_invalid_argument_string
    length1 = 12.to_l
    length2 = "I am not a Length!"
    assert_raises ArgumentError do
      result = length1 >= length2
    end
  end

  def test_Operator_GreaterThanOrEqual_invalid_argument_numeric_string
    length1 = 12.to_l
    length2 = "11"
    assert_raises ArgumentError do
      result = length1 >= length2
    end
  end

  def test_Operator_GreaterThanOrEqual_invalid_argument_point
    length1 = 12.to_l
    length2 = ORIGIN
    assert_raises ArgumentError do
      result = length1 >= length2
    end
  end


  # ========================================================================== #
  # method Length.<
  # http://www.sketchup.com/intl/developer/docs/ourdoc/length#<

  def test_Operator_LessThan_api_example
    length1 = 12.to_l
    length2 = 11.to_l
    if length1 < length2
      puts "length1 is less than length2"
    else
      puts "length1 is not less than length2"
    end
  end

  def test_Operator_LessThan_Length_is_greater_than_Length
    length1 = 12.to_l
    length2 = 11.to_l
    result = length1 < length2
    assert_equal(false, result)
  end

  def test_Operator_LessThan_Length_is_equal_Length_with_tolerance
    length1 = 11.to_l
    length2 = (11.0 + SKETCHUP_FLOAT_TOLERANCE).to_l
    result = length1 < length2
    assert_equal(false, result)
  end

  def test_Operator_LessThan_Length_is_equal_Length
    length1 = 12.to_l
    length2 = 12.to_l
    result = length1 < length2
    assert_equal(false, result)
  end

  def test_Operator_LessThan_Length_is_less_than_Length
    length1 = 11.to_l
    length2 = 12.to_l
    result = length1 < length2
    assert_equal(true, result)
  end

  def test_Operator_LessThan_Length_is_greater_than_Float
    length1 = 12.to_l
    length2 = 11.to_l.to_f
    result = length1 < length2
    assert_equal(false, result)
  end

  def test_Operator_LessThan_Length_is_equal_Float
    length1 = 12.to_l
    length2 = 12.to_l.to_f
    result = length1 < length2
    assert_equal(false, result)
  end

  def test_Operator_LessThan_Length_is_less_than_Float
    length1 = 11.to_l
    length2 = 12.to_l.to_f
    result = length1 < length2
    assert_equal(true, result)
  end

  def test_Operator_LessThan_Float_is_greater_than_Length
    length1 = 12.to_l.to_f
    length2 = 11.to_l
    result = length1 < length2
    assert_equal(false, result)
  end

  def test_Operator_LessThan_Float_is_equal_Length
    length1 = 12.to_l.to_f
    length2 = 12.to_l
    result = length1 < length2
    assert_equal(false, result)
  end

  def test_Operator_LessThan_Float_is_less_than_Length
    length1 = 11.to_l.to_f
    length2 = 12.to_l
    result = length1 < length2
    assert_equal(true, result)
  end

  def test_Operator_LessThan_invalid_argument_string
    length1 = 12.to_l
    length2 = "I am not a Length!"
    assert_raises ArgumentError do
      result = length1 < length2
    end
  end

  def test_Operator_LessThan_invalid_argument_numeric_string
    length1 = 12.to_l
    length2 = "11"
    assert_raises ArgumentError do
      result = length1 < length2
    end
  end

  def test_Operator_LessThan_invalid_argument_point
    length1 = 12.to_l
    length2 = ORIGIN
    assert_raises ArgumentError do
      result = length1 < length2
    end
  end


  # ========================================================================== #
  # method Length.<=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/length#<=

  def test_Operator_LessThanOrEqual_api_example
    length1 = 11.to_l
    length2 = 12.to_l
    if length1 <= length2
      puts "length1 is less than or equal length2"
    else
      puts "length1 is greater than length2"
    end
  end

  def test_Operator_LessThanOrEqual_Length_is_greater_than_Length
    length1 = 12.to_l
    length2 = 11.to_l
    result = length1 <= length2
    assert_equal(false, result)
  end

  def test_Operator_LessThanOrEqual_Length_is_equal_Length_with_tolerance
    length1 = 11.to_l
    length2 = (11.0 + SKETCHUP_FLOAT_TOLERANCE).to_l
    result = length1 <= length2
    assert_equal(true, result)
  end

  def test_Operator_LessThanOrEqual_Length_is_equal_Length
    length1 = 12.to_l
    length2 = 12.to_l
    result = length1 <= length2
    assert_equal(true, result)
  end

  def test_Operator_LessThanOrEqual_Length_is_less_than_Length
    length1 = 11.to_l
    length2 = 12.to_l
    result = length1 <= length2
    assert_equal(true, result)
  end

  def test_Operator_LessThanOrEqual_Length_is_greater_than_Float
    length1 = 12.to_l
    length2 = 11.to_l.to_f
    result = length1 <= length2
    assert_equal(false, result)
  end

  def test_Operator_LessThanOrEqual_Length_is_equal_Float
    length1 = 12.to_l
    length2 = 12.to_l.to_f
    result = length1 <= length2
    assert_equal(true, result)
  end

  def test_Operator_LessThanOrEqual_Length_is_less_than_Float
    length1 = 11.to_l
    length2 = 12.to_l.to_f
    result = length1 <= length2
    assert_equal(true, result)
  end

  def test_Operator_LessThanOrEqual_Float_is_greater_than_Length
    length1 = 12.to_l.to_f
    length2 = 11.to_l
    result = length1 <= length2
    assert_equal(false, result)
  end

  def test_Operator_LessThanOrEqual_Float_is_equal_Length
    length1 = 12.to_l.to_f
    length2 = 12.to_l
    result = length1 <= length2
    assert_equal(true, result)
  end

  def test_Operator_LessThanOrEqual_Float_is_less_than_Length
    length1 = 11.to_l.to_f
    length2 = 12.to_l
    result = length1 <= length2
    assert_equal(true, result)
  end

  def test_Operator_LessThanOrEqual_invalid_argument_string
    length1 = 12.to_l
    length2 = "I am not a Length!"
    assert_raises ArgumentError do
      result = length1 <= length2
    end
  end

  def test_Operator_LessThanOrEqual_invalid_argument_numeric_string
    length1 = 12.to_l
    length2 = "11"
    assert_raises ArgumentError do
      result = length1 <= length2
    end
  end

  def test_Operator_LessThanOrEqual_invalid_argument_point
    length1 = 12.to_l
    length2 = ORIGIN
    assert_raises ArgumentError do
      result = length1 <= length2
    end
  end


  # ========================================================================== #
  # method Length.<=>
  # http://www.sketchup.com/intl/developer/docs/ourdoc/length#<=>

  def test_Operator_Sort_api_example
    length1 = 20.to_l
    length2 = 30.to_l
    result = length1 <=> length2
  end

  def test_Operator_Sort_Length_is_greater_than_Length
    length1 = 12.to_l
    length2 = 11.to_l
    result = length1 <=> length2
    assert_equal(1, result)
  end

  def test_Operator_Sort_Length_is_equal_Length_with_tolerance
    length1 = 11.to_l
    length2 = (11.0 + SKETCHUP_FLOAT_TOLERANCE).to_l
    result = length1 <=> length2
    assert_equal(0, result)
  end

  def test_Operator_Sort_Length_is_equal_Length
    length1 = 12.to_l
    length2 = 12.to_l
    result = length1 <=> length2
    assert_equal(0, result)
  end

  def test_Operator_Sort_Length_is_less_than_Length
    length1 = 11.to_l
    length2 = 12.to_l
    result = length1 <=> length2
    assert_equal(-1, result)
  end

  def test_Operator_Sort_Length_is_greater_than_Float
    length1 = 12.to_l
    length2 = 11.to_l.to_f
    result = length1 <=> length2
    assert_equal(1, result)
  end

  def test_Operator_Sort_Length_is_equal_Float
    length1 = 12.to_l
    length2 = 12.to_l.to_f
    result = length1 <=> length2
    assert_equal(0, result)
  end

  def test_Operator_Sort_Length_is_less_than_Float
    length1 = 11.to_l
    length2 = 12.to_l.to_f
    result = length1 <=> length2
    assert_equal(-1, result)
  end

  def test_Operator_Sort_Float_is_greater_than_Length
    length1 = 12.to_l.to_f
    length2 = 11.to_l
    result = length1 <=> length2
    assert_equal(1, result)
  end

  def test_Operator_Sort_Float_is_equal_Length
    length1 = 12.to_l.to_f
    length2 = 12.to_l
    result = length1 <=> length2
    assert_equal(0, result)
  end

  def test_Operator_Sort_Float_is_less_than_Length
    length1 = 11.to_l.to_f
    length2 = 12.to_l
    result = length1 <=> length2
    assert_equal(-1, result)
  end

  def test_Operator_Sort_invalid_argument_string
    length1 = 12.to_l
    length2 = "I am not a Length!"
    assert_nil(length1 <=> length2)
  end

  def test_Operator_Sort_invalid_argument_numeric_string
    length1 = 12.to_l
    length2 = "11"
    assert_nil(length1 <=> length2)
  end

  def test_Operator_Sort_invalid_argument_point
    length1 = 12.to_l
    length2 = ORIGIN
    assert_nil(length1 <=> length2)
  end


  # ========================================================================== #
  # method Length.inspect
  # http://www.sketchup.com/intl/developer/docs/ourdoc/length#inspect

  def test_inspect_api_example
    length = 55.to_l
    str = length.to_s
  end

  def test_inspect
    length = 55.to_l
    result = length.inspect
    assert_kind_of(String, result)
    assert_equal(55.0.to_s, result)
  end


  # ========================================================================== #
  # method Length.to_s
  # http://www.sketchup.com/intl/developer/docs/ourdoc/length#to_s

  def test_to_s_api_example
    length = 55.to_l
    str = length.to_s
  end

  def test_to_s
    length = 55.to_l
    result = length.to_s
    assert_kind_of(String, result)
    expected = Sketchup.format_length(55)
    assert_equal(expected, result)
  end


  # ========================================================================== #
  # method Length.to_f
  # http://www.sketchup.com/intl/developer/docs/ourdoc/length#to_f

  def test_to_f_api_example
    length = 55.to_l
    f = length.to_f
  end

  def test_to_f
    length = 55.to_l
    result = length.to_f
    assert_kind_of(Float, result)
    assert_equal(55.0, result)
  end


  # ========================================================================== #
  # method Length.is_a?
  # This is not a method we implement, but the Length class used to be derived
  # from Float prior to SU2015 by a low level hack which broke in SU2015 64bit.

  def test_is_a_Query_Float
    assert_kind_of(Float, 10.to_l)
  end

  def test_is_a_Query_Numeric
    assert_kind_of(Numeric, 10.to_l)
  end

  def test_is_a_Query_Comparable
    assert_kind_of(Comparable, 10.to_l)
  end


  # ========================================================================== #
  # method Length.kind_of?

  def test_kind_of_Query_Float
    assert_kind_of(Float, 10.to_l)
  end

  def test_kind_of_Query_Numeric
    assert_kind_of(Numeric, 10.to_l)
  end

  def test_kind_of_Query_Comparable
    assert_kind_of(Comparable, 10.to_l)
  end


  # ========================================================================== #
  # method Length.frozen?

  def test_frozen_Query
    assert(10.to_l.frozen?)
  end


  # ========================================================================== #
  # method Length.freeze

  def test_trust
    length = 10.to_l
    assert_equal(length, length.freeze)
  end


  # ========================================================================== #
  # method Length.tainted?

  def test_tainted_Query
    assert_equal(false, 10.to_l.tainted?)
  end


  # ========================================================================== #
  # method Length.taint

  def test_taint
    assert_raises RuntimeError do
      10.to_l.taint
    end
  end


  # ========================================================================== #
  # method Length.untrusted?

  def test_untrusted_Query
    assert_equal(false, 10.to_l.untrusted?)
  end


  # ========================================================================== #
  # method Length.untrust

  def test_untrust
    assert_raises RuntimeError do
      10.to_l.untrust
    end
  end


  # ========================================================================== #
  # method Length.trust

  def test_trust
    length = 10.to_l
    assert_equal(length, length.trust)
  end


  # ========================================================================== #
  # method Length.hash

  def test_hash
    length1 = 10.to_l
    length2 = 10.to_l
    assert_equal(length1.hash, length2.hash)
  end


  # ========================================================================== #
  # method Length.dup

  def test_dup
    assert_raises TypeError do
      10.to_l.dup
    end
  end


  # ========================================================================== #
  # method Length.clone

  def test_clone
    assert_raises TypeError do
      10.to_l.clone
    end
  end


  # ========================================================================== #
  # method Length.!

  def test_test_Operator_Not
    assert_equal(false, !10.to_l)
  end


  # ========================================================================== #
  # method Length.===

  def test_Operator_CaseEquality_api_example
    length1 = 20.to_l
    length2 = 30.to_l
    is_equal = length1 === length2
  end

  def test_Operator_CaseEquality_Length_is_greater_than_Length
    length1 = 12.to_l
    length2 = 11.to_l
    result = length1 === length2
    assert_equal(false, result)
  end

  def test_Operator_CaseEquality_Length_is_equal_Length_with_tolerance
    length1 = 11.to_l
    length2 = (11.0 + SKETCHUP_FLOAT_TOLERANCE).to_l
    result = length1 === length2
    # This calls Float.=== which doesn't do tolerance comparison.
    assert_equal(false, result)
  end

  def test_Operator_CaseEquality_Length_is_equal_Length
    length1 = 12.to_l
    length2 = 12.to_l
    result = length1 === length2
    assert_equal(true, result)
  end

  def test_Operator_CaseEquality_Length_is_less_than_Length
    length1 = 11.to_l
    length2 = 12.to_l
    result = length1 === length2
    assert_equal(false, result)
  end

  def test_Operator_CaseEquality_Length_is_greater_than_Float
    length1 = 12.to_l
    length2 = 11.to_l.to_f
    result = length1 === length2
    assert_equal(false, result)
  end

  def test_Operator_CaseEquality_Length_is_equal_Float
    length1 = 12.to_l
    length2 = 12.to_l.to_f
    result = length1 === length2
    assert_equal(true, result)
  end

  def test_Operator_CaseEquality_Length_is_less_than_Float
    length1 = 11.to_l
    length2 = 12.to_l.to_f
    result = length1 === length2
    assert_equal(false, result)
  end

  def test_Operator_CaseEquality_Float_is_greater_than_Length
    length1 = 12.to_l.to_f
    length2 = 11.to_l
    result = length1 === length2
    assert_equal(false, result)
  end

  def test_Operator_CaseEquality_Float_is_equal_Length
    length1 = 12.to_l.to_f
    length2 = 12.to_l
    result = length1 === length2
    assert_equal(true, result)
  end

  def test_Operator_CaseEquality_Float_is_less_than_Length
    length1 = 11.to_l.to_f
    length2 = 12.to_l
    result = length1 === length2
    assert_equal(false, result)
  end

  def test_Operator_CaseEquality_invalid_argument_string
    length1 = 12.to_l
    length2 = "I am not a Length!"
    result = length1 === length2
    assert_equal(false, result)
  end

  def test_Operator_CaseEquality_invalid_argument_numeric_string
    length1 = 12.to_l
    length2 = "11"
    result = length1 === length2
    assert_equal(false, result)
  end

  def test_Operator_CaseEquality_invalid_argument_point
    length1 = 12.to_l
    length2 = ORIGIN
    result = length1 === length2
    assert_equal(false, result)
  end


end # class
