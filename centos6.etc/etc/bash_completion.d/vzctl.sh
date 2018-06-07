# OpenVZ vzctl bash completion by Kir Kolyshkin <kir@openvz.org>
# Put this file to /etc/bash_completion.d/
# modified Thorsten Schifferdecker <tsd@debian.systs.org>

_get_ves()
{
	local cmd=$1
	local rm_empty='sed s/^-[[:space:]]*//'
	# Only allow this completion when user has root privileges
	[ "$EUID" -ne 0 ] && return 1
	case $cmd in
		create)
			# create a new CTID, by increasing the last one
			local veids=`/usr/sbin/vzlist -H -a -octid \
				2>/dev/null | tail -1`
			[ -n "$veids" ] || veids=100
			echo $((veids+1))
			;;
		start|mount|umount|destroy|delete)
			# stopped CTs
			/usr/sbin/vzlist -H -S -octid 2>/dev/null
			/usr/sbin/vzlist -H -S -oname 2>/dev/null | $rm_empty
			;;
		stop|restart|enter|exec*|suspend|chkpnt)
			# running CTs
			/usr/sbin/vzlist -H -octid 2>/dev/null
			/usr/sbin/vzlist -H -oname 2>/dev/null | $rm_empty
			;;
		resume|restore)
			# suspended CTs
			(/usr/sbin/vzlist -HS -o status,ctid;
			 /usr/sbin/vzlist -HS -o status,name) 2>/dev/null | \
				grep '^suspended ' | \
				sed 's/^suspended *//' | $rm_empty
			;;
		convert)
			# stopped CTs on simfs
			(/usr/sbin/vzlist -HS -o layout,ctid;
			 /usr/sbin/vzlist -HS -o layout,name) 2>/dev/null | \
				grep '^simfs ' | \
				sed 's/^simfs *//' | $rm_empty
			;;
		compact|snapshot*)
			# CTs on ploop
			(/usr/sbin/vzlist -H -a -o layout,ctid;
			 /usr/sbin/vzlist -H -a -o layout,name) 2>/dev/null | \
				grep '^ploop ' | \
				sed 's/^ploop *//' | $rm_empty
			;;
		*)
			# All CTs
			/usr/sbin/vzlist -H -a -octid 2>/dev/null
			/usr/sbin/vzlist -H -a -oname 2>/dev/null | $rm_empty
			;;
	esac
}

