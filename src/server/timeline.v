module server

import log
import net
import net.websocket
import time
import veb
import conf
import database
import service.timeline

@['/api/v1/timelines'; get]
pub fn (mut app App) timelines(mut ctx Context) veb.Result {
	schema := ctx.query['schema'] or { '' }
	timelines := database.search[database.Timeline](schema: schema) or {
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}

	return ctx.return_content(.ok, .ok, timelines)
}

@['/api/v1/timelines/realtime'; get]
pub fn (mut app App) timeline_realtime(mut ctx Context) veb.Result {
	key := ctx.get_header(.sec_websocket_key) or {
		return ctx.request_error('Missing Sec-WebSocket-Key header')
	}
	ctx.takeover_conn()
	ctx.conn.set_write_timeout(time.infinite)
	ctx.conn.set_read_timeout(time.infinite)

	spawn fn (mut ws websocket.Server, mut connection net.TcpConn, key string) {
		mut sc := ws.handle_handshake(mut connection, key) or {
			log.error('Failed to connect to the WebSocket client!')
			return
		}
	}(mut app.timeline_ws, mut ctx.conn, key)

	return veb.no_result()
}

fn timeline_ws() !&websocket.Server {
	mut logger := log.new_thread_safe_log()
	$if prod {
		logger.set_level(.disabled)
	} $else {
		logger.set_level(log.get_level())
		logger.set_time_format(.tf_ss)
	}

	mut ws := websocket.new_server(.ip, conf.data.port, '', logger: logger)
	ws.on_connect(fn [mut logger] (mut server_client websocket.ServerClient) !bool {
		server_client.client.logger = logger
		return true
	})!
	ws.on_message(fn (mut client websocket.Client, msg &websocket.Message) ! {
		client.write_string('not implemented yet!')!
	})
	return ws
}

@['/api/v1/timeline/:id'; get]
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
