module server

import log
import veb
import model
import service.ack
import service.db
import service.entity

@['/api/v1/entity/:id']
pub fn (app &App) get_entity(mut ctx Context, id string) veb.Result {
	access_log(ctx)
	if id.contains('.') {
		ent := entity.get_by_alias(id) or {
			log.error('Something happend when searching: ${err}')
			response := model.MessageResponse{
				status:  .error
				message: err.msg()
			}
			ctx.res.set_status(.internal_server_error)
			return ctx.json(response)
		}

		response := model.Response{
			status:  .ok
			content: ent
		}
		return ctx.json(response)
	}

	res := db.get[model.Entity](id: id) or {
		log.error('Something happend when searching: ${err}')
		response := model.MessageResponse{
			status:  .error
			message: err.msg()
		}
		ctx.res.set_status(.internal_server_error)
		return ctx.json(response)
	}
	if entity := res.result {
		response := model.Response{
			status:  .ok
			content: entity
		}
		return ctx.json(response)
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
	acks := ack.get_acking(id) or {
		log.error('Something happend when retriving acking: ${err}')
		response := model.ErrorResponse{
			error: err.msg()
		}

		ctx.res.set_status(.internal_server_error)
		return ctx.json(response)
	}

	response := model.Response{
		status:  .ok
		content: acks
	}
	return ctx.json(response)
}

@['/api/v1/entity/:id/acker']
pub fn (app &App) get_acker(mut ctx Context, id string) veb.Result {
	access_log(ctx)
	acks := ack.get_acker(id) or {
		log.error('Something happend when retriving acker: ${err}')
		response := model.ErrorResponse{
			error: err.msg()
		}

		ctx.res.set_status(.internal_server_error)
		return ctx.json(response)
	}

	response := model.Response{
		status:  .ok
		content: acks
	}
	return ctx.json(response)
}
