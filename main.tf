resource "aws_key_pair" "keygen" {
  key_name   = var.key
  public_key = tls_private_key.pkey.public_key_openssh
}

resource "tls_private_key" "pkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "pkeyfile" {
  content  = tls_private_key.pkey.private_key_pem
  filename = "tfkey"
}

resource "aws_dynamodb_table" "tf_state_lock" {
  name         = "TerraformStateLock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "dynamodb-tf-state-lock"
  }
}


resource "aws_instance" "my-ec2" {
  ami                         = data.aws_ami.amzlinux.id
  instance_type               = var.inst-type
  vpc_security_group_ids      = [aws_security_group.cust-sg.id]
  subnet_id                   = aws_subnet.subnet.id
  availability_zone           = var.availability_zone
  key_name                    = var.key
  associate_public_ip_address = true
  user_data                   = file("test.sh")
  depends_on                  = [aws_ebs_volume.ebs]

  tags = {
    Name = var.instance-name
  }
}

resource "aws_ebs_volume" "ebs" {
  availability_zone = "ap-south-1a"
  size              = 5

  tags = {
    Name = "ebs"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.my-ec2.id

}
