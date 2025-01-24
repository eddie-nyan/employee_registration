class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[ show edit update destroy ]

  # GET /employees or /employees.json
  def index
    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || 10).to_i
    @sort = params[:sort] || "created_at"
    @direction = params[:direction] || "desc"

    @employees = Employee.all

    if params[:query].present?
      search_query = "%#{params[:query].downcase.strip}%"
      @employees = @employees.where(
        "LOWER(employee_id) LIKE :query OR LOWER(name) LIKE :query OR LOWER(phone) LIKE :query",
        query: search_query
      )
    end

    @total_count = @employees.count
    @employees = @employees.order("#{@sort} #{@direction}")
                          .page(@page)
                          .per(@per_page)

    respond_to do |format|
      format.html
      format.turbo_stream do
        Rails.logger.debug "Search Query: #{params[:query]}"
        Rails.logger.debug "Total Results: #{@employees.count}"

        if @employees.empty? && params[:query].present?
          render turbo_stream: turbo_stream.replace(
            "employees_table",
            partial: "table_content",
            locals: { no_results_message: "No employees found matching '#{params[:query]}'" }
          )
        else
          render turbo_stream: turbo_stream.replace(
            "employees_table",
            partial: "table_content"
          )
        end
      end
    end
  end

  # GET /employees/1 or /employees/1.json
  def show
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees or /employees.json
  def create
    @employee = Employee.find_or_initialize_by(employee_id: employee_params[:employee_id])

    if @employee.persisted?
      flash[:notice] = "Employee ID already registered. Registered on: #{@employee.registered_at}"
      redirect_to edit_employee_path(@employee)
    else
      @employee.registered_at = Time.current
      if @employee.update(employee_params)
        redirect_to @employee, notice: "Employee was successfully registered."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /employees/1 or /employees/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: "Employee was successfully updated." }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1 or /employees/1.json
  def destroy
    @employee.destroy!

    respond_to do |format|
      format.html { redirect_to employees_path, status: :see_other, notice: "Employee was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def employee_params
      params.require(:employee).permit(:employee_id, :name, :phone)
    end
end
