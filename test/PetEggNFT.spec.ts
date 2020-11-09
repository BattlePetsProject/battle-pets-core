import { PetEggNft } from '../typechain/PetEggNft'
import { PetEggNftFactory } from '../typechain/PetEggNftFactory'
import { BigNumber } from 'ethers'

const { ethers, network } = require('@nomiclabs/buidler')

const petEggNftAddress: { [name: string]: string } = {
  bsct: '0x0B619B394cA844576E571E43b6A120882Eb8C59a',
  bsc: '0x8A3ACae3CD954fEdE1B46a6cc79f9189a6C79c56',
}
let petEggNft: PetEggNft

describe('PetEggNFT', function () {
  beforeEach(async () => {
    const petEggNftFactory: PetEggNftFactory = await ethers.getContractFactory('PetEggNFT')
    petEggNft = petEggNftFactory.attach(petEggNftAddress[network.name])
  })

  it('allPets', async function () {
    const account = '0x337e3cee9c3e892f84c76b0ec2c06fd4ab06a734'
    const length = await petEggNft.balanceOf(account)
    const allPets: Array<{
      petType: BigNumber
      battlePower: BigNumber
    }> = await Promise.all(
      Array.from(Array(Number(length)).keys()).map(async (index) => {
        const tokenId = await petEggNft.tokenOfOwnerByIndex(account, `${index}`)
        return await petEggNft.petInfoMap(tokenId)
      })
    )
    console.log(allPets[0].petType.toString() + ' ' + allPets[0].battlePower.toString())
    console.log(JSON.stringify(allPets))
  })
})
