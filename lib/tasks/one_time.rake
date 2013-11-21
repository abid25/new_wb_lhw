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
						csv << [v.name, total.count, entry.address,entry.flatten].meta_submission_date
					end
				end
			end

		end
	end


	desc "FPO's entry saving"
	task :fpo_save_entry => :environment do
		Visitor.where(designation: "FPO").each do |v|
			v.phone_entries.where(meta_submission_date: Date.parse("01-#{month_num}-2013").beginning_of_day..Date.parse("01-#{month_num}-2013").end_of_day).each do |entry|
				entry.save
			end
		end
	end

	desc "FPO's report for 2013"
	task :fpo_reports_2013 => :environment do
		(1..11).each do |month_num|
			Visitor.where(designation: "FPO").each do |v|

				CSV.open("testing/#{v.name.delete(' ')}_#{month_num}.csv", 'wb') do |csv|
					csv << %w[Name forms_sent location date]

					(1..Time.days_in_month(month_num, 2013)).each do |day_num|
						if(v.phone_entries.where(meta_submission_date: Date.parse("#{day_num}-#{month_num}-2013").beginning_of_day..Date.parse("#{day_num}-#{month_num}-2013").end_of_day).present?)

							csv << [v.name, v.phone_entries.where(meta_submission_date: Date.parse("#{day_num}-#{month_num}-2013").beginning_of_day..Date.parse("#{day_num}-#{month_num}-2013").end_of_day).count,
								v.phone_entries.where(meta_submission_date: Date.parse("#{day_num}-#{month_num}-2013").beginning_of_day..Date.parse("#{day_num}-#{month_num}-2013").end_of_day).last.address,
								Date.parse("#{day_num}-#{month_num}-2013")														
							]
						end
					end
				end
			end
		end
	end

end