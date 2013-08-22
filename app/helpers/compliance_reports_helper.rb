module ComplianceReportsHelper
	
	def status(compliance_percentage)
=begin
		case compliance_percentage
			when 0..20
			  "fail"
			when 20..50
			  "warning"
			when 50..80
			  "pass"
			else
			  "exceptional"
		end
=end
	case compliance_percentage
			when 0..20
			  "fail"
		end
	end
	
	def overall_compliance_barchart(collection, width='auto', height='auto', label_count='automatic', slanted_text='automatic', text_angle='automatic')
		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', 'Name')
		data_table.new_column('number', 'Total Compliance %')

		for unit in collection
			if session[:start_time]
				data_table.add_row([unit.name.titleize, unit.total_monitoring_compliance(@start_time).to_f ])
			else
				data_table.add_row([unit.name.titleize, unit.total_monitoring_compliance(Date.today.beginning_of_month - 1.month).to_f ])
			end
		end

		opts   = {:height=> height ,:chartArea=> {:top => 5, :height=> "95%"}, :animation => {:duration => '2000', :easing => 'inAndOut'},:hAxis => {:viewWindowMode=> 'explicit',:viewWindow=>{:max=>100, :min=>-10},:minvalue => 0, :maxValue => 100}}
		@barchart = GoogleVisualr::Interactive::BarChart.new(data_table, opts)
		
		return @barchart
	end
	
	def overall_compliance_trend(collection, width='auto', height='auto', label_count='automatic', slanted_text='automatic', text_angle='automatic')
		line_series = Hash.new

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', 'Name')

		[*collection].each_with_index {|unit, index|
			data_table.new_column('number', unit.name.titleize+" Compliance %")
			line_series[index.to_s] = {:lineWidth => 3+(1*index),:pointSize => 7+(1*index)}
		}
		data_table.new_column('boolean' , nil, nil, 'certainty')
		
		[*collection].last.total_percentage.each_key {|key| 
			result = []
			[*collection].each {|unit|
				
				result.append(unit.total_percentage[key] ? unit.total_percentage[key] : 0)
			}
			data_table.add_row([key]+ result.flatten+[true])
		}

		opts   = {:height=> height ,:chartArea=> {:top => 25, :height=> "85%", :width=>"90%"},:lineWidth => 3,:pointSize => 7, :series => line_series, :curveType=> "function",:legend=>{:position=>"top"}, :animation => {:duration => '2000', :easing => 'linear'},:vAxis => {:viewWindowMode=> 'explicit',:viewWindow=>{:max=>101, :min=>-10,:minvalue => 0, :maxValue => 100}}}
		@barchart = GoogleVisualr::Interactive::LineChart.new(data_table, opts)
		
		return @barchart
	end
	
	def activity_compliance_barchart(collection, width='auto', height='auto', label_count='automatic', slanted_text='automatic', text_angle='automatic')
		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', 'Name')
		data_table.new_column('number', 'Total %')
		data_table.new_column('number', 'Monitoring %')
		data_table.new_column('number', 'Reporting %')
		
		for unit in collection
			data_table.add_row([unit.name.titleize, unit.total_percentage,unit.monitoring_percentage,unit.reporting_percentage])
		end

		opts   = {:height=> height, :chartArea=> {:top => 5, :height=> "95%"},:animation => {:duration => '2000', :easing => 'inAndOut'},:hAxis => {:viewWindowMode=> 'explicit',:viewWindow=>{:max=>100, :min=>-10},:minvalue => 0, :maxValue => 100}}
		@barchart = GoogleVisualr::Interactive::BarChart.new(data_table, opts)
		
		return @barchart
	end
	
end
