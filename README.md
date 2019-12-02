# CHKP-AWS_ASG
Deploys a Check Point ASG using Terraform in North (inbound) hub.
Deploys both external load balancer.
Deploys web servers in internal subnet behind an internal load balancer.

Needs:
- terraform installed
    Ie. using https://azurecitadel.com/prereqs/wsl/
- an existing R80.30 Check Point Management prepared with autoprovision and policy for the ASG
    https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk112575
- AWS credentials in variable file or better as Environment Variables on the host
    Example added to the end of .bashrc on your host
        export AWS_ACCESS_KEY_ID='XXXXXXXXXXXXXXXXX'
        export AWS_SECRET_ACCESS_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        export AWS_REGION=eu-central-1

Notes:
- Management server communicate with gateways over public IPs
- Tested with terraform version 0.11

Run:
Before you run the templates, terraform.tfvars needs to be updated. At least SICKey, pwd_hash and public_key_path. 
And make sure relevant variables (management_server_name, template_name and SICKey) matches your Management server autoprovision configuration that you did above.

Put the files in a directory (download or git clone) on your host (the host where terraform is installed), and from that directory run:
- 'terraform init'
- 'terraform 0.12upgrade' (only if terraform version 0.12 is used)
- 'terraform plan' (optional)
- 'terraform apply'


Testing: When the deployment finishes, it prints the web app DNS name. Web app on port 80 and 8080.

- When the deployment finished it still takes a few minutes for all the Check Point autoprovison to finish.
- Test published web apps by browsing to web app DNS name.
- Verify logs in SmartConsole


Stop/destroy: When finished, stop instances or run 'terraform destroy' to remove the deployment

Known issues:
