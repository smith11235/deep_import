namespace :db do
	desc "Rebuild Database: db:drop db:create db:migrate"
	task :rebuild do
		Rake::Task['db:drop'].invoke
		Rake::Task['db:create'].invoke
		Rake::Task['db:migrate'].invoke
	end
end



