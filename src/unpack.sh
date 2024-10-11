#!/usr/bin/env bash

# Copyright [2024] [Didier M. Roche]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


function unpack () {
  local fileNM=${1}
  
  local doneIt=0
  
  while [ ${doneIt} -eq 0 ]
  do
    mimeType=$(file -b --mime-type ${fileNM} | grep "x-tar\|gzip\|bzip2\|xz" | cut --delimiter=/ -f 2)

    case ${mimeType} in
      gzip|x-gzip)
        gunzip -q ${fileNM}
        fileNM=$( basename ${fileNM} .gz ) # so that if there is a tar file, then it will be processed
      ;;
      x-tar)
        dirbase=$(tar tf ${fileNM} | awk -F/ '{print $1}' | sort -u)
        tar xvpf ${fileNM} 2>&1 > /dev/null
        vrb "Uncompressed in dir ${dirbase}"
        doneIt=1 # need this one since tar keeps the archive after unpacking
      ;;
      *)
        doneIt=1
      ;;
    esac

    fileNM=$(find . -type f)
  done
		
}

# The End of All Things (op. cit.)
