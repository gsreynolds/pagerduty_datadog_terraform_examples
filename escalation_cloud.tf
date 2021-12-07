resource "pagerduty_schedule" "cloud_primary" {
  name      = "Cloud Team - Primary On Call"
  time_zone = "Europe/London"
  teams     = [pagerduty_team.teams["cloud"].id]

  layer {
    name                         = "Weekdays"
    rotation_turn_length_seconds = 24 * 60 * 60
    rotation_virtual_start       = "2021-11-01T12:00:00+00:00"
    start                        = "2021-11-01T12:00:00+00:00"
    users = [
      pagerduty_user.users["wile.e.coyote"].id,
      pagerduty_user.users["daffy.duck"].id,
      pagerduty_user.users["cloud2"].id,
    ]
    restriction {
      duration_seconds  = 4 * 24 * 60 * 60
      start_day_of_week = 1
      start_time_of_day = "12:00:00"
      type              = "weekly_restriction"
    }
  }
  layer {
    name                         = "Weekend"
    rotation_turn_length_seconds = 7 * 24 * 60 * 60
    rotation_virtual_start       = "2021-11-01T12:00:00+00:00"
    start                        = "2021-11-01T12:00:00+00:00"
    users = [
      pagerduty_user.users["daffy.duck"].id,
      pagerduty_user.users["cloud2"].id,
      pagerduty_user.users["wile.e.coyote"].id,
    ]

    restriction {
      duration_seconds  = 3 * 24 * 60 * 60
      start_day_of_week = 5
      start_time_of_day = "12:00:00"
      type              = "weekly_restriction"
    }
  }
  lifecycle {
    ignore_changes = [
      teams,
    ]
  }
}

resource "pagerduty_schedule" "cloud_secondary" {
  name      = "Cloud Team - Secondary On Call"
  time_zone = "Europe/London"
  teams     = [pagerduty_team.teams["cloud"].id]

  layer {
    name                         = "Weekdays"
    rotation_turn_length_seconds = 24 * 60 * 60
    rotation_virtual_start       = "2021-11-01T12:00:00+00:00"
    start                        = "2021-11-01T12:00:00+00:00"
    users = [
      pagerduty_user.users["daffy.duck"].id,
      pagerduty_user.users["cloud2"].id,
      pagerduty_user.users["wile.e.coyote"].id,
    ]
    restriction {
      duration_seconds  = 4 * 24 * 60 * 60
      start_day_of_week = 1
      start_time_of_day = "12:00:00"
      type              = "weekly_restriction"
    }
  }
  layer {
    name                         = "Weekend"
    rotation_turn_length_seconds = 7 * 24 * 60 * 60
    rotation_virtual_start       = "2021-11-01T12:00:00+00:00"
    start                        = "2021-11-01T12:00:00+00:00"
    users = [
      pagerduty_user.users["cloud2"].id,
      pagerduty_user.users["wile.e.coyote"].id,
      pagerduty_user.users["daffy.duck"].id,
    ]

    restriction {
      duration_seconds  = 3 * 24 * 60 * 60
      start_day_of_week = 5
      start_time_of_day = "12:00:00"
      type              = "weekly_restriction"
    }
  }
}

resource "pagerduty_escalation_policy" "cloud" {
  name      = "Cloud Team Escalation Policy"
  num_loops = 2
  teams     = [pagerduty_team.teams["cloud"].id]

  rule {
    escalation_delay_in_minutes = 30
    target {
      id   = pagerduty_schedule.cloud_primary.id
      type = "schedule_reference"
    }
  }
  rule {
    escalation_delay_in_minutes = 30
    target {
      id   = pagerduty_schedule.cloud_secondary.id
      type = "schedule_reference"
    }
  }
  rule {
    escalation_delay_in_minutes = 30

    target {
      id   = pagerduty_user.users["cloud1"].id
      type = "user_reference"
    }
  }
}
