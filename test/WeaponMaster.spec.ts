import { expect } from 'chai'
import { BigNumber } from 'ethers'

import { WeaponMaster } from '../typechain/WeaponMaster'
import { WeaponMasterFactory } from '../typechain/WeaponMasterFactory'
import { approveErc20, erc721SetApprovalForAll } from './shared/utilities'

const { ethers, network } = require('@nomiclabs/buidler')
const petTokenAddress: { [name: string]: string } = {
  bsct: '0xe59af933b309aFF12f323111B2B1648fF45D5dc0',
  bsc: '0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8',
}
const weaponNftAddress: { [name: string]: string } = {
  bsct: '0x2F2d38bC4C9d7b2A57432d8a7AB2093a432885Ca',
  bsc: '0xBe7095dBBe04E8374ea5F9f5B3f30A48D57cb004',
}
const weaponMasterAddress: { [name: string]: string } = {
  bsct: '0xF3F0FdD548D52ac5a80E81125974aD95a96F3c53',
  bsc: '0x0c2fC172c822B923f92A17aD9EA5c15aD7332624',
}

let weaponMaster: WeaponMaster

describe('WeaponMaster', function () {
  beforeEach(async () => {
    const weaponMasterFactory: WeaponMasterFactory = await ethers.getContractFactory('WeaponMaster')
    weaponMaster = weaponMasterFactory.attach(weaponMasterAddress[network.name])
  })

  it('getPoolInfo', async function () {
    const poolInfo: {
      allocPoint: BigNumber
      lastRewardBlock: BigNumber
      accWeaponPerShare: BigNumber
      0: BigNumber
      1: BigNumber
      2: BigNumber
    } = await weaponMaster.poolInfoMap(weaponNftAddress[network.name])
    console.log(`getPoolInfo ${poolInfo.allocPoint}, ${poolInfo.lastRewardBlock}, ${poolInfo.accWeaponPerShare}`)
  })

  it('addPool', async function () {
    let addPoolTx = await weaponMaster.add(BigNumber.from(1), weaponNftAddress[network.name], false)
    console.log(`addPool weaponNFT ${addPoolTx.hash}`)
    await addPoolTx.wait()
    // addPoolTx = await weaponMaster.add(BigNumber.from(2), petTokenAddress[network.name], false)
    // console.log(`addPool ${addPoolTx.hash}`)
    // await addPoolTx.wait()
    /**
     addPool weaponNFT 0xb51af825a2eb8fca5f9e5a760f7e325ba95177d4c8eec532d9b63927be138913
     */
  })

  it('stakePet', async function () {
    await approveErc20(petTokenAddress[network.name], weaponMasterAddress[network.name])
    const tx = await weaponMaster.stake(
      petTokenAddress[network.name],
      BigNumber.from(10).mul(BigNumber.from(10).pow(18)),
      {
        gasLimit: 9999999,
      }
    )
    console.log(`stakePet ${tx.hash}`)
    await tx.wait()
    console.log(`stakePet done`)
    /**
     approveErc20 0x9861cc6b1c9c1baec01693cebb701f1744f8fa1d2b4a867e3b58e04b80a19dfd
     approveErc20 done
     stakePet 0x57f5dfc0af72d52fb65029b8ae42678821134de79a30306d66427a8e4572f25a
     stakePet done
     */
  })

  it('pendingWeapon', async function () {
    const pendingWeapon = await weaponMaster.pendingWeapon(
      weaponNftAddress[network.name],
      '0x337e3cee9c3e892f84c76b0ec2c06fd4ab06a734'
    )
    console.log(`pendingWeapon ${pendingWeapon.toString()}`)
  })

  it('poolUserInfo', async function () {
    const poolUserInfo: {
      amount: BigNumber
      rewardDebt: BigNumber
      0: BigNumber
      1: BigNumber
    } = await weaponMaster.poolUserInfoMap(weaponNftAddress[network.name], '0x337e3cee9c3e892f84c76b0ec2c06fd4ab06a734')
    console.log(`poolUserInfo ${poolUserInfo.amount.toString()},  ${poolUserInfo.rewardDebt.toString()}`)
  })

  it('unstakePet', async function () {
    const tx = await weaponMaster.unstake(
      petTokenAddress[network.name],
      BigNumber.from(3).mul(BigNumber.from(10).pow(18)),
      {
        gasLimit: 9999999,
      }
    )
    console.log(`unstakePet ${tx.hash}`)
    await tx.wait()
    console.log(`unstakePet done`)
    /**
     unstakePet 0xf0261478d7cc4adbbedd129b279d03fac0834be83aa3ce5963993901888269d1
     unstakePet done
     */
  })

  it('stakeWeaponNFT', async function () {
    // await erc721SetApprovalForAll(weaponNftAddress[network.name], weaponMasterAddress[network.name])
    const tokenId = 0
    const tx = await weaponMaster.stakeWeaponNFT(tokenId, {
      gasLimit: 9999999,
    })
    console.log(`stakeWeaponNFT ${tx.hash}`)
    await tx.wait()
    console.log(`stakeWeaponNFT done`)
    /**
     approveErc721 0x5f0b60de283c030d7834b38c9b840b261e359260c86d7a911821133fd793312c
     approveErc721 done
     stakeWeaponNFT 0x64e87ecff6892a4f09097120ff0c6a6540dad2ccfb9b3c40c5eafad82b2b10b3
     stakeWeaponNFT done
     */
  })

  it('unstakeWeaponNFT', async function () {
    const tokenId = 1
    const tx = await weaponMaster.unstakeWeaponNFT(tokenId, {
      gasLimit: 9999999,
    })
    console.log(`unstakeWeaponNFT ${tx.hash}`)
    await tx.wait()
    console.log(`unstakeWeaponNFT done`)
    /**
     unstakeWeaponNFT 0xcbf437effbd14ff88fd40299078981447e079d5c62c9444b30065024f93d28a5
     unstakeWeaponNFT done
     */
  })
})
