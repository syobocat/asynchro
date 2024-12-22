module server

import log
import veb
import model
import service.db
import service.entity

@['/api/v1/entity/:id']
pub fn (app &App) get_entity(mut ctx Context, id string) veb.Result {
	access_log(ctx)
	if id.contains('.') {
		ent := entity.get_by_alias(id) or {
			log.error('Something happend when searching: ${err}')
			return ctx.return_message(.internal_server_error, .error, err.msg())
		}

		return ctx.return_content(.ok, .ok, ent)
	}

	res := db.get[model.Entity](id: id) or {
		log.error('Something happend when searching: ${err}')
		return ctx.return_message(.internal_server_error, .error, err.msg())
	}
	if ent := res.result {
		return ctx.return_content(.ok, .ok, ent)
	} else {
		if _hint := ctx.query['hint'] {
			return ctx.server_error('Currently Asynchro does not support "search with hint"')
		} else {
			ctx.res.set_status(.not_found)
			return ctx.send_response_to_client('application/json', '{"error":"entity not found"}')
		}
	}
}

@['/api/v1/entity/:id/acking']
pub fn (app &App) get_acking(mut ctx Context, id string) veb.Result {
	access_log(ctx)
	res := db.get[model.Acking](id: id) or {
		log.error('Something happend when retrieving acking: ${err}')
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}
	acks := res.result or { return ctx.server_error('Unexpected Error') }

	return ctx.return_content(.ok, .ok, acks.acks)
}

@['/api/v1/entity/:id/acker']
pub fn (app &App) get_acker(mut ctx Context, id string) veb.Result {
	access_log(ctx)
	res := db.get[model.Acker](id: id) or {
		log.error('Something happend when retrieving acker: ${err}')
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}
	acks := res.result or { return ctx.server_error('Unexpected Error') }

	return ctx.return_content(.ok, .ok, acks.acks)
}
