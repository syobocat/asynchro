module util

import conf

pub fn is_my_domain(domain string) bool {
	return conf.data.host == domain
}

pub fn is_ccid(addr string) bool {
	return addr.len == 42 && addr.limit(3) == 'con' && !addr.contains('.')
}

fn is_cdid_rune(c rune) bool {
	if c >= `0` && c <= `9` {
		return true
	}
	if c < `a` || c > `z` {
		return false
	}
	if c == `i` || c == `l` || c == `o` || c == `u` {
		return false
	}
	return true
}

pub fn is_cdid(addr string, prefix rune) bool {
	key := match addr.len {
		26 {
			addr
		}
		27 {
			if addr[0] != prefix {
				return false
			}
			addr[1..]
		}
		else {
			return false
		}
	}
	return key.runes().all(is_cdid_rune(it))
}
