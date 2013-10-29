class Reading < ActiveRecord::Base
	begin
    @@nest = NestThermostat::Nest.new({email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS']})
    @@nest.device='Upstairs'
  rescue
    puts "nest API not available"
  end
  validates :temp, presence: true

  validate :within_ci, on: :create
  after_create :evaluate_temperature
  # def validate(record)
  #   unless record.within_ci?
  #     record.errors[:temp] << 'is outside the confidence interval'
  #   end
  # end

  def temperature
		temp
	end

  def self.nest_current_temp
    @@nest.current_temperature
  end

  def self.nest_set_to
    @@nest.temperature    
  end

	def self.running_average(n=3)
	  ActiveRecord::Base.connection.execute("select avg(temp) from readings group by id order by id desc limit #{n}")[0]["avg"].to_f
	end

	def self.stddev
	  ActiveRecord::Base.connection.execute("select stddev_samp(temp) from readings")[0]["stddev_samp"].to_f
  end

  def within_ci
    unless (temp > Reading.average('temp') - (Reading.stddev * 2)) && 
       (temp < Reading.average('temp') + (Reading.stddev * 2))
      errors.add(:temp, "is not within the confidence interval")
    end
  end

  def self.use_nest_api?
    last_reading_using_nest = Reading.where(:nest_updated => true).
                              order('id desc').first
    
    if last_reading_using_nest.nil?
      return true
    elsif Time.now - last_reading_using_nest.created_at > 60*5
      return true
    else
      return false
    end
  end

  def self.nest_on?
    last_reading_using_nest = Reading.where(:nest_updated => true).
                              order('id desc').first
    # if the last known state is more than 10 minutes old
    # consider it unknown
    if last_reading_using_nest.nil?
      return nil
    elsif Time.now - last_reading_using_nest.created_at > 5*60
      return nil
    else
      last_reading_using_nest.nest_on
    end
  end

  def evaluate_temperature
    ## if the room temperature is less than the target
    ## then turn on the thermostat
    puts "evaluating temperature"
    if Reading.running_average(4) < ENV['TARGET_TEMP'].to_f && Reading.use_nest_api?
      ## Set the device to higher than it's current
      ## reading to force it on
      if Reading.nest_on?.nil? || Reading.nest_on? == false
        puts "Anderson is cold, it is #{temp}, turning on the thermostat"
        @@nest.temperature = @@nest.current_temperature + 2.0
        nest_on = true
        nest_updated=true
        save
      end
    end
    ## if we are at or above the target temp, turn it off
    if Reading.running_average(2) >= ENV['TARGET_TEMP'].to_f
      if Reading.nest_on?
        puts "target temp (#{ENV['TARGET_TEMP']}) met at #{temp}, turning off nest"
        @@nest.temperature = @@nest.current_temperature - 5.0
        nest_on = false
        nest_updated=true
        save
      end
    end
  end
end
