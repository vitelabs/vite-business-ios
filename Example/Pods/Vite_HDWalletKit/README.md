# Vite_HDWalletKit

[![Build Status](https://travis-ci.org/vitelabs/Vite_HDWalletKit.svg)](https://travis-ci.org/vitelabs/Vite_HDWalletKit)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Vite_HDWalletKit.svg)](https://img.shields.io/cocoapods/v/Vite_HDWalletKit.svg)
[![Platform](https://img.shields.io/cocoapods/p/Vite_HDWalletKit.svg?style=flat)](http://cocoadocs.org/docsets/Vite_HDWalletKit)


Vite_HDWalletKit  is a swift framework that you  can  create mnemonic words ,bip public key ,address 

You can check if the mnemonic generation is working right [here](https://iancoleman.io/bip39/).

## Features
- Mnemonic recovery phrease in [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
- BIP32 Root Key
- BIP32 Extended Private Key, use Ed25519 & Blake2b encrypt
- BIP32 Extended Public Key, use Ed25519 & Blake2b encrypt
- Derived Addresses, use Ed25519 & Blake2b encrypt

## Installation
### CocoaPods
<p>To integrate HDWalletKit into your Xcode project using <a href="http://cocoapods.org">CocoaPods</a>, specify it in your <code>Podfile</code>:</p>
<pre><code class="ruby language-ruby">pod 'Vite_HDWalletKit'</code></pre>

## How to use
#### Generate seed and convert it to mnemonic sentence.
```swift
let mnemonic = Mnemonic.generator(entropy: entropy)
print(mnemonic)
let seed = Mnemonic.createBIP39Seed(mnemonic: mnemonic)
print(seed.toHexString())

```
#### PrivateKey and key derivation (BIP39)

```swift
let key = HDBip.masterKey(seed: seed)

for i in 0..<10 {
let path = "\(HDBip.viteAccountPrefix)/\(i)'"
guard let k = HDBip.deriveForPath(path: path, seed: seed) else { fatalError() }
guard let (seed, address) = k.stringPair() else { fatalError() }
let account = "\(path) \(seed)  \(address)"
}
let masterPrivateKey = PrivateKey(seed: seed, network: .main)
```

## License
Vite_HDWalletKit is released under the [MIT License](https://github.com/essentiaone/HDWallet/blob/develop/LICENSE).
