
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
        #Task.delete_all
        newTasks = []
        #response.parsed_response.each do |k, v|
        
        statuses = response.parsed_response["taskStatuses"]
        #
        # For each response, check if the entry already exists in the local cache
        # if not, add it - these are the new jobs since last check
        # If yes, ignore - the task already exists

        statuses.each do |job|
          suri = job["serverUniqueRequestId"]
          img = job["imageUrl"]
          req = job["requestedResponseFormat"]
         # v.each do |a|
         puts "" + job.to_s
         if Task.exists?(xim_id: suri)
              # do nothing
            else
              newTasks << Task.new(xim_id: suri, isturkjob: false, imageurl: img , attachmentformat: req)
            end 
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

#============================================
#Preview is called by Turk workers ONLY
#so isturkjob is always set to true
#============================================

def preview
  puts "IN PREVIEW"
  @server = params[:id]
  @assignment = params[:assignmentId]
  @imagelocation = params[:imageUrl]
  @hit = params[:hitId]
  @worker = params[:workerId]
  @attachmentformat = params[:requestedResponseFormat]
  @turktext = "Ignore all the graphics in this image - just type the text content"

  #puts "attachmentformat ==========> " + @attachmentformat
  #@task = Task.new(xim_id: @server, imageurl: @imagelocation, isturkjob: true, attachmentformat: @attachmentformat)  
  #puts "task id " + @task.id

  id = params[:id]
  if (@assignment != "ASSIGNMENT_ID_NOT_AVAILABLE")
    puts "mturk - read to work on task - " + @assignment.to_s
    #task has been accepted
    # create new task IF it does not exist 
    # if it already exists, we add additional data that it is assigned to turk and lock it during edit

    if Task.exists?(xim_id: @server)
      puts "Task @server already exists"
      t = Task.find_by_xim_id(@server)
      t.isturkjob = true
      @turktext = "Create a powerpoint file with the diagram and text in it. You MUST submit a powerpoint file"
      t.save
    else
      t = Task.new(xim_id: @server, isturkjob: true, attachmentformat: @attachmentformat, imageurl: @imagelocation)
      t.save
    end
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
    #
    # Then this is a mturk job since There is no user id.
    # So we find the task using the xim_id
    #  mturk job - look up by xim_id
    #
    @task = Task.find_by_xim_id(@server)
  else
     #
     # this is a local task ie done by a ximly worker
     # from the worker portal
     #
     @task = Task.find_by_xim_id(params[:id])
     email = current_user.email.to_s
     xim_id= @task.xim_id.to_s
     @imagelocation = @task.imageurl

      #
      #Lock the task..
      #Locking it makes it unavailable to other users
      #
      options = {
        :headers => {'Content-type' => 'application/x-www-form-urlencoded'},
        :body => {
          :serverUniqueRequestId => @task.xim_id,
          :emailId => email
        }
      }
      r = HTTParty.post(@@base + '/task/lock', options).inspect
  end
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
    puts "found task " + @task.to_s

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
      if (@fileext == "ppt" || @fileext == "pptx")
        #
        # then we are good- do nothing
        # 
        @isppt = true
      else
        #
        # return invalid response
        #
        puts "*****PPT is false"
        @isppt = false
        puts "returning..."
        return url_for(:only_path => true )
      end

    #upload_file = ""
  end

  if (params[:task] != nil )
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
    @options = {
      :body => {
        :serverUniqueRequestId => @task.xim_id,
        :output => @output,
      }
    }
  end


    r = HTTMultiParty.post(@@base + '/task/submit', @options).inspect
    puts "submit response from server" + r
    puts "turk job = " + @task.isturkjob.to_s
    turkjob = @task.isturkjob
    @task.destroy
    if (turkjob == false)
    # redirect only if it is on the portal
    puts "sending to root_url"
    respond_to do |format|
      format.html { redirect_to root_url}
    end
  else 
    #
    # for mturks. returns the relative url because of the option
    #:only_path - If true, returns the relative URL (omitting the protocol, host name, and port) (false by default).
    #
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


 
