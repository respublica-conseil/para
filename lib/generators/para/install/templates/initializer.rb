Para.config do |config|
  # Configure authentication method to be called when accessing the admin panel
  #
  # config.authenticate_admin_method = :authenticate_admin!

  # Configure the method to retrieve current admin user from
  #
  # config.current_admin_method = :current_admin_user

  # Configure the default Kaminari pagination theme to use
  #
  # config.pagination_theme = 'twitter-bootstrap-3'

  # Configure the default admin HTML page <title>
  #
  # config.admin_title = ::I18n.t('para.admin.title')

  # Configure the default max depth for trees
  #
  # config.default_tree_max_depth = 3

  # Configure the methods which Para will try to call on resources to fetch
  # their name.
  #
  # Default is [:name, :title]
  #
  # config.resource_name_methods += [:full_name]

  # Configure the theme navigation bar color not gray but blue darker
  #
  # config.dark_theme = true

  # Do not uncollapse by default "inset" nested fields, which makes all such nested field
  # blocks get collapsed on page load, and can be easier to read for big blocks.
  #
  # This also speeds up page loading when used in conjunction to remote partial loading
  # for nested fields
  #
  # config.uncollapse_inset_nested_fields = false

  # Set this to false if you want to define the :file and :image simple form inputs in the
  # app, to customize them.
  #
  # config.load_file_inputs = false

  # Set if the Para::Breadcrumb::Controller module should be included into the
  # app, allowing easy breadcrumbs management in the app.
  #
  # Default is true
  #
  # config.enable_app_breadcrumbs = false

  # Para plugins to load
  #
  # config.plugins = []
end
