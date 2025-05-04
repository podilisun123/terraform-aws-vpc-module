locals {
  resource_name = "${var.projct_name}-${var.environment}"
  zones_names = slice(data.aws_availability_zones.available.names,0,2)
}
