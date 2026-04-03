//
//  PaymentResult.swift
//  Primal
//
//  Represents the result of a Lightning payment, including the preimage
//  needed for L402 proof-of-payment flows.
//

struct PaymentResult {
    enum Status {
        /// Payment succeeded and the wallet returned a result.
        case completed
        /// Payment succeeded but preimage/hash could not be extracted.
        case completedNoProof
    }

    /// Whether the payment completed with or without extractable proof.
    let status: Status

    /// The payment preimage (hex). Proof-of-payment for L402 flows.
    /// Nil if the wallet/provider doesn't surface it.
    let preimage: String?

    /// The payment hash (hex). Identifies the Lightning payment.
    let paymentHash: String?
}
