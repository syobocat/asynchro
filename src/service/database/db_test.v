module database

import time
import model

fn test_api() {
	init()!
	entity_a := Entity{
		id:                    'con100000000000000000000000000000000000000'
		domain:                'example.tld'
		affiliation_document:  'eyJkdW1teSI6ImRvY3VtZW50In0K'
		affiliation_signature: '44756d6d79205369676e6174757265'
		cdate:                 time.utc()
		mdate:                 time.utc()
	}
	upsert(entity_a)!
	result := get_by_id[Entity]('con100000000000000000000000000000000000000')!
	entity_b := result.result or { panic('') }
	assert entity_a.affiliation_document == entity_b.affiliation_document
}
