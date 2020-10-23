import { expect } from 'chai'
import { PetToken } from '../typechain/PetToken'
import { PetTokenFactory } from '../typechain/PetTokenFactory'
import { BigNumber } from 'ethers'

const { ethers, network } = require('@nomiclabs/buidler')

const petTokenAddress: { [name: string]: string } = {
  bsct: '0xe59af933b309aFF12f323111B2B1648fF45D5dc0',
  bsc: '0x4d4e595d643dc61EA7FCbF12e4b1AAA39f9975B8'
}
const petIdoAddress: { [name: string]: string } = {
  bsct: '0x973df181FC4b317bcb961540cB5F2034AaEAfC3b',
  bsc: '0xD88ff9035a8abF2E973f9d30baFaE7eF28AAa630'
}

let petToken: PetToken

describe('PetToken', function() {
  beforeEach(async () => {
    const petTokenFactory: PetTokenFactory = await ethers.getContractFactory('PetToken')
    petToken = petTokenFactory.attach(petTokenAddress[network.name])
  })

  it('decimals', async function() {
    expect(await petToken.decimals()).to.equal(18)
  })

  it('totalSupply', async function() {
    const totalSupply: BigNumber = await petToken.totalSupply()
    console.log(totalSupply.toString())
  })

  it('transferToPetIdo', async function() {
    const tx = await petToken.transfer(
      petIdoAddress[network.name],
      BigNumber.from(1600).mul(BigNumber.from(10).pow(22))
    )
    console.log(`transferToPetIdo ${tx.hash}`)
    await tx.wait()
    console.log(`transferToPetIdo done`)
  })
})
