require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../test_helper'

class <%= class_name %>Test < Test::Unit::TestCase

  def setup
    super
    @<%= singular_name %>_count = <%= class_name %>.count
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  protected

  def <%= singular_name %>
    <%= table_name %>(:one)
  end

  def <%= singular_name %>_created
    <%= class_name %>.count == @<%= singular_name %>_count + 1
  end

  def <%= singular_name %>_deleted
    <%= class_name %>.count == @<%= singular_name %>_count - 1
  end

  def no_<%= singular_name %>_created
    <%= class_name %>.count == @<%= singular_name %>_count
  end

  alias_method :no_<%= singular_name %>_deleted, :no_<%= singular_name %>_created
end
