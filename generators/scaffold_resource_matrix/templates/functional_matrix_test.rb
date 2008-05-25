require File.dirname(__FILE__) + '/<%= controller_file_path %>_controller_test'
require 'functional_test_matrix'

class <%= controller_class_name %>ControllerMatrixTest < <%= controller_class_name %>ControllerTest
  extend FunctionalTestMatrix

<% spaces = plural_name.length > 9 ? ' ' * (plural_name.length - 9) : '' -%>
<% resource_space = plural_name.length > 9 ? '' : ' ' * (9 - plural_name.length) -%>
<%- if authenticated -%>
  matrix :resource, :html_ok,    <%= spaces %>:html_nouser, :xml_ok,     <%= spaces %>:xml_nouser
  action :index,    :<%= plural_name %>,  <%= resource_space %>:login,       :<%= plural_name %>,  <%= resource_space %>:unauth
  action :new,      :ok,         <%= spaces %>:login,       :not_accept, <%= spaces %>:unauth
  action :show,     :ok,         <%= spaces %>:login,       :ok,         <%= spaces %>:unauth
  action :edit,     :ok,         <%= spaces %>:login,       :not_accept, <%= spaces %>:unauth
  action :create,   :created,    <%= spaces %>:login,       :created,    <%= spaces %>:unauth
  action :destroy,  :destroyed,  <%= spaces %>:login,       :destroyed,  <%= spaces %>:unauth
  action :update,   :updated,    <%= spaces %>:login,       :updated,    <%= spaces %>:unauth
<%- else -%>
  matrix :resource, :html_ok,    <%= spaces %>:xml_ok
  action :index,    :<%= plural_name %>,  <%= resource_space %>:<%= plural_name %>
  action :new,      :ok,         <%= spaces %>:not_accept
  action :show,     :ok,         <%= spaces %>:ok
  action :edit,     :ok,         <%= spaces %>:not_accept
  action :create,   :created,    <%= spaces %>:created
  action :destroy,  :destroyed,  <%= spaces %>:destroyed
  action :update,   :updated,    <%= spaces %>:updated
<%- end -%>

  attr_reader :params, :session, :format, :<%= singular_name %>_attributes

  def matrix_setup_index(setup, expect)
    get :index, params, session
  end

  def matrix_setup_new(setup, expect)
    get :new, params, session
  end

  def matrix_setup_show(setup, expect)
    get :show, params.merge(:id => <%= singular_name %>_id), session
  end

  def matrix_setup_edit(setup, expect)
    get :edit, params.merge(:id => <%= singular_name %>_id), session
  end

  def matrix_setup_create(setup, expect)
    post :create, params.merge(:<%= singular_name %> => <%= singular_name %>_attributes), session
  end

  def matrix_setup_destroy(setup, expect)
    delete :destroy, params.merge(:id => <%= singular_name %>_id), session
  end

  def matrix_setup_update(setup, expect)
    put :update, params.merge(:id => <%= singular_name %>_id,
                              :<%= singular_name %> => <%= singular_name %>_attributes),
      session
  end

  def matrix_test_ok(setup)
    assert_kind_of <%= class_name %>, assigns(:<%= singular_name %>)
    assert_response :success
  end

  def matrix_test_<%= plural_name %>(setup)
    assert_response :success
    assert_kind_of Array, assigns(:<%= plural_name %>)
  end

  def matrix_test_created(setup)
    assert_kind_of <%= class_name %>, assigns(:<%= singular_name %>)
    created_<%= plural_name %> = new_count - @old_count
    assert_equal 1, created_<%= plural_name %>, "should have created one <%= class_name %>"
    if format == :html
      assert_redirected_to <%= singular_name %>_path(assigns(:<%= singular_name %>))
    else
      assert_response :created
    end
  end

  def matrix_test_destroyed(setup)
    deleted_<%= plural_name %> = @old_count - new_count
    assert_equal 1, deleted_<%= plural_name %>, "should have deleted one <%= class_name %>"
    if format == :html
      assert_redirected_to <%= plural_name %>_path
    else
      assert_response :ok
    end
  end

  def matrix_test_updated(setup)
    assert_equal @old_count, new_count, "number of <%= class_name.pluralize %> should not change"
    if format == :html
      assert_redirected_to <%= singular_name %>_path(assigns(:<%= singular_name %>))
    else
      assert_response :ok
    end
  end

  def matrix_test_not_accept(setup)
    assert_response :not_acceptable
  end
  <%- if authenticated -%>
  def matrix_test_login(setup)
    assert_redirected_to login_path
  end

  def matrix_test_unauth(setup)
    assert_response :unauthorized
  end
  <%- end -%>
  
  def matrix_init_resource(format, arg2)
    <%- if authenticated -%>
    if arg2 == :ok
      @session = {:user_id => users(:quentin).id}
    else
      @session = {}
    end
    <%- else -%>
    @session = {}
    <%- end -%>
    @format = format
    if format == :html
      @params = {}
    else
      @params = {:format => format.to_s}
    end
    @<%= singular_name %>_attributes = {}
  end

  protected

  def <%= singular_name %>_id
    <%= table_name %>(:one).id
  end

end
