class ZonesController < ApplicationController
  before_action :set_zone, only: [:show, :edit, :update, :destroy]

  def index
    @zones = Zone.all
  end

  def new
    @zone = Zone.new
  end

  def show

  end

  def create
    @zone = Zone.new(zone_params)

    respond_to do |format|
      if @zone.save
        format.html { redirect_to zones_url, notice: 'Zone was successfully created.' }
        format.json { render :show, status: :created, location: @zone }
      else
        format.html { render :new }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end

  end

  def update
    respond_to do |format|
      if @zone.update(zone_params)
        format.html { redirect_to zones_url, notice: 'Zone was successfully updated.' }
        format.json { render :show, status: :ok, location: @zone }
      else
        format.html { render :edit }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @zone.destroy
    respond_to do |format|
      format.html { redirect_to zones_url, notice: 'Zone was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_zone
      @zone = Zone.find(params[:id])
    end

    def zone_params
      params.require(:zone).permit(:code, :description, :classification, :color_code)
    end
end