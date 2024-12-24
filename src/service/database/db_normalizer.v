module database

import util

interface Normalizable {
mut:
	id            string
	schema_id     u32
	schema        string
	policy_id     u32
	policy        ?string
	policy_params ?string
}

fn preprocess[T](mut object Normalizable) ! {
	object.id = normalize_id[T](object.id)!

	if object.schema_id == 0 {
		object.schema_id = schema_url_to_id(object.schema)!
	}

	if policy := object.policy {
		if object.policy_id == 0 {
			object.policy_id = schema_url_to_id(policy)!
		}
	}
}

fn postprocess(mut object Normalizable, object_type rune) ! {
	if object.id.len == 26 {
		object.id = '${object_type}${object.id}'
	}

	if object.schema.len == 0 {
		object.schema = schema_id_to_url(object.schema_id)!
	}

	if object.policy == none {
		object.policy = schema_id_to_url(object.policy_id)!
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
