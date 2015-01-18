#!/usr/bin/env ruby

# rsa.rb - the world's worst RSA implementation
#
# Copyright (c) 2015, Wesley Merkel <ooesili@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'prime'

KEY_SPACE = 100

#========== KEY DERIVATION ==========#

# pick a random number "e" between 1 and phi, such that d is a coprime of phi
def get_public(phi)
  (2...phi).find_all {|e| e.gcd(phi) == 1}.sample
end

# find the number "d" between 1 and phi, such that d*e is congruent to 1,
# modulus phi
def get_private(phi, e)
  (2...phi).find {|d| e*d % phi == 1}
end


#========== MAIN OPERATIONS ==========#

def gen_key
  # get 2 random primes
  p, q = Prime.each.take_while {|x| x <= KEY_SPACE}.sample(2)
  # special easy case of Euler's totient function
  phi = (p-1)*(q-1)
  # calculate modulus, public key, and private key
  n = p*q
  e = get_public(phi)
  d = get_private(phi, e)
  # print results
  puts "modulus:     #{n}"
  puts "public key:  #{e}"
  puts "private key: #{d}"
  puts "(internal information)"
  puts "phi:         #{phi}"
  puts "p,q:         #{p},#{q}"
end

def encrypt
  # get key info
  printf "modulus: "
  n = Integer(STDIN.gets)
  printf "public key: "
  e = Integer(STDIN.gets)
  # get message
  puts "type message:"
  msg = STDIN.gets.chomp
  # encrypt and print each character's ordinal
  puts msg.each_char.map {|char| char.ord**e % n}.join(' ')
end

def decrypt
  # get key info
  printf "modulus: "
  n = Integer(STDIN.gets)
  printf "private key: "
  d = Integer(STDIN.gets)
  # get message
  puts "type message:"
  msg = STDIN.gets.chomp
  # extract tokens, decrypt, and print
  puts msg.scan(/\d+/).map {|token| (Integer(token)**d % n).chr}.join
end

def crack
  # get key info
  printf "modulus: "
  n = Integer(STDIN.gets)
  printf "public key: "
  e = Integer(STDIN.gets)
  # factorize modulus
  p, q = 0, 0
  (2...Math.sqrt(n)).each {|x| Prime.prime? x}.each do |x|
    y, rem = n.divmod(x)
    if rem == 0
      p, q = x, y
      # because p and q are the only factors of n, other than 1 and itself, we
      # can be certain that we have found the only prime factors
      break
    end
  end
  # calculate phi and private key
  phi = (p-1)*(q-1)
  d = get_private(phi, e)
  puts "private key: #{d}"
  puts "(internal information)"
  puts "phi:         #{phi}"
  puts "p,q:         #{p},#{q}"
end


#========== ARGUMENT PARSING ==========#

help_message = <<EOF
usage:
  #{$0} -h       (display this help message)
  #{$0} -g       (generate keypair)
  #{$0} -e       (encrypt a message)
  #{$0} -d       (decrypt a message)
  #{$0} -c       (crack a public key)
EOF

# make sure that there is exactly one argument
if ARGV.length != 1
  if ARGV.size == 0
    warn "#{$0}: no command given"
  else
    warn "#{$0}: too many arguments"
  end
  warn help_message
  exit 1
else
  # figure out what to do
  case ARGV[0]
  when "-h"; puts help_message
  when "-g"; gen_key
  when "-e"; encrypt
  when "-d"; decrypt
  when "-c"; crack
  else
    warn "#{$0}: invalid command"
    warn help_message
    exit 1
  end
end
