variable "service_examples" {
  type = map(object({
    name        = string
    description = string
  }))

  default = {
    "datadog_agent" = { name = "ACME Datadog Agent", description = "Example service for service level integration" },
  }
}

resource "pagerduty_service" "acme_example" {
  for_each          = var.service_examples
  name              = each.value.name
  description       = each.value.description
  escalation_policy = pagerduty_escalation_policy.cloud.id
  alert_grouping_parameters {
    type = "intelligent"
    config {}
  }
  incident_urgency_rule {
    type    = "constant"
    urgency = "severity_based"
  }
  alert_creation          = "create_alerts_and_incidents"
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = "null"
}

resource "pagerduty_service_integration" "datadog_agent_datadog" {
  name    = data.pagerduty_vendor.datadog.name
  service = pagerduty_service.acme_example["datadog_agent"].id
  vendor  = data.pagerduty_vendor.datadog.id
}
