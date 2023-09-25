class Market < ApplicationRecord
  has_many :transactions
  validates_uniqueness_of :order
  scope :sort_ascending, -> {order(order: :asc)}
end
