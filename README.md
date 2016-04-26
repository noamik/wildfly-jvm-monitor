# Provides basic jvm stats monitoring for wildfly with two slaves

The following components of wildfly are monitored through this script collection:

- host controller
- process controller
- slave100
- slave200

where slave100 and slave200 are the names of the two servers configured on the monitored host. While a more generic approach to server monitoring would be certainly a good idea, I won't be able to provide it due to time constraints. I will happily accept patches that do though.

# Usage

In order to work this collection of scripts require the use of a zabbix_agent.d configuration (`/etc/zabbix/zabbix_agentd.d/userparameter_jvm.conf`) as follows:

    # JVM user parameter
    UserParameter=jvm.processcontroller.running[*],/opt/jvm-monitor/monitor-jvm.sh "$1"
    UserParameter=jvm.processcontroller.limittrapstarter[*],/opt/jvm-monitor/monitor-jvm-limits.sh "$1"

# Disclaimer

These scripts are provided as is and come with no warranty and no further documentation. They can't be deployed and run out-of-the-box. You will need to be familiar with wildfly, bash and zabbix to make use of it. They weren't intended for public release when written. I've published them upon request by: https://issues.jboss.org/browse/WFCORE-974#