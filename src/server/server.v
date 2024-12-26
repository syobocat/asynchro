module server

import log
import net.http
import term
import veb
import conf
import model

const logo = term.magenta("\n     ,---.                    |\n     |---|,---.,   .,---.,---.|---.,---.,---.\n     |   |`---.|   ||   ||    |   ||    |   |\n     `   '`---'`---|`   '`---'`   '`    `---'\n               `---'\n")
const uwulogo = term.cyan("\n,   .                              |              \n|\\  |,   .,---.,---.,   .,---.,---.|---.,---.,---.\n| \\ ||   |,---|`---.|   ||   ||    |   ||    |   |\n`  `'`---|`---^`---'`---|`   '`---'`   '`    `---'\n     `---'          `---'\n")

pub struct Context {
	veb.Context
}

pub struct App {
	veb.Middleware[Context]
pub:
	data conf.Data
}

pub fn serve(uwu bool) {
	mut app := &App{
		data: &conf.data
	}
	cors := veb.cors[Context](veb.CorsOptions{
		origins:         ['*']
		allowed_headers: ['*']
		allowed_methods: [.get, .head, .put, .patch, .post, .delete]
		expose_headers:  ['trace-id']
	})
	app.route_use('/api/v1/:endpoint...', cors)
	app.route_use('/services', cors)

	if uwu {
		startup_message(uwulogo, app.data.host, app.data.bind, app.data.port)
	} else {
		startup_message(logo, app.data.host, app.data.bind, app.data.port)
	}

	veb.run_at[App, Context](mut app, veb.RunParams{
		family:               .ip
		host:                 app.data.bind
		port:                 app.data.port
		show_startup_message: false
	}) or { panic(err) }
}

fn startup_message(aa string, host string, bind string, port int) {
	println('==================================================')
	println(aa)
	println('This is ${host}. listening on ${bind}:${port}...')
	println('==================================================')
}

fn access_log(ctx &Context) {
	method := ctx.req.method
	url := ctx.req.url
	log.debug('[API] Received request: [${method}] ${url}')
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
