variable "acme_web_services" {
  type = map(object({
    name        = string
    description = string
  }))

  default = {
    "web_app" = { name = "ACME Web App", description = "ACME dot com web frontend application" },
    "web_db"  = { name = "ACME Web DB", description = "ACME dot com backend databases" },
  }
}

resource "pagerduty_service" "acme_web" {
  for_each          = var.acme_web_services
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
