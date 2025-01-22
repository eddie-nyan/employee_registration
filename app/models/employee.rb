class Employee < ApplicationRecord
    # Validations
    validates :employee_id, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9]{1,5}\z/, message: "must be alphanumeric and no more than 5 characters" }
    validates :name, presence: true
    validates :phone, allow_blank: true, format: { with: /\A\d{0,11}\z/, message: "must be numeric and no more than 11 digits" }
end
