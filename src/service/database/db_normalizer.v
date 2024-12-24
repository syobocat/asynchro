module database

import util

interface Normalizable {
	id            string
	schema_id     u32
	schema        string
	policy_id     u32
	policy        ?string
	policy_params ?string
}

fn preprocess[T](object Normalizable) !(string, u32, u32) {
	id := normalize_id[T](object.id)!

	schema_id := if object.schema_id == 0 {
		schema_url_to_id(object.schema)!
	} else {
		object.schema_id
	}

	policy_id := if object.policy_id == 0 {
		if policy := object.policy {
			schema_url_to_id(policy)!
		} else {
			0
		}
	} else {
		object.policy_id
	}

	return id, schema_id, policy_id
}

fn postprocess(object Normalizable, object_type rune) !(string, string, ?string) {
	id := match object.id.len {
		27 { object.id }
		26 { '${object_type}${object.id}' }
		else { return error('length of ID should be either 26 or 27') }
	}

	schema := if object.schema.len == 0 && object.schema_id > 0 {
		schema_id_to_url(object.schema_id)!
	} else {
		object.schema
	}

	// Somehow object.policy can be Some(''), so unwrap before check
	if (object.policy or { '' }).len == 0 && object.policy_id > 0 {
		return id, schema, schema_id_to_url(object.policy_id)!
	} else {
		return id, schema, object.policy
	}
}

pub fn normalize_id[T](id_raw string) !string {
	$if T is Timeline {
		split := id_raw.split_nth('@', 2)
		if domain := split[1] {
			if !util.is_my_domain(domain) {
				return error('invalid timeline id: ${id_raw}')
			}
		}

		id := split[0]

		return normalize_id_generic(id, `t`)
	}
	$if T is Profile {
		return normalize_id_generic(id_raw, `p`)
	}
	return error('not implemented')
}

fn normalize_id_generic(id string, id_type rune) !string {
	normalized := match id.len {
		26 {
			id
		}
		27 {
			if id[0] != id_type {
				return error("id must start with '${id_type}'")
			}
			id[1..]
		}
		else {
			return error('id must be 26 characters long')
		}
	}

	return normalized
}
