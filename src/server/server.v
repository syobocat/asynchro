module server

import log
import net.http
import net.websocket
import term
import veb
import conf
import model

const logo = term.magenta("\n     ,---.                    |\n     |---|,---.,   .,---.,---.|---.,---.,---.\n     |   |`---.|   ||   ||    |   ||    |   |\n     `   '`---'`---|`   '`---'`   '`    `---'\n               `---'\n")
const uwulogo = term.cyan("\n,   .                              |              \n|\\  |,   .,---.,---.,   .,---.,---.|---.,---.,---.\n| \\ ||   |,---|`---.|   ||   ||    |   ||    |   |\n`  `'`---|`---^`---'`---|`   '`---'`   '`    `---'\n     `---'          `---'\n")

pub enum RequesterType {
	unknown
	local_user
	remote_user
	remote_domain
}

pub struct Context {
	veb.Context
pub mut:
	tag                     string
	requester_type          RequesterType
	requester_id            ?string
	requester_is_registered bool
}

pub struct App {
	veb.Middleware[Context]
pub mut:
	timeline_ws &websocket.Server
}

pub fn serve(uwu bool) ! {
	mut app := &App{
		timeline_ws: timeline_ws()!
	}
	cors := veb.cors[Context](veb.CorsOptions{
		origins:         ['*']
		allowed_headers: ['*']
		allowed_methods: [.get, .head, .put, .patch, .post, .delete]
		expose_headers:  ['trace-id']
	})
	app.route_use('/api/v1/:endpoint...', cors)
	app.route_use('/services', cors)
	app.use(handler: access_log)
	app.use(handler: verify_authorization)
	app.route_use('/api/v1/entity', handler: check_is_registered)
	app.route_use('/api/v1/kv/:key', handler: check_is_registered)
	app.route_use('/api/v1/subscriptions/mine', handler: check_is_local)

	if uwu {
		startup_message(uwulogo, conf.data.host, conf.data.bind, conf.data.port)
	} else {
		startup_message(logo, conf.data.host, conf.data.bind, conf.data.port)
	}

	veb.run_at[App, Context](mut app, veb.RunParams{
		family:               .ip
		host:                 conf.data.bind
		port:                 conf.data.port
		show_startup_message: false
	})!
}

fn startup_message(aa string, host string, bind string, port int) {
	println('==================================================')
	println(aa)
	println('This is ${host}. listening on ${bind}:${port}...')
	println('==================================================')
}

fn access_log(ctx &Context) bool {
	method := ctx.req.method
	url := ctx.req.url
	log.debug('[API] Received request: [${method}] ${url}')
	return true
}

fn (mut ctx Context) return_error(status http.Status, err string, msg ?string) veb.Result {
	response := model.ErrorResponse{
		error:   err
		message: msg
	}

	ctx.res.set_status(status)
	return ctx.json(response)
}

fn (mut ctx Context) return_content[T](http_status http.Status, status model.Status, content T) veb.Result {
	response := model.Response[T]{
		status:  status
		content: content
	}

	ctx.res.set_status(http_status)
	return ctx.json(response)
}

fn (mut ctx Context) return_message(http_status http.Status, status model.Status, msg string) veb.Result {
	response := model.MessageResponse{
		status:  status
		message: msg
	}

	ctx.res.set_status(http_status)
	return ctx.json(response)
}

fn (mut ctx Context) return(http_status http.Status, status model.Status) veb.Result {
	response := model.EmptyResponse{
		status: status
	}

	ctx.res.set_status(http_status)
	return ctx.json(response)
}
