module server

import log
import veb
import service.database
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
		res := database.resolve_semanticid(key, user_id) or {
			log.error('Something happend when lookup semanticID: ${err}')
			return ctx.return_error(.internal_server_error, err.msg(), none)
		}
		sid := res.result or { return ctx.return_error(.not_found, 'User not found', none) }

		sid
	}

	normalized := util.normalize_timeline_id(query) or {
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}
	res := database.get_opt[database.Timeline](id: normalized) or {
		log.error('Something happend when retrieving timeline: ${err}')
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}
	if timeline := res.result {
		return ctx.return_content(.ok, .ok, timeline)
	} else {
		return ctx.return_error(.not_found, 'User not found', none)
	}
}
