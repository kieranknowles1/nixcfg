variable "project" {
  type = string
}

variable "alert_email" {
  type = string
}

resource "aws_ce_anomaly_monitor" "default" {
  name = "selwonk-anomaly-monitor"
  monitor_type = "CUSTOM"

  monitor_specification = jsonencode({
    And = null
    CostCategories = null
    Dimensions = null
    Not = null
    Or = null
    Tags = {
      Key = "user:Project"
      MatchOptions = null
      Values = [var.project]
    }
  })
}

# Warn if I'm projected to spend more than $0.10. Costs are expected
# to be negligible.
resource "aws_ce_anomaly_subscription" "zerospend" {
  name = "zerospend"
  frequency = "DAILY"

  monitor_arn_list = [aws_ce_anomaly_monitor.default.arn]

  subscriber {
    type = "EMAIL"
    address = var.alert_email
  }

  threshold_expression {
    dimension {
      key = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values = ["0.10"]
    }
  }
}
