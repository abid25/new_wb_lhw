# == Schema Information
#
# Table name: visitors
#
#  id               :integer(4)      not null, primary key
#  device_id        :string(15)      not null
#  name             :string(255)     not null
#  district_id      :integer(4)      not null
#  designation      :string(255)     not null
#  units_assigned :integer(4)      not null
#

class Visitor < ActiveRecord::Base
	include Reportable

	has_many :pd_psts, :primary_key => :device_id, :foreign_key => :device_id 
	has_many :pd_dtes, :primary_key => :device_id, :foreign_key => :device_id 
	has_many :assessments, :primary_key => :device_id, :foreign_key => :device_id 
	has_many :mentorings, :primary_key => :device_id, :foreign_key => :device_id 
	has_many :phone_entries, :primary_key => :device_id, :foreign_key => :device_id 
	has_many :lhw_details, primary_key: :lhs_code, foreign_key: :lhs_code, conditions: ' lhs_code != "" '

	scope :submits_reports, where("designation NOT IN (?)", ["FPO"])	
	belongs_to :district

	NOT_USED_IN_COMPLIANCE = ['ReportingCommunityMeeting', 'ReportingFacility', 'ReportingBirthDeath', 'ReportingChildHealth', 'ReportingFamilyPlanning', 'ReportingMaternalHealth', 'ReportingTreatment']

	# (no. of days in the field) / 20
	#this will be the number of unique days in the month that the LHS has uploaded forms. special task forms included
	def number_of_days_in_field(time_filter)
		days_in_field = []
		phone_entries_with_time_filter(time_filter).each do |entry|
			days_in_field << entry.meta_submission_date.to_date
		end
		(days_in_field.uniq.count.to_f / 20.0).round(1) * 100
	end


	#  (no. of uniq LHWs visited) / 20 
	def number_of_lhw_visited_compliance(time_filter)
		lhw_visited = []
		phone_entries_with_time_filter(time_filter).each do |entry|
			if entry.detail.class == "SpecialTaskDetail".constantize
				lhw_visited << entry.detail.lhw_visited
			else
				lhw_visited << entry.detail.lhw_code unless entry.detail.blank?
			end
		end

		(lhw_visited.count.to_f / 20.0) * 100
	end

	def phone_entries_with_time_filter(time_filter)
		phone_entries.where(type: phone_entries.collect(&:type).uniq - Visitor::NOT_USED_IN_COMPLIANCE, start_time: time_filter..time_filter.end_of_month)
	end

	# form compliance
	def total_compliance(time_filter)
		'%.1f' % (total_form_submitted_used_for_compliance(time_filter).to_f)
	end

	def total_form_submitted_used_for_compliance(time_filter)
		phone_entries.where(type: phone_entries.collect(&:type).uniq - Visitor::NOT_USED_IN_COMPLIANCE, start_time: time_filter..time_filter.end_of_month).count
	end

	def assessments_required(number_of_months)
		self.units_assigned*number_of_months
	end
	
	def mentorings_required(number_of_months)
		self.units_assigned*number_of_months
	end
	
	def pdpsts_required(number_of_months)
		number_of_months
	end
	
	def pddtes_required(number_of_months)
		number_of_months
	end
	
	def reports_required
		self.designation !="FPO" ? 1 : 0
	end

	def counts_for_compliance(end_time)
		self.total_conducted  = self.phone_entries.counts_for_compliance.group(" DATE_FORMAT(start_time, '%b %y')").order("start_time ASC").where(:start_time=>(end_time.beginning_of_month-1.year..end_time.end_of_day)).count
		self.total_expected   = (self.units_assigned*4) + 7
		self.total_percentage = self.total_conducted.each_with_object({}) {|(k, v), h| h[k] = v > self.total_expected ? 100 : ((v.to_f/self.total_expected.to_f)*100).round(1) } 
	end
	

	def indicator_statistics(end_time, activities)
		self.statistics = Hash.new
		
		for activity in activities
			detail = activity.reflections[:detail].klass			
			from_substring = "FROM `visitors` LEFT OUTER JOIN `phone_entries` ON `phone_entries`.`device_id` = `visitors`.`device_id` AND `phone_entries`.`type` IN ('#{activity.name}') INNER JOIN `#{detail.table_name}` ON `phone_entries`.`id` = `#{detail.table_name}`.`#{activity.reflections[:detail].foreign_key}` WHERE `visitors`.`id` = '#{self.id}' AND (`phone_entries`.`start_time` >= '2012-01-01 00:00:00') Group BY MONTH(start_time)"
			self.statistics[activity.name] = detail.find_by_sql("SELECT DATE_FORMAT(start_time, '%b %y') as 'date' #{activity_fields(activity)} #{from_substring}")
		end
	end
	
end
