module MyModule::ConsentAttestation {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::string::String;
    
    /// Struct representing a consent attestation for trips or activities
    struct ConsentRecord has store, key {
        participant_address: address,     // Address of the person giving consent
        activity_description: String,     // Description of the trip/activity
        consent_timestamp: u64,          // When consent was given
        is_valid: bool,                  // Whether consent is still valid
    }
    
    /// Error codes
    const E_CONSENT_NOT_FOUND: u64 = 1;
    const E_UNAUTHORIZED: u64 = 2;
    
    /// Function to create a new consent attestation
    public fun create_consent_attestation(
        participant: &signer, 
        activity_description: String
    ) {
        let participant_addr = signer::address_of(participant);
        let current_time = timestamp::now_microseconds();
        
        let consent_record = ConsentRecord {
            participant_address: participant_addr,
            activity_description,
            consent_timestamp: current_time,
            is_valid: true,
        };
        
        move_to(participant, consent_record);
    }
    
    /// Function to verify and retrieve consent attestation
    public fun verify_consent_attestation(
        participant_address: address
    ): (String, u64, bool) acquires ConsentRecord {
        assert!(exists<ConsentRecord>(participant_address), E_CONSENT_NOT_FOUND);
        
        let consent_record = borrow_global<ConsentRecord>(participant_address);
        
        (
            consent_record.activity_description,
            consent_record.consent_timestamp,
            consent_record.is_valid
        )
    }
    
    /// Optional: Function to revoke consent (bonus - keeps within line limit)
    public fun revoke_consent(participant: &signer) acquires ConsentRecord {
        let participant_addr = signer::address_of(participant);
        assert!(exists<ConsentRecord>(participant_addr), E_CONSENT_NOT_FOUND);
        
        let consent_record = borrow_global_mut<ConsentRecord>(participant_addr);
        consent_record.is_valid = false;
    }
}