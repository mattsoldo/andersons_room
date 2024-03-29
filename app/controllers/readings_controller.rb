class ReadingsController < ApplicationController
  before_action :set_reading, only: [:show, :edit, :update, :destroy]
  # before_action :setup_nest_api, only: [:index]

  # GET /readings
  # GET /readings.json
  def index
    # @readings = Reading.all
    @latest_reading = Reading.last
  end

  # GET /readings/1
  # GET /readings/1.json
  def show
  end

  # GET /readings/new
  def new
    @reading = Reading.new
  end

  # GET /readings/1/edit
  def edit
  end

  # POST /readings
  # POST /readings.json
  def create
    puts "New Reading: #{request.headers["X-Request-ID"]}, params: #{reading_params}"

    @reading = Reading.new(reading_params)
    respond_to do |format|
      if @reading.save
        format.html { redirect_to @reading, notice: 'Reading was successfully created.' }
        format.json { render action: 'show', status: :created, location: @reading }
      else
        format.html { render action: 'new' }
        format.json { render json: @reading.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /readings/1
  # PATCH/PUT /readings/1.json
  def update
    respond_to do |format|
      if @reading.update(reading_params)        
        format.html { redirect_to @reading, notice: 'Reading was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @reading.errors, status: :unprocessable_entity }
        puts reading_params
      end
    end
  end

  # DELETE /readings/1
  # DELETE /readings/1.json
  def destroy
    @reading.destroy
    respond_to do |format|
      format.html { redirect_to readings_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reading
      @reading = Reading.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reading_params
      params.require(:reading).permit(:temp, :recorded_at)
    end

    def setup_nest_api
      @nest = NestThermostat::Nest.new({email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS']})
      @nest.device='Upstairs'
    end
end
