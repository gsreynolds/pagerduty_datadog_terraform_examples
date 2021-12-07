resource "pagerduty_ruleset" "cloud_datadog" {
  name = "Cloud Platform Datadog"
  team {
    id = pagerduty_team.teams["cloud"].id
  }
}

# https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/ruleset_rule
# Datadog monitors etc have been tagged with pdservice:<SERVICEKEY> which match the keys used in the Terraform map variables for the services
resource "pagerduty_ruleset_rule" "cloud_acme_web_services_datadog" {
  for_each = var.acme_web_services
  ruleset  = pagerduty_ruleset.cloud_datadog.id
  position = index(keys(var.acme_web_services), each.key)
  disabled = false
  conditions {
    operator = "and"
    subconditions {
      operator = "contains"
      parameter {
        value = "pdservice:${each.key}"
        path  = "payload.group"
      }
    }
  }
  actions {
    route {
      value = pagerduty_service.acme_web[each.key].id
    }
    severity {
      value = "info"
    }
  }
}

###############################################################################
#                                                                             #
# PagerDuty's API does not permit the "creation" of the catch all rule since  #
# it exists by default. The current best workaround is to `terraform import`  #
# the catch all rule ID so Terraform can manage it.                           #
# See: https://github.com/PagerDuty/terraform-provider-pagerduty/issues/353   #
#                                                                             #
###############################################################################

resource "pagerduty_ruleset_rule" "cloud_datadog_catch_all" {
  ruleset = pagerduty_ruleset.cloud_datadog.id
  # catch_all = true
  position = 0
  lifecycle {
    ignore_changes = [position]
  }
  actions {
    severity {
      value = "info"
    }
    suppress {
      # Change to false to create incidents from the events that have reached the catch-all rule
      value = true
    }
    route {
      value = pagerduty_service.catch_all["datadog"].id
    }
    annotate {
      value = "Event was processed by catch-all rule - investigate and create an event rule to handle."
    }
  }
}
