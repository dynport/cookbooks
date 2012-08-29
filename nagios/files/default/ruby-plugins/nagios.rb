OK = 0
WARNING = 1
CRITICAL = 2
UNKNOWN = 3

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

def abort_with_messages(messages)
  messages.each do |message|
    puts "ERROR: #{message}"
  end
  puts OPTS.to_s
  abort_unknown
end

def validate_attributes!(attributes)
  if (messages = validation_messages_from_attributes(attributes)).any?
    abort_with_messages(messages)
  end
end
