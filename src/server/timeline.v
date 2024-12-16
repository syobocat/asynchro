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
		sid := db.resolve_semanticid(key, user_id) or {
			log.error('Something happend when lookup semanticID: ${err}')
			response := model.ErrorResponse{
				error: err.msg()
			}

			ctx.res.set_status(.internal_server_error)
			return ctx.json(response)
		}
		sid
	}

	res := db.get[model.Timeline](id: query) or {
		log.error('Something happend when retrieving timeline: ${err}')
		response := model.ErrorResponse{
			error: err.msg()
		}

		ctx.res.set_status(.internal_server_error)
		return ctx.json(response)
	}
	if timeline := res.result {
		response := model.Response{
			status:  .ok
			content: timeline
		}

		return ctx.json(response)
	} else {
		response := model.ErrorResponse{
			error: 'Timeline not found'
		}

		ctx.res.set_status(.not_found)
		return ctx.json(response)
	}
}
