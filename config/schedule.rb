job_type :run_ruby, 'cd :path && bundle exec :task'

every 10.minutes do
	run_ruby "ruby main.rb"
end