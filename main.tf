## Using terraform I'm creating a infrastructure.
provider "aws" {
    region = "us-east-1"
    profile = "my-profile"
  } 

# Creating VPC....

resource "aws_vpc" "Project_VPC" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name="Project_VPC"
    }
}

# Creating Internet-Gateway.....

resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.Project_VPC.id
    tags = {
      "Name" = "my-igw"
    }
  
}

## Creating security groups for EC2 instance....

resource "aws_security_group" "Project_SG" {
    vpc_id = aws_vpc.Project_VPC.id
    ingress {
        description = "Defining ingress rules for SG/ Security-Group."
        from_port = 0
        to_port = 0
        #protocol = "tcp"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

   /* ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }*/

    egress {
        description = "Defining egress rues for SG / Security-Group."
        from_port = 0
        to_port = 0
        #protocol = "tcp"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
    tags = {
      Name="Project_SG"
    }
}

## Creating a public subnet .....

resource "aws_subnet" "my-public-subnet" {
    vpc_id = aws_vpc.Project_VPC.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = {
      Name="my-public-subnet"
    }
  
}

### Creating a route table....

resource "aws_route_table" "my-route-table" {
    vpc_id = aws_vpc.Project_VPC.id
    route {
        cidr_block="0.0.0.0/0"
        gateway_id=aws_internet_gateway.my-igw.id
    }
}

### Doing route association...

resource "aws_route_table_association" "rt_asso" {
    subnet_id = aws_subnet.my-public-subnet.id
    route_table_id=aws_route_table.my-route-table.id
  
}

### Creating EC2 instance .....

resource "aws_instance" "K-Master" {
    ami = "ami-080e1f13689e07408"
    instance_type = "t2.medium"
    key_name = "My-Key_Pair"
    subnet_id = aws_subnet.my-public-subnet.id
    security_groups = [aws_security_group.Project_SG.id]
    tags = {
      "Name"="K-Master"
    }
}

resource "aws_instance" "K-Slave" {
    ami = "ami-080e1f13689e07408"
    instance_type = "t2.micro"
    key_name = "My-Key_Pair"
    subnet_id = aws_subnet.my-public-subnet.id
    security_groups = [aws_security_group.Project_SG.id]
    tags = {
      "Name"="K-Slave"
    }
}
