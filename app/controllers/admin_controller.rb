class AdminController < ApplicationController

  def zones
    @zones = Zone.all
  end
end
