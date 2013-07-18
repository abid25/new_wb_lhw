class DistrictsController < ApplicationController

	before_filter :authenticate_user!
# Doing CanCan calls by hand cause new to this and this a fairly complex usecase

	def compliance_report
		if params[:time_filter].nil?
			@district = District.find(params[:id])
			@start_time = Time.now.prev_month.beginning_of_month
			@end_time = Time.now.prev_month.end_of_month
		else
			@district = District.find(params[:time_filter][:id])
			@start_time = Time.zone.parse(params[:time_filter]["start_time(3i)"]+"-"+params[:time_filter]["start_time(2i)"]+"-"+params[:time_filter]["start_time(1i)"])
			@end_time = @start_time.end_of_month
		end	

		unless @district.nil?	
			authorize! :view_indicators_reports, @district
			@number_of_months = (@end_time.year*12+@end_time.month) - (@start_time.year*12+@start_time.month) + 1

			@province = Province.find(1)
			@province.compliance_statistics(@end_time)
			@district.compliance_statistics(@end_time)
			@officers = @district.visitors
			@district.officers_with_compliance_statistics(@start_time,@end_time,@number_of_months,@officers)
			@officers.sort! { |p1, p2| p2.total_percentage <=> p1.total_percentage }

			@phone_entries = @district.phone_entries.includes(:visitor).where(:start_time=>(@start_time..@end_time.end_of_day))
			@boundaries = District.get_boundaries(@district)

			define_activity_legend
			define_details_images
			respond_to do |format| # why the hell do i need to pull a request.xhr check here...?
				if request.xhr?
					format.js (render 'compliance_report.js.erb')
				else
					format.html (render 'compliance_report.html.erb')
				end
			end
		else
			flash[:error] = "The specified district does not exist."
			redirect_to root_path
		end
	rescue ArgumentError
		puts "caught exception!!!~"			
	end

	def indicators_report_by_people
		if params[:time_filter].nil?
			@district = District.find_by_district_name(params[:id])
			@start_time = Time.now.prev_month.beginning_of_month
			@end_time = Time.now.prev_month.end_of_month
		else 
			@district = District.find_by_district_name(params[:time_filter][:id])
			@start_time = Time.zone.parse(params[:time_filter]["start_time(3i)"]+"-"+params[:time_filter]["start_time(2i)"]+"-"+params[:time_filter]["start_time(1i)"])
			@end_time = @start_time.end_of_month
		end	
		
		@district = District.find_by_district_name(params[:id])
		unless @district.nil?
			authorize! :view_indicators_reports, @district
			indicators_init
			
			@province = @district.province
			@visitors = @district.visitors.order("name ASC")

			if @visitors.empty?
				flash[:error] = "The specified district has no assigned personnel"
				redirect_to root_path
			else
				@district.visitors_with_indicator_statistics(@start_time,@end_time,@visitors, @activities)

				@province.indicator_statistics(@end_time, @activities)
				@district.indicator_statistics_for_visitors(@end_time, @activities)
			end

		else
			flash[:error] = "The specified district does not exist."
			redirect_to root_path
		end
	end
	
	def indicators_report
		if params[:time_filter].nil?
			@district = District.find_by_district_name(params[:id])
			@start_time = Time.now.prev_month.beginning_of_month
			@end_time = Time.now.prev_month.end_of_month
		else 
			@district = District.find_by_district_name(params[:time_filter][:id])
			@start_time = Time.zone.parse(params[:time_filter]["start_time(3i)"]+"-"+params[:time_filter]["start_time(2i)"]+"-"+params[:time_filter]["start_time(1i)"])
			@end_time = @start_time.end_of_month
		end	
		@district = District.find_by_district_name(params[:id])
		unless @district.nil?
			authorize! :view_indicators_reports, @district
			
			@activities = PhoneEntry.activities[0..6]

			@indicators = []
			@indicator_names= Hash.new
			@indicator_hooks= Hash.new

			for activity in @activities
				indicators = activity.indicators2.find_all{|indicator| indicator.indicator_type == "integer" }
				@indicator_names[activity.name] = indicators.collect {|indicator| indicator.full_name} 
				@indicator_hooks[activity.name] = indicators.collect {|indicator| indicator.indicator_activity.name+"_"+indicator.hook} 
				@indicators += indicators
			end
			
			gon.indicator_names = @indicator_names
			gon.indicator_hooks = @indicator_hooks		


			@province = @district.province
			@facilities = @district.health_facilities.order("name ASC")
			#@visitors = @district.visitors.order("name ASC")
			@district.facilities_with_indicator_statistics(@start_time,@end_time,@facilities, @activities)
			
			@province.indicator_statistics(@end_time, @activities)
			@district.indicator_statistics_for_facilities(@end_time, @activities)
			
		else
			flash[:error] = "The specified district does not exist."
			redirect_to root_path
		end
	end

	def compliance_table
		calculate_compliances
	end

	def monitoring_compliance_table
		calculate_compliances
	end

	def reporting_compliance_table
		calculate_compliances
	end

	private

	def calculate_compliances
		if params[:time_filter].present? && params[:time_filter][:designation].present?
			designation = params[:time_filter].delete :designation
			@visitors   = Visitor.where(designation: designation)
		else
			@visitors = Visitor.where(designation: "LHS")
		end

		@district = District.find_by_district_name(params[:id])
		
		if params[:time_filter].nil?
			@start_time = Time.now.prev_month.beginning_of_month
			@end_time   = Time.now.prev_month.end_of_month
		else
			@time_filter = Time.zone.parse(params[:time_filter]["start_time(3i)"]+"-"+params[:time_filter]["start_time(2i)"]+"-"+params[:time_filter]["start_time(1i)"])
			@start_time  = Time.zone.parse(params[:time_filter]["start_time(3i)"]+"-"+params[:time_filter]["start_time(2i)"]+"-"+params[:time_filter]["start_time(1i)"])
			@end_time    = @start_time.end_of_month
		end

		session[:start_time] = @start_time
		session[:end_time]   = @end_time
	end
end