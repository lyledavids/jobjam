import { ethers } from 'ethers';

export function shortenAddress(address) {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

export function formatEther(wei) {
  return ethers.formatEther(wei);
}

export function parseEther(ether) {
  return ethers.parseEther(ether);
}