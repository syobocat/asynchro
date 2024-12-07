module entity

import json
import conf
import time
import model

pub fn affiliation(document model.AffiliationDocument, signature string) !string {
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
	return signer
}
