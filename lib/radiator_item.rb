require 'active_support/all'
require 'business_time'

class RadiatorItem
  attr_accessor :name

  RADIATORS_UPDATE_FREQUENCY_IN_DAYS = 7
  PROGRESS_TRACK_UPDATE_FREQUENCY_IN_DAYS = 1
  
  def initialize(name,status,last_updated)
    @name, @status = name,status
    @last_updated = last_updated.is_a?(String) ? Date.strptime(last_updated.chomp,'%m/%d/%Y') : last_updated.to_date unless last_updated.blank?
  end

  def to_widget_data
    return no_data if not_enough_data?
    {
      :label => @name,
      :class => @status == "Yes" ? "label-yes" : "label-no",
      :progress_track_updated_status_class =>  updated_recently? ? "angry-icon-hide" : "angry-icon-show" 
    }
  end

  def updated_recently?
    return false if @last_updated.blank?
    last_update_date_in_days.business_days.ago <= @last_updated
  end
  
  private
  
  def no_data
    {
      :label => @name,
      :class => "label",
      :progress_track_updated_status_class => "angry-icon-hide"
    }
  end

  def last_update_date_in_days
    return PROGRESS_TRACK_UPDATE_FREQUENCY_IN_DAYS if @name == "Delivery Schedule"
    RADIATORS_UPDATE_FREQUENCY_IN_DAYS
  end
  
  def not_enough_data?
    [@name, @status, @last_updated].collect(&:to_s).include?('')
  end
end
