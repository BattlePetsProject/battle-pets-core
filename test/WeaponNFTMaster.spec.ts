import { WeaponNftMaster } from '../typechain/WeaponNftMaster'
import { WeaponNftMasterFactory } from '../typechain/WeaponNftMasterFactory'
import { BigNumber } from 'ethers'
import { approveErc20 } from './shared/utilities'

const { ethers, network } = require('@nomiclabs/buidler')

const petTokenAddress: { [name: string]: string } = {
  bsct: '0xe59af933b309aFF12f323111B2B1648fF45D5dc0',
  bsc: '0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8',
}
const BAKE = '0xe02df9e3e622debdd69fb838bb799e3f168902c5'

const weaponTokenAddress: { [name: string]: string } = {
  bsct: '0xC8a9bE619760dBf97c28122d1fc170F2ED11C93A',
  bsc: '0x3664d30A612824617e3Cf6935d6c762c8B476eDA',
}
const weaponNftMasterAddress: { [name: string]: string } = {
  bsct: '0x846D8a20Bde63c267278C8B972Bb15BCc6dC3283',
  bsc: '0xaDb60Ed40314E0B8Af8f91bC1b402011AbfaCBfC',
}
let weaponNftMaster: WeaponNftMaster

describe('WeaponNftMaster', function () {
  beforeEach(async () => {
    const weaponNftMasterFactory: WeaponNftMasterFactory = await ethers.getContractFactory('WeaponNftMaster')
    weaponNftMaster = weaponNftMasterFactory.attach(weaponNftMasterAddress[network.name])
  })

  it('getPetAmount', async function () {
    const bake = await weaponNftMaster.BAKE()
    const pet = await weaponNftMaster.PET()
    const petAmount: BigNumber = await weaponNftMaster.getPetAmount(
      BAKE,
      BigNumber.from(300).mul(BigNumber.from(10).pow(18))
    )
    console.log(
      `${bake} 
        ${pet}
        getPetAmount ${petAmount.toString()}`
    )
  })

  it('synthesisByBake', async function () {
    // await approveErc20(BAKE, weaponNftMasterAddress[network.name])
    const tx = await weaponNftMaster.synthesis(
      BAKE,
      BigNumber.from(1),
      BigNumber.from(10000).mul(BigNumber.from(10).pow(18)),
      {
        gasLimit: 9999999,
      }
    )
    console.log(`synthesisByBAKE ${tx.hash}`)
    await tx.wait()
    console.log(`synthesisByBAKE done`)
    /**
     approveErc20 0x87d5a28d5be88e731eb17c5b7551445825dedae6ccabcab389ce719f3266b57a
     approveErc20 done
     synthesisByBAKE 0x32535daaee8400bc4fa14f8c03ae49ff7cdb8decd0aeea43832607628e9d3e18
     synthesisByBAKE done
     */
  })

  it('synthesisByWeapon', async function () {
    await approveErc20(weaponTokenAddress[network.name], weaponNftMasterAddress[network.name])
    const tx = await weaponNftMaster.synthesis(
      weaponTokenAddress[network.name],
      BigNumber.from(1),
      BigNumber.from(300).mul(BigNumber.from(10).pow(18)),
      {
        gasLimit: 9999999,
      }
    )
    console.log(`synthesisByWeapon ${tx.hash}`)
    await tx.wait()
    console.log(`synthesisByWeapon done`)
    /**
     approveErc20 0xa34440f650384638141c5ffeaaadd1658053cdad8b382f06176a20f48a32edc9
     approveErc20 done
     synthesisByWeapon 0x408c42e57b20033f70f8af9f681ca051f609d1491e3cbe399f301094e9c5f534
     synthesisByWeapon done
     */
  })

  it('synthesisByPet', async function () {
    await approveErc20(petTokenAddress[network.name], weaponNftMasterAddress[network.name])
    const tx = await weaponNftMaster.synthesis(
      petTokenAddress[network.name],
      BigNumber.from(2),
      BigNumber.from(500).mul(BigNumber.from(10).pow(18)),
      {
        gasLimit: 9999999,
      }
    )
    console.log(`synthesisByPet ${tx.hash}`)
    await tx.wait()
    console.log(`synthesisByPet done`)
    /**
     approveErc20 0x70b602c50e1463a10af9b6584a3e4c0eaf6dd025b3976ccc252bfc5d8fe12f7b
     approveErc20 done
     synthesisByPet 0x9aae278d1949087c077c56135cda8ee75ede4e4c7f8370bdf51a95ce679a3e6c
     synthesisByPet done
     */
  })

  it('upgradeByBake', async function () {
    // await approveErc20(BAKE, weaponNftMasterAddress[network.name])
    const tx = await weaponNftMaster.upgrade(BAKE, 1, BigNumber.from(300).mul(BigNumber.from(10).pow(18)), {
      gasLimit: 9999999,
    })
    console.log(`upgradeByBake ${tx.hash}`)
    await tx.wait()
    console.log(`upgradeByBake done`)
    /**
     upgradeByBake 0x491cb97c41f52f88bbc4f5db92a1acf1078b481d044b31f36ab100d4cde6f947
     upgradeByBake done
     */
  })

  it('upgradeByWeapon', async function () {
    // await approveErc20(weaponTokenAddress[network.name], weaponNftMasterAddress[network.name])
    const tx = await weaponNftMaster.upgrade(
      weaponTokenAddress[network.name],
      2,
      BigNumber.from(10).mul(BigNumber.from(10).pow(18)),
      {
        gasLimit: 9999999,
      }
    )
    console.log(`upgradeByWeapon ${tx.hash}`)
    await tx.wait()
    console.log(`upgradeByWeapon done`)
    /**
     upgradeByWeapon 0xf7a76b8822fb578aaa2b8cd7feb99fc8bdff6d87237ec59dbfdee8922ce9b306
     upgradeByWeapon done
     */
  })

  it('upgradeByPet', async function () {
    await approveErc20(petTokenAddress[network.name], weaponNftMasterAddress[network.name])
    const tx = await weaponNftMaster.upgrade(
      petTokenAddress[network.name],
      2,
      BigNumber.from(100).mul(BigNumber.from(10).pow(18)),
      {
        gasLimit: 9999999,
      }
    )
    console.log(`upgradeByPet ${tx.hash}`)
    await tx.wait()
    console.log(`upgradeByPet done`)
    /**
     approveErc20 0x1448bfa9a5faf6eacb7d63ec3f59b5fbd299ca155ea6b5529a16333948e7aafc
     approveErc20 done
     upgradeByPet 0xd402c4b6221baedda798e24fece04ae4b12c1b880824d02c27ec4f8ef556d1a4
     upgradeByPet done
     */
  })
})
