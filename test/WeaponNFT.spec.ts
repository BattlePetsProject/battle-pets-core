import { WeaponNft } from '../typechain/WeaponNft'
import { WeaponNftFactory } from '../typechain/WeaponNftFactory'
import { BigNumber } from 'ethers'
import { approveErc20 } from './shared/utilities'

const { ethers, network } = require('@nomiclabs/buidler')

const petTokenAddress: { [name: string]: string } = {
  bsct: '0xe59af933b309aFF12f323111B2B1648fF45D5dc0',
  bsc: '0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8',
}
const BAKE = '0xe02df9e3e622debdd69fb838bb799e3f168902c5'

const weaponTokenAddress: { [name: string]: string } = {
  bsct: '0x84525cE72f4f10C1Daa471C17f0DE14F96cd3132',
  bsc: '0x3664d30A612824617e3Cf6935d6c762c8B476eDA',
}
const weaponNftAddress: { [name: string]: string } = {
  bsct: '0x2F2d38bC4C9d7b2A57432d8a7AB2093a432885Ca',
  bsc: '0xBe7095dBBe04E8374ea5F9f5B3f30A48D57cb004',
}
const weaponNftMasterAddress: { [name: string]: string } = {
  bsct: '0xCa4465C6926C6195127e1414A85cd572Ab15092E',
  bsc: '0xaDb60Ed40314E0B8Af8f91bC1b402011AbfaCBfC',
}
let weaponNft: WeaponNft

describe('WeaponNft', function () {
  beforeEach(async () => {
    const weaponNftFactory: WeaponNftFactory = await ethers.getContractFactory('WeaponNft')
    weaponNft = weaponNftFactory.attach(weaponNftAddress[network.name])
  })

  it('totalSupply', async function () {
    const totalSupply: BigNumber = await weaponNft.totalSupply()
    console.log(totalSupply.toString())
  })

  it('ownerOf', async function () {
    const owner = await weaponNft.ownerOf(1)
    console.log(`ownerOf ${owner}`)
  })

  it('getWeaponInfo', async function () {
    const weaponInfo: {
      weaponType: BigNumber
      stakingPower: BigNumber
      level: BigNumber
      petToGet: BigNumber
      bakeToGet: BigNumber
    } = await weaponNft.weaponInfoMap(2)
    console.log(
      `getWeaponInfo ${weaponInfo.weaponType}, ${weaponInfo.level}, ${weaponInfo.stakingPower}, ${weaponInfo.petToGet}, ${weaponInfo.bakeToGet}`
    )
  })

  it('grantMintRoleToWeaponNftMaster', async function () {
    const mintRole: string = await weaponNft.MINT_ROLE()
    const tx = await weaponNft.grantRole(mintRole, weaponNftMasterAddress[network.name])
    console.log(`grantMintRoleToWeaponNftMaster ${tx.hash}`)
    await tx.wait()
    console.log(`grantMintRoleToWeaponNftMaster done`)
    /**
     grantMintRoleToWeaponNftMaster 0xa065a9df3f828116f44912557d42ea3d8d1838b933beeee08e68a8bb1f0c54af
     grantMintRoleToWeaponNftMaster done
     */
  })

  it('burn', async function () {
    const burnTx = await weaponNft.burn(1, {
      gasLimit: 9999999,
    })
    console.log(`burn ${burnTx.hash}`)
    await burnTx.wait()
    console.log(`burn done`)
    /**
     grantMintRoleToWeaponNftMaster 0x0b353edf119ef9fca7a1c4c94613674737e3627f84f1feaa1f55466078be245b
     grantMintRoleToWeaponNftMaster done
     */
  })

  it('bakeReserve', async function () {
    const bakeReserve = await weaponNft.bakeReserve()
    console.log(`bakeReserve ${bakeReserve}`)
  })

  it('petReserve', async function () {
    const petReserve = await weaponNft.petReserve()
    console.log(`petReserve ${petReserve}`)
  })
})
