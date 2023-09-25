class Explore < ApplicationRecord
  belongs_to :profile
  belongs_to :category
  has_many :guide_ratings,dependent: :destroy
  has_many :explore_ratings,dependent: :destroy
  has_many :bookings,dependent: :nullify

  self.per_page = 5

  scope :with_category, ->(id) {
    where(category_id: id)
  }
  scope :exclude_user,->(user){
    list = user.profile.blocked_users
    list << user.profile.id
    where.not(:profile_id => list)
  }
  scope :with_country_name, ->(country_name) {
   where(:profiles => {:country => [*country_name]})
  }

  scope :from_this_month, lambda { where("explores.created_at > ? AND explores.created_at < ?", Time.now.beginning_of_month, Time.now.end_of_month) }


  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'

    case sort_option.to_s
      when /^created_at_/
        order("explores.created_at #{ direction }")
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
     :with_country_name
   ]
 )

end
