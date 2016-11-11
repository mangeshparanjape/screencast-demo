provider "aws" {
	region = "us-east-1"
}

module "vpc" {
	source = "github.com/outerstack/vpc"
	name = "Outerstack"
	availability_zones = ["us-east-1b", "us-east-1c", "us-east-1d"]
}

module "ecs" {
	source = "github.com/outerstack/ecs-cluster"	
	name = "outerstack-prod"
	environment = "prod"
	vpc_id = "${module.vpc.id}"
	availability_zones = "${module.vpc.public_availability_zones}"
	subnets = "${module.vpc.public_subnets}"
}

module "alb" {
	source = "github.com/outerstack/ecs-cluster"
	name = "outerstack-io"
	route53_cname = "outerstack.io"
	route53_zone_id = "Z2F9K1T0LTFXHB"
	cert_dir = "~/outerstack/ssl/outerstack.io"
	subnets = "${module.vpc.public_subnets}"
	vpc_id = "${module.vpc.id}"
}

module "app" {
	source = "github.com/outerstack/ecs-service"
	name = "io-app"
	registry = "341734255325.dkr.ecr.us-east-1.amazonaws.com"	
	cluster_id = "${module.ecs.id}"
	target_group_arn = "${module.alb.target_group_arn}"
}

module "rds" {
	source = "github.com/outerstack/rds"
	name = "outerstack"
	engine = "mysql"
	engine_version = "5.7.11"
	port = "3306"
	instance_class = "db.t2.micro"
	parameter_group_name = "default.mysql5.7"
	master_username = "root"
	master_password = "XXXXXXXXXX"
	vpc_id = "${module.vpc.id}"	
	subnet_ids = "${module.vpc.private_subnets}"
}