import { WeaponToken } from '../typechain/WeaponToken'
import { WeaponTokenFactory } from '../typechain/WeaponTokenFactory'
import { BigNumber } from 'ethers'

const { ethers, network } = require('@nomiclabs/buidler')

const weaponTokenAddress: { [name: string]: string } = {
  bsct: '0x84525cE72f4f10C1Daa471C17f0DE14F96cd3132',
  bsc: '0x3664d30A612824617e3Cf6935d6c762c8B476eDA',
}
const weaponMasterAddress: { [name: string]: string } = {
  bsct: '0xF3F0FdD548D52ac5a80E81125974aD95a96F3c53',
  bsc: '0x0c2fC172c822B923f92A17aD9EA5c15aD7332624',
}

let weaponToken: WeaponToken

describe('WeaponToken', function () {
  beforeEach(async () => {
    const weaponTokenFactory: WeaponTokenFactory = await ethers.getContractFactory('WeaponToken')
    weaponToken = weaponTokenFactory.attach(weaponTokenAddress[network.name])
  })

  it('totalSupply', async function () {
    const totalSupply: BigNumber = await weaponToken.totalSupply()
    console.log(totalSupply.toString())
  })

  it('balanceOf', async function () {
    const balance: BigNumber = await weaponToken.balanceOf(weaponTokenAddress[network.name])
    console.log(balance.toString())
  })

  it('grantSafeMintRoleToWeaponMaster', async function () {
    const safeMintRole: string = await weaponToken.SAFE_MINT_ROLE()
    const tx = await weaponToken.grantRole(safeMintRole, weaponMasterAddress[network.name])
    console.log(`grantSafeMintRoleToWeaponMaster ${tx.hash}`)
    await tx.wait()
    console.log(`grantSafeMintRoleToWeaponMaster done`)
    /**
     grantSafeMintRoleToWeaponMaster 0x323a5ad3ce8365a20c7eb43bac1b0901d326c0c863a1166540a29a70692d30f9
     grantSafeMintRoleToWeaponMaster done
     */
  })

  it('getRoleMember', async function () {
    const safeMintRole: string = await weaponToken.SAFE_MINT_ROLE()
    const member: string = await weaponToken.getRoleMember(safeMintRole, 0)
    console.log(`getRoleMember ${member}`)
    /**
     getRoleMember 0xf4E27074E09e0b91e48EF551dd3bffFF52D3b2de
     */
  })
})
