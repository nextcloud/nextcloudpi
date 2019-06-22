#!/bin/bash

# Backward updates mechanism

set -e

source /usr/local/etc/library.sh

# Get the array of updates dir
# The files in updates dir are sorted by tag number
# Files names follow the syntax of a tag: x.y.z.sh
i=0
while read line ; do
  updates_list[ $i ]="$line"
  (( i++ ))
done < <( ls -1 updates | sort -V)

starting_checkpoint=0
len=${#updates_list[@]}
end_of_list=$(expr $len - 1)

# The latest checkpoint is the newer version in updates dir
latest_checkpoint=${updates_list[$end_of_list]}
latest_checkpoint_version=$( basename ${latest_checkpoint} .sh )
current_version=$( grep -oP "\d+\.\d+\.\d+" /usr/local/etc/ncp-version | cut -d'v' -f1 )

# Compare current version with latest checkpoint
# If the current version is more recent than the latest checkpoint there is no need for backward updates

BACKWARD_UPDATES=$( is_more_recent_than ${latest_checkpoint_version} ${current_version} )

if $BACKWARD_UPDATES ; then

  # Execute a series of updates of older versions

  # Binary search to find the right checkpoint to begin the updates
  # Checkpoints are considered the updates files
  # An update file will update the system to the version it has as a tag
  # <tag>.sh will update ncp to <tag> version

  # An update is *applicable* when it is more recent than the current version
  # An older update/checkpoint is not *applicable* to our system
    
  lower_bound=0
  upper_bound=$end_of_list
  while [ $lower_bound -le $upper_bound ]; do
    x=$(expr $upper_bound + $lower_bound)
    mid=$(expr $x / 2 )

    #Compare mid's version with current version

    mid_version=$( basename ${updates_list[$mid]} .sh )
    apply_update=$( is_more_recent_than ${mid_version} ${current_version} )

    if $apply_update ; then 
      # Mid's version update is applicable to the current version
      # Check if the previous checkpoint (mid-1) is applicable

      previous=$(expr $mid - 1)
      previous_version=$( basename ${updates_list[$previous]} .sh )
      if [ "$mid" -gt 0 ] ; then
        #Compare previous's version with current version
	applied=$( is_more_recent_than ${current_version} ${previous_version} )

	# If the previous checkpoint is not applicable then mid is the starting checkpoint
	# Otherwise keep on binary searching
	if $applied ; then
          starting_checkpoint=$mid
	  break
	fi
      else
        # mid is at 0, so this is the starting checkpoint
	starting_checkpoint=$mid
	break
      fi
      # Continue searching for starting checkpoint
      upper_bound=$(expr $mid - 1)

    else
      # Mid's version update is not applicable to the current version
      # Check if the next checkpoint (mid+1) is applicable

      next=$(expr $mid + 1)
      next_version=$( basename ${updates_list[$next]} .sh )

      #Compare next's version with current version
      applied=$( is_more_recent_than ${current_version} ${next_version} )

      # If next checkpoint is not applicable then next is the starting checkpoint
      # Otherwise keep on binary searching
      if $applied ; then
        # Continue searching for starting checkpoint
        lower_bound=$(expr $mid + 1)
      else
        # The next version is the starting checkpoint
	starting_checkpoint=$next
	break
      fi
    fi
  done

  # Starting checkpoint has been found so update the system for the rest updates

  for(( i=${starting_checkpoint}; i<=${end_of_list}; i++)); do
    update_file=${updates_list[i]}
    tag_update=$( basename ${update_file} .sh )
    echo "Update system to version ${tag_update}"
    ./updates/${update_file} || exit 1
  done
fi

