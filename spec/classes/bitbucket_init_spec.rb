require 'spec_helper'

describe 'bitbucket' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context os do
        let(:facts) do
          facts
        end

        it { is_expected.to compile.with_all_deps }

        # Test containment of classes
        it { is_expected.to contain_class('bitbucket::install') }
        it { is_expected.to contain_class('bitbucket::config') }
        it { is_expected.to contain_class('bitbucket::service') }
        it { is_expected.to contain_class('bitbucket::backup') }

        # Test class relationships
        it { is_expected.to contain_class('bitbucket::install').that_comes_before('Class[bitbucket::config]') }
        it { is_expected.to contain_class('bitbucket::config').that_notifies('Class[bitbucket::service]') }
        it { is_expected.to contain_class('bitbucket::service').that_comes_before('Class[bitbucket::backup]') }
      end
    end
  end
  context 'unsupported operating system' do
    describe 'test class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          'os' => {
            'family'  => 'Solaris',
            'name'    => 'Nexenta',
            'release' => {
              'major' => '7'
            }
          }
        }
      end

      it { expect { is_expected.to contain_service('bitbucket') }.to raise_error(Puppet::Error, %r{Nexenta 7 not supported}) }
    end
  end
end
