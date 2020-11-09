import { BigNumber } from 'ethers'

const { ethers, network } = require('@nomiclabs/buidler')

const idoFinAddr: { [name: string]: string } = {
  bsct: '0xf9e89b5aCA2e6061d22EA98CBCc2d826E3f9E4b1',
  bsc: '0xb9427922991ad2E15cB2BF2F44D9172092bF5D93',
}
const buyFinAddr: { [name: string]: string } = {
  bsct: '0xf9e89b5aCA2e6061d22EA98CBCc2d826E3f9E4b1',
  bsc: '0x70Dd2253fAF966643289e03aDD8871EfAF711E37',
}
const BAKE = '0xe02df9e3e622debdd69fb838bb799e3f168902c5'
const BAKERY_SWAP_FACTORY = '0x01bf7c66c6bd861915cdaae475042d3c4bae16a7'
const BUSD: { [name: string]: string } = {
  bsct: '0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee',
  bsc: '0xe9e7cea3dedca5984780bafc599bd69add087d56',
}
const WBNB: { [name: string]: string } = {
  bsct: '0x094616f0bdfb0b526bd735bf66eca0ad254ca81f',
  bsc: '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c',
}
const petTokenAddress: { [name: string]: string } = {
  bsct: '0xe59af933b309aFF12f323111B2B1648fF45D5dc0',
  bsc: '0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8',
}
const petEggNftAddress: { [name: string]: string } = {
  bsct: '0x0B619B394cA844576E571E43b6A120882Eb8C59a',
  bsc: '0x8A3ACae3CD954fEdE1B46a6cc79f9189a6C79c56',
}
const petIdoAddress: { [name: string]: string } = {
  bsct: '0x973df181FC4b317bcb961540cB5F2034AaEAfC3b',
  bsc: '0xD88ff9035a8abF2E973f9d30baFaE7eF28AAa630',
}
const petMasterAddress: { [name: string]: string } = {
  bsct: '0xfe292e44fE33579b3690dE57302263B3d6B59739',
  bsc: '0x4A2a35D0D259ecd344FaB05adEb9c72389ADF2D8',
}
const weaponTokenAddress: { [name: string]: string } = {
  bsct: '0x84525cE72f4f10C1Daa471C17f0DE14F96cd3132',
  bsc: '0x3664d30A612824617e3Cf6935d6c762c8B476eDA',
}
const weaponNftAddress: { [name: string]: string } = {
  bsct: '0x2F2d38bC4C9d7b2A57432d8a7AB2093a432885Ca',
  bsc: '0xBe7095dBBe04E8374ea5F9f5B3f30A48D57cb004',
}
const weaponNftMasterFinAddr: { [name: string]: string } = {
  bsct: '0xf9e89b5aCA2e6061d22EA98CBCc2d826E3f9E4b1',
  bsc: '0xc23E20cB7082dfB84496745E43fF89c657ff2724',
}
const weaponNftMasterAddress: { [name: string]: string } = {
  bsct: '0xCa4465C6926C6195127e1414A85cd572Ab15092E',
  bsc: '0xaDb60Ed40314E0B8Af8f91bC1b402011AbfaCBfC',
}
const weaponMasterAddress: { [name: string]: string } = {
  bsct: '0xF3F0FdD548D52ac5a80E81125974aD95a96F3c53',
  bsc: '0x0c2fC172c822B923f92A17aD9EA5c15aD7332624',
}

async function deployContract(name: string, args: any[] = []) {
  console.log(`start deployContract ${name}, ${args}`)
  // @ts-ignores
  const factory = await ethers.getContractFactory(name)

  // If we had constructor arguments, they would be passed into deploy()
  const contract = await factory.deploy(...args)

  // The address the Contract WILL have once mined
  console.log(`contract ${name} address ${contract.address}`)

  // The transaction that was sent to the network to deploy the Contract
  console.log(`contract ${name} deploy transaction hash ${contract.deployTransaction.hash}`)

  // The contract is NOT deployed yet; we must wait until it is mined
  await contract.deployed()
  console.log(`finish deployContract ${name}`)
}

async function transferPetEggNFTOwnershipToPetIDO() {
  const PetEggNFT = await ethers.getContractFactory('PetEggNFT')
  const tx = await PetEggNFT.attach(petEggNftAddress[network.name]).transferOwnership(petIdoAddress[network.name])
  console.log(`transferPetEggNFTOwnershipToPetIDO ${tx.hash}`)
  await tx.wait()
}

