# frozen_string_literal: true

#
# Cookbook Name:: aws-parallelcluster
# Recipe:: intel_install
#
# Copyright 2013-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

case node['cfncluster']['cfn_node_type']
when 'MasterServer'


  # Install the intel-hpc-platform rpms
  yum_repository 'intel-hpc-platform' do
    description   'Intel(R) HPC Platform meta-Packages for EL7'
    baseurl       'https://yum.repos.intel.com/hpc-platform/el7'
    gpgkey        'https://yum.repos.intel.com/hpc-platform/el7/setup/PUBLIC_KEY.PUB'
    repo_gpgcheck true
    retries 3
    retry_delay 5
  end

  yum_package "intel-hpc-platform-*-#{node['cfncluster']['intelhpc']['version']}" do
    retries 3
    retry_delay 5
  end

  # parallel studio is intel's optimized libraries, this is the runtime (free) version
  yum_repository 'intel-psxe-runtime-2020' do
    description   'Intel(R) Parallel Studio XE 2020 Runtime'
    baseurl       'https://yum.repos.intel.com/2020'
    gpgkey        'https://yum.repos.intel.com/2020/setup/RPM-GPG-KEY-intel-psxe-runtime-2020'
    repo_gpgcheck true
    retries 3
    retry_delay 5
  end

  yum_package "intel-psxe-runtime-#{node['cfncluster']['psxe']['version']}" do
    retries 3
    retry_delay 5
  end


  # intel optimized versions of python
  yum_repository 'intelpython' do
    description   'Intel(R) Distribution for Python* for Linux OS'
    baseurl       'http://yum.repos.intel.com/intelpython'
    gpgkey        'http://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB'
    repo_gpgcheck true
    retries 3
    retry_delay 5
  end

  yum_package "intelpython2-#{node['cfncluster']['intelpython2']['version']} intelpython3-#{node['cfncluster']['intelpython3']['version']}" do
    retries 3
    retry_delay 5
  end

end

# This rpm installs a file /etc/intel-hpc-platform-release that contains the INTEL_HPC_PLATFORM_VERSION
bash "install intel hpc platform" do
  cwd node['cfncluster']['sources_dir']
  code <<-INTEL
    set -e
    yum install -y /opt/intel/rpms/*
  INTEL
  creates '/etc/intel-hpc-platform-release'
end

# create intelpython module directory
directory "#{node['cfncluster']['modulefile_dir']}/intelpython"

cookbook_file 'intelpython2_modulefile' do
  path "#{node['cfncluster']['modulefile_dir']}/intelpython/2"
  user 'root'
  group 'root'
  mode '0755'
end

cookbook_file 'intelpython3_modulefile' do
  path "#{node['cfncluster']['modulefile_dir']}/intelpython/3"
  user 'root'
  group 'root'
  mode '0755'
end

# intel optimized math kernel library
create_modulefile "#{node['cfncluster']['modulefile_dir']}/intelmkl" do
  source_path "/opt/intel/psxe_runtime/linux/mkl/bin/mklvars.sh"
  modulefile "#{node['cfncluster']['psxe']['version']}"
end

# intel psxe
create_modulefile "#{node['cfncluster']['modulefile_dir']}/intelpsxe" do
  source_path "/opt/intel/psxe_runtime/linux/bin/psxevars.sh"
  modulefile "#{node['cfncluster']['psxe']['version']}"
end
