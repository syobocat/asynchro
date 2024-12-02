module entity

import json
import conf
import time
import model

pub fn get(key string) ![]model.Entity {
	db := conf.data.db

	entities := sql db {
		select from model.Entity where ccid == key
	}!

	return entities
}

fn store(entity model.Entity) ! {
	existence := get(entity.ccid)!
	if _ := existence[0] {
		db := conf.data.db
		sql db {
			update model.Entity set domain = entity.domain, affiliation_document = entity.affiliation_document,
			affiliation_signature = entity.affiliation_signature, mdate = time.utc() where ccid == entity.ccid
		}!
	} else {
		store_new(entity)!
	}
}

fn store_new(entity model.Entity) ! {
	db := conf.data.db

	sql db {
		insert entity into model.Entity
	}!
}

pub fn affiliation(document model.AffiliationDocument, signature string) ! {
	signer := document.signer
	existence := get(signer)!
	if entity := existence[0] {
		entity_document := json.decode(model.AffiliationDocument, entity.affiliation_document)!
		if document.signed_at < entity_document.signed_at {
			return error('Newer affiliation exists')
		}
	}

	if document.domain == conf.data.host {
		match conf.data.metadata.registration {
			.open {
				store_new(model.Entity{
					ccid:                  document.signer
					domain:                document.domain
					affiliation_document:  json.encode(document)
					affiliation_signature: signature
					cdate:                 time.utc()
					mdate:                 time.utc()
				})!
			}
			.invite {
				return error('Currently Asynchro does not support invitations.')
			}
			.close {
				return error('Registration is closed.')
			}
		}
	} else {
		new_entity := model.Entity{
			ccid:                  document.signer
			domain:                document.domain
			affiliation_document:  json.encode(document)
			affiliation_signature: signature
			cdate:                 time.utc()
			mdate:                 time.utc()
		}
		store(new_entity)!
	}
}
