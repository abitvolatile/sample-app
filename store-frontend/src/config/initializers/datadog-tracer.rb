# config/initializers/datadog-tracer.rb

Datadog.configure do |c|
  c.tracer.enabled = true
  c.tracer.port = 8126
  c.tracer.partial_flush.enabled = false
  c.tracer env: 'dev'

  # To enable debug mode:
  c.diagnostics.debug = false
end
