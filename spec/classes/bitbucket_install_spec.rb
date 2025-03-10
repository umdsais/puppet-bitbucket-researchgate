require 'spec_helper'

describe 'bitbucket' do
  describe 'bitbucket::install' do
    context 'supported operating systems' do
      on_supported_os.each do |os, facts|
        context os do
          let(:facts) do
            facts
          end
          let(:params) do
            { version: BITBUCKET_VERSION }
          end

          it 'deploys bitbucket from archive' do
            is_expected.to contain_archive("/tmp/atlassian-bitbucket-#{BITBUCKET_VERSION}.tar.gz")
              .with('extract_path' => '/opt/bitbucket',
                    'source' => "https://product-downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-#{BITBUCKET_VERSION}.tar.gz",
                    'creates' => "/opt/bitbucket/atlassian-bitbucket-#{BITBUCKET_VERSION}/conf",
                    'user' => 'atlbitbucket',
                    'group' => 'atlbitbucket',
                    'checksum_type' => 'md5')
          end

          it 'manages the bitbucket home directory' do
            is_expected.to contain_file('/home/bitbucket')
              .with('ensure' => 'directory',
                    'owner' => 'atlbitbucket',
                    'group' => 'atlbitbucket')
          end

          it 'manages the bitbucket application directory' do
            is_expected.to contain_file("/opt/bitbucket/atlassian-bitbucket-#{BITBUCKET_VERSION}")
              .with('ensure' => 'directory',
                    'owner' => 'atlbitbucket',
                    'group' => 'atlbitbucket').that_requires("Archive[/tmp/atlassian-bitbucket-#{BITBUCKET_VERSION}.tar.gz]")
          end

          context 'when managing the user and group inside the module' do
            let(:params) do
              { manage_usr_grp: true }
            end

            context 'when no user or group are specified' do
              it { is_expected.to contain_user('atlbitbucket').with_shell('/bin/bash') }
              it { is_expected.to contain_group('atlbitbucket') }
            end
            context 'when a user and group is specified' do
              let(:params) do
                { user: 'mybitbucketuser', group: 'mybitbucketgroup' }
              end

              it { is_expected.to contain_user('mybitbucketuser') }
              it { is_expected.to contain_group('mybitbucketgroup') }
            end
          end

          context 'when managing the user and group outside the module' do
            context 'when no user or group are specified' do
              let(:params) do
                { manage_usr_grp: false }
              end

              it { is_expected.not_to contain_user('atlbitbucket') }
              it { is_expected.not_to contain_group('atlbitbucket') }
            end
          end

          context 'overwriting params' do
            let(:params) do
              {
                version: BITBUCKET_VERSION,
                installdir: '/custom/bitbucket',
                homedir: '/random/homedir',
                user: 'foo',
                group: 'bar',
                uid: 333,
                gid: 444,
                download_url: 'http://downloads.atlassian.com',
                deploy_module: 'staging',
              }
            end

            it do
              is_expected.to contain_staging__file("atlassian-bitbucket-#{BITBUCKET_VERSION}.tar.gz")
                .with('source' => "http://downloads.atlassian.com/atlassian-bitbucket-#{BITBUCKET_VERSION}.tar.gz")
              is_expected.to contain_staging__extract("atlassian-bitbucket-#{BITBUCKET_VERSION}.tar.gz")
                .with('target'  => "/custom/bitbucket/atlassian-bitbucket-#{BITBUCKET_VERSION}",
                      'user'    => 'foo',
                      'group'   => 'bar',
                      'creates' => "/custom/bitbucket/atlassian-bitbucket-#{BITBUCKET_VERSION}/conf")
                .that_comes_before('File[/random/homedir]')
                .that_requires('File[/custom/bitbucket]')
                .that_notifies("Exec[chown_/custom/bitbucket/atlassian-bitbucket-#{BITBUCKET_VERSION}]")
            end

            it do
              is_expected.to contain_user('foo').with('home' => '/random/homedir',
                                              'shell' => '/bin/bash',
                                              'uid'   => 333,
                                              'gid'   => 444)
            end
            it { is_expected.to contain_group('bar') }
            it 'manages the bitbucket home directory' do
              is_expected.to contain_file('/random/homedir').with('ensure' => 'directory',
                                                          'owner' => 'foo',
                                                          'group' => 'bar')
            end
          end
        end
      end
    end
  end
end
