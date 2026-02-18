## ezAdmin

### ZAD (Zabbix Agent Deployer)

A set of scripts developed with the goal of facilitating the deployment and updating of Zabbix agents in diverse and large-scale environments.

By default, includes the x86_64 and x86_32 packages of Zabbix Agent 2 v7.0.23 LTS OpenSSL for Windows Server 2016+. Dependencies last updated on 2026-02-17.

#### Usage

To run this script, you need to be using Windows 10, Server 2016, or later, with an x86_64 architecture. Older and x86_32 versions of Windows may still be targeted for deployment. The executor must have the appropriate privileges on the ZAD base directory and target servers. Additionally, all devices and credentials involved must be part of trusted forests or domains within a directory service.

1. Prefer to clone the repository to ensure that the binaries are healthy, as downloading in ZIP format sometimes does not include the LFS objects.

2. Optionally, run **Update-ZadDeps.ps1** or **Update-ZadDeps.bat** to update the dependencies.

3. Get the desired [32-bit and 64-bit packages of Zabbix Agent or Zabbix Agent 2](https://www.zabbix.com/download_agents), save them in the **pkg** folder, replacing the old files and reusing their names.

4. Unlock each of the binary files by right-clicking, going to **Properties**, checking **Unlock** in the **General** tab, and pressing **Apply**.

5. By default, ZAD uses LTS releases of Zabbix Agent 2, so edit lines **4 to 9** and/or **42 to 46** of the **cfg\callback.bat** to reflect your monitoring environment, especially if you use Zabbix Agent instead of Zabbix Agent 2.

6. Edit the **cfg\servers.txt** file to reference the servers that will receive the agent, one per line, without blank lines, tabulations or spaces.

7. Choose the script and run it! **Start-PsRemoZad.ps1** (asynchronous via PSRemoting) is expected to be faster than **Start-PsExecZad.bat** (synchronous via PsExec), so prefer to run the first one and, in case of failure, try the second one; Remember to remove successful servers from **cfg\servers.txt** before the next attempt.

8. Track progress through your monitoring or inventory system; In case of failure, send us the logs **zad-install.log**, **zad-uninstall.log** and **zad-control.log**, present in **C:\Windows\Temp** of each failed server.

#### Highlights

Credits to Igor Pavlov for developing the 7-Zip<sup>[1](./bin/7za-license.txt)</sup>, to Tarma Software for the Uninstall<sup>[2](./bin/uninstall-license.txt)</sup> tool, to Sysinternals for the PsTools<sup>[3](./bin/psexec-license.txt)</sup> toolkit, to cURL Project for the cURL<sup>[4](./bin/curl-license.txt)</sup> utility, as well as to Zabbix LLC for Zabbix<sup>[5](./pkg/zabbixagent-license.txt)</sup> itself.
