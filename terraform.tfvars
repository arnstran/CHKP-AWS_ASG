# Adjust vars for the AWS settings and region
# These VPCs, subnets, and gateways will be created as part of the demo
public_key_path = "~/.ssh/id_rsa.pub"
aws_region = "eu-central-1"
management_server_name = "mgmt"
template_name = "Inbound-ASG-configuration"
key_name = "AWS_pub_key"
aws_vpc_cidr = "10.30.0.0/16"
cg_size = "c5.large"
ws_size = "t2.micro"
r53zone = "domain.com."
externaldnshost = "cg-demo"
SICKey = ""
AllowUploadDownload = "true"
pwd_hash = ""

my_user_data = <<-EOF
                #!/bin/bash
                clish -c 'set user admin shell /bin/bash' -s
                blink_config -s 'gateway_cluster_member=false&ftw_sic_key=vpn12345&upload_info=true&download_info=true&admin_hash="$1$BBROBBBB$3PnqP2zapsWO.mrkGbqGQ1"'		
                addr="$(ip addr show dev eth0 | awk "/inet/{print \$2; exit}" | cut -d / -f 1)"
                dynamic_objects -n LocalGateway -r "$addr" "$addr" -a
                EOF

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
                    EOF
