module server

import log
import veb
import model
import service.database
import service.entity

@['/api/v1/entity'; get]
pub fn (app &App) get_self_entity(mut ctx Context) veb.Result {
	requester := ctx.requester_id or {
		return ctx.return_message(.forbidden, .error, 'requester not found')
	}

	res := database.get_opt[database.Entity](id: requester) or {
		log.error('Something happend when searching: ${err}')
		return ctx.return_message(.internal_server_error, .error, err.msg())
	}

	ent := res.result or { return ctx.return_error(.not_found, 'entity not found', none) }

	return ctx.return_content(.ok, .ok, ent)
}

@['/api/v1/entity/:id'; get]
pub fn (app &App) get_entity(mut ctx Context, id string) veb.Result {
	if id.contains('.') {
		ent := entity.get_by_alias(id) or {
			log.error('Something happend when searching: ${err}')
			return ctx.return_message(.internal_server_error, .error, err.msg())
		}

		return ctx.return_content(.ok, .ok, ent)
	}

	res := database.get_opt[database.Entity](id: id) or {
		log.error('Something happend when searching: ${err}')
		return ctx.return_message(.internal_server_error, .error, err.msg())
	}
	if ent := res.result {
		return ctx.return_content(.ok, .ok, ent)
	} else {
		if _hint := ctx.query['hint'] {
			return ctx.server_error('Currently Asynchro does not support "search with hint"')
		} else {
			return ctx.return_error(.not_found, 'entity not found', none)
		}
	}
}

@['/api/v1/entity/:id/acking'; get]
pub fn (app &App) get_acking(mut ctx Context, id string) veb.Result {
	acks := database.get[model.Acking](id: id) or {
		log.error('Something happend when retrieving acking: ${err}')
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}

	return ctx.return_content(.ok, .ok, acks.acks)
}

@['/api/v1/entity/:id/acker'; get]
pub fn (app &App) get_acker(mut ctx Context, id string) veb.Result {
	acks := database.get[model.Acker](id: id) or {
		log.error('Something happend when retrieving acker: ${err}')
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}

	return ctx.return_content(.ok, .ok, acks.acks)
}
