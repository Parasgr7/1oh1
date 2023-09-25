class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_one :profile
  has_many :messages
  has_many :subscriptions
  has_many :chats, through: :subscriptions
  has_many :notifications, foreign_key: :recipient_id
  #for tracking visits and events of users in website
  has_many :visits, class_name: "Ahoy::Visit"
  has_many :events, class_name: "Ahoy::Event"

  self.per_page = 10
  scope :sort_by_created_desc, -> {order(created_at: :desc)}
  
  def full_name
    "#{firstname}  #{lastname}"
  end

  scope :search_query, lambda { |query|
   return nil  if query.blank?

   terms = query.downcase.split(/\s+/)

   terms = terms.map { |e|
     ('%'+e.gsub('*', '%') + '%').gsub(/%+/, '%')
   }
   num_or_conditions = 2
   where(
       terms.map {
         or_clauses = [
             "LOWER(users.firstname) LIKE ?",
             "LOWER(users.email) LIKE ?"
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
       order("users.created_at #{ direction }")
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

  def admin?
  has_role?(:admin)
  end

  def guest?
    has_role?(:guest)
  end

  def existing_chats_users
    existing_chat_users = []
    self.chats.each do |chat|
    existing_chat_users.concat(chat.subscriptions.where.not(user_id: self.id).map {|subscription| subscription.user})
    end
    existing_chat_users.uniq
  end

  def self.from_omniauth(auth)
    # Creates a new user only if it doesn't exist
    where(email: auth.info.email).first_or_initialize do |user|
      user.add_role :guest
      user.provider = auth.provider
      user.uid = auth.uid
      user.firstname = auth.info.first_name
      user.lastname = auth.info.last_name
      user.email = auth.info.email
      user.password = SecureRandom.hex
      user.skip_confirmation!
    end
  end


end
