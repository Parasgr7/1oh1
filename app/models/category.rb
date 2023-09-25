class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name
  has_many :explores,:dependent => :delete_all
  has_many :guides,:dependent => :delete_all
  has_many :explore_ratings, :dependent => :delete_all
  has_many :guide_ratings, :dependent => :delete_all
  has_many :explore_profiles, :through => :explores,:source => :profile,:dependent => :delete_all
  has_many :guide_profiles, :through => :guides,:source => :profile,:dependent => :delete_all
  has_and_belongs_to_many :projects, :dependent => :delete_all
  self.per_page = 10
  scope :distinct_country, -> (country) { where(:profiles => {:country => country}).distinct }

  scope :verified, -> {where(verified: true)}
  scope :search_query, lambda { |query|
   return nil  if query.blank?

   terms = query.downcase.split(/\s+/)

   terms = terms.map { |e|
     ( '%'+e.gsub('*', '%') + '%').gsub(/%+/, '%')
   }
   num_or_conditions = 2
   where(
       terms.map {
         or_clauses = [
             "LOWER(categories.name) LIKE ?",
             "LOWER(categories.slug) LIKE ?"
         ].join(' OR ')
         "(#{ or_clauses })"
       }.join(' AND '),
       *terms.map { |e| [e] * num_or_conditions }.flatten
   )
 }
 scope :sorted_by, lambda { |sort_option|
   direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'

   case sort_option.to_s
     when /^created_at_/
       order("categories.created_at #{ direction }")
     when /^user_type_name_/
       order("LOWER(user_types.name) #{ direction }")
     else
       raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
   end
 }

  filterrific(
  default_filter_params: { sorted_by: 'created_at_desc' },
  available_filters: [
    :sorted_by,
    :search_query,
  ]
)

  def self.options_for_category_name
   Category.pluck(:name).uniq
  end

end
