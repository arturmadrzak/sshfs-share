# shellcheck shell=sh

Describe 'entrypoint.sh'
  Include 'spec/entrypoint_helper.sh'

  BeforeEach 'create_sshd_config'
  AfterEach 'remove_sshd_config'

  # configure entrypoint to not use full path for sshd only for test purpose.
  # sshd require to be run with full path that makes it non-mockable
  export SSHD="sshd"

  Mock ssh-keygen
    echo "ssh-keygen ${*}"
  End
  Mock sshd
    echo "sshd ${*}"
  End

  It 'should fail if sshd_config path does not exist'

    When run script entrypoint.sh --sshd-conf=/tmp/not-existing-file

    The output should be blank
    The error should include '/tmp/not-existing-file'
    The status should be failure
  End

  It 'should run with defaults without options and arguments'

    When run script entrypoint.sh

    The contents of file "${SSHD_CONF}" should include "Port 60022"
    The contents of file "${SSHD_CONF}" should include "PasswordAuthentication yes"
    The contents of file "${SSHD_CONF}" should include "PermitEmptyPasswords yes"
    The contents of file "${SSHD_CONF}" should include "PermitRootLogin yes"
    The output should include "ssh-keygen -A"
    The output should include "sshd -D"
    The status should be success
  End

  It 'should set listening port'

     When run script entrypoint.sh --port 22022

    The contents of file "${SSHD_CONF}" should include "Port 22022"
    The output should not be blank
    The status should be success
  End
End # Describe 'entrypoint.sh'
