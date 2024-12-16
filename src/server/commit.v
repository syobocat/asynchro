module server

import json
import log
import veb
import model
import service.store

@['/api/v1/commit'; post]
pub fn (app &App) commit(mut ctx Context) veb.Result {
	data := ctx.req.data
	request := json.decode(model.Commit, data) or {
		response := model.ErrorResponse{
			error: err.msg()
		}

		ctx.res.set_status(.bad_request)
		return ctx.json(response)
	}

	if request.document.len > 8192 {
		response := model.ErrorResponse{
			error: 'Document size is too large'
		}

		ctx.res.set_status(.bad_request)
		return ctx.json(response)
	}

	// TODO: Get key

	res := store.commit(.execute, request.document, request.signature, request.option,
		none) or { // TODO: replace `none` with the key
		log.error('Commit failed: ${err}')
		response := model.ErrorResponse{
			error: err.msg()
		}

		ctx.res.set_status(.internal_server_error)
		return ctx.json(response)
	}

	if res.status == .permission_denied {
		ctx.res.set_status(.forbidden)
	}

	resp_status := match res.status {
		.ok { model.Status.ok }
		.already_exists, .already_deleted { model.Status.processed }
		.permission_denied { model.Status.error }
	}

	response := model.Response{
		status:  resp_status
		content: res.result
	}
	return ctx.json(response)
}
