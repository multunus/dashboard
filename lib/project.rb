require 'forwardable'
require 'ostruct'

class Project
  attr_accessor :name, :radiator_items

  def initialize(name, radiator_items)
    @name = name
    @radiator_items = radiator_items
  end

  def to_widget_data
    {
      "#{name}" => radiator_items.collect(&:to_widget_data)
    }
  end
  
end
