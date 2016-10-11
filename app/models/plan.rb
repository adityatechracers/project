class Plan
  attr_accessor :name

  CONFIG = YAML.load_file("#{Rails.root}/config/plans.yml")

  class << self
    def free_plan
      new('Free')
    end

    def trial_duration
      CONFIG['trial']['duration_in_days']
    end

    def each_plan(&block)
      CONFIG['plans'].keys.each_with_index do |p, i|
        yield new(p), i
      end
    end

    def names
      CONFIG['plans'].keys
    end
  end

  def initialize(name)
    @name = name
    @name = 'Bronze' if name == 'Free'
  end

  def ==(other)
    other.is_a?(Plan) && other.name == @name
  end

  def num_users
    CONFIG['plans'][@name]['users']
  end

  def description
    CONFIG['plans'][@name]['description']
  end

  def monthly_cost
    CONFIG['plans'][@name]['monthly_cost']
  end

  def is_enterprise?
    self.name == "Enterprise"
  end

  def numeric_monthly_cost
    if self.is_enterprise? then 99999
    else self.monthly_cost end
  end

  def stripe_plan
    Stripe::Plan.all.data.find { |p| p['name'] == @name }
  end
end
