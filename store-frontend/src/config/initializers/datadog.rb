Datadog.configure do |c|

  c.tracer env: 'dev'
  
  # This will activate auto-instrumentation for Rails
  c.use :rails, {'analytics_enabled': true, 'distributed_tracing': true}
  # use environment variable instead for trace hostname
  #c.tracer hostname: 'agent'

end
