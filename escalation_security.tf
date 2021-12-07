resource "pagerduty_escalation_policy" "security" {
  name      = "Security Escalation Policy"
  num_loops = 2
  teams     = [pagerduty_team.teams["security"].id]

  rule {
    escalation_delay_in_minutes = 30
    target {
      id   = pagerduty_user.users["security1"].id
      type = "user_reference"
    }
  }
  rule {
    escalation_delay_in_minutes = 30
    target {
      id   = pagerduty_user.users["security2"].id
      type = "user_reference"
    }
  }
}
