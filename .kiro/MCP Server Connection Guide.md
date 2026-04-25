1. Install the AWS CLI by following the instructions at [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
    
2. Configure your AWS credentials using one of these methods:
    From the AWS CLI, run the following command:
    
    `aws configure sso`
    
    Follow the prompts to set up your SSO configuration.
    
3. Test your configuration:
    
    `aws sts get-caller-identity`
    
4. Install uv (if not already installed)
    
    ###### On macOS and Linux
    
    `curl -LsSf https://astral.sh/uv/install.sh | sh`
    
    ###### Windows
    
    `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`