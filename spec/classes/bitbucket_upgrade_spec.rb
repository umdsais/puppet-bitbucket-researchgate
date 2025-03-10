require 'spec_helper.rb'

describe 'bitbucket' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context os do
        let(:facts) do
          facts
        end

        context 'prepare for upgrade of bitbucket' do
          let(:params) do
            { javahome: '/opt/java' }
          end
          let(:facts) do
            facts.merge(bitbucket_version: '3.1.0')
          end

          it 'stops service and remove old config file' do
            is_expected.to contain_exec('service bitbucket stop && sleep 15')
            is_expected.to contain_exec('rm -f /home/bitbucket/stash-config.properties')
              .with(command: 'rm -f /home/bitbucket/stash-config.properties')
            is_expected.to contain_notify('Attempting to upgrade bitbucket')
          end
        end
      end
    end
  end
end
