// This transaction configures the signer's account with an empty FUSD vault.
//
// It also links the following capabilities:
//
// - FungibleToken.Receiver: this capability allows this account to accept FUSD deposits.
// - FungibleToken.Balance: this capability allows anybody to inspect the FUSD balance of this account.

import FungibleToken from 0xf8d6e0586b0a20c7
import FUSD from 0xf8d6e0586b0a20c7

transaction {

    prepare(signer: AuthAccount) {

        // It's OK if the account already has a Vault, but we don't want to replace it
        if(signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) != nil) {

            //@dev !!
            // if Account does have a Vault, in this case it is the Admin account, and it 
            // needs the receiver, so link it here. This must be cleaner, but for testing 
            // purposes it is fine.
            signer.link<&FUSD.Vault{FungibleToken.Receiver}>(
                /public/fusdReceiver,
                target: /storage/fusdVault
            )
            return
        }
        
        // Create a new FUSD Vault and put it in storage
        signer.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&FUSD.Vault{FungibleToken.Receiver}>(
            /public/fusdReceiver,
            target: /storage/fusdVault
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&FUSD.Vault{FungibleToken.Balance}>(
            /public/fusdBalance,
            target: /storage/fusdVault
        )
    }
}