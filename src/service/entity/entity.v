module entity

import encoding.hex
import json
import conf
import time
import model
import fleximus.vdns
import database
import s2s
import signature
import util

pub fn affiliation(document_raw string, sig string) !database.Entity {
	document := json.decode(model.AffiliationDocument, document_raw)!
	signer := document.signer
	res := database.get_opt[database.Entity](id: signer)!
	if entity := res.result {
		entity_document := json.decode(model.AffiliationDocument, entity.affiliation_document)!
		if time.parse_rfc3339(document.signed_at)! < time.parse_rfc3339(entity_document.signed_at)! {
			return error('Newer affiliation exists')
		}
	}

	now := time.utc().format_rfc3339()
	if util.is_my_domain(document.domain) {
		match conf.data.metadata.registration {
			.open {
				new_entity := database.Entity{
					id:                    document.signer
					domain:                document.domain
					affiliation_document:  document_raw
					affiliation_signature: sig
					cdate:                 now
					mdate:                 now
				}
				new_entity_meta := database.EntityMeta{
					id: document.signer
				}
				database.insert(new_entity)!
				database.insert(new_entity_meta)!
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
		new_entity := database.Entity{
			id:                    document.signer
			domain:                document.domain
			affiliation_document:  document_raw
			affiliation_signature: sig
			cdate:                 now
			mdate:                 now
		}
		database.upsert(new_entity)!
		return new_entity
	}
}

pub fn get_by_alias(alias string) !database.Entity {
	res := database.get_opt[database.Entity](alias: alias)!
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

	if mut entity := database.get_opt[database.Entity](id: ccid)!.result {
		entity.set_alias(alias)!
		return entity
	} else {
		mut entity := pull_from_remote(ccid, kv['hint'])!
		entity.set_alias(alias)!
		return entity
	}
}

pub fn pull_from_remote(id string, remote string) !database.Entity {
	entity := s2s.get_entity(remote, id, none)!
	signature_bytes := hex.decode(entity.affiliation_signature)!
	signature.verify(entity.affiliation_document.bytes(), signature_bytes, id)!

	return affiliation(entity.affiliation_document, entity.affiliation_signature)!
}
