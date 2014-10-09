resource "aws_instance" "ubuntu-node" {
  ami = "ami-9657e6fe"
  instance_type = "t2.micro"

  key_name = "Phil_Laptop"

  security_groups = ["sg-4deba028"]
  subnet_id = "subnet-4acd2513"
  associate_public_ip_address = "true"
  
  user_data = "${file("user_data.yaml")}"

  count = 10
}
