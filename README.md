# CHKP-AWS_ASG
Deploys a Check Point ASG using Terraform with VMSS in both North (inbound) hub.

Needs:
- terraform installed
    https://azurecitadel.com/prereqs/wsl/
- an existing R80.20 Check Point Management prepared with autoprovision and policy for the ASG
    https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk112575
- AWS credentials in variable file or better as Environment Variables on the host
    Example added to the end of .bashrc on your host
        export AWS_ACCESS_KEY_ID='XXXXXXXXXXXXXXXXX'
        export AWS_SECRET_ACCESS_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        export AWS_REGION=eu-central-1

Notes:
- Management server communicate with gateways over public IPs

Run:
put the files in a directory on your host (download or git clone) and fron that directory run:
'terraform init'
'terraform plan' (optional)
'terrafrom apply'

Known issues:
