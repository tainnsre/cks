include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  #source = "git::git@github.com:ViktorUJ/cks.git//terraform/modules/k8s_self_managment/?ref=task_01"
  source = "../../..//modules/k8s_self_managment/"

  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }

}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  region       = local.vars.locals.region
  aws          = local.vars.locals.aws
  prefix       = local.vars.locals.prefix
  tags_common  = local.vars.locals.tags
  app_name     = "k8s"
  subnets_az   = dependency.vpc.outputs.subnets_az_cmdb
  vpc_id       = dependency.vpc.outputs.vpc_id
  cluster_name = "k8s1"
  node_type    = "spot" #"ondemand"  "spot"
  k8s_master = {
    k8_version     = "1.26.0"
    runtime        = "cri-o" # docker  , cri-o  , containerd ( need test it )
    runtime_script = "template/runtime.sh"
    instance_type  = "t3.medium"
    key_name       = "cks"
    ami_id         = "ami-06410fb0e71718398"
    #  ubuntu  :  20.04 LTS  ami-06410fb0e71718398     22.04 LTS  ami-00c70b245f5354c0a
    subnet_number      = "0"
    user_data_template = "template/master.sh"
    pod_network_cidr   = "10.0.0.0/16"
    cidrs              = ["0.0.0.0/0"]
    eip                = "true"
    utils_enable       = "false"
    task_script_url    = "https://raw.githubusercontent.com/ViktorUJ/cks/fix_links/tasks/cka/01/scripts/master.sh"
    calico_url         = "https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml"
    ssh = {
      private_key = ""
      pub_key     = ""
    }
    root_volume = {
      type = "gp3"
      size = "12"
    }
  }
  k8s_worker = {
    # we can  configure each node independently
    #   "node_1" = {
    #     k8_version         = "1.25.0"
    #     instance_type      = "t3.medium"
    #     key_name           = "cks"
    #     ami_id             = "ami-00c70b245f5354c0a"
    #     subnet_number      = "0"
    #     user_data_template = "template/worker.sh"
    #     runtime            = "cri-o"
    #     runtime_script     = "template/runtime.sh"
    #     task_script_url    = "https://raw.githubusercontent.com/ViktorUJ/cks/task_01/tasks/cks/03/scripts/worker.sh"
    #     node_labels        = "work_type=falco,aws_scheduler=true"
    #     cidrs              = ["0.0.0.0/0"]
    #     root_volume        = {
    #       type = "gp3"
    #       size = "20"
    #     }
    #   }

    #   "node_2" = {
    #     k8_version         = "1.26.0"
    #     instance_type      = "t3.medium"
    #     key_name           = "cks"
    #     ami_id             = "ami-00c70b245f5354c0a"
    #     subnet_number      = "0"
    #     user_data_template = "template/worker.sh"
    #     runtime            = "cri-o"
    #     runtime_script     = "template/runtime.sh"
    #     task_script_url    = ""
    #     node_labels        = "work_type=infra_core,aws_scheduler=true"
    #
    #     cidrs       = ["0.0.0.0/0"]
    #     root_volume = {
    #       type = "gp3"
    #       size = "20"
    #     }
    #   }
    #

  }
}
