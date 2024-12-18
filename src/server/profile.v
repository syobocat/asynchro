module server

import log
import veb
import service.db
import model

@['/api/v1/profile/:owner/:semantic_id']
pub fn (app &App) profile(mut ctx Context, owner string, semantic_id string) veb.Result {
	access_log(ctx)
	if owner == '' && semantic_id == '' {
		response := model.ErrorResponse{
			error:   'Invalid request'
			message: 'semanticID and owner are required'
		}
		ctx.res.set_status(.bad_request)
		return ctx.json(response)
	}
	res := db.get[model.Profile](id: semantic_id, owner: owner) or {
		log.error('Something happend when retrieving profile: ${err}')
		response := model.ErrorResponse{
			error: err.msg()
		}

		ctx.res.set_status(.internal_server_error)
		return ctx.json(response)
	}
	prof := res.result or {
		response := model.ErrorResponse{
			error: 'Profile not found'
		}

		ctx.res.set_status(.not_found)
		return ctx.json(response)
	}

	response := model.Response{
		status:  .ok
		content: prof
	}
	return ctx.json(response)
}
