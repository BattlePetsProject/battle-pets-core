import { Erc20 } from '../../typechain/Erc20'
import { Erc20Factory } from '../../typechain/Erc20Factory'

import { Erc721 } from '../../typechain/Erc721'
import { Erc721Factory } from '../../typechain/Erc721Factory'

const { ethers } = require('@nomiclabs/buidler')

export const approveErc20 = async (token: string, to: string) => {
  const erc20Factory: Erc20Factory = await ethers.getContractFactory('Erc20')
  const erc20: Erc20 = erc20Factory.attach(token)
  const approveTx = await erc20.approve(to, ethers.constants.MaxUint256)
  console.log(`approveErc20 ${approveTx.hash}`)
  await approveTx.wait()
  console.log(`approveErc20 done`)
}

export const approveErc721 = async (token: string, to: string, tokenId: number) => {
  const erc721Factory: Erc721Factory = await ethers.getContractFactory('Erc721')
  const erc721: Erc721 = erc721Factory.attach(token)
  const approveTx = await erc721.approve(to, tokenId)
  console.log(`approveErc721 ${approveTx.hash}`)
  await approveTx.wait()
  console.log(`approveErc721 done`)
}

export const erc721SetApprovalForAll = async (token: string, to: string) => {
  const erc721Factory: Erc721Factory = await ethers.getContractFactory('Erc721')
  const erc721: Erc721 = erc721Factory.attach(token)
  const setApprovalForAllTx = await erc721.setApprovalForAll(to, true)
  console.log(`erc721SetApprovalForAll ${setApprovalForAllTx.hash}`)
  await setApprovalForAllTx.wait()
  console.log(`erc721SetApprovalForAll done`)
}
