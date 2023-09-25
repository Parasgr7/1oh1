class Wallet < ApplicationRecord
  belongs_to :profile
  has_many  :wallet_histories
end
