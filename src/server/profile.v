module server

import log
import veb
import service.db
import model

@['/api/v1/profile/:owner/:semantic_id']
pub fn (app &App) profile(mut ctx Context, owner string, semantic_id string) veb.Result {
	access_log(ctx)
	if owner == '' && semantic_id == '' {
		return ctx.return_error(.bad_request, 'Invalid request', 'semanticID and owner are required')
	}
	res := db.get_opt[model.Profile](id: semantic_id, owner: owner) or {
		log.error('Something happend when retrieving profile: ${err}')
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}
	prof := res.result or { return ctx.return_error(.not_found, 'Profile not found', none) }

	return ctx.return_content(.ok, .ok, prof)
}
