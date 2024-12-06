module store

import encoding.hex
// import conf
import model
import service.entity
import service.signature

pub enum CommitMode {
	execute
	dry_run
	local_only_execute
}

pub fn commit(mode CommitMode, document model.Document, document_raw string, sig string) ! {
	if document.key_id == '' {
		signature_bytes := hex.decode(sig)!
		signature.verify(document_raw.bytes(), signature_bytes, document.signer)!
	} else {
		return error('Currently Asynchro does not support subkeys')

		/*
		signer := entity.get(document.signer)![0] or { return error('No such signer') }
		ccid := if signer.domain == conf.data.host {
			// TODO
			''
		} else {
			// TODO
			''
		}

		if ccid != document.signer {
			return error('Wrong signer')
		}

		signature_bytes := hex.decode(sig)!
		signature.verify(document_raw.bytes(), signature_bytes, document.key_id)!
		*/
	}
	match document {
		model.AffiliationDocument {
			entity.affiliation(document, sig)!
		}
		else {
			return error('Not implemented yet')
		}
	}
}
