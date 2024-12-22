module server

import log
import veb
import model
import service.db
import util

@['/api/v1/timeline/:id']
pub fn (app &App) timeline(mut ctx Context, id string) veb.Result {
	split := id.split('@')
	key := split[0]
	domain := split.last()
	query := if split.len == 1 || util.is_my_domain(domain) || util.is_cdid(key, `t`) {
		key
	} else {
		user_id := split[1]
		res := db.resolve_semanticid(key, user_id) or {
			log.error('Something happend when lookup semanticID: ${err}')
			return ctx.return_error(.internal_server_error, err.msg(), none)
		}
		sid := res.result or { return ctx.return_error(.not_found, 'User not found', none) }

		sid
	}

	res := db.get[model.Timeline](id: query) or {
		log.error('Something happend when retrieving timeline: ${err}')
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}
	if timeline := res.result {
		return ctx.return_content(.ok, .ok, timeline)
	} else {
		return ctx.return_error(.not_found, 'User not found', none)
	}
}
