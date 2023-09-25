class Transaction < ApplicationRecord
  belongs_to :profile
  has_many :wallet_histories, foreign_key: :action_id
  belongs_to :market
end
