require 'os'

module Hagent
	class Info
		def self.cpu
			cpu_info 							= ""
			cpu_frequency 				= "0"
			number_of_cores 			= "0"
			number_of_threads 		= "0"
			thermal_level 				= "0"

			if OS.mac?
				cpu_info 						= `sysctl -n machdep.cpu.brand_string | tr '\n' ' '`.strip
				cpu_frequency 			= `sysctl -n hw.cpufrequency | tr '\n' ' '`.strip
				number_of_cores 		= `sysctl -n hw.physicalcpu | tr '\n' ' '`.strip
				number_of_threads 	= `sysctl -n hw.logicalcpu | tr '\n' ' '`.strip
				thermal_level 			= `sysctl -n machdep.xcpm.cpu_thermal_level | tr '\n' ' '`.strip

			elsif OS.linux?
				cpu_info 						= `cat /proc/cpuinfo | grep 'model name' | uniq | cut -d: -f2 | awk '{$1=$1};1'`.strip
				cpu_frequency 			= `cat /proc/cpuinfo | grep 'MHz' | uniq  | cut -d: -f2 | awk '{$1=$1};1'`.strip
				number_of_cores 		= `cat /proc/cpuinfo | grep 'cpu cores' | cut -d ':' -f2 | cut -d' ' -f2 | uniq`.strip
				number_of_threads  	= `cat /proc/cpuinfo | grep 'processor' | wc -l`.strip

			elsif OS.windows?
				cpu_info 						= `wmic cpu get name`
				cpu_frequency 			= `wmic cpu get MaxClockSpeed`.scan(/\d/)
				number_of_cores 		= `wmic cpu get NumberOfCores`.scan(/\d/)
				number_of_threads 	= `wmic cpu get NumberOfLogicalProcessors`.scan(/\d/)
				thermal_level 			= `wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature`.scan(/\d/)
			end

			return {
				cpu_info: 					cpu_info,
				cpu_frequency: 			cpu_frequency,
				number_of_cores: 		number_of_cores,
				number_of_threads: 	number_of_threads,
				thermal_level: 			thermal_level
			}	
		end


		def self.memory
			if OS.mac?
				free_memory   			= `vm_stat | grep 'Pages free:' | cut -d: -f2 | awk '{$1=$1};1'`.strip.scan(/\d/).join.to_i * 4096
				active_memory 			= `vm_stat | grep 'Pages active:' | cut -d: -f2 | awk '{$1=$1};1'`.strip.scan(/\d/).join.to_i * 4096
				inactive_memory 		= `vm_stat | grep 'Pages inactive:' | cut -d: -f2 | awk '{$1=$1};1'`.strip.scan(/\d/).join.to_i * 4096
				speculative_memory 	= `vm_stat | grep 'Pages speculative:' | cut -d: -f2 | awk '{$1=$1};1'`.strip.scan(/\d/).join.to_i * 4096
				wired_down_memory 	= `vm_stat | grep 'Pages wired down:' | cut -d: -f2 | awk '{$1=$1};1'`.strip.scan(/\d/).join.to_i * 4096
				total_memory				= free_memory.to_i + active_memory.to_i + inactive_memory.to_i + speculative_memory.to_i + wired_down_memory.to_i

				return {
					total_memory: 			total_memory,
					free_memory: 				free_memory,
					active_memory: 			active_memory,
					inactive_memory:  	inactive_memory,
					speculative_memory: speculative_memory,
					wired_down_memory: 	wired_down_memory
				}

			elsif OS.linux?
				free_memory 				= `vmstat -s | grep 'free memory' | cut -dK -f1`.strip.scan(/\d/).join.to_i
				active_memory 			= `vmstat -s | grep 'active memory' | cut -dK -f1`.strip.scan(/\d/).join.to_i
				inactive_memory 		= `vmstat -s | grep 'inactive memory' | cut -dK -f1`.strip.scan(/\d/).join.to_i
				used_memory 				= `vmstat -s | grep 'used memory' | cut -dK -f1`.strip.scan(/\d/).join.to_i
				buffer_memory 			= `vmstat -s | grep 'buffer memory' | cut -dK -f1`.strip.scan(/\d/).join.to_i
				total_memory				= free_memory.to_i + active_memory.to_i + inactive_memory.to_i + speculative_memory.to_i + wired_down_memory.to_i

				return {
					total_memory: 			total_memory,
					free_memory: 				free_memory,
					active_memory: 			active_memory,
					inactive_memory:  	inactive_memory,
					used_memory: 				used_memory,
					buffer_memory: 			buffer_memory
				}
			elsif OS.windows?

			end	
		end



		def self.drive
			if OS.mac?
				total_size 			= `df -h | tail -n +2 | head -1 | awk '{print $2}'`.scan(/\d/).join.to_i * 1024 * 1024 * 1024
				used_size 			= `df -h | tail -n +2 | head -1 | awk '{print $3}'`.scan(/\d/).join.to_i * 1024 * 1024 * 1024
				available_size 	= `df -h | tail -n +2 | head -1 | awk '{print $4}'`.scan(/\d/).join.to_i * 1024 * 1024 * 1024

				return {
					total_size: 		total_size,
					used_size: 			used_size,
					available_size: available_size,
				}
			elsif OS.linux?
				total_size 			= `df -h | tail -n +2 | head -1 | awk '{print $2}'`.scan(/\d/).join.to_i * 1024 * 1024 * 1024
				used_size 			= `df -h | tail -n +2 | head -1 | awk '{print $3}'`.scan(/\d/).join.to_i * 1024 * 1024 * 1024
				available_size 	= `df -h | tail -n +2 | head -1 | awk '{print $4}'`.scan(/\d/).join.to_i * 1024 * 1024 * 1024

				return {
					total_size: 		total_size,
					used_size: 			used_size,
					available_size: available_size,
				}

			elsif OS.windows?
				total_size 			= `wmic logicaldisk get size,freespace,caption | find "C:"`.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(" ")[1]
				used_size 			= `wmic logicaldisk get size,freespace,caption | find "C:"`.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(" ")[2]
				available_size 	= total_size.to_i - used_size.to_i

				return {
					total_size: 		total_size,
					used_size: 			used_size,
					available_size: available_size,
				}

			end	
		end
	end
end