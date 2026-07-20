variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  type    = string
  default = "ami-0866a3c8686eaeeba"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"  # यहाँ हमने t2.micro को बदलकर t3.micro कर दिया है
}

variable "key_name" {
  type    = string
  default = "my-aws-key"
}
