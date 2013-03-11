
class TasksController < ApplicationController
  #before_filter :authenticate_user!
  before_filter :authenticate_user!, :except => [:preview, :postview]
  include HTTParty
  format :json
  @@base ='http://default-environment-jrcyxn2kkh.elasticbeanstalk.com'
  #base_uri 'localhost:8080'
  #@base = 'http://localhost:8080/MarcoPolo'
  # GET /tasks
  # GET /tasks.json
  def index
    puts "sadfdsafd"
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
  @server = params[:serverUniqueRequestId]
  @assignment = params[:assignmentId]
  @imagelocation = params[:imageurl]
  id = params[:id]
  if (@assignmentId != "ASSIGNMENT_ID_NOT_AVAILABLE")
    #task has been accepted
      # add new task and then display it
      t = Task.new(xim_id: @server, imageurl: @imagelocation)
      t.save     
      redirect_to action: :edit, id: id
    else 
      #preview mode
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
    #@task = Task.find(params[:id])
    puts "**********Task id is" + params[:id]
    @task = Task.find_by_xim_id(params[:id])
    #@task.xim_id = params[:id].to_i
    # FIXME - hard coded image for now

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
    @task = Task.find(params[:id])
    output = params[:task][:output]

    puts "output is " + output.to_s

    options = {
      :headers => {'Content-type' => 'application/x-www-form-urlencoded'},
      :body => {
        :serverUniqueRequestId => @task.xim_id,
        :output => output
      }
    }

    puts "CALLING OUT TO + " +  @@base

    #r = HTTParty.post('http://default-environment-jrcyxn2kkh.elasticbeanstalk.com/task/submit', options).inspect
    r = HTTParty.post(@@base + '/task/submit', options).inspect

    puts "response ======" + r.to_s





    #puts "OUTPUT...." + output
    respond_to do |format|
      if @task.update_attributes(params[:task])
        #format.html { redirect_to @task, notice: r.to_s}
        format.html { redirect_to root_url}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
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
