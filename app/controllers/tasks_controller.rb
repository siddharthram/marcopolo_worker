
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
        #response.parsed_response.each do |k, v|
        
        statuses = response.parsed_response["taskStatuses"]
        statuses.each do |job|
          suri = job["serverUniqueRequestId"]
          img = job["imageUrl"]
          req = job["requestedResponseFormat"]
         # v.each do |a|
            puts "" + job.to_s
            newTasks << Task.new(xim_id: suri, isturkjob: false, imageurl: img , attachmentformat: req, isvalid:true)     
            puts "SAVING T.... " + t.to_s
         # end
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
  @attachmentformat = params[:requestedResponseFormat]

  #puts "attachmentformat ==========> " + @attachmentformat
  @task = Task.new(xim_id: @server, imageurl: @imagelocation, isturkjob: true, attachmentformat: @attachmentformat, isvalid:true)  
  #puts "task id " + @task.id

  id = params[:id]
  if (@assignment != "ASSIGNMENT_ID_NOT_AVAILABLE")
    puts "mturk - read to work on task - " + @assignment.to_s
    #task has been accepted
      # add new task and then display it
      t = Task.new(xim_id: @server, isturkjob: true, attachmentformat: @attachmentformat, imageurl: @imagelocation, isvalid:true)
      t.save     
      redirect_to action: :edit, id: @server, attachmentformat: @attachmentformat, hitId: @hit, workerId: @worker, imageUrl: @imagelocation, assignmentId: @assignment, serverUniqueRequestId: @server
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
  # testing
  #@format="ppt"
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
    puts "PARAMS============" + params.to_s
    @id = params[:id]
    @task = Task.find(params[:id])
    @task.isvalid = true
    #puts "found task " + @task.to_s

    @assignment = params[:assignmentId]
    @current_user = current_user

    @output = params[:output]
    @options = nil
    @attachment = nil
    if (params[:task])
      ofile = params[:task][:attachment].original_filename
      puts "ofile is +" + ofile.to_s
      @fileext = File.extname(ofile)
      @fileext = @fileext.sub(/^\./,'')
      if ((@fileext != "ppt") && (@fileext != "pptx"))
        puts "invalid file extention"
        @task.isvalid = false
      end
    #upload_file = ""


    puts "Adding PPT attachment..."
    @attachment = params[:task][:attachment]

    @options = {
      #:headers => {'Content-type' => 'multipart/form-data'},
      #:headers => {'Content-type' => 'application/octet-stream'},
      :body => {
        :serverUniqueRequestId => @task.xim_id,
        :output => @output,
        :attachmentFileExtension => @fileext,
        :attachment => File.new(@attachment.tempfile.to_path)
      }
    }

  else
    #
    # params task = nil. not an attacment
    #
    @options = {
      :body => {
        :serverUniqueRequestId => @task.xim_id,
        :output => @output,
      }
    }
  end
  if (@task.isvalid == true)
    r = HTTMultiParty.post(@@base + '/task/submit', @options).inspect
    puts "submit response from server" + r
    puts "turk job = " + @task.isturkjob.to_s
  end
  if (@task.isturkjob == false)
    # redirect only if it is on the portal
    puts "sending to root_url"
    respond_to do |format|
      format.html { redirect_to root_url}
    end
  else 
      url_for(:only_path => true )
  end
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