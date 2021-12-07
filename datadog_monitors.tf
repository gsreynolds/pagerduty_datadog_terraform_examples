
# Monitors
resource "datadog_monitor" "acme_web_alb" {
  name    = "ACME Web ALB healthy hosts"
  type    = "metric alert"
  message = "Monitor triggered. Notify: @pagerduty-${datadog_integration_pagerduty_service_object.ruleset_example.service_name}"

  query = "avg(last_5m):avg:aws.applicationelb.un_healthy_host_count{name:acme-web-lb} >= 2"
  monitor_thresholds {
    ok       = 0
    warning  = 1
    critical = 2
  }

  evaluation_delay = 60
  tags             = ["pdservice:web_app"]
}

resource "datadog_monitor" "acme_web_asg" {
  name    = "ACME Web ASG in-service hosts"
  type    = "metric alert"
  message = "Monitor triggered. Notify: @pagerduty-${datadog_integration_pagerduty_service_object.ruleset_example.service_name}"

  query = "avg(last_5m):avg:aws.autoscaling.group_in_service_instances{name:acme-web-frontends} <= 1"
  monitor_thresholds {
    ok       = 2
    warning  = 2
    critical = 1
  }

  evaluation_delay = 60
  tags             = ["pdservice:web_app"]
}

resource "datadog_monitor" "acme_db" {
  name    = "ACME Web RDS free storage space"
  type    = "metric alert"
  message = "Monitor triggered. Notify: @pagerduty-${datadog_integration_pagerduty_service_object.ruleset_example.service_name}"

  query = "avg(last_5m):avg:aws.rds.free_storage_space{name:acmewebdb-postgres} <= 1000000000"
  monitor_thresholds {
    ok       = 4000000000
    warning  = 2000000000
    critical = 1000000000
  }

  evaluation_delay = 60
  tags             = ["pdservice:web_db"]
}

resource "datadog_monitor" "acme_service_example" {
  name    = "ACME Datadog Agent alert"
  type    = "service check"
  message = "Datadog agent is down on {{host.name}}. Notify: @pagerduty-${datadog_integration_pagerduty_service_object.service_example.service_name}"

  query = "\"datadog.agent.up\".over(\"*\").by(\"host\").last(2).count_by_status()"

  evaluation_delay = 60
  notify_no_data   = true
}

