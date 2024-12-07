module entity

import encoding.hex
import json
import conf
import time
import model
import fleximus.vdns
import service.s2s
import service.signature

pub fn affiliation(document model.AffiliationDocument, sig string) !model.Entity {
	signer := document.signer
	res := get(signer)!
	if entity := res.result {
		entity_document := json.decode(model.AffiliationDocument, entity.affiliation_document)!
		if document.signed_at < entity_document.signed_at {
			return error('Newer affiliation exists')
		}
	}

	if document.domain == conf.data.host {
		match conf.data.metadata.registration {
			.open {
				new_entity := model.Entity{
					ccid:                  document.signer
					domain:                document.domain
					affiliation_document:  json.encode(document)
					affiliation_signature: sig
					cdate:                 time.utc()
					mdate:                 time.utc()
				}
				store_new(new_entity)!
				return new_entity
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
			affiliation_signature: sig
			cdate:                 time.utc()
			mdate:                 time.utc()
		}
		store(new_entity)!
		return new_entity
	}
}

pub fn get_by_alias(alias string) !model.Entity {
	res := search_by_alias(alias)!
	if ent := res.result {
		return ent
	}

	resp := vdns.query(vdns.Query{
		domain:   '_concrnt.${alias}'
		@type:    .txt
		resolver: '1.1.1.1:53' // TODO: make it customizable
	})!

	mut kv := map[string]string{}

	for answer in resp.answers {
		if key, value := answer.record.split_once('=') {
			kv[key] = value
		}
	}

	ccid := kv['ccid'] or { return error('ccid not found') }
	sig := kv['sig'] or { return error('sig not found') }
	signature_bytes := hex.decode(sig)!
	signature.verify(alias.bytes(), signature_bytes, ccid)!

	if _entity := get(ccid)!.result {
		pull_from_remote(ccid, kv['hint'])!
		set_alias(ccid, alias)!
	}

	// Don't reuse previous get(ccid) in order to ensure that alias is set
	// This SHOULD return an entity, because of pull_from_remote()
	res2 := get(ccid)!
	ent := res2.result or { return error('entity not found') }

	return ent
}

pub fn pull_from_remote(id string, remote string) !model.Entity {
	entity := s2s.get_entity(remote, id, none)!
	signature_bytes := hex.decode(entity.affiliation_signature)!
	signature.verify(entity.affiliation_document.bytes(), signature_bytes, id)!

	affiliation_document := json.decode(model.AffiliationDocument, entity.affiliation_document)!
	return affiliation(affiliation_document, entity.affiliation_signature)!
}
