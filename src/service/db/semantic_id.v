module db

import model

pub fn resolve_semanticid(id string, owner string) !DBResult[string] {
	res := get[model.SemanticID](id: id, owner: owner)!
	if sid := res.result {
		return wrap_result([sid.target])
	} else {
		return wrap_result[string]([])
	}
}
