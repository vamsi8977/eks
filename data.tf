data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.aws_region}-${var.environment}-vpc"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name = "tag:Tier"
    values = [
      "Private",
    ]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name = "tag:Tier"
    values = [
      "Public",
    ]
  }
}
