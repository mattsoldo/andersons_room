class ReadingsController < ApplicationController
  before_action :set_reading, only: [:show, :edit, :update, :destroy]
  before_action :setup_nest_api, only: [:index]

  # GET /readings
  # GET /readings.json
  def index
    @readings = Reading.all
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
    @reading = Reading.new(reading_params)

    respond_to do |format|
      if @reading.save
        ## if the room temperature is less than the target
        ## then turn on the thermostat
        puts "evaluating temperature"
        if @reading.temp < ENV['TARGET_TEMP'].to_f
          setup_nest_api
          puts "Anderson is cold, it is #{@reading.temp}, turning on the thermostat"
          @nest.device='Upstairs'
          ## Set the device to higher than it's current
          ## reading to force it on
          @nest.temperature = @nest.current_temperature + 2.0
        end
        ## if we are at or above the target temp, turn it off
        if @reading.temp >= ENV['TARGET_TEMP'].to_f
          puts "target temp (#{ENV['TARGET_TEMP']}) met at #{@reading.temp}, turning off nest"
          setup_nest_api
          @nest.device='Upstairs'
          @nest.temperature = @nest.current_temperature - 5.0
        end
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
    end
end
