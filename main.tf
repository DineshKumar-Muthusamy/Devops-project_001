resource "aws_instance" "server001" {
  
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t3.micro"

  tags = {
    Name = "Server_001"
  }
}