#!/bin/bash

check_cli(){
        if ! command -v aws &> /dev/null; then
                echo "AWS CLI is not Installed" >&2
                return 1
        fi
        return 0
}
aws_cli_install(){

        echo "AWS-CLI is now installing"
        if find . -name "awscli-bundle.zip" 2>/dev/null | grep -q .; then
                echo"You already have it zip"
        else
                 curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

        fi
        #Unzipping file

        unzip awscli-bundle.zip &> /dev/null
        #Finally installing the bundle 
        sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws &> /dev/null

        echo "Cleaning the Zip file & Removing them"    
        rm -rf awscli-bundle.zip
        rm -rf awscli-bundle
}
python_install(){
        if command -v python3 -v python &>/dev/null; then
                echo "Python is already Installed"
        else
                sudo apt install python-is-python3 -y
        fi
}
wait_for_instance() {
    local instance_id="$1"
    echo "Waiting for instance $instance_id to be in running state..."

    while true; do
        state=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].State.Name' --output text)
        if [[ "$state" == "running" ]]; then
            echo "Instance $instance_id is now running."
            break
        fi
        sleep 10
    done
}
aws_configure(){
        export AWS_ACCESS_KEY_ID=""
        export AWS_SECRET_ACCESS_KEY=""
        export AWS_DEFAULT_REGION="us-east-1"
}
create_ec2_resource(){
        echo "Creating EC2 Instance"    
            local ami_id="$1"
    local instance_type="$2"
    local key_name="$3"
    local subnet_id="$4"
    local security_group_ids="$5"
    local instance_name="$6"

    # Run AWS CLI command to create EC2 instance
    instance_id=$(aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --key-name "$key_name" \
        --subnet-id "$subnet_id" \
        --security-group-ids "$security_group_ids" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )

        # If the instance_id is empty then return fail
        if [[ -z "$instance_id" ]]; then
                echo "Instance is Failed"
        else
                echo "$instance_id, Congraulation your EC2 is created Successfully"
        fi

        wait_for_instance "$instance_id"
}


main() {
check_cli || aws_cli_install
python_install
aws_configure
AMI_ID="ami-020cba7c55df1f615"
INSTANCE_TYPE="t2.micro"
KEY_NAME="script"
SUBNET_ID=""
SECURITY_GROUP_IDS="sg-07fdb4a9e58307b9c"
INSTANCE_NAME="CreatedEC2"
create_ec2_resource "$AMI_ID" "$INSTANCE_TYPE" "$KEY_NAME" "$SUBNET_ID" "$SECURITY_GROUP_IDS" "$INSTANCE_NAME"

}

main "$@"


