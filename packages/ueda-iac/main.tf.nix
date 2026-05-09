{
  terraform = {
    cloud = {
      organization = "ueda";
      workspaces = {
        name = "base";
      };
    };

    required_providers.aws = {
      source = "hashicorp/aws";
    };
  };

  provider.aws = {
    region = "us-east-2";
  };
}
