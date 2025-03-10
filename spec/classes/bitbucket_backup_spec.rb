require 'spec_helper.rb'

describe 'bitbucket' do
  describe 'bitbucket::backup' do
    context 'supported operating systems' do
      on_supported_os.each do |os, facts|
        context os do
          let(:facts) do
            facts
          end

          context 'install bitbucket backup client with default params' do
            it 'deploys bitbucket backup client 3.2.0 from zip' do
              is_expected.to contain_archive("/tmp/bitbucket-backup-distribution-#{BACKUP_VERSION}.zip").with(
                'source'       => "https://maven.atlassian.com/content/groups/public/com/atlassian/bitbucket/server/backup/bitbucket-backup-distribution/#{BACKUP_VERSION}/bitbucket-backup-distribution-#{BACKUP_VERSION}.zip",
                'extract_path' => '/opt/bitbucket-backup',
                'creates'      => "/opt/bitbucket-backup/bitbucket-backup-client-#{BACKUP_VERSION}/lib",
                'user'         => 'atlbitbucket',
                'group'        => 'atlbitbucket',
              )
            end

            it 'manages the bitbucket-backup directories' do
              is_expected.to contain_file('/opt/bitbucket-backup')
                .with('ensure' => 'directory',
                      'owner'  => 'atlbitbucket',
                      'group'  => 'atlbitbucket')
              is_expected.to contain_file("/opt/bitbucket-backup/bitbucket-backup-client-#{BACKUP_VERSION}")
                .with('ensure' => 'directory',
                      'owner'  => 'atlbitbucket',
                      'group'  => 'atlbitbucket').that_requires("Archive[/tmp/bitbucket-backup-distribution-#{BACKUP_VERSION}.zip]")

              is_expected.to contain_file('/opt/bitbucket-backup/archives')
                .with('ensure' => 'directory',
                      'owner'  => 'atlbitbucket',
                      'group'  => 'atlbitbucket')
            end
            it 'manages the backup cron job' do
              backup_cmd = [
                '/usr/bin/java',
                "-Dbitbucket.password='password'",
                "-Dbitbucket.user='admin'",
                "-Dbitbucket.baseUrl='https://foo.example.com'",
                '-Dbitbucket.home=/home/bitbucket',
                '-Dbackup.home=/opt/bitbucket-backup/archives',
                "-jar /opt/bitbucket-backup/bitbucket-backup-client-#{BACKUP_VERSION}/bitbucket-backup-client.jar",
              ].join(' ')

              is_expected.to contain_cron('Backup Bitbucket').with(
                'ensure'  => 'present',
                'command' => backup_cmd,
                'user'    => 'atlbitbucket',
                'hour'    => '5',
                'minute'  => '0',
              )
            end
            it 'removes old archives' do
              is_expected.to contain_tidy('remove_old_archives')
                .with('path'    => '/opt/bitbucket-backup/archives',
                      'age'     => '4w',
                      'matches' => '*.tar',
                      'type'    => 'mtime',
                      'recurse' => 2)
            end
          end

          context 'should contain custom java path' do
            let(:params) do
              { javahome: '/java/path' }
            end

            it do
              backup_cmd = [
                '/java/path/bin/java',
                "-Dbitbucket.password='password'",
                "-Dbitbucket.user='admin'",
                "-Dbitbucket.baseUrl='https://foo.example.com'",
                '-Dbitbucket.home=/home/bitbucket',
                '-Dbackup.home=/opt/bitbucket-backup/archives',
                "-jar /opt/bitbucket-backup/bitbucket-backup-client-#{BACKUP_VERSION}/bitbucket-backup-client.jar",
              ].join(' ')

              is_expected.to contain_class('bitbucket').with_javahome('/java/path')
              is_expected.to contain_cron('Backup Bitbucket').with('command' => backup_cmd)
            end
          end

          context 'should contain custom backup client version' do
            let(:params) do
              { backupclient_version: '99.43.111' }
            end

            it do
              backup_cmd = [
                '/usr/bin/java',
                "-Dbitbucket.password='password'",
                "-Dbitbucket.user='admin'",
                "-Dbitbucket.baseUrl='https://foo.example.com'",
                '-Dbitbucket.home=/home/bitbucket',
                '-Dbackup.home=/opt/bitbucket-backup/archives',
                '-jar /opt/bitbucket-backup/bitbucket-backup-client-99.43.111/bitbucket-backup-client.jar',
              ].join(' ')

              is_expected.to contain_archive('/tmp/bitbucket-backup-distribution-99.43.111.zip')
                .with('source' => 'https://maven.atlassian.com/content/groups/public/com/atlassian/bitbucket/server/backup/bitbucket-backup-distribution/99.43.111/bitbucket-backup-distribution-99.43.111.zip',
                      'extract_path' => '/opt/bitbucket-backup',
                      'creates' => '/opt/bitbucket-backup/bitbucket-backup-client-99.43.111/lib',
                      'user' => 'atlbitbucket',
                      'group' => 'atlbitbucket')
              is_expected.to contain_file('/opt/bitbucket-backup/bitbucket-backup-client-99.43.111')
                .with('ensure' => 'directory',
                      'owner'  => 'atlbitbucket',
                      'group'  => 'atlbitbucket')
              is_expected.to contain_cron('Backup Bitbucket').with('command' => backup_cmd)
            end
          end

          context 'should contain custom backup home' do
            let(:params) do
              { backup_home: '/my/backup' }
            end

            it do
              is_expected.to contain_class('bitbucket').with_backup_home(%r{my/backup})
              is_expected.to contain_file('/my/backup/archives')
                .with('ensure' => 'directory',
                      'owner'  => 'atlbitbucket',
                      'group'  => 'atlbitbucket')
              is_expected.to contain_cron('Backup Bitbucket').with('command' => [
                '/usr/bin/java',
                "-Dbitbucket.password='password'",
                "-Dbitbucket.user='admin'",
                "-Dbitbucket.baseUrl='https://foo.example.com'",
                '-Dbitbucket.home=/home/bitbucket',
                '-Dbackup.home=/my/backup/archives',
                "-jar /my/backup/bitbucket-backup-client-#{BACKUP_VERSION}/bitbucket-backup-client.jar",
              ].join(' '))
            end
          end

          context 'should contain custom backup user and password' do
            let(:params) do
              { backupuser: 'myuser', backuppass: 'mypass', }
            end

            it do
              backup_cmd = [
                '/usr/bin/java',
                "-Dbitbucket.password='mypass'",
                "-Dbitbucket.user='myuser'",
                "-Dbitbucket.baseUrl='https://foo.example.com'",
                '-Dbitbucket.home=/home/bitbucket',
                '-Dbackup.home=/opt/bitbucket-backup/archives',
                "-jar /opt/bitbucket-backup/bitbucket-backup-client-#{BACKUP_VERSION}/bitbucket-backup-client.jar",
              ].join(' ')

              is_expected.to contain_class('bitbucket')
                .with_backupuser('myuser')
                .with_backuppass('mypass')
              is_expected.to contain_cron('Backup Bitbucket')
                .with('command' => backup_cmd)
            end
          end

          context 'should remove old archives' do
            let(:params) do
              { backup_keep_age: '1y', backup_home: '/my/backup', }
            end

            it do
              is_expected.to contain_tidy('remove_old_archives')
                .with('path' => '/my/backup/archives',
                      'age' => '1y')
            end
          end
        end
      end
    end
  end
end