_vzctl()
{
	#echo "ARGS: $*"
	#echo "COMP_WORDS: $COMP_WORDS"
	#echo "COMP_CWORD: $COMP_CWORD"
	#echo "COMP_WORDS[1]: ${COMP_WORDS[1]}"

	COMPREPLY=()
	local cur=${COMP_WORDS[COMP_CWORD]}
	local prev=${COMP_WORDS[COMP_CWORD-1]}


	local vzctl_common_opts="--quiet --verbose --help --version"
	local vzctl_cmds="create destroy delete mount umount chkpnt restore \
		suspend resume \
		set start stop restart status quotaon quotaoff quotainit \
		enter exec exec2 runscript console"
	local vzctl_create_opts="--ostemplate --config --private --root \
		--layout --diskspace --diskinodes --ipadd --hostname \
		--name --description"
	local vzctl_convert_opts="--layout"
	local vzctl_set_opts="--save --onboot --root --private \
		--userpasswd --disabled --ipadd --ipdel \
		--hostname --nameserver --searchdomain \
		--numproc --numtcpsock --numothersock --vmguarpages \
		--kmemsize --tcpsndbuf --tcprcvbuf --othersockbuf \
		--dgramrcvbuf --oomguarpages --lockedpages --privvmpages \
		--shmpages --numfile --numflock --numpty --numsiginfo \
		--dcachesize --numiptent --physpages --swappages \
		--vm_overcommit --cpuunits --cpulimit --cpus --cpumask --nodemask \
		--netfilter --netdev_add --netdev_del --netif_add --netif_del \
		--diskquota --mount_opts \
		--diskspace --diskinodes --quotatime --quotaugidlimit \
		--capability --devnodes --devices --applyconfig \
		--name --ioprio --iolimit --iopslimit \
		--setmode --meminfo --bootorder --features \
		--reset_ub --stop-timeout --offline-resize"
	local vzctl_start_opts="--wait --force --skip-fsck --skip-remount"
	local vzctl_stop_opts="--fast --skip-umount"
	local vzctl_restart_opts="$vzctl_start_opts $vzctl_stop_opts"
	local vzctl_snapshot_create_opts="--id --name --description \
		--skip-suspend --skip-config"
	local vzctl_snapshot_switch_opts="--id --skip-resume --must-resume \
		--skip-config"
	local vzctl_snapshot_mount_opts="--id --target"
	local vzctl_snapshot_list_opts="-H --no-header -o --output --id \
		-L --list --help"

	local netfilter_names="disabled stateless stateful full"

	local cap_names="chown dac_override dac_read_search fowner fsetid kill
		setgid setuid setpcap linux_immutable net_bind_service
		net_broadcast net_admin net_raw ipc_lock ipc_owner
		sys_module sys_rawio sys_chroot sys_ptrace sys_pacct
		sys_admin sys_boot sys_nice sys_resource sys_time
		sys_tty_config mknod lease setveid ve_admin"

	local feature_names="sysfs nfs sit ipip ppp ipgre bridge nfsd"

	if test -f /proc/vz/ploop_minor; then
		vzctl_cmds+=" convert compact snapshot \
			snapshot-mount snapshot-umount \
			snapshot-switch snapshot-delete snapshot-list"
	fi

	case $COMP_CWORD in
	1)
		# command or global option
		COMPREPLY=( $( compgen -W "$vzctl_cmds $vzctl_common_opts" -- $cur ) )
		;;

	2)
		case "$prev" in
		--help|--version)
			COMPREPLY=()
			;;
		--*)
			# command
			COMPREPLY=( $( compgen -W "$vzctl_cmds" -- $cur ) )
			;;
		*)
			# CTID
			COMPREPLY=( $( compgen -W "$(_get_ves $prev)" -- $cur ) )
			;;
		esac
		;;

	*) # COMP_CWORD >= 3
		if [ $COMP_CWORD -eq 3 -a ${COMP_WORDS[1]::2} = "--" ]; then
			# Global option was used, need CTID here
			COMPREPLY=( $( compgen -W "$(_get_ves $prev)" -- $cur ) )
		else

			# flag or option
			case $prev in
			--ostemplate)
				COMPREPLY=( $( compgen -W "$(/usr/sbin/vztmpl-dl --list-all)" -- $cur ) )
				;;
			--onboot|--disabled|--diskquota)
				COMPREPLY=( $( compgen -W "yes no" -- $cur ) )
				;;
			--setmode)
				COMPREPLY=( $( compgen -W "restart ignore" -- $cur ) )
				;;
			--config|--applyconfig)
				local configs=$(command ls -1 /etc/vz/conf/*.conf-sample |
						    cut -d "-" -f 2- | sed -e 's#.conf-sample$##')

				COMPREPLY=( $( compgen -W "$configs" -- $cur ) )
				;;
			--layout)
				COMPREPLY=( $( compgen -W "ploop ploop:expanded ploop:plain ploop:raw simfs" -- $cur ) )
				;;
			--netfilter)
				COMPREPLY=( $( compgen -W "$netfilter_names" -- $cur ) )
				;;
			--netdev*)
				local devs=`ip addr show | awk '/^[0-9]/ && /UP/ && !/venet/ && !/lo/ \
						    { print $2 }' | sed s/://`

				COMPREPLY=( $( compgen -W "$devs" -- $cur ) )
				;;
			--meminfo)
				local meminfo="none privvmpages:1"
				COMPREPLY=( $( compgen -W "$meminfo" -- $cur ) )
				;;
			--ioprio)
				# ioprio range: 0 - 7 (default : 4)
				local ioprio='0 1 2 3 4 5 6 7'
				COMPREPLY=( $( compgen -W "$ioprio" -- $cur ) )
				;;
			--capability)
				# capname:on|off
				COMPREPLY=( $( compgen -W "$cap_names" -- $cur ) )
				# FIXME: add :on or :off -- doesn't work :(
#				if [[ ${#COMPREPLY[@]} -le 1 ]]; then
#					if [[ $cur =~ ":" ]]; then
#						cap=${cur%%:*}
#					else
#						cap=${COMPREPLY[0]%%:*}
#					fi
					# Single match: add :on|:off
#					COMPREPLY=( $(compgen -W \
#					"${cap}:on ${cap}:off" -- $cur) )
#				fi
				;;
			--features)
				# featurename:on|off
				COMPREPLY=( $( compgen -W "$feature_names" -- $cur ) )
				# FIXME: add :on or :off -- can't make it work
				;;
			--devnodes)
				# FIXME: device:r|w|rw|none
				local devs=''
				COMPREPLY=( $( compgen -W "$devs" -- $cur ) )
				;;
			--devices)
				# FIXME: b|c:major:minor|all:r|w|rw
				local devices=''
				COMPREPLY=( $( compgen -W "$devices" -- $cur ) )
				;;
			--ipdel)
				# Only allow this completion
				# when user has root privileges
				[ "$EUID" -ne 0 ] && return 1
				# Get CTID
				local cmd=${COMP_WORDS[1]}
				local ve=${COMP_WORDS[2]}
				if [ ${cmd::2} = "--" ] ; then
					# --verbose or --quiet used
					ve=${COMP_WORDS[3]}
				fi
				local ips="`/usr/sbin/vzlist -H -o ip $ve 2>/dev/null | grep -vi -`"
				COMPREPLY=( $( compgen -W "$ips all" -- $cur ) )
				;;
			--netif_del)
				local netif
				if [ -f /proc/vz/veth ]; then
					# Get CTID
					local cmd=${COMP_WORDS[1]}
					local ve=${COMP_WORDS[2]}
					if [ ${cmd::2} = "--" ] ; then
						# --verbose or --quiet used
						ve=${COMP_WORDS[3]}
					fi
					# get veth(ernet) device of CT, proc and config
					local netif_proc="`awk "/${ve}/ { print \\$4 }" /proc/vz/veth`"
					local netif_conf="`grep ^NETIF /etc/vz/conf/${ve}.conf |
						sed -e 's/"/\n/g' -e 's/;/\n/g' -e 's/,/\n/g' -e 's/=/ /g' | awk '/^ifname/ {print \$2}'`"
					netif="$netif_proc $netif_conf"
				fi
				COMPREPLY=( $( compgen -W "$netif" -- $cur ) )
				;;
			--private|--root)
				# FIXME
				# Dir autocompletion works bad since there is
				# a space added. Alternatively, we could use
				# -o dirname option to 'complete' -- but it
				# makes no sense for other parameters (UBCs
				# etc). So no action for now.
				;;
			--id|--uuid)
				# Only allow this completion
				# when user has root privileges
				[ "$EUID" -ne 0 ] && return 1
				# Get command and CTID
				local cmd=${COMP_WORDS[1]}
				local ve=${COMP_WORDS[2]}
				if [ ${cmd::2} = "--" ] ; then
					# --verbose or --quiet used
					cmd=${COMP_WORDS[2]}
					ve=${COMP_WORDS[3]}
				fi
				local ids
				case ${cmd} in
				    snapshot-umount)
					# For umount, only give mounted IDs
					ids="`/usr/sbin/vzctl --quiet snapshot-list $ve -H -ouuid,device 2>/dev/null | awk 'NF==2 {print $1}' | tr -d '{}'`"
					;;
				    snapshot-*)
					# For other commands, give all IDs
					ids="`/usr/sbin/vzctl --quiet snapshot-list $ve -H -ouuid 2>/dev/null | tr -d '{}'`"
					;;
				    *)
					# Do not give anything for other cmds
					# including 'snapshot' itself
					# since it requires a new unused ID
					return 0
					;;
				esac
				COMPREPLY=( $( compgen -W "$ids" -- $cur ) )
				;;
			*)
				if [[ "${prev::2}" != "--" || "$prev" = "--save" ]]; then
					# List options
					local cmd=${COMP_WORDS[1]}
					if [ ${cmd::2} = "--" ] ; then
						# --verbose or --quiet used
						cmd=${COMP_WORDS[2]}
					fi

					case "$cmd" in
					create)
						COMPREPLY=( $( compgen -W "$vzctl_create_opts" -- $cur ) )
						;;
					set)
						COMPREPLY=( $( compgen -W "$vzctl_set_opts" -- $cur ) )
						;;
					convert)
						COMPREPLY=( $( compgen -W "$vzctl_convert_opts" -- $cur ) )
						;;
					suspend|resume|chkpnt|restore)
						COMPREPLY=( $( compgen -W "--dumpfile" -- $cur ) )
						;;
					start)
						COMPREPLY=( $( compgen -W "$vzctl_start_opts" -- $cur ) )
						;;
					stop)
						COMPREPLY=( $( compgen -W "$vzctl_stop_opts" -- $cur ) )
						;;
					restart)
						COMPREPLY=( $( compgen -W "$vzctl_restart_opts" -- $cur ) )
						;;
					snapshot)
						COMPREPLY=( $( compgen -W "$vzctl_snapshot_create_opts" -- $cur ) )
						;;
					snapshot-switch)
						COMPREPLY=( $( compgen -W "$vzctl_snapshot_switch_opts" -- $cur ) )
						;;
					snapshot-delete|snapshot-umount)
						COMPREPLY=( $( compgen -W "--id" -- $cur ) )
						;;
					snapshot-mount)
						COMPREPLY=( $( compgen -W "$vzctl_snapshot_mount_opts" -- $cur ) )
						;;
					snapshot-list)
						COMPREPLY=( $( compgen -W "$vzctl_snapshot_list_opts" -- $cur ) )
						;;
					*)
						;;
					esac
				else
					# Option that requires an argument
					# which we can't autocomplete
					COMPREPLY=( $( compgen -W "" -- $cur ) )
				fi
				;;
			esac
		fi
	esac

	return 0
}

complete -F _vzctl vzctl

# EOF
