module server

import encoding.base64
import json
import log
import time
import database
import service.signature
import util
import veb

struct BearerToken {
	header    JwtHeader
	payload   JwtPayload
	signature []u8
}

struct JwtHeader {
	alg string
	typ string
}

struct JwtPayload {
	jti string
	iat string
	exp string
	aud string
	iss string
	sub string
}

fn parse_bearer_token(token string) !BearerToken {
	split := token.split('.')
	if split.len != 3 {
		return error('Invalid JWT')
	}
	header_json := base64.url_decode_str(split[0])
	header := json.decode(JwtHeader, header_json)!
	if header.typ != 'JWT' || header.alg != 'CONCRNT' {
		return error('Unsupported JWT')
	}

	payload_json := base64.url_decode_str(split[1])
	payload := json.decode(JwtPayload, payload_json)!
	if payload.exp != '' {
		exp := time.unix(payload.exp.u64())
		now := time.utc()
		if exp < now {
			return error('Expired token')
		}
	}

	sig := base64.url_decode(split[2])
	signature.verify('${split[0]}.${split[1]}'.bytes(), sig, payload.iss)!

	return BearerToken{
		header:    header
		payload:   payload
		signature: sig
	}
}

fn verify_authorization(mut ctx Context) bool {
	method := ctx.req.method
	url := ctx.req.url

	authorization := ctx.get_header(.authorization) or { return true }
	token_string := authorization.all_after_last('Bearer ')
	token := parse_bearer_token(token_string) or {
		log.info('[API] Request Blocked: Invalid Authorization header: [${method}] ${url}')
		ctx.request_error('Invalid Authorization header')
		return false
	}

	if !util.is_my_domain(token.payload.aud) {
		log.info('[API] Request Blocked: JWT is not for this domain: [${method}] ${url}')
		ctx.request_error('JWT is not for this domain')
		return false
	}
	if token.payload.sub != 'concrnt' {
		log.info('[API] Request Blocked: Invalid subject: [${method}] ${url}')
		ctx.request_error('Invalid subject')
		return false
	}

	ccid := if util.is_ccid(token.payload.iss) {
		token.payload.iss
	} else if util.is_ckid(token.payload.iss) {
		// TODO: Subkey validation
		''
	} else {
		log.info('[API] Request Blocked: Invalid issuer: [${method}] ${url}')
		ctx.request_error('Invalid issuer')
		return false
	}

	entity := database.get[database.Entity](id: ccid) or {
		log.info('[API] Request Blocked: Entity not found: [${method}] ${url}')
		ctx.res.set_status(.forbidden)
		ctx.send_response_to_client('application/json', '{}')
		return false
	}
	ctx.tag = entity.tag
	if entity.tag.contains('_block') {
		log.info('[API] Request Blocked: Blocked user: [${method}] ${url}')
		ctx.return_error(.forbidden, 'you are blocked', none)
		return false
	}

	if util.is_my_domain(token.payload.aud) {
		// TODO: Passport?

		if _ := database.get[database.EntityMeta](id: ccid) {
			ctx.requester_is_registered = true
		}
		ctx.requester_type = .local_user
		ctx.requester_id = ccid
	} else {
		// TODO: Passport?
		ctx.requester_type = .remote_user
		ctx.requester_id = ccid
	}

	// TODO: Some other validation

	return true
}

struct PermissionError {
	error  string = 'you are not authorized to perform this action'
	detail string
}

fn (mut ctx Context) permission_error(what string) veb.Result {
	response := PermissionError{
		detail: 'you are not ${what}'
	}

	log.info('[API] Request Blocked: User is not ${what}: [${ctx.req.method}] ${ctx.req.url}')
	ctx.res.set_status(.forbidden)
	return ctx.json(response)
}

fn check_is_admin(mut ctx Context) bool {
	if ctx.tag.contains('_admin') {
		return true
	} else {
		ctx.permission_error('admin')
		return false
	}
}

fn check_is_local(mut ctx Context) bool {
	if ctx.requester_type == .local_user {
		return true
	} else {
		ctx.permission_error('local')
		return false
	}
}

fn check_is_known(mut ctx Context) bool {
	if ctx.requester_type != .unknown {
		return true
	} else {
		ctx.permission_error('known')
		return false
	}
}

fn check_is_united(mut ctx Context) bool {
	if ctx.requester_type == .remote_domain {
		return true
	} else {
		ctx.permission_error('united')
		return false
	}
}

fn check_is_registered(mut ctx Context) bool {
	if ctx.requester_is_registered {
		return true
	} else {
		ctx.permission_error('registered')
		return false
	}
}
