class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    if current_user.profile
      @projects = Project.all
      if params[:search]
        @results = Category.verified.ransack(name_cont: params[:search].downcase).result
      else
        @profile = current_user.profile
        @project = Project.includes(:categories,:projects_categories,profile: :user)
        @popular_projects = @project.where(:profiles=>{:country=>"India"}).limit(4)
        @popular_in_country = @project.where(:profiles=>{:country=>current_profile.country}).where.not("profile_id = ?",current_profile.id )
      end
    else
      redirect_to first_page_introduction_path
      flash[:error] = "Build your profile first"
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @comments = @project.project_comments.sort_by_created_desc
  end

  # GET /projects/new
  def new
    unless session[:project].empty?
      @project = session[:project]
      puts @project
      @project_categories = session[:project_categories]
      @project_profile = Profile.find_by_id(@project["profile_id"])
    end
  end

  # GET /projects/1/edit
  def edit
  end
  # POST /projects
  def create
    @project = Project.new(session[:project])
    categories = session[:project_categories].map{|x| Category.find_by_name(x)}

    categories.each do |category|
      @project.categories << category
    end
    if @project.save!
      flash[:success]= 'Project was successfully created.'
      @flashing = flash
      session[:project] = nil
      session[:project_categories] = nil
      respond_to do |format|
        format.html { redirect_to profiles_path, success: 'Project was successfully created.' }
      end
    end
  end

  # Create project from profile_builder
  def create_project_builder
    puts project_params
    @project = Project.new(project_params)
    @project.profile = current_profile
    flash.now[:success]= 'Project was successfully created.'
    @flashing = flash
    @projects = current_profile.projects.sort_by_created_desc
    if @project.save!
      respond_to do |format|
        format.js
      end
    end
  end

  def edit_project_builder
    @project = Project.find_by_id(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update_project_builder
    @project = Project.find_by_id(params[:id])
    @projects = current_profile.projects.sort_by_created_desc
    if @project.update(project_params)
      flash.now[:success]= 'Project was successfully edited.'
      @flashing = flash
      respond_to do |format|
        format.js
      end
    end
  end

  def create_comment
    @project_comment = ProjectComment.new
    @project_comment.project_id = project_comment_params[:id]
    @project_comment.comment = project_comment_params[:comment]
    @project_comment.profile = current_user.profile
    flash.now[:success]= 'Comment was successfully created.'
    @flashing = flash
    if @project_comment.save
      respond_to do |format|
        format.js
      end
    end
  end

  def overview
    if !session[:project].nil?
      @project = session[:project]
      @project_categories = session[:project_categories]
    end
  end

  def update_overview
    params_change = overview_params
    params_change["image"] = params_change["image"].split(',')
    @project = Project.new(overview_params)
    @project.profile_id = current_user.profile.id
    session[:project] = @project
    session[:project_categories] = params["tags"].split(',')
    redirect_to project_collaborators_path
  end

  def collaborators
    if !session[:project].nil?
      @project = session[:project]
      session[:project].reject! {|k, v| %w"id created_at updated_at".include? k }
    end
  end

  def update_collaborators
    if session[:project].present?
      project=session[:project]
      params_change = edit_support_params
      project["help_needed"] = params_change["help_needed"].split(',')
      project["help"] = edit_support_params["help"]
      session[:project] = project
      redirect_to projects_details_path
    end
  end

  def details
  end

  def update_details
    if session[:project].present?
      project=session[:project]
      params_change = edit_details_params
      project["tools"] = params_change["tools"].split(',')
      project["supplies"] = params_change["supplies"].split(',')
      project["gaps"] = edit_details_params["gaps"]
      project["challenges"] = edit_details_params["challenges"]
      project["description"] = edit_details_params["description"]
      project["completion_date"] = edit_details_params["completion_date"]
      session[:project] = project
      redirect_to new_project_path
    end
  end

  def edit_overview
    id = params[:id]
    @project = Project.find_by_id(id)
    params_change = overview_params
    params_change["image"] = params_change["image"].split(',')
    tags = params["tags"].split(',')
    categories_tag = tags.map{|name|  Category.find_by_name(name)}
    @project.categories = categories_tag
    @project.update_attributes(params_change)
    flash[:success]= 'Successfully edited.'
    render :js => "window.location = '#{project_path(@project)}'"

  end

  def edit_collaborators
    id = params[:id]
    @project = Project.find_by_id(id)
    params_change = edit_support_params
    params_change["help_needed"] = params_change["help_needed"].split(',')

    @project.update_attributes(params_change)
    flash[:success]= 'Successfully edited.'
    render :js => "window.location = '#{project_path(@project)}'"
  end

  def edit_details
    id = params[:id]
    @project = Project.find_by_id(id)
    params_change = edit_details_params
    params_change["supplies"] = params_change["supplies"].split(',')
    params_change["tools"] = params_change["tools"].split(',')
    @project.update_attributes(params_change)
    flash.now[:success]= 'Successfully edited.'
    @flashing = flash
    respond_to do |format|
      format.js
    end
  end

  # # DELETE /projects/1
  def destroy
    @project = Project.find_by_id(params[:id])
    if !@project.nil?
      @project.destroy
      flash[:success] = "Project Deleted!"
      @flashing = flash
      @projects = current_user.profile.projects.sort_by_created_desc
      respond_to do |format|
        format.html {redirect_to profiles_path}
        format.js
      end
    end

  end

  def open_edit_project_modal
    @project = Project.includes(:categories).find(params[:id])
    @class = params[:class]
    @colab_ids = @project.colab_id
    @categories_name = @project.categories.pluck(:name)
    @help_needed=@project.help_needed
    respond_to do |format|
      format.js
    end
  end

  def list_categories_name
    data = !params[:q].nil? ? params[:q].split(" ") : ""
    respond_to do |format|
      format.json{
        @categories = Category.verified.ransack(name_cont_any: data).result
      }
    end
  end

  def filter_result
    query_param = fetch_country_params(params)

    if params[:filter] == 'popular'
      @project = Project.includes(:categories,:projects_categories,profile: :user)
      if params[:country].nil?
        @popular_projects = @project.where(:profiles=>{:country=>"India"})
        @popular_in_country = @project.where(:profiles=>{:country=>current_profile.country}).where.not("profile_id = ?",current_profile.id )
      else
        @popular_projects = @project.where(:profiles=>query_param)
        @popular_in_country = @project.where(:profiles=>query_param).where.not("profile_id = ?",current_profile.id )
      end
      @results = []
    elsif params[:filter] == 'status'
      if params[:country].nil?
        @idea = Project.where(:status=>"idea").where.not(profile: current_profile)
        @progress = Project.where(:status=>"progress").where.not(profile: current_profile)
        @completed = Project.where(:status=>"completed").where.not(profile: current_profile)
      else
        @idea = Project.includes(:profile).where(:status=>"idea",:profiles=>query_param).where.not(profile: current_profile)
        @progress = Project.includes(:profile).where(:status=>"progress",:profiles=>query_param).where.not(profile: current_profile)
        @completed = Project.includes(:profile).where(:status=>"completed",:profiles=>query_param).where.not(profile: current_profile)
      end
      @results = []
    elsif params[:filter] == 'help'
      if params[:country].nil?
        @help_needed = Project.where(:help=>1).where.not(profile: current_profile)
      else
        @help_needed = Project.includes(:profile).where(:help=>1,:profiles=>query_param).where.not(profile: current_profile)
      end
      @results = []
    else
      if params[:country].nil?
        @most_recent = Project.order(created_at: :desc).where.not(profile: current_profile)
      else
        @most_recent = Project.includes(:profile).where(:profiles=>query_param).order(created_at: :desc).where.not(profile: current_profile)
      end
      @results = []
    end
    @filter = params[:filter]
    respond_to do |format|
      format.js
    end
  end

  def offer_help
    project = Project.find_by_id(params["project_id"])
    receiver = project.profile
    other_user = receiver.user
    sender = current_profile
    message = params[:message]
    category = Category.find_by_name(params["category"])
    chat = find_chat(other_user) || Chat.new(identifier: SecureRandom.base64(10))
    if !chat.persisted?
      chat.save
      chat.subscriptions.create(user_id: current_user.id)
      chat.subscriptions.create(user_id: other_user.id)
    end
    puts chat.slug
    payload = {content:message, chat_id: chat.id,user_id: current_user.id}
    Message.create(payload)
    redirect_to user_chat_path(current_user,chat.slug, :other_user => other_user.id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    def edit_details_params
      params.permit(:description,:completion_date,:gaps,:challenges,:tools,:supplies)
    end

    def edit_support_params
      params.permit(:help,:help_needed)
    end

    def country
      if current_user.profile
        current_user.profile.country
      end
    end

    def overview_params
      params.permit(:name,:summary,:image,:status)
    end

    def current_profile
      current_user.profile
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.permit(:name,:summary,:description,:image,:status,:help,:completion_date,:gaps,:challenges,:tools,:supplies,:help_needed)
    end

    def project_comment_params
      params.permit(:id,:comment)
    end
end
