module model

pub enum DocumentType {
	ack
	unack
	affiliation
	association
	delete
	enact
	revoke
	event
	message
	passport
	profile
	subscribe
	unsubscribe
	subscription
	timeline
	retract
	tombstone
}

pub type Document = DocumentBase
	| AffiliationDocument
	| TombstoneDocument
	| AckDocument
	| UnackDocument
	| MessageDocument
	| AssociationDocument
	| ProfileDocument
	| TimelineDocument
	| SubscriptionDocument
	| PassportDocument
	| DeleteDocument
	| RevokeDocument
	| EnactDocument
	| RetractDocument
	| SubscribeDocument
	| UnsubscribeDocument

pub struct DocumentBase {
pub:
	signer          string
	key_id          ?string
	type            DocumentType
	signed_at       string @[json: 'signedAt']
	id              ?string
	semantic_id     ?string @[json: 'semanticID']
	owner           ?string
	schema          string @[omitempty]
	policy          ?string
	policy_params   ?string @[json: 'policyParams']
	policy_defaults ?string @[json: 'policyDefaults']
}

pub struct AffiliationDocument {
	DocumentBase
pub:
	domain string
}

pub struct TombstoneDocument {
	DocumentBase
pub:
	reason string
}

struct RelationDocument {
	DocumentBase
pub:
	from string
	to   string
}

pub struct AckDocument {
	RelationDocument
}

pub struct UnackDocument {
	RelationDocument
}

pub struct MessageDocument {
	DocumentBase
pub:
	timelines []string
}

pub struct AssociationDocument {
	DocumentBase
pub:
	timelines []string
	variant   string
	target    string
}

pub struct ProfileBody {
	username    string
	description string
	avatar      string
	banner      string
}

pub struct ProfileDocument {
	DocumentBase
pub:
	body ProfileBody
}

struct IndexableDocument {
	DocumentBase
pub:
	indexable    bool
	domain_owned bool @[json: 'domainOwned']
}

pub struct TimelineDocument {
	IndexableDocument
}

pub struct SubscriptionDocument {
	IndexableDocument
}

pub struct PassportDocument {
	DocumentBase
pub:
	domain string
	entity string
	keys   []Key
}

struct TargettedDocument {
	DocumentBase
pub:
	target string
}

pub struct DeleteDocument {
	TargettedDocument
}

pub struct RevokeDocument {
	TargettedDocument
}

pub struct EnactDocument {
	TargettedDocument
pub:
	key_id string
	root   string
	parent string
}

pub struct RetractDocument {
	TargettedDocument
pub:
	timeline string
}

struct SubDocument {
	TargettedDocument
pub:
	subscription string
}

pub struct SubscribeDocument {
	SubDocument
}

pub struct UnsubscribeDocument {
	SubDocument
}
