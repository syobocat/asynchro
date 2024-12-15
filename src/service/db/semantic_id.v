module db

import model

pub fn resolve_semanticid(id string, owner string) !string {
	res := get[model.SemanticID](id: id, owner: owner)!
	sid := res.result or { return '' }
	return sid.target
}
