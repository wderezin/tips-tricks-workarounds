
variable how_many {
  type = number
  description = "How many times you want to run random_id"
}

variable bucket_size {
  type = number
  description = "The number of modulo buckets."
}

variable byte_length {
  type = number
  description = "Byte length of random_id"
}

resource random_id index {
  count = var.how_many

  keepers = {
    force = uuid()
  }
  byte_length = var.byte_length
}

locals {
  values = [ for i in random_id.index : "x=${i.dec % var.bucket_size}" ]
}

output index {
  value = local.values
}