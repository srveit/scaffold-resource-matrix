require File.dirname(__FILE__) + '<%= '/..' * controller_class_nesting_depth %>/../test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase

  def setup
    super
    @old_count  = <%= class_name %>.count
  end

  def test_placebo
    assert_equal 2, @old_count
  end

  protected

  def new_count
    <%= class_name %>.count
  end

end
