class Guide < ApplicationRecord
  belongs_to :profile
  belongs_to :category
  has_many :explore_ratings,dependent: :destroy
  has_many :guide_ratings,dependent: :destroy
  has_many :bookings,dependent: :nullify

    scope :sort_by_created_desc, -> {order(created_at: :desc)}

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

    scope :with_category_name, ->(category_name) {
     where(:categories => {:name => [*category_name]})
    }

    scope :from_this_month, lambda { where("guides.created_at > ? AND guides.created_at < ?", Time.now.beginning_of_month, Time.now.end_of_month) }


    scope :sorted_by, lambda { |sort_option|
      direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'

      case sort_option.to_s
        when /^created_at_/
          order("guides.created_at #{ direction }")
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
       :with_category_name,
       :availabilty
     ]
   )

end
