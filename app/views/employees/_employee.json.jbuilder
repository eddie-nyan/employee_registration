json.extract! employee, :id, :employee_id, :name, :phone, :registered_at, :created_at, :updated_at
json.url employee_url(employee, format: :json)
