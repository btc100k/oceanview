//
//  OceanEarnPay.swift
//  OceanView
//
//  Created by Raymond on 4/8/24.
//

import Foundation

struct Earning: Codable {
	let blockHash: String
	let ts: String
	let sharesInWindow: Int
	let feesCollectedSatoshis: Int
	let satoshisNetEarned: Int

	enum CodingKeys: String, CodingKey {
		case blockHash = "block_hash"
		case ts
		case sharesInWindow = "shares_in_window"
		case feesCollectedSatoshis = "fees_colected_satoshis"
		case satoshisNetEarned = "satoshis_net_earned"
	}
}

struct Payout: Codable {
	let ts: String
	let onChainTxid: String
	let totalSatoshisNetPaid: Int
	let isGenerationTxn: Bool

	enum CodingKeys: String, CodingKey {
		case ts
		case onChainTxid = "on_chain_txid"
		case totalSatoshisNetPaid = "total_satoshis_net_paid"
		case isGenerationTxn = "is_generation_txn"
	}
}

struct EarnPayResult: Codable {
	let startTs: String
	let endTs: String
	let earnings: [Earning]
	let payouts: [Payout]

	enum CodingKeys: String, CodingKey {
		case startTs = "start_ts"
		case endTs = "end_ts"
		case earnings
		case payouts
	}
}

struct EarnPayRoot: Codable {
	let result: EarnPayResult
}
