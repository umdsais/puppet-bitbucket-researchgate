require 'spec_helper.rb'

describe 'bitbucket' do
  describe 'bitbucket::service' do
    context 'supported operating systems' do
      on_supported_os.each do |os, facts|
        context os do
          let(:facts) do
            facts
          end

          context 'default params' do
            it { is_expected.to contain_service('bitbucket') }
          end

          context 'overwriting service_manage param' do
            let(:params) do
              { service_manage: false }
            end

            it { is_expected.not_to contain_service('bitbucket') }
          end

          context 'overwriting service params' do
            let(:params) do
              { service_ensure: 'stopped', service_enable: false, }
            end

            it do
              is_expected.to contain_service('bitbucket')
                .with('ensure' => 'stopped',
                      'enable' => 'false')
            end
          end
        end
      end
    end
  end
end
