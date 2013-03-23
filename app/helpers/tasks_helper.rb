module TasksHelper
  @@base ='http://default-environment-jrcyxn2kkh.elasticbeanstalk.com'

	def getTasks
		response = HTTParty.get(@@base + '/task/open')
        puts "response = " + response.to_s
        Task.delete_all
        newTasks = []
        response.parsed_response.each do |k, v|
          v.each do |a|
            puts "" + a.to_s
            newTasks << Task.new(xim_id: a["serverUniqueRequestId"], imageurl: a["imageUrl"] )     
            puts "SAVING T.... " + t.to_s
          end
        end
        Task.import newTasks
    end
end
