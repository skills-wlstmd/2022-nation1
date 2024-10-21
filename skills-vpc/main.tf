module "vpc" {
  source = "./modules"

  vpc_name = local.vpc.name
  vpc_cidr = local.vpc.cidr

  private_subnet_a_name =  "skills-private-a"
  private_subnet_a_cidr = "10.0.0.0/24"

  private_subnet_b_name =  "skills-private-b"
  private_subnet_b_cidr = "10.0.1.0/24"

  private_subnet_c_name = "skills-private-c"
  private_subnet_c_cidr = "10.0.2.0/24"

  public_subnet_a_name = "skills-public-a"
  public_subnet_a_cidr = "10.0.3.0/24"

  public_subnet_b_name = "skills-public-b"
  public_subnet_b_cidr = "10.0.4.0/24"

  public_subnet_c_name = "skills-public-c"
  public_subnet_c_cidr = "10.0.5.0/24"

  igw_name = "skills-igw"

  nat_a_name = "skills-natgw-a"
  nat_b_name = "skills-natgw-b"
  nat_c_name = "skills-natgw-c"

  public_rt_name = "skills-public-rt"
  private_a_rt_name = "skills-private-a-rt"
  private_b_rt_name = "skills-private-b-rt"
  private_c_rt_name = "skills-private-c-rt"
}