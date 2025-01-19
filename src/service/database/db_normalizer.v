module database

import util

fn object_type[T]() !rune {
	$if T is Timeline {
		return `t`
	}
	$if T is Profile {
		return `p`
	}
	$if T is Subscription {
		return `s`
	}
	return error('unknown type')
}

pub fn preprocess_id[T](id string) !string {
	type := object_type[T]() or { return id }
	return preprocess_id_generic(id, type)
}

pub fn postprocess_id[T](id string) !string {
	type := object_type[T]() or { return id }
	return postprocess_id_generic(id, type)
}

fn preprocess_id_generic(id_raw string, id_type rune) !string {
	id := if id_type == `t` {
		split := id_raw.split_nth('@', 2)
		if domain := split[1] {
			if !util.is_my_domain(domain) {
				return error('invalid timeline id: ${id_raw}')
			}
		}
		split[0]
	} else {
		id_raw
	}

	match id.len {
		26 {
			return id
		}
		27 {
			if id[0] != id_type {
				return error("id must start with '${id_type}'")
			}
			return id[1..]
		}
		else {
			return error('id must be 26 characters long')
		}
	}
}

fn postprocess_id_generic(id string, id_type rune) !string {
	match id.len {
		27 {
			return id
		}
		26 {
			return '${id_type}${id}'
		}
		else {
			return error('length of ID should be either 26 or 27')
		}
	}
}
