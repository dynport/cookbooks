require "optparse"
OK = 0
WARNING = 1
CRITICAL = 2
UNKNOWN = 3

def smaller_is_worse!
  @smaller_is_worse = true
end

def smaller_is_worse?
  @smaller_is_worse == true
end

def comparision_factor
  smaller_is_worse? ? -1 : 1
end

def abort_ok
  exit(OK)
end

def abort_warning
  exit(WARNING)
end

def abort_critical
  exit(CRITICAL)
end

def abort_unknown
  exit(UNKNOWN)
end

def rescue_from_all
  yield
rescue SystemExit => err
  puts "caught: #{err.class} #{err.message}"
  exit(err.status)
rescue Exception => err
  puts "ERROR: #{err.message}"
  abort_unknown
end

def abort_with_messages(messages)
  messages.each do |message|
    puts "ERROR: #{message}"
  end
  puts OPTS.to_s
  abort_unknown
end

def validate_presence(attributes, *keys)
  keys.map { |key| "#{key.to_s.upcase} must be set" if attributes[key].nil? }.compact
end

# smaller_is_worse should be used for e.g times ago
# warning: 60s ago, critical: 600s is okay => (60 - 600) * -1 > 0
def validate_thresholds(attributes)
  messages = []
  messages << "CRITICAL must be set" if attributes[:critical].nil?
  messages << "WARNING must be set" if attributes[:warning].nil?
  if attributes[:warning] && attributes[:critical]
    if ((attributes[:warning] - attributes[:critical]) * comparision_factor) <= 0
      messages << "WARNING must be #{smaller_is_worse? ? "bigger" : "smaller"} than CRITICAL" 
      end
  end
  messages
end

def all_validations(attributes)
  custom_validations(attributes) + validate_thresholds(attributes)
end

def validate_attributes!(attributes)
  messages = validate_thresholds(attributes)
  messages += yield if block_given?
  if messages.any?
    abort_with_messages(messages)
  end
end
