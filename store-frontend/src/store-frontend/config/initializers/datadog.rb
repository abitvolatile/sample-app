Datadog.configure do |c|
  
  c.tracer env: 'dev'
  
  # This will activate auto-instrumentation for Rails
  c.use :rails, {'analytics_enabled': true, 'distributed_tracing': true, 'service_name': 'store-frontend', 'cache_service': 'store-frontend-cache', 'database_service': 'store-frontend-sqlite'}
  # Make sure requests are also instrumented
  c.use :http, {'analytics_enabled': true, 'distributed_tracing': true, 'service_name': 'store-frontend'}
end
