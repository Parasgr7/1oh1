class Contact < ApplicationRecord
  enum category: [:customer_care, :security, :technical, :hr,:investor, :pr_communication]
end
