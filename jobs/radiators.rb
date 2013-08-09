require 'google_drive'

SCHEDULER.every '60m', :first_in => 0 do
  radiator =  ProjectRadiatorReader.new
  radiator.fetch
  projects = radiator.projects.to_widget_data

  projects.keys.each do |project_name|
    projects = radiator.projects.to_widget_data
    send_event(project_name.downcase, {items: projects[project_name]})
  end
end

