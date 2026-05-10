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

  resource = {
    aws_route53domains_registered_domain = {
      shunueda_com = {
        domain_name = "shunueda.com";
        auto_renew = true;

        # Privacy
        admin_privacy = true;
        billing_privacy = true;
        registrant_privacy = true;
        tech_privacy = true;

        transfer_lock = true;
      };
    };
  };
}
