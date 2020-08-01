Datadog.configure do |c|
  
  c.tracer env: 'dev'
  
  # This will activate auto-instrumentation for Rails
  c.use :rails, {'analytics_enabled': true, 'distributed_tracing': true, 'service_name': 'store-frontend'}
  # commented out hostname, use environment variable instead
  #c.tracer hostname: 'agent'
  #c.tracer env: 'dev'
  #c.tracer service: 'store-frontend'
end