async function main() {
  // await deployContract('PetToken')
  /**
   start deployContract PetToken,
   contract PetToken address 0x829963c82F7040795f0E07c1F98544a82288bcE4
   contract PetToken deploy transaction hash 0x63657f6a6d16ba71e955dc9d5235792ab493204b28e68f9fb3fe9aa1d9d1844c
   finish deployContract PetToken
   start deployContract PetToken,
   contract PetToken address 0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8
   contract PetToken deploy transaction hash 0x3b3d238eaf1e67211edf6582d139e8f2d0c05230a85fd2481b6b087718f20986
   finish deployContract PetToken
   */
  // await deployContract('PetEggNFT')
  /**
   start deployContract PetEggNFT,
   contract PetEggNFT address 0x0B619B394cA844576E571E43b6A120882Eb8C59a
   contract PetEggNFT deploy transaction hash 0x7b4f8d5fa0c34e3b2663ae6f1dec060e47a7932230e7c9bed831d0bc3d3c7ea1
   finish deployContract PetEggNFT
   start deployContract PetEggNFT,
   contract PetEggNFT address 0x8A3ACae3CD954fEdE1B46a6cc79f9189a6C79c56
   contract PetEggNFT deploy transaction hash 0x7e038785f919178d4c4033f2fd4008e8b865790efb3a8445d3221aa740bf2b3d
   finish deployContract PetEggNFT
   */
  // await deployContract('PetIDO', [
  //   BigNumber.from(3E6),
  //   idoFinAddr[network.name],
  //   buyFinAddr[network.name],
  //   petTokenAddress[network.name],
  //   BAKERY_SWAP_FACTORY,
  //   BUSD[network.name],
  //   WBNB[network.name],
  //   petEggNftAddress[network.name]
  // ])
  /**
   start deployContract PetIDO, 3000000,0xf9e89b5aCA2e6061d22EA98CBCc2d826E3f9E4b1,0xf9e89b5aCA2e6061d22EA98CBCc2d826E3f9E4b1,0xe59af933b309aFF12f323111B2B1648fF45D5dc0,0x01bf7c66c6bd861915cdaae475042d3c4bae16a7,0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee,0x094616f0bdfb0b526bd735bf66eca0ad254ca81f,0x0B619B394cA844576E571E43b6A120882Eb8C59a
   contract PetIDO address 0x973df181FC4b317bcb961540cB5F2034AaEAfC3b
   contract PetIDO deploy transaction hash 0xcd03bcf6a1076105b72f7994fa0ae149b286f268a5d8e3d3c8b0fdefc43ca184
   finish deployContract PetIDO
   start deployContract PetIDO, 3000000,0xb9427922991ad2E15cB2BF2F44D9172092bF5D93,0x70Dd2253fAF966643289e03aDD8871EfAF711E37,0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8,0x01bf7c66c6bd861915cdaae475042d3c4bae16a7,0xe9e7cea3dedca5984780bafc599bd69add087d56,0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,0x8A3ACae3CD954fEdE1B46a6cc79f9189a6C79c56
   contract PetIDO address 0xD88ff9035a8abF2E973f9d30baFaE7eF28AAa630
   contract PetIDO deploy transaction hash 0x133294d2e3fb35ece2f23baa3583d3f791973e3630e872430de57e08b68c934c
   finish deployContract PetIDO
   */
  // await transferPetEggNFTOwnershipToPetIDO()
  // transferPetEggNFTOwnershipToPetIDO 0x599c93e37f0476b3e3beddcca3df7696ebf08de3b357b32db93c79e6eacc5eac
  // transferPetEggNFTOwnershipToPetIDO 0xc0e60e875bec2dff76b588411f25a5ac7e1e08e14dde45cc66aa5d88b27c43da
  // await deployContract('PetMaster', [
  //   petTokenAddress[network.name],
  //   BigNumber.from(1501804),
  //   BigNumber.from(4).mul(BigNumber.from(10).pow(18))
  // ])
  /**
   start deployContract PetMaster, 0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8,1501804,4000000000000000000
   contract PetMaster address 0x4A2a35D0D259ecd344FaB05adEb9c72389ADF2D8
   contract PetMaster deploy transaction hash 0x3b9cff786e97488ac53b01ad23c4f02337c7cd0bccad3e7f99840687b285d789
   finish deployContract PetMaster
   */
  // await deployContract('WeaponToken')
  /**
   start deployContract WeaponToken,
   contract WeaponToken address 0x84525cE72f4f10C1Daa471C17f0DE14F96cd3132
   contract WeaponToken deploy transaction hash 0xf3581499150d6b6278a763c0b206d6b9393cdc9d8e280c99f3afe878dddfc42d
   finish deployContract WeaponToken

   bsc
   start deployContract WeaponToken,
   contract WeaponToken address 0x3664d30A612824617e3Cf6935d6c762c8B476eDA
   contract WeaponToken deploy transaction hash 0x4942e45dfbbc0298a3360c2ae9f1a6309935cac93fc7710dff084d7a3bc9e846
   finish deployContract WeaponToken
   */
  // await deployContract('WeaponNFT', [petTokenAddress[network.name], BAKE])
  /**
   start deployContract WeaponNFT, 0xe59af933b309aFF12f323111B2B1648fF45D5dc0,0xe02df9e3e622debdd69fb838bb799e3f168902c5
   contract WeaponNFT address 0x2F2d38bC4C9d7b2A57432d8a7AB2093a432885Ca
   contract WeaponNFT deploy transaction hash 0x809485252a1b532c65e0d592ab1a0d49d1c9f410ccca70ce88e4f297528a95e9
   finish deployContract WeaponNFT
   bsc
   start deployContract WeaponNFT, 0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8,0xe02df9e3e622debdd69fb838bb799e3f168902c5
   contract WeaponNFT address 0xBe7095dBBe04E8374ea5F9f5B3f30A48D57cb004
   contract WeaponNFT deploy transaction hash 0x96d3c9268f929d91afd69154afa5e80dd1958b9eded8dfa9d5bd6b00171a62c0
   finish deployContract WeaponNFT
   */
  // await deployContract('WeaponNftMaster', [
  //   petTokenAddress[network.name],
  //   weaponNftAddress[network.name],
  //   BAKE,
  //   weaponTokenAddress[network.name],
  //   weaponNftMasterFinAddr[network.name],
  //   BAKERY_SWAP_FACTORY,
  // ])
  /**
   start deployContract WeaponNftMaster, 0xe59af933b309aFF12f323111B2B1648fF45D5dc0,0x2F2d38bC4C9d7b2A57432d8a7AB2093a432885Ca,0xe02df9e3e622debdd69fb838bb799e3f168902c5,0x84525cE72f4f10C1Daa471C17f0DE14F96cd3132,0xf9e89b5aCA2e6061d22EA98CBCc2d826E3f9E4b1,0x01bf7c66c6bd861915cdaae475042d3c4bae16a7
   contract WeaponNftMaster address 0xCa4465C6926C6195127e1414A85cd572Ab15092E
   contract WeaponNftMaster deploy transaction hash 0xe3fc96955592ab4075dcaf63d48ad37f95572732c71821dd7a2e1ead64fc4bb7
   finish deployContract WeaponNftMaster
   bsc
   start deployContract WeaponNftMaster, 0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8,0xBe7095dBBe04E8374ea5F9f5B3f30A48D57cb004,0xe02df9e3e622debdd69fb838bb799e3f168902c5,0x3664d30A612824617e3Cf6935d6c762c8B476eDA,0xc23E20cB7082dfB84496745E43fF89c657ff2724,0x01bf7c66c6bd861915cdaae475042d3c4bae16a7
   contract WeaponNftMaster address 0xaDb60Ed40314E0B8Af8f91bC1b402011AbfaCBfC
   contract WeaponNftMaster deploy transaction hash 0xcf57d2395a83513a01ac9630776892f71625910fe1ecaa542549689ef7ad5c10
   finish deployContract WeaponNftMaster
   */
  // await deployContract('WeaponMaster', [
  //   weaponTokenAddress[network.name],
  //   weaponNftAddress[network.name],
  //   BigNumber.from(2078752),
  //   BigNumber.from(250000).mul(BigNumber.from(10).pow(18)).div(28800),
  // ])
  /**
   start deployContract WeaponMaster, 0x84525cE72f4f10C1Daa471C17f0DE14F96cd3132,0x2F2d38bC4C9d7b2A57432d8a7AB2093a432885Ca,3488280,8680555555555555555
   contract WeaponMaster address 0xF3F0FdD548D52ac5a80E81125974aD95a96F3c53
   contract WeaponMaster deploy transaction hash 0x37ed2acfe55868b02c303d7ca8747870947d58e577a756266e398571cd7e4c21
   finish deployContract WeaponMaster
   bsc
   start deployContract WeaponMaster, 0x3664d30A612824617e3Cf6935d6c762c8B476eDA,0xBe7095dBBe04E8374ea5F9f5B3f30A48D57cb004,2078752,8680555555555555555
   contract WeaponMaster address 0x0c2fC172c822B923f92A17aD9EA5c15aD7332624
   contract WeaponMaster deploy transaction hash 0x123d5691dd03fd9cb28ef5b89c418fed90c33e28b45090138274ca81736b8e99
   finish deployContract WeaponMaster
   */
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
