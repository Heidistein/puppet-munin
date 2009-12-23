# plugin.pp - configure a specific munin plugin
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# adapted and improved by admin(at)immerda.ch

### defines

define munin::plugin (
    $ensure = "present",
    $script_path_in = '',
    $config = '')
{
<<<<<<< HEAD
	debug ( "munin_plugin: name=$name, ensure=$ensure, script_path=$script_path" )
	$plugin = "/etc/munin/plugins/$name"
	$plugin_conf = "/etc/munin/plugin-conf.d/$name.conf"
	case $ensure {
		"absent": {
			debug ( "munin_plugin: suppressing $plugin" )
			file { $plugin: ensure => absent, } 
		}
		default: {
			$plugin_src = $ensure ? { "present" => $name, default => $ensure }
			debug ( "munin_plugin: making $plugin using src: $plugin_src" )
			file { $plugin:
				ensure => "$script_path/${plugin_src}",
				require => Package["munin-node"],
				notify => Service["munin-node"],
			}
		}
	}
	case $config {
		'': {
			debug("no config for $name")
			file { $plugin_conf: ensure => absent }
		}
		default: {
			case $ensure {
				absent: {
					debug("removing config for $name")
					file { $plugin_conf: ensure => absent }
				}
				default: {
					debug("creating $plugin_conf")
					file { $plugin_conf:
						content => "[${name}]\n$config\n",
						mode => 0644, owner => root, group => root,
					}
				}
			}
		}
	}
}

define munin::remoteplugin($ensure = "present", $source, $config = '') {
	case $ensure {
		"absent": { munin::plugin{ $name: ensure => absent } }
		default: {
			file {
				"${module_dir_path}/munin/plugins/${name}":
					source => $source,
					mode => 0755, owner => root, group => root;
			}
			munin::plugin { $name:
				ensure => $ensure,
				config => $config,
				script_path => "${module_dir_path}/munin/plugins",
			}
		}
	}
}

class munin::plugins::base {

	file {
		[ "/etc/munin/plugins", "/etc/munin/plugin-conf.d" ]:
			source => "puppet://$server/modules/common/empty",
			ensure => directory, checksum => mtime,
			ignore => '.ignore',
			recurse => true, purge => true, force => true, 
			mode => 0755, owner => root, group => root,
			notify => Service[munin-node];
		"/etc/munin/plugin-conf.d/munin-node":
			ensure => present, 
			mode => 0644, owner => root, group => root,
			notify => Service[munin-node],
			before => Package[munin-node];
	}

}

# handle if_ and if_err_ plugins
class munin::plugins::interfaces inherits munin::plugins::base {

	$ifs = gsub(split($munin_interfaces, " "), "(.+)", "if_\\1")
	$if_errs = gsub(split($munin_interfaces, " "), "(.+)", "if_err_\\1")
	plugin {
		$ifs: ensure => "if_";
		$if_errs: ensure => "if_err_";
	}


}

class munin::plugins::linux inherits munin::plugins::base {

	plugin {
		[ df_abs, forks, iostat, memory, processes, cpu, df_inode, irqstats,
		  netstat, open_files, swap, df, entropy, interrupts, load, open_inodes,
		  vmstat
		]:
			ensure => present;
		acpi: 
			ensure => $acpi_available;
	}

	include munin::plugins::interfaces
}

class munin::plugins::debian inherits munin::plugins::base {

	plugin { apt_all: ensure => present; }

}

class munin::plugins::vserver inherits munin::plugins::base {

	plugin {
		[ netstat, processes ]:
			ensure => present;
	}

=======
    include munin::plugin::scriptpaths
    $real_script_path = $script_path_in ? { '' => $munin::plugin::scriptpaths::script_path, default => $script_path_in }

    $plugin_src = $ensure ? { "present" => $name, default => $ensure }
    $plugin = "/etc/munin/plugins/$name"
    $plugin_conf = "/etc/munin/plugin-conf.d/$name.conf"
    case $ensure {
    	"absent": {
    		file { $plugin: ensure => absent, }
    	}
    	default: {
            case $kernel {
                openbsd: { $basic_require = File['/var/run/munin'] }
                default: { $basic_require = Package['munin-node'] }
            }
            if $require {
                $real_require = [ $require, $basic_require ]
            } else {
                $real_require = $basic_require
            }
    		file { $plugin:
    		    ensure => "${real_script_path}/${plugin_src}",
    			require => $real_require,
    			notify => Service['munin-node'];
    		}

    	}
    }
    case $config {
    	'': {
    		file { $plugin_conf: ensure => absent }
    	}
    	default: {
    		case $ensure {
    			absent: {
    				file { $plugin_conf: ensure => absent }
    			}
    			default: {
    				file { $plugin_conf:
    					content => "[${name}]\n$config\n",
    					mode => 0644, owner => root, group => 0,
    				}
                    if $require {
                        File[$plugin_conf]{
                            require +> $require,
                        }
                    }
    			}
    		}
    	}
    }
>>>>>>> 76352415fec5c2ab6975e3a8843dd4983f7cae6a
}
