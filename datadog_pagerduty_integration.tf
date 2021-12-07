
# PagerDuty integration
resource "datadog_integration_pagerduty" "pagerduty" {
  subdomain = var.pagerduty_subdomain
  lifecycle {
    ignore_changes = [
      schedules,
    ]
  }
}

resource "datadog_integration_pagerduty_service_object" "event_orchestration_example" {
  depends_on   = [datadog_integration_pagerduty.pagerduty]
  service_name = "ACMECloudEventOrchestration"
  service_key  = pagerduty_event_orchestration.my_monitor.integration[0].parameters[0].routing_key
}

resource "datadog_integration_pagerduty_service_object" "ruleset_example" {
  depends_on   = [datadog_integration_pagerduty.pagerduty]
  service_name = "ACMECloudRuleset"
  service_key  = pagerduty_ruleset.cloud_datadog.routing_keys[0]
}

resource "datadog_integration_pagerduty_service_object" "service_example" {
  depends_on   = [datadog_integration_pagerduty.pagerduty]
  service_name = "ACMEServiceExample"
  service_key  = pagerduty_service_integration.datadog_agent_datadog.integration_key
}
