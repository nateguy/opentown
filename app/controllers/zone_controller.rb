class ZoneController < ApplicationController
  def index
    @zones = Zone.all
  end
end
