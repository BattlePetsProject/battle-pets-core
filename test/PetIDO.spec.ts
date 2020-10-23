import { expect } from 'chai'
import { BigNumber } from 'ethers'

import { PetIdo } from '../typechain/PetIdo'
import { PetIdoFactory } from '../typechain/PetIdoFactory'
import { approveErc20 } from './shared/utilities'

const { ethers, network } = require('@nomiclabs/buidler')
const petTokenAddress: { [name: string]: string } = {
  bsct: '0xe59af933b309aFF12f323111B2B1648fF45D5dc0',
  bsc: '0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8'
}
const petIdoAddress: { [name: string]: string } = {
  bsct: '0x973df181FC4b317bcb961540cB5F2034AaEAfC3b',
  bsc: '0xD88ff9035a8abF2E973f9d30baFaE7eF28AAa630'
}
const BUSD: { [name: string]: string } = {
  bsct: '0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee',
  bsc: '0xe9e7cea3dedca5984780bafc599bd69add087d56'
}
const WBNB: { [name: string]: string } = {
  bsct: '0x094616f0bdfb0b526bd735bf66eca0ad254ca81f',
  bsc: '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c'
}
const BAKE = '0xe02df9e3e622debdd69fb838bb799e3f168902c5'

let petIdo: PetIdo

describe('PetIdo', function() {
  beforeEach(async () => {
    const petIdoFactory: PetIdoFactory = await ethers.getContractFactory('PetIDO')
    petIdo = petIdoFactory.attach(petIdoAddress[network.name])
  })

  it('setMinIdoAmount', async function() {
    const tx = await petIdo.setMinIdoAmount(BigNumber.from(833).mul(BigNumber.from(10).pow(15)))
    console.log(`setMinIdoAmount ${tx.hash}`)
    await tx.wait()
    console.log(`setMinIdoAmount done`)
  })

  it('setMinBuyAmount', async function() {
    const tx = await petIdo.setMinBuyAmount(BigNumber.from(10).mul(BigNumber.from(10).pow(18)))
    console.log(`setMinBuyAmount ${tx.hash}`)
    await tx.wait()
    console.log(`setMinBuyAmount done`)
  })

  it('setPetBusdIdoPrice', async function() {
    const tx = await petIdo.setPetBusdIdoPrice(BigNumber.from(3333333333))
    console.log(`setPetBusdIdoPrice ${tx.hash}`)
    await tx.wait()
    console.log(`setPetBusdIdoPrice done`)
  })

  it('minIdoAmount', async function() {
    const minIdoAmount = await petIdo.minIdoAmount()
    console.log(`minIdoAmount ${minIdoAmount}`)
  })

  it('addSupportToken', async function() {
    let addSupportTokenTx = await petIdo.addSupportToken(BUSD[network.name])
    console.log(`addSupportToken ${addSupportTokenTx.hash}`)
    await addSupportTokenTx.wait()
    addSupportTokenTx = await petIdo.addSupportToken(WBNB[network.name])
    console.log(`addSupportToken ${addSupportTokenTx.hash}`)
    await addSupportTokenTx.wait()
    addSupportTokenTx = await petIdo.addSupportToken(BAKE)
    console.log(`addSupportToken ${addSupportTokenTx.hash}`)
    await addSupportTokenTx.wait()
    /**
     addSupportToken 0x7d5b6f851701c4b701edceba01790d61e62a6715956fd54d4700b520a8adfb0e
     addSupportToken 0x4d6d52dcd7d0209fb3502a14d8ab8588039cf0c910d6d4bbe029f5f60aced642
     addSupportToken 0xb10149706f0b8dcc847c1957904d0a16a8f13b430f6867538360519f67afc3dd

     addSupportToken 0x3cf0defb4a6f28fd974539976006b01f30db94093e52ad726191003e5144c8fd
     addSupportToken 0x4813841fb9822b2221d0fb797914aee52d4bcc0dbc48c050544970642e53a322
     addSupportToken 0xcabed4dbbef411b854266e587a28834c66da10b444950ff76d541e14d73496a7
     */
  })

  it('setEnableBuyNftByPet', async function() {
    let setEnableBuyNftByPetTx = await petIdo.setEnableBuyNftByPet(true)
    console.log(`setEnableBuyNftByPet ${setEnableBuyNftByPetTx.hash}`)
    await setEnableBuyNftByPetTx.wait()
    // setEnableBuyNftByPet 0x356d52f83096caa7f8a9dfc7c56b99ba36802c4289b78b1323e2084e80240312
  })

  it('ido', async function() {
    await approveErc20(BUSD[network.name], petIdoAddress[network.name])
    const tx = await petIdo.ido(
      BigNumber.from(3).mul(BigNumber.from(10).pow(18)),
      BigNumber.from(1),
      BUSD[network.name],
      {
        gasLimit: 9999999
      }
    )
    console.log(`ido ${tx.hash}`)
    await tx.wait()
    console.log(`ido done`)
    /**
     approveErc20 0xec72739fc846216a64d2a7d94126662d23c4df94195db20d1d66e5be9a36829d
     approveErc20 done
     ido 0xd868e9665f2d55e1a4ad046eb0ae5bfe304818f1bfed6e50f4b1987c34c5af6f
     ido done
     */
  })

  it('idoBake', async function() {
    await approveErc20(BAKE, petIdoAddress[network.name])
    const tx = await petIdo.ido(BigNumber.from(500).mul(BigNumber.from(10).pow(18)), BigNumber.from(1), BAKE, {
      gasLimit: 9999999
    })
    console.log(`idoBake ${tx.hash}`)
    await tx.wait()
    console.log(`idoBake done`)
    /**
     approveErc20 0xb9e37a2c7de3645eb68cda8709eca272350c16d7d83021bb2364f09a91134345
     approveErc20 done
     idoBake 0x8fb588394173d018aaf2999a39b140f17c697a234a950af16ace2bb879370be2
     idoBake done
     */
  })

  it('idoBnb', async function() {
    const tx = await petIdo.idoBnb(BigNumber.from(2), {
      value: BigNumber.from(4).mul(BigNumber.from(10).pow(18)),
      gasLimit: 9999999
    })
    console.log(`idoBnb ${tx.hash}`)
    await tx.wait()
    console.log(`idoBnb done`)
    /**
     idoBnb 0x449195df431ad447ca1295db585b0ad1b5e7df0261ec464034a1bbef85f8af51
     idoBnb done
     */
  })

  it('buyNftByPet', async function() {
    await approveErc20(petTokenAddress[network.name], petIdoAddress[network.name])
    const tx = await petIdo.buyNftByPet(BigNumber.from(20).mul(BigNumber.from(10).pow(18)), BigNumber.from(1))
    console.log(`buyNftByPet ${tx.hash}`)
    await tx.wait()
    console.log(`buyNftByPet done`)
    /**
     buyNftByPet 0x3004f86623f153f06ac08c9eae03031dedc707d0c7b6d7edc75976a00aae7f2e
     buyNftByPet done
     */
  })

  it('currentIdoAmount', async function() {
    const currentIdoAmount = await petIdo.currentIdoAmount()
    console.log(`currentIdoAmount ${currentIdoAmount}`)
  })

  it('maxTotalIdoAmount', async function() {
    const maxTotalIdoAmount = await petIdo.maxTotalIdoAmount()
    console.log(`maxTotalIdoAmount ${maxTotalIdoAmount}`)
  })

  it('getPrice', async function() {
    const price = await petIdo.getPrice(WBNB[network.name], BUSD[network.name])
    console.log(`getPrice ${price}`)
  })
})
