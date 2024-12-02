module entity

import json
import conf
import model

fn get(key string) ![]model.Entity {
	db := conf.data.db

	entities := sql db {
		select from model.Entity where ccid == key
	}!

	return entities
}

fn store(entity model.Entity) ! {
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
				store(model.Entity{
					ccid:                  document.signer
					domain:                document.domain
					affiliation_document:  json.encode(document)
					affiliation_signature: signature
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
		return error('Not implemented yet.')
	}
}
