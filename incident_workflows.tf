resource "pagerduty_incident_workflow" "major_incident" {
  name        = "Major Incident Workflow"
  description = "This Incident Workflow is an example"
  step {
    name   = "Send Status Update"
    action = "pagerduty.com:incident-workflows:send-status-update:1"
    input {
      name  = "Message"
      value = "Major incident declared. Expect next status update in 15 minutes."
    }
  }
  step {
    action = "pagerduty.com:incident-workflows:add-responders:1"
    name   = "Add Responders"

    input {

      name  = "Message"
      value = "Please help me with {{incident.title}} - {{incident.url}}"
    }
    input {

      name = "Responders"
      value = jsonencode(
        [
          jsonencode(
            {
              id   = pagerduty_escalation_policy.cloud.id
              type = "escalation_policy"
            }
          ),
          jsonencode(
            {
              id   = pagerduty_escalation_policy.security.id
              type = "escalation_policy"
            }
          ),
          jsonencode(
            {
              id   = pagerduty_user.users["daffy.duck"].id
              type = "user"
            }
          ),
        ]
      )
    }
  }
  step {
    action = "pagerduty.com:incident-workflows:add-stakeholders:1"
    name   = "Add Stakeholders"

    input {

      name = "Stakeholders"
      value = jsonencode(
        [
          jsonencode(
            {
              id   = pagerduty_team.teams["cloud"].id
              type = "team"
            }
          ),
          jsonencode(
            {
              id   = pagerduty_team.teams["security"].id
              type = "team"
            }
          ),
          jsonencode(
            {
              id   = pagerduty_user.users["security1"].id
              type = "user"
            }
          ),
          jsonencode(
            {
              id   = pagerduty_user.users["cloud1"].id
              type = "user"
            }
          ),
        ]
      )
    }
  }
}

resource "pagerduty_incident_workflow_trigger" "major_incident_manual_trigger" {
  type                       = "manual"
  workflow                   = pagerduty_incident_workflow.major_incident.id
  subscribed_to_all_services = true
}
