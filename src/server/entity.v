module server

import log
import veb
import model
import service.entity

@['/api/v1/entity/:id']
pub fn (app &App) get_entity(mut ctx Context, id string) veb.Result {
	if id.contains('.') {
		return ctx.server_error('Currently Asynchro does not support "search by alias"')
	}

	res := entity.get(id) or {
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
