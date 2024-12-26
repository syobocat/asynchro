module timeline

import conf
import database
import util

@[noinit]
pub struct TimelineID {
pub:
	id          ?string
	domain      ?string
	semantic_id ?string
	user_id     ?string
}

@[noinit]
pub struct NormalizedPureTimelineID {
pub:
	id     string
	domain string
}

fn (tlid NormalizedPureTimelineID) str() string {
	return '${tlid.id}@${tlid.domain}'
}

@[noinit]
pub struct NormalizedSemanticTimelineID {
pub:
	domain      string
	semantic_id string
	user_id     string
}

fn (tlid NormalizedSemanticTimelineID) str() string {
	return '${tlid.semantic_id}@${tlid.user_id}@${tlid.domain}'
}

type NormalizedTimelineID = NormalizedPureTimelineID | NormalizedSemanticTimelineID

pub fn parse_tlid(id_raw string) !TimelineID {
	split := id_raw.split('@')
	match split.len {
		1 {
			// t+<hash>
			return TimelineID{
				id:     id_raw
				domain: conf.data.host
			}
		}
		2 {
			// t+<hash>@<domain> or
			// t+<hash>@<user> or
			// <semanticID>@<user>
			is_id := util.is_cdid(split[0], `t`)
			is_user := util.is_ccid(split[1])
			if is_id && is_user {
				// t+<hash>@<user>
				id := split[0]
				user_id := split[1]
				return TimelineID{
					id:      id
					user_id: user_id
				}
			}
			if is_id && !is_user {
				// t+<hash>@<domain>
				id := split[0]
				domain := split[1]
				return TimelineID{
					id:     id
					domain: domain
				}
			}
			if !is_id && is_user {
				// <semanticID>@<user>
				semantic_id := split[0]
				user_id := split[1]
				return TimelineID{
					semantic_id: semantic_id
					user_id:     user_id
				}
			}
			return error('Unknown ID Schema')
		}
		3 {
			// <semanticID>@<userID>@<domain>
			semantic_id := split[0]
			user_id := split[1]
			domain := split[2]
			return TimelineID{
				domain:      domain
				semantic_id: semantic_id
				user_id:     user_id
			}
		}
		else {
			return error('Unknown ID Schema')
		}
	}
}

pub fn (tlid TimelineID) normalized() !NormalizedTimelineID {
	domain := tlid.domain or {
		entity := database.get[database.Entity](id: tlid.user_id)!
		entity.domain
	}

	if id := tlid.id {
		return NormalizedTimelineID(NormalizedPureTimelineID{
			id:     id
			domain: domain
		})
	}
	if semantic_id := tlid.semantic_id {
		user_id := tlid.user_id or { return error('Invalid TimelineID') }
		if !util.is_my_domain(domain) {
			return NormalizedTimelineID(NormalizedSemanticTimelineID{
				semantic_id: semantic_id
				user_id:     user_id
				domain:      domain
			})
		} else {
			res := database.resolve_semanticid(semantic_id, user_id)!
			id := res.result or { return error('SemanticID ${semantic_id} does not exist') }
			return NormalizedTimelineID(NormalizedPureTimelineID{
				id:     id
				domain: domain
			})
		}
	}
	return error('Invalid TimelineID')
}

fn (tlid TimelineID) get_full_id() !string {
	normalized := tlid.normalized()!
	return normalized.str()
}
