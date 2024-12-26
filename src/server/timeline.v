module server

import log
import veb
import service.database
import service.timeline

@['/api/v1/timeline/:id']
pub fn (app &App) timeline(mut ctx Context, id string) veb.Result {
	tlid := timeline.parse_tlid(id) or { return ctx.request_error('Invalid TimelineID') }
	if semantic_id := tlid.semantic_id {
		user_id := tlid.user_id or { return ctx.request_error('Invalid TimelineID') }
		res := database.resolve_semanticid(semantic_id, user_id) or {
			log.error('Something happend when lookup semanticID: ${err}')
			return ctx.return_error(.internal_server_error, err.msg(), none)
		}
		_ := res.result or { return ctx.return_error(.not_found, 'User not found', none) }
	}
	normalized_wrapped := tlid.normalized() or { return ctx.request_error('Invalid TimelineID') }
	if normalized_wrapped !is timeline.NormalizedPureTimelineID {
		return ctx.request_error('Invalid TimelineID')
	}
	normalized := normalized_wrapped as timeline.NormalizedPureTimelineID

	res := database.get_opt[database.Timeline](id: normalized.id) or {
		log.error('Something happend when retrieving timeline: ${err}')
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}
	if timeline := res.result {
		return ctx.return_content(.ok, .ok, timeline)
	} else {
		return ctx.return_error(.not_found, 'User not found', none)
	}
}
