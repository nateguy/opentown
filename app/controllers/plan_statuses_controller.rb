class PlanStatusesController < ApplicationController

  before_action :set_plan_status, only: [:edit, :update, :destroy]


  def activate
    @plan_statuses = PlanStatus.all
    @plan_statuses.each do |plan_status|
      plan_status.active = false
      plan_status.save
    end

    if @plan_status.update(active: params[:active])
      redirect_to :back, notice: 'Status updated.'
    else
      redirect_to :back, notice: 'Status update failed.'
    end
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def create
    @plan_status = PlanStatus.new(plan_status_params)


    if @plan_status.save
      redirect_to :back, notice: 'Status updated.'
    else
      redirect_to :back, notice: 'Status update failed.'
    end
  end

  def destroy
    @plan_status.destroy
    redirect_to :back, notice: 'Status deleted.'

  end

  def update




    if @plan_status.update(plan_status_params)

      if @plan_status.active
        #set all to current as true, set rest as false

        @all_plan_status_items = Plan.find(@plan_status.plan_id).plan_statuses

        @all_plan_status_items.each do |item|

          if (item.id <= @plan_status.id)
            item.update(active: true)
          else
            item.update(active: false)
          end

        end
      end



      redirect_to :back, notice: 'Status updated.'
    else
      redirect_to :back, notice: 'Status update failed.'
    end

  end

  def new

    @plan_id = params[:plan_id]
    @plan_status = PlanStatus.new
    respond_to do |format|
      format.js
    end
  end

  def show

    # plan_id = params[:id]
    # @plan = Plan.find(plan_id)
    # @plan_statuses = @plan.plan_statuses
  end

  private

    def set_plan_status
      @plan_status = PlanStatus.find(params[:id])
    end

    def plan_status_params
      params.require(:plan_status).permit(:stage, :active, :plan_id, :status_id, :effect_date)
    end

    def plan_status_active_param
      params.require(:plan_status).permit(:active)
    end


end
