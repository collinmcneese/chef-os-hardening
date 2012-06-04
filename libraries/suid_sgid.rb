#
# Cookbook Name:: security
# Library:: suid_sgid
#
# Copyright 2012, Dominik Richter
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef::Recipe::SuidSgid
  def self.remove_suid_sgid_from( file )
    if not File::exists?(file)
      puts "-- suid_sgid: Couldn't find file '#{file}'"
      return
    end

    ok = system "chmod -s '#{file}'"
    puts "ee suid_sgid: Couldn't remove SUID/SGID from '#{file}'" if not ok
  end

  def self.find_all_suid_sgid_files( start_at = "/" )
    # "find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -print 2>/dev/null"
    # don't limit to one filesystem, go nuts recursively: (ie without -xdev)
    find = "find / \\( -perm -4000 -o -perm -2000 \\) -type f -print 2>/dev/null"
    `#{find}`.split("\n")
  end

  def self.remove_suid_sgid_from_blacklist( blacklist )
    blacklist.
    find_all{|file| File::exists?(file)}.
    each{|file| 
      puts "-- suid_sgid: Blacklist SUID/SGID for '#{file}', removing bit..."
      self.remove_suid_sgid_from(file)
    }
  end

  def self.remove_suid_sgid_from_unkown( whitelist = [], root = "/", dry_run = false )
    self.find_all_suid_sgid_files( root ).
    find_all{|file| 
      in_whitelist = whitelist.include?(file)
      puts "-- suid_sgid: Whitelisted file '#{file}', not altering SUID/SGID bit" if in_whitelist and not dry_run
      not in_whitelist
    }.
    each{|file|
      puts "-- suid_sgid: SUID/SGID on '#{file}'" + ((dry_run) ? " (dry_run)" : ", removing bit...")
      self.remove_suid_sgid_from(file) if not dry_run
    }
  end

end