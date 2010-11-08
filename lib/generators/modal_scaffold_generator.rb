require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

class ModalScaffoldGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)

  include Rails::Generators::Migration
  no_tasks { attr_accessor :model_name, :model_attributes }

  argument :model_name, :type => :string, :required => true, :banner => 'ModelName'
  argument :args_for_c_m, :type => :array, :default => [], :banner => 'controller_actions and model:attributes'

  class_option :skip_model, :desc => 'Don\'t generate a model or migration file.', :type => :boolean

      def initialize(*args, &block)
        super

        @model_attributes = []

        @skip_model = options.skip_model?

        args_for_c_m.each do |arg|
          if arg.include?(':')
            @model_attributes << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
          end
        end

        @model_attributes.uniq!

        if @model_attributes.empty?
          @skip_model = true # skip model if no attributes
          if model_exists?
            model_columns_for_attributes.each do |column|
              @model_attributes << Rails::Generators::GeneratedAttribute.new(column.name.to_s, column.type.to_s)
            end
          else
            @model_attributes << Rails::Generators::GeneratedAttribute.new('name', 'string')
          end
        end
      end

  def create_model
    template 'model.rb', "app/models/#{singular_name}.rb"
  end

  def create_migration
    unless @skip_model || options.skip_migration?
      migration_template 'migration.rb', "db/migrate/create_#{plural_name}.rb"
    end
  end

  def create_controller
    @source_root = File.expand_path('../templates', __FILE__)

    template 'controller.rb', "app/controllers/#{plural_name}_controller.rb"

    Dir.chdir( File.expand_path(@source_root, 'views') )
    
    Dir.glob(File.join("*", "*.erb")).each do |file|
      file.gsub!(/views\//,"")
      template "views/#{file}", "app/views/#{plural_name}/#{file}"
    end

    route "resources #{plural_name.to_sym.inspect}"
  end

  private

  def singular_table_name
    singular_name
  end

  def plural_table_name
    plural_name
  end

  def singular_name
    model_name.underscore
  end

  def plural_name
    model_name.underscore.pluralize
  end

  def class_name
    model_name.camelize
  end

  def plural_class_name
    plural_name.camelize
  end

  def model_exists?
    File.exist? destination_path("app/models/#{singular_name}.rb")
  end

  def controller_methods(dir_name)
    controller_actions.map do |action|
      #read_template("#{dir_name}/#{action}.rb")
    end.join("  \n").strip
  end

  def controller_actions
    []
  end

  def human_name
    singular_name.humanize
  end

  def attributes
    model_attributes
  end

  # FIXME: Should be proxied to ActiveRecord::Generators::Base
  # Implement the required interface for Rails::Generators::Migration.
  def self.next_migration_number(dirname) #:nodoc:
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end
end
