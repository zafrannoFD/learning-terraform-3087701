data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.nano"

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y java-17-amazon-corretto wget

    TOMCAT_VERSION=$(curl -s https://downloads.apache.org/tomcat/tomcat-10/ | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
    wget -q "https://downloads.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" -O /tmp/tomcat.tar.gz
    tar -xzf /tmp/tomcat.tar.gz -C /opt
    mv "/opt/apache-tomcat-${TOMCAT_VERSION}" /opt/tomcat
    chmod +x /opt/tomcat/bin/*.sh
    nohup /opt/tomcat/bin/startup.sh &
  EOF

  tags = {
    Name = "HelloWorld"
  }
}
