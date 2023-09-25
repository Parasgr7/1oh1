class WalletHistory < ApplicationRecord
  belongs_to :wallet
  belongs_to :action, polymorphic: true, optional: true
end
