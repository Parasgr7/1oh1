class Project < ApplicationRecord
  belongs_to :profile
  has_and_belongs_to_many :categories
  has_many :project_comments, dependent: :destroy
  serialize :colab_id
  serialize :tools
  serialize :supplies
  serialize :image
  serialize :help_needed

  scope :sort_by_created_desc, -> {order(created_at: :desc)}

  self.per_page = 5

  enum status: [:idea, :progress, :completed]
  scope :exclude_user,->(user){
    list = user.profile.blocked_users
    list << user.profile.id
    where.not(:profile_id => list)
  }
  scope :with_category, ->(id) {
    where(categories:{id: id})
  }
  scope :with_country_name, ->(country_name) {
   where(:profiles => {:country => [*country_name]})
  }

  scope :from_this_month, lambda { where("projects.created_at > ? AND projects.created_at < ?", Time.now.beginning_of_month, Time.now.end_of_month) }


  scope :with_status, ->(status) {
   where(:projects => {:status => [*status.downcase]})
  }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'

    case sort_option.to_s
      when /^created_at_/
        order("projects.created_at #{ direction }")
      # when /^user_type_name_/
      #   order("LOWER(user_types.name) #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  filterrific(
   default_filter_params: { sorted_by: 'created_at_desc' },
   available_filters: [
     :sorted_by,
     :with_country_name,
     :with_status
   ]
 )

end
