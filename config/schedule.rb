job_type :run_ruby, 'cd :path && bundle exec :task'

every 1.day, at: "11:30 am" do
	run_ruby "ruby main.rb"
end