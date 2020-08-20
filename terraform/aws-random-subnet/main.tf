
// How to select a random subnet when using aws_instance so it won't change on you in the future.

data aws_vpc default {
  default = true
}

data aws_subnet_ids current {
  vpc_id = data.aws_vpc.default.id
}

data aws_ami current {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Use Amazon Linux 2 AMI (HVM) SSD Volume Type
  name_regex = "^amzn2-ami-hvm-.*x86_64-gp2"
  owners     = ["137112412989"] # Amazon
}

resource random_id index {
  keepers = {
    force = uuid()
  }
  byte_length = 2
}

locals {
  //  We need to convert the subnet ids from a set to list
  subnet_ids_list = tolist(data.aws_subnet_ids.current.ids)
  //  Using random_id and modulo you can a random index into the subnet_ids list
  subnet_ids_random_index = random_id.index.dec % length(data.aws_subnet_ids.current.ids)
  instance_subnet_id      = local.subnet_ids_list[local.subnet_ids_random_index]
}

resource aws_instance instance {
  ami           = data.aws_ami.current.id
  instance_type = "t3.micro"

  subnet_id = local.instance_subnet_id

  lifecycle {
    //    Ignore changes to the subnet_id field after deployment just in case the subnet_ids list changes.
    ignore_changes = [subnet_id]
  }

  tags = {
    Name = "random_subnet_test"
  }
}

output subnet_id {
  value = local.instance_subnet_id
}