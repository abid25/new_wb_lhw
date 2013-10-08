require 'csv'

namespace :one_time do 
	desc "Daily report for FPO' S "
	task :daily_report_for_fpo => :environment do
		CSV.open('tmp/daily_report_for_fpo.csv', 'wb') do |csv|
			csv << %w[Name forms_sent location]

			Visitor.where(designation: "FPO").each do |v|
				total = v.phone_entries.where(meta_submission_date: (Date.today - 1.day).beginning_of_day..Date.today.end_of_day)
				if total.present?
					v.phone_entries.where(meta_submission_date: (Date.today - 1.day).beginning_of_day..Date.today.end_of_day).each do |entry|
						csv << [v.name, total.count, v.address].flatten
					end
				end
			end

		end
	end
end