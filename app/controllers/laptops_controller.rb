class LaptopsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_laptop, only: [:destroy, :show, :edit, :update]

  def index
      if params[:query].present?
        sql_query = "name ILIKE :query OR description ILIKE :query OR address ILIKE :query"
        @laptops = Laptop.where(sql_query, query: "%#{params[:query]}%")
      else
        @laptops = Laptop.all.order(created_at: :desc)
      end

    # the `geocoded` scope filters only laptops with coordinates (latitude & longitude)
    @markers = @laptops.geocoded.map do |laptop|
      {
        lat: laptop.latitude,
        lng: laptop.longitude,
        infoWindow: render_to_string(partial: "info_window", locals: { laptop: laptop }),
        image_url: helpers.asset_url('map-marker.png')
      }
    end
  end

  def show
    @booking = Booking.new
    @laptop = Laptop.find(params[:id])
  end

  def new
    @laptop = Laptop.new
  end

  def create
    @laptop = Laptop.new(laptop_params)
    @laptop.user = current_user
    @laptop.save ? (redirect_to dashboard_path) : (render :new)
  end

  def destroy
    @laptop.destroy
    redirect_to dashboard_path
  end

  def edit
  end

  def update
    if @laptop.update(laptop_params)
      redirect_to dashboard_path
    else
      render :edit
    end
  end

  private

  def set_laptop
    @laptop = Laptop.find(params[:id])
  end

  def laptop_params
    params.require(:laptop).permit(:address, :price_per_day, :name, :description, :photo)
  end
end
