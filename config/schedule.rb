# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every 4.hours do
  runner "ChildHealth.delay.import_data"
  runner "HealthHouse.delay.import_data"
  runner "ChildHealth.delay.import_data"
  runner "Maternal.delay.import_data"
  runner "Newborn.delay.import_data "
  runner "SpecialTask.delay.import_data"
  runner "SupportGroupMeeting.delay.import_data"
  runner "FpClient.delay.import_data"

  runner "ReportingCommunityMeeting.delay.import_data"
  runner "ReportingFacility.delay.import_data"
  runner "ReportingBirthDeath.delay.import_data"
  runner "ReportingChildHealth.delay.import_data"
  runner "ReportingFamilyPlanning.delay.import_data"
  runner "ReportingTreatment.delay.import_data"
end