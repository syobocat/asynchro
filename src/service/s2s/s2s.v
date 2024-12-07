module s2s

import json
import net.http
import net.urllib
import model

const api_path = '/api/v1'

fn get_document[T](url string) !T {
	resp := http.get(url.str())!

	if !http.status_from_int(resp.status_code).is_success() {
		return error('request does not success: ${resp.status_msg}')
	}
	content := resp.body

	return json.decode(T, content)
}

pub fn get_entity(host string, ccid string, hint ?string) !model.Entity {
	query := if h := hint {
		'hint=${urllib.query_escape(h)}'
	} else {
		''
	}
	url := urllib.URL{
		scheme:    'https'
		host:      host
		path:      '${api_path}/entity/${urllib.path_escape(ccid)}'
		raw_query: query
	}

	return get_document[model.Entity](url.str())
}
