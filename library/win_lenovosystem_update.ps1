#!powershell

# Copyright: (c) 2018, Simon Baerlocher <s.baerlocher@sbaerlocher.ch>
# Copyright: (c) 2018, ITIGO AG <opensource@itigo.ch>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.ArgvParser
#Requires -Module Ansible.ModuleUtils.CommandUtil
#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$search = Get-AnsibleParam -obj $params -name "search" -type "str" -default "C" -validateset "C", "R", "A"
$action = Get-AnsibleParam -obj $params -name "policy" -type "str" -default "INSTALL" -validateset "INSTALL", "DOWNLOAD", "LIST"

$result = @{
    changed = $false
}

$tvsu_app = Get-Command -Name "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe" -CommandType Application -ErrorAction SilentlyContinue
if (-not $tvsu_app) {
    Fail-Json -obj $result -message "Failed to find Lenovo System Update, please install it"
}

function Update-LenovoSystemUpdate {

    param(
        $tvsu_app,
        $search,
        $action
    )

    $argumentList = Argv-ToString -arguments @("/CM", "-search", $tvsu_app, "-action", $action)
    $res = Start-Process "$($tvsu_app.Path)" -wait -PassThru -ArgumentList $argumentList

}

Update-LenovoSystemUpdate -tvsu_app $tvsu_app -search $search -action $action

$result = @{
    changed = $true
    vars1 = $search
    vars2 = $action
}

# Return result
Exit-Json -obj $result
