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

pub fn normalize_timeline_id(id_raw string) !string {
	split := id_raw.split_nth('@', 2)
	if domain := split[1] {
		if !is_my_domain(domain) {
			return error('invalid timeline id: ${id_raw}')
		}
	}

	id := split[0]

	normalized := match id.len {
		26 {
			id
		}
		27 {
			if id[0] != `t` {
				return error("timeline id must start with 't'")
			}
			id[1..]
		}
		else {
			return error('timeline id must be 26 characters long')
		}
	}

	return normalized
}
