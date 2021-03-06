class ScaffoldResourceMatrixGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super
    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    set_type_attribute_default
  end

  # We need to set the default value for the type attribute to ''. If
  # we don't and use the current default of 'MyString', the ficture
  # will not load because the class MyString does not exist.
  def set_type_attribute_default
    attributes.each do |attribute|
      if attribute.name == 'type'
        def attribute.default; ''; end
      end
    end
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, and test directories.
      m.directory('app/views/layouts')
      m.directory('public/stylesheets')
      m.directory('test/fixtures')
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))

      for action in scaffold_views
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end

      # Layout and stylesheet.
      m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))
      m.template('style.css', 'public/stylesheets/scaffold.css')

      m.template('model.rb', File.join('app/models', class_path, "#{file_name}.rb"))

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb"),
                 :assigns => {:authenticated => options[:authenticated]}
      )

      m.template('functional_test.rb',
                 File.join('test/functional', controller_class_path,
                           "#{controller_file_name}_controller_test.rb"))
      m.template("functional_matrix_test.rb",
                 File.join('test/functional',controller_class_path,
                           "#{controller_file_name}_controller_matrix_test.rb"),
                 :assigns => {:authenticated => options[:authenticated]})

      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
      m.template('unit_test.rb',       File.join('test/unit',       class_path, "#{file_name}_test.rb"))
      m.template('fixtures.yml',       File.join('test/fixtures', "#{table_name}.yml"))

      unless options[:skip_migration]
        m.migration_template(
          'migration.rb', 'db/migrate', 
          :assigns => {
            :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}",
            :attributes     => attributes
          }, 
          :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
        )
      end

      m.route_resources controller_file_name
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} scaffold_resource_matrix ModelName [field:type, field:type] [--authenticated]"
    end

    def scaffold_views
      %w[ index show new edit ]
    end

    def scaffold_actions
      %w[ create destroy edit index new show update ]
    end

    def add_options!(opt)
      opt.on('-a', '--authenticated') { |value| options[:authenticated] = value }
    end

    def model_name 
      class_name.demodulize
    end
end
