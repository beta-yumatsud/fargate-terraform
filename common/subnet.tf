## network: subnet
# If need to divide public and private, divide this file.
data "aws_availability_zones" "available" {}

resource "aws_subnet" "main" {
  count             = "${var.aws_az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table_association" "main" {
  count          = "${var.aws_az_count}"
  route_table_id = "${aws_route_table.main.id}"
  subnet_id      = "${element(aws_subnet.main.*.id, count.index)}"
}

output "subnets" {
  value = "${aws_subnet.main.*.id}"
}
