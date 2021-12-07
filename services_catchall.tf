# During implementation, it can be useful to utilise the Catch-All rules at the 
# bottom of the rulesets to create suppressed alerts (or incidents) for events not yet handled 
# with event rules.
#
# These suppressed alerts should likely be info severity and reviewed regularly
# If alerts are choosen not be suppressed and incidents are created, they should 
# possibly not assigned to a real escalation policy.

variable "catch_all_services" {
  type = map(object({
    name        = string
    description = string
  }))

  default = {
    "datadog" = { name = "Datadog Catch-all", description = "Catch-all service for triage of events from Datadog not currently matched with event rules." },
  }
}

# Catch All - note PagerDuty actively drops emails to example.com domain or domains ending .invalid
resource "pagerduty_user" "_noone_nowhere" {
  name      = "No One Nowhere"
  email     = "noone.nowhere@example.com"
  role      = "limited_user"
  job_title = "Dummy User for Catch All purposes"
}

resource "pagerduty_escalation_policy" "catchall" {
  name      = "Catchall Escalation Policy"
  num_loops = 2
  teams     = [pagerduty_team.teams["cloud"].id]

  rule {
    escalation_delay_in_minutes = 30

    target {
      id   = pagerduty_user._noone_nowhere.id
      type = "user_reference"
    }
  }
}


resource "pagerduty_service" "catch_all" {
  for_each          = var.catch_all_services
  name              = each.value.name
  description       = each.value.description
  escalation_policy = pagerduty_escalation_policy.catchall.id
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
