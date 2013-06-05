
class TasksController < ApplicationController
  include TasksHelper
  #before_filter :authenticate_user!
  before_filter :authenticate_user!, :except => [:preview, :postview, :edit, :update]
  #include HTTParty
  include HTTMultiParty
  format :json
  #base_uri 'localhost:8080'
  #@base = 'http://localhost:8080/MarcoPolo'
  # GET /tasks
  # GET /tasks.json
  def index
    #puts "sadfdsafd"
    if current_user.try(:admin?)
      puts "YO, ADMIN!!!"
      page = params[:page]
      if (page == nil )
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
      puts "YO, TASK!!"
    #@tasks = Task.all
    @tasks = Task.paginate(:page => params[:page], :per_page => 5)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tasks }
    end
  else # not admin
    puts "Bad boy.. not admin"
    render :file =>  "public/403.html"
  end
end



def preview
  puts "IN PREVIEW"
  @server = params[:id]
  @assignment = params[:assignmentId]
  @imagelocation = params[:imageUrl]
  @hit = params[:hitId]
  @worker = params[:workerId]
  @format = params[:requestedResponseFormat]

  @task = Task.new(xim_id: @server, imageurl: @imagelocation, isturkjob: true )  

  id = params[:id]
  if (@assignment != "ASSIGNMENT_ID_NOT_AVAILABLE")
    puts "mturk - read to work on task - " + @assignment.to_s
    #task has been accepted
      # add new task and then display it
      t = Task.new(xim_id: @server, imageurl: @imagelocation)
      t.save     
      redirect_to action: :edit, id: @server, format: @format, hitId: @hit, workerId: @worker, imageUrl: @imagelocation, assignmentId: @assignment, serverUniqueRequestId: @server
    else 
      #preview mode
      puts "=============PREVIEW MODE=================="
      render  :layout => 'noheader' #:layout => false # render the preivew with no layout
    end
  end



  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    puts "---------====ENTERING EDIT=========----"
    @task = nil
     email = ""
  @server = params[:serverUniqueRequestId]
  @assignment = params[:assignmentId]
  @imagelocation = params[:imageUrl]
  @worker = params[:workerId]
  @hit = params[:hitId]
  @attach = params[:attach]
  @format = params[:format]

  # testing
  @format="ppt"
  @id = params[:id]


  puts "**********Task id is" + params[:id]  + @worker.to_s + @hit.to_s
 #xim_id = params[:id]
  if (current_user == nil)
    #mturk job - look up by xim_id
    @task = Task.find_by_xim_id(@server)
    puts 'imagelocation is' + @imagelocation
  else
      @task = Task.find_by_xim_id(params[:id])
      email = current_user.email.to_s
      xim_id= @task.xim_id.to_s
      @imagelocation = @task.imageurl
      puts "===sending data " + xim_id + " " + email
      #Lock the task..
      options = {
      :headers => {'Content-type' => 'application/x-www-form-urlencoded'},
      :body => {
        :serverUniqueRequestId => @task.xim_id,
        :emailId => email
       }
     }
     r = HTTParty.post(@@base + '/task/lock', options).inspect
       #r = HTTParty.get(@@base + '/task/lock?' +  "serverUniqueRequestId=" + xim_id + "&emailId=" + email).inspect
       puts "r= " + r.to_s
     end

    #@task.xim_id = params[:id].to_i
    # FIXME - hard coded image for now
      render  :layout => 'noheader' #:layout => false # render the preivew with no layout

  end

  # POST /tasks
  # POST /tasks.json
  def create
    puts "CREATING..."
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update

    puts "UPDATING...."
    @id = params[:id]
    @task = Task.find(params[:id])
    puts "found task " + @task.to_s

    @assignment = params[:assignmentId]
    @current_user = current_user
    @output = params[:output]
    @attachment = params[:task][:attachment]
    #puts "attachment = " + @attachment
    #puts "output is " + @output.to_s
    puts "server id" + @task.xim_id
    puts "attachment" + @attachment.to_s
    puts "assignement id = " + @assignment.to_s
    puts "task is" + params[:task].to_s

    upload_file = File.read(params[:task][:attachment].tempfile.to_path).force_encoding("BINARY")

    #upload_file = File.new(@attachment, "rb")
    #File.open(Rails.root.join('public', 'uploads', @attachment.original_filename), 'w') do |file|
     # file.write(@attachment.read)  
    #end
    #puts "uploaded" + upload_file.to_s


    @options = {
      #:headers => {'Content-type' => 'multipart/form-data'},
      :headers => {'Content-type' => 'application/octet-stream'},
      :body => {
        :serverUniqueRequestId => @task.xim_id,
        :output => @output,
        :attachment => upload_file

      }
    }

    @mturk = {
      #:headers => {'Content-type' => 'application/x-www-form-urlencoded'},
      :body     => {
        :assignmentId => @assignment,
        :output => @output
      }
    }

    r = HTTMultiParty.post(@@base + '/task/submit', @options).inspect
    puts "submit response from server" + r
    respond_to do |format|
      format.html { redirect_to root_url}
    end

    #r = HTTParty.post("http://workersandbox.mturk.com/mturk/externalSubmit",@mturk).inspect
    #puts "response from turk is " + r
    #puts "response ======" + r.to_s
    #getTasks
    #puts "done with tasks.. getting the next one"
    #puts "FIRST IS=====" + Task.first.to_s
    
#alert ("opt is " + @options);
#$.post("http://default-environment-jrcyxn2kkh.elasticbeanstalk.com/task/submit",@options,function()
 # {alert("posted to server")});
#$(form).submit(data, function(d) { alert("retuned " + d) });

    #puts "OUTPUT...." + output
  #respond_to do |format|
      #format.html { render action: "edit" }
   #   format.js
      #format.json { render json: @task.errors, status: :unprocessable_entity }
    #end

=begin
    respond_to do |format|
      puts "format ==== " + format.to_s
       if @task.update_attributes(params[:task])
        #format.html { redirect_to @task, notice: r.to_s}
        #format.html { redirect_to root_url}
        if (Task.first == nil)
          puts "NOOOO MOOOORE Tasks"
          render :file => "public/nomore.html"
        else
          puts "++++++++++editing " + Task.first.to_s
          #format.html { redirect_to edit_task_path(Task.first.xim_id) }
        #format.html {render action: "edit"}
        format.js
        format.json { head :no_content }
      end
    else
      format.html { render action: "edit" }
      format.js
      format.json { render json: @task.errors, status: :unprocessable_entity }
    end
  end
=end

end

def notify
  puts "--=----IN NOTIFY===-====="
    @id = params[:id]
    @task = Task.find(params[:id])
    output = params[:output]

    puts "ID is " + @id.to_s+ " task is " + @task.to_s + " output is " + @output
  @options = {
      :headers => {'Content-type' => 'application/x-www-form-urlencoded'},
      :body => {
        :serverUniqueRequestId => @task.xim_id,
        :output => output
      }
    }
  r = HTTParty.post(@@base + '/task/submit', @options).inspect
  puts "submit response from server"
end


  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end
end
