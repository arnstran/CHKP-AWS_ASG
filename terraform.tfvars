# Adjust vars for the AWS settings and region
# These VPCs, subnets, and gateways will be created as part of the demo
public_key_path = "~/.ssh/id_rsa.pub"
aws_region = "eu-central-1"
management_server_name = "mgmt"
template_name = "Inbound-ASG-configuration"
key_name = "AWS_pub_key"
aws_vpc_cidr = "10.30.0.0/16"
//aws_external1_subnet_cidr = "10.30.1.0/24"
//aws_external2_subnet_cidr = "10.30.2.0/24"
//aws_webserver1_subnet_cidr = "10.30.10.0/24"
//aws_webserver2_subnet_cidr = "10.30.20.0/24"
cg_size = "c5.large"
ws_size = "t2.micro"
r53zone = "domain.com."
externaldnshost = "cg-demo"
SICKey = ""
AllowUploadDownload = "true"
pwd_hash = ""

ubuntu_user_data = <<-EOF
                    #!/bin/bash
                    until sudo apt-get update && sudo apt-get -y install apache2;do
                      sleep 1
                    done
                    until curl \
                      --output /var/www/html/CloudGuard.png \
                      --url https://www.checkpoint.com/wp-content/uploads/cloudguard-hero-image.png ; do
                       sleep 1
                    done
                    sudo chmod a+w /var/www/html/index.html 
                    echo "<html><head><meta http-equiv=refresh content="5" /> </head><body><center><H1>" > /var/www/html/index.html
                    echo $HOSTNAME >> /var/www/html/index.html
                    echo "<BR><BR>Check Point CloudGuard ASG Demo <BR><BR>Any Cloud, Any App, Unmatched Security<BR><BR>" >> /var/www/html/index.html
                    echo "<img src=\"/CloudGuard.png\" height=\"25%\">" >> /var/www/html/index.html
                    until curl -fsSL https://get.docker.com -o get-docker.sh;do
                      sleep 1
                    done
                    until sh get-docker.sh;do
                      sleep 1
                    done
                    until sudo docker pull bkimminich/juice-shop:v7.5.1;do
                      sleep 1
                    done
                    until sudo docker run -d -p 3000:3000 bkimminich/juice-shop:v7.5.1;do
                      sleep 1
                    done
                    EOF
