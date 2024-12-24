module schema

import net.http
import service.db

pub fn fetch(url string) !db.Schema {
	res := db.get_schema_by_url(url)!
	if schema := res.result {
		return schema
	}

	_ := http.fetch(http.FetchConfig{
		url:    url
		header: http.new_header_from_map({
			.accept: 'application/json'
		})
	})!

	schema := db.Schema{
		url: url
	}

	db.insert(schema)!

	inserted := db.get[db.Schema](id: url)!

	return inserted
}

pub fn url_to_id(url string) !u32 {
	schema := fetch(url)!
	return schema.id
}

pub fn id_to_url(id u32) !string {
	res := db.get_schema_by_id(id)!
	schema := res.result or { return error('Not found') }
	return schema.url
}
