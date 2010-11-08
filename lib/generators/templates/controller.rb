class <%= class_name.pluralize %>Controller < ApplicationController

  before_filter :get_<%= class_name.tableize %>, :only => [:index]
  before_filter :get_<%= class_name.underscore %>, :except => [:index, :new, :create]

  def index
  end

  def show
  end

  def edit
  end

  def create
    @<%= class_name.underscore %> = <%= class_name %>.new(params[:<%= class_name.underscore %>])
    if params[:<%= class_name.underscore %>]
      if @<%= class_name.underscore %>.save
        get_<%= class_name.tableize %>
      end
    end
  end

  def update
    @updated = @<%= class_name.underscore %>.update_attributes(params[:<%= class_name.underscore %>])
    if @updated
        get_<%= class_name.tableize %>
    end
  end

  def destroy
    @<%= class_name.underscore %>.destroy
    @destroyed = true
    if @destroyed
        get_<%= class_name.tableize %>
    end
  end

  private

  def get_<%= class_name.tableize %>
    @<%= class_name.tableize %> = <%= class_name %>.all
  end

  def get_<%= class_name.underscore %>
    @<%= class_name.underscore %> = <%= class_name %>.find(params[:id])
  end
end



